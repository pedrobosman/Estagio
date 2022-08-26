function [PVs] = ReceberPVs(ClienteENos)
% DEFINIR MVS da Placa Térmica
clienteOPC = ClienteENos{1};
Nos = ClienteENos{2};

NosPVs = [Nos(2) Nos(4)];
PVs = readValue(clienteOPC,NosPVs);
PVs = [PVs{1} PVs{2}];
end

