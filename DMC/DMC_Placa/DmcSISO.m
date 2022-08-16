%% DMC - Com OPC - Placa Térmica
clear;clc;
%% Inicializando a planta G
load('GPlanta.mat');
G11 = G(1,1);
G22 = G(2,2);

%% Conectando ao Servidor OPC
% opc = InicializarClienteOPC('localhost',48030);
% 
% while strcmp(opc{1}.Name,'Erro')
%     disp('Solicitando nova conexão com o Servidor.');
%    [opc] = InicializarClienteOPC('localhost',48030);
%    pause(1);
% end

%% Conectando Placa Térmica com USB
    PlacaTermica = PlacaTermicaMatlab();

%% Obtendo valores do Step p/ calcular parâmetros DMC
IntervaloTempoSeg = 3000;
Ts = 2;
t = 0:Ts:IntervaloTempoSeg;
u = ones(1,length(t));
y_step = lsim(G11,u,t);

%% Definir Horizontes de predição e controle (Np e M)

Np = 200;    %H Predição
M = 1;      %H Controle

%% Obtendo a matriz dinâmica S (coeficientes Sn da resposta ao degrau)
S_n = y_step(2:end); 
S = toeplitz(S_n(1:Np),[S_n(1) zeros(1,M-1)]);

%% Encontrando coeficientes da resposta ao impulto (hi)
h = zeros(Np,1);
h(1) = S(1);
for j = 2:Np
    h(j) = S(j) - S(j-1);
end

%% Calculando matriz H como forma de calcular as ações passadas (P)
h = h';
H = h(1,2:end);
for i = 2:Np
    H = [H; h(1,i+1:end) zeros(1,i-1)];
end
h = h';

%% Iniciando valores

% Setpoint
ySetPoint = 32*ones(Np,1);
% Valor medido (Simulado)
yRealk = zeros(Np,1);
% Y de Predição
yPredicao = 0;
% Ações passadas P
P = zeros(Np,1);
% Delta U's já aplicados (passados)
DeltaUPassados = zeros(Np-1,1);
% Fator de Supressão R
Peso = 5;
R = Peso*diag(diag(ones(M)));
% Erro
e = 0;

u = 0;
uAnterior = 0;

% % Variáveis do sistema simulado
% iteracoesDaSimulacao = 3000;
% y       = zeros(iteracoesDaSimulacao,1);
% u       = zeros(iteracoesDaSimulacao,1);
% tempo   = zeros(iteracoesDaSimulacao,1);


%% Iniciando o controlador
while(true)
    %tempo(k) = (k-1)*Ts;
    
    % Ler Y 
    PVS = PlacaTermica.readOutput(); %ReceberPVs(opc); %Leitura da Planta yk
    PV1 = PVS(1);          %Malha 1
    PV2 = PVS(2);          %Malha 2
    
    % Execute programa DMC
    yRealk = PVS(1)*ones(Np,1);

    e = ySetPoint - yRealk - P;

    %Cálculo das ações de controle
    DeltaU = (S'*S+R)\(S'*e); 
    
    DeltaUPassados = [DeltaU(1); DeltaUPassados(1:end-1)];

    %Predição
    yPredicao = S*DeltaU + yRealk + P; 

    %Cálculo das ações passadas
    p = H*DeltaUPassados;

    for i=1:Np
     P(i) = 0;
        for m=1:i
         P(i) = P(i) + p(m);
        end
    end
    
    % Aplicando sinal de controle 
    %  Escreva U
    u = uAnterior + DeltaU(1);
    PlacaTermica.writeInput(u,0);
    %DefinirMVs(opc,1,u);

    uAnterior = u;
    
    disp('**********************************************');
    disp('PV:');
    disp(PV1);
    if PV1>40
        PlacaTermica.writeInput(0,0);
        %DefinirMVs(opc,1,0);
        break;
    end
    disp('MV:');
    disp(u);    
    disp('**********************************************');
    disp(yPredicao(1:5));
    disp('**********************************************');

    pause(Ts);
    clc;
end





























