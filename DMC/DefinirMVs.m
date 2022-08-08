function [] = DefinirMVs(ClienteENos,Malhas,Valores)
% DEFINIR MVS da Placa Térmica
%   Variável Malha:
%   0 - Definir as duas malhas.
%   1 - Definir somente a Primeira Malha
%   2 - Definir somente a Segunda  Malha

clienteOPC = ClienteENos{1};
Nos = ClienteENos{2};

NosMVs = [Nos(1) Nos(3)];
if Malhas == 0
    writeValue(clienteOPC,NosMVs,{Valores(1),Valores(2)});
elseif Malhas == 1
    writeValue(clienteOPC,NosMVs(1),Valores(1));
elseif Malhas == 2
    writeValue(clienteOPC,NosMVs(2),Valores(1));
end

