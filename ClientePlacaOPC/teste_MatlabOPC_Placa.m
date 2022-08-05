%% Conexão com o servidor OPC UA.

% O endpoint especificado é do tipo "opc.tcp://localhost:48030"

uaClient = opcua('localhost',48030); 
connect(uaClient)


%% Inicialização  com a especificação dos nós do Servidos OPC UA

ObjNode = findNodeByName(uaClient.Namespace,'OPC_UA_Server','-once');

PlacaNode = findNodeByName(ObjNode,'PlacaTermica','-once');

Malha_1_Node = findNodeByName(PlacaNode,'Malha1','-once');

MV_1_Node = findNodeByName(Malha_1_Node,'MV');
PV_1_Node = findNodeByName(Malha_1_Node,'PV');

Malha_2_Node = findNodeByName(PlacaNode,'Malha2','-once');

MV_2_Node = findNodeByName(Malha_2_Node,'MV');
PV_2_Node = findNodeByName(Malha_2_Node,'PV');


%% Exemplo de criação de conjuntos de nós

nodes = [MV_1_Node,PV_1_Node, MV_2_Node, PV_2_Node]; 

MV_nodes = [MV_1_Node, MV_2_Node]; % Nós das MVs

%% Exemplo de escrita nos nós das MVs

newValues = {40,0};    
writeValue(uaClient,MV_nodes,newValues);

%% Exemplo de leitura de todos os nós

[v,t,q] = readValue(uaClient,nodes) % [Value, Timestamp, Quality]

%% Mais detalhes em link

link = "https://www.mathworks.com/help/icomm/ug/read-and-write-current-opc-ua-server-data.html"



