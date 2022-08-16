classdef PlacaTermicaMatlab
    %PLACATERMICAMATLAB Summary of this class goes here
    %   Detailed explanation goes here
    %{
    // ------------------------------------------------------------------------------------- //
//                           LABORATÓRIO DE CONTROLE DIGITAL                             //
//                                                                                       //
// Descrição: Realiza a comunicação entre a serial e o módulo de temperatura para        //
//            escrita de entradas do aquecedor e leituras de temperatura dos sensores    //
//                                                                                       //
// Utiliza um protocolo de comunicação que pode receber as seguintes mensagens:          //
//                                                                                       //
// W#INPUT1,INPUT2$ - Recebe os valores das entradas (em %)                              //
//                    Em caso de êxito, envia a resposta W#OK$                           //
//                    Ex.: W#50.00,40.00$   
                      Máximo: 100.0 / Mínimo: 0.0                                        //
//              R#$ - Envia os valores lidos dos sensores (em ºC)                        //
//                    Resposta: R#OUTPUT1,OUTPUT2$                                       //
//                    Ex.: R#35.00,32.00$                                                
                      Máximo: 100.0 / Mínimo: 0.0                                        //
//              T#$ - Testa se a comunicação serial está funcionando correntamente       //
//                    Resposta: T#OK$                                                    //
// ------------------------------------------------------------------------------------- //
    %}
    
    properties (Access = private)
        READ_MESSAGE_HEAD       
        WRITE_MESSAGE_HEAD        
        TEST_MESSAGE_HEAD         
        MESSAGE_TERMINATOR        
        START_DATA               
        DATA_SEPARATOR
        CALIB_MESSAGE_HEAD
        
        serialPort;
    end
    
    methods
        function obj = PlacaTermicaMatlab(varargin)
            %PLACATERMICAMATLAB Construct an instance of this class
            %  Conecta a uma porta especificada em varargin ou busca a
            %  lista de portas disponiveis, envia um comando de teste (T#$)
            %  e conecta na primeira que receber o acknoledgement (T#OK$)
            
            obj.READ_MESSAGE_HEAD  = 'R';       
            obj.WRITE_MESSAGE_HEAD = 'W';       
            obj.TEST_MESSAGE_HEAD  = 'T'; 
            obj.CALIB_MESSAGE_HEAD = 'C';
            obj.MESSAGE_TERMINATOR = '$';       
            obj.START_DATA         = '#';       
            obj.DATA_SEPARATOR     = ',';
            
            % Obtem a lista de portas com disponiveis para conexao
            if (nargin == 0)
                availableConnections = false;
                ports = serialportlist("available");
                
                if(~isempty(ports))
                    i = 1; 
                    while(~availableConnections)
                        obj.serialPort = serialport(ports(i), 9600);
                        pause(2);
                        % envia o comando de teste para verificar se está
                        % conectado com um arduino que contém o firmware
                        % da placa térmica
                        if (obj.test())
                            availableConnections = true;
                            fprintf("Conectado a porta %s\n", ports(i));
                        else
                            clear obj.serialPort;
                            if (i == length(ports))
                                fprintf("Sem portas disponíveis para conexão\n");
                                break;
                            end
                        end
                        i = i+1;
                    end
                else
                   fprintf("Sem portas disponíveis para conexão\n"); 
                end
            elseif (nargin > 0) 
                port = varargin{1};
                obj.serialPort = serialport(port, 9600);
                pause(2);
                [testStatus, message, errormsg] = obj.test();
                if (~testStatus)
                   error(errormsg);
                   clear obj.serialPort;
                end
            end
        end
        
                
        function [output, errorMessage] = readOutput(obj)
            % Envia um comando de leitura (R#$) para a placa
            %   output - vetor de duas posições contendo as temperaturas de
            %            cada malha 
            output = zeros(1,2);
            errorMessage = '';
            
            readMessage = strcat(obj.READ_MESSAGE_HEAD, obj.START_DATA, obj.MESSAGE_TERMINATOR);
            
            obj.write(readMessage);
            readResponse = obj.read();
            
            startDataIndex = strfind(readResponse, obj.START_DATA);
            terminatorIndex = strfind(readResponse, obj.MESSAGE_TERMINATOR);
            separatorIndex = strfind(readResponse, obj.DATA_SEPARATOR);
            
            if (isempty(startDataIndex) || isempty(terminatorIndex) || isempty(separatorIndex))
                output = [];
                errorMessage = 'Confirmacao de leitura invalida';
            else                     
                output(1) = str2double(readResponse(startDataIndex+1:separatorIndex-1));
                output(2) = str2double(readResponse(separatorIndex+1:terminatorIndex-1));
            end
            
            
        end
        
        function [isWriteSuccessful, errorMessage] = writeInput(obj, varargin)
            % Envia um comando de escrita (W#in1,in2$) para a placa 
            %   isWriteSuccessful - confirmação de sucesso na escrita
            %   exemplos de utilização:
            %       writeInput(); - escreve 0 em ambas as entradas
            %       writeInput(MV); - escreve o valor de MV em ambas as entradas
            %       writeInput(MV1, MV2); - escreve o valor de MV1 na
            %                               entrada 1 e MV2 na entrada 2
            isWriteSuccessful = false;
            errorMessage = '';
            
            in1 = 0.0;
            in2 = 0.0;
            if (nargin == 2)
                if(length(varargin{1}) == 1)
                    in1 = varargin{1};
                    in2 = in1;
                else
                    in1 = varargin{1}(1);
                    in2 = varargin{1}(2);
                end
            elseif (nargin > 2) 
                in1 = varargin{1}(1);
                in2 = varargin{2}(1);
            end
            
            writeMessage = strcat(obj.WRITE_MESSAGE_HEAD, obj.START_DATA, num2str(in1,'%.2f'),  obj.DATA_SEPARATOR, num2str(in2,'%.2f'), obj.MESSAGE_TERMINATOR);
            writeTemplate = strcat(obj.WRITE_MESSAGE_HEAD, obj.START_DATA, 'OK', obj.MESSAGE_TERMINATOR);
            
            obj.write(writeMessage);
            writeResponse = obj.read();
            if (strcmp(writeResponse, writeTemplate))
                isWriteSuccessful = true;
            else
                errorMessage = 'Confirmacao de escrita invalida';
            end
        end
        
        function [isTestSuccessful, message, errorMessage] = test(obj)
            % Comando de ping para testar a comunicação se a placa contém o firmware
            % válido
            % Retorna T#OK$
            errorMessage = '';
            isTestSuccessful = false;
            
            testMessage = strcat(obj.TEST_MESSAGE_HEAD, obj.START_DATA, obj.MESSAGE_TERMINATOR);
            testTemplate = strcat(obj.TEST_MESSAGE_HEAD, obj.START_DATA, 'OK', obj.MESSAGE_TERMINATOR);
            
            obj.write(testMessage);
            testResponse = obj.read();
            if (strcmp(testResponse, testTemplate))
                isTestSuccessful = true;
            else
                errorMessage = 'Confirmacao de teste invalida';
            end
            message = testResponse;
        end
        
        function [calibCte, errorMessage] = setCalibCte(obj, varargin)
            % Modifica ou obtém a constante de calibração da placa
            % o valor deve estar na faixa 0 < valor <= 1
            %  exemplos de utilização:
            %    valor = setCalibCte() - obtém o valor da constante
            %    setCalibCte(valor)  - modifica o valor da constante
            errorMessage = '';
            
            
            if (nargin >= 2)
                if (length(varargin{1}) >= 1)
                    calibCte = varargin{1}(1);
                else
                    calibCte = '';
                end
            else
                calibCte = '';
            end
            
            calibMessage = strcat(obj.CALIB_MESSAGE_HEAD, obj.START_DATA, num2str(calibCte,'%.3f'), obj.MESSAGE_TERMINATOR);
            
            obj.write(calibMessage);
            calibResponse = obj.read();
            if (strcmp(calibResponse(1), obj.CALIB_MESSAGE_HEAD))
                startDataIndex = strfind(calibResponse, obj.START_DATA);
                terminatorIndex = strfind(calibResponse, obj.MESSAGE_TERMINATOR);
                     
                calibCte = str2double(calibResponse(startDataIndex+1:terminatorIndex-1));
            else
                errorMessage = 'Confirmacao invalida';
            end
            
        end
    end     
    
    methods (Access = private)
        function write(obj,text)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
                writeline(obj.serialPort, text); 
        end
      
        function message = read(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
                message = readline(obj.serialPort); 
                message = convertStringsToChars(message);
        end
        
    end
    
end

