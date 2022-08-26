function [opcConn] = InicializarClienteOPC(IP,PORTA)
%INICIALIZARCLIENTEOPC Inicializa e conecta cliente OPC
%
ClienteDeErro = opc.ua.Client;
NodeDeErro = opc.ua.Node;
ClienteDeErro.Name = 'Erro';
NodeDeErro.Name = 'Erro';


try
    cliente = opcua(IP,PORTA); 
    connect(cliente);
    if strcmp(cliente.Status,'Connected')
        disp('Cliente Conectado!');
    end
catch
    disp('Erro ao tentar conexão com servidor OPC.');
    cliente =  ClienteDeErro;
    nos = NodeDeErro;
    opcConn = {cliente,nos};
    return
end

try
% Pasta OPC_UA_Server
NodeObjeto = findNodeByName(cliente.Namespace,'OPC_UA_Server','-once');
% Pasta PlacaTermica
NodePlacaTermica = findNodeByName(NodeObjeto,'PlacaTermica','-once');

% Pasta Malha1
NodeMalha1 = findNodeByName(NodePlacaTermica,'Malha1','-once');
% Pasta Malha2
NodeMalha2 = findNodeByName(NodePlacaTermica,'Malha2','-once');

% Dados - Malha1
NodeMV1 = findNodeByName(NodeMalha1 ,'MV');
NodePV1 = findNodeByName(NodeMalha1 ,'PV');
% Dados - Malha2
NodeMV2 = findNodeByName(NodeMalha2 ,'MV');
NodePV2 = findNodeByName(NodeMalha2 ,'PV');
catch
    disp('Erro ao obter Nós do servidor OPC. Tentar novamente!');
    cliente =  ClienteDeErro;
    nos = NodeDeErro;
    opcConn = {cliente,nos};
    return
end
nos = [NodeMV1,NodePV1,NodeMV2,NodePV2];
opcConn = {cliente,nos};
end

