classdef (Abstract) Controlador < handle
    %CONTROLADOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        MV
        PV
        SP
        modo
        tempoAmostragem
    end
    
   
    methods 
        function obj = Controlador()
            obj.SP = 0;
            obj.MV = 0;
            obj.PV = 0;
            obj.tempoAmostragem = 1;
            obj.modo = "MANUAL";  
        end
        
        function set.SP(obj,SP)
            obj.SP = SP;
        end
        
        function set.PV(obj,PV)
            obj.PV = PV;
        end
        
        function set.tempoAmostragem(obj,tempoAmostragem)
            obj.tempoAmostragem = tempoAmostragem;
        end
        
        function set.modo(obj,modo)
            MODOS = ["MANUAL", "AUTO", "FEEDFORWARD"];
            modo_aux = upper(strip(modo));
            if ismember(modo_aux, MODOS)
                obj.modo = modo_aux;
            end
        end
        
       
        function MV = get.MV(obj)
           MV = obj.MV; 
        end
        
    end
    
    methods (Abstract)
        setParametros(obj,parametros)
        calculateOutput(obj)
    end
end

