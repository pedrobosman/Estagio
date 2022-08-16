classdef ControladorPID < Controlador
    %CONTROLADORPID Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        Kp
        Ti
        Td
        N
        Proporcional
        Integral
        Derivativo
        erroAnterior
        PVanterior
        MVmax
        MVmin
    end
    
    methods
        function obj = ControladorPID(parametros, tempoAmostragem)
           obj.tempoAmostragem = tempoAmostragem;
           obj.Proporcional = 0;
           obj.Integral = 0;
           obj.Derivativo = 0;
           obj.erroAnterior = 0;
           obj.PVanterior = 0;
           obj.MVmax = 100;
           obj.MVmin = 0;
           obj.setParametros(parametros);
        end
        
        function obj = calculateOutput(obj)
            if obj.modo == "MANUAL"
                obj.SP = obj.PV;
            end
            
            erro = obj.SP - obj.PV;
            
            obj.Proporcional = obj.Kp * erro;
            if (obj.MV <= obj.MVmax) && (obj.MV >= obj.MVmin)
                obj.Integral = obj.Integral + (obj.Kp * obj.tempoAmostragem / obj.Ti) * obj.erroAnterior;
            end
            obj.Derivativo = (obj.Td / (obj.Td + obj.N * obj.tempoAmostragem)) * obj.Derivativo ...
                           - ((obj.Kp * obj.Td * obj.N) / (obj.Td + obj.N * obj.tempoAmostragem)) * (obj.PV - obj.PVanterior);
            
            obj.erroAnterior = erro;
            obj.PVanterior = obj.PV;
            
            obj.MV = obj.Proporcional + obj.Integral  + obj.Derivativo;
        end
        
        function obj = setParametros(obj,parametros)
           obj.Kp = 0;
           obj.Ti = realmax;
           obj.Td = 0;
           obj.N = 100;
           
           numPar = length(parametros);
           
           if numPar == 1 % Controlador P
              obj.Kp = parametros(1);
           elseif numPar == 2 % Controlador PI
              obj.Kp = parametros(1);
              obj.Ti = parametros(2);
           elseif numPar == 3 % Controlador PID
              obj.Kp = parametros(1);
              obj.Ti = parametros(2);
              obj.Td = parametros(3);
           elseif numPar == 4 % Controlador PID com filtro derivativo N
              obj.Kp = parametros(1);
              obj.Ti = parametros(2);
              obj.Td = parametros(3);
              obj.N = parametros(4);
           end
        end
    end
end

