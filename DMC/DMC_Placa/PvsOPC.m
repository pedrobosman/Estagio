%Inicializando Cliente OPC
opc = InicializarClienteOPC('localhost',48030);

while strcmp(opc{1}.Name,'Erro')
    disp('Solicitando nova conexão com o Servidor.');
   [opc] = InicializarClienteOPC('localhost',48030);
   pause(1);
end

while(true)
DefinirMVs(opc,1,0);
DefinirMVs(opc,2,0);
PVS = ReceberPVs(opc);
PV1 = PVS(1)
PV2 = PVS(2)
disp('**********************************')
pause(2);
end
