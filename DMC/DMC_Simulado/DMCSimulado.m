%% DMC - Simulação - Placa Térmica
clear;clc;
%% Inicializando a planta G
load('GPlanta.mat');
G11 = G(1,1);
G22 = G(2,2);

%% Obtendo modelo discreto - simular y(k)
% Modificar y(k) na simulação
Ts = 2;
GD11 = c2d(G11,Ts);

%% Obtendo valores do Step p/ calcular parâmetros DMC
IntervaloTempoSeg = 3000;

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


%% Iniciando variáveis para a Simulação

% Setpoint
ySetPoint = 32*ones(Np,1);%(G11.Num{1}(2))*ones(Np,1);
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

% Variáveis do sistema simulado
iteracoesDaSimulacao = 3000;
y       = zeros(iteracoesDaSimulacao,1);
u       = zeros(iteracoesDaSimulacao,1);
tempo   = zeros(iteracoesDaSimulacao,1);


%% Iniciando a Simulação
for k= 1:(iteracoesDaSimulacao)

    tempo(k) = (k-1)*Ts;
    % Ler Y /Simulado  
%     if  k==1
%         y(k) = 0;
%     elseif k<=2
%         y(k) = 0.9488*y(k-1) + 0.0007667*u(k-1);
%     else
%         y(k) = 0.9488*y(k-1) + 0.0007667*u(k-1)+0.01852*u(k-2);    
%     end
    if  k==1
        y(k) = 0;
    elseif k<=5
        y(k) = 0.9895*y(k-1);
    elseif k<=6
        y(k) = 0.9895*y(k-1)+0.0007667*u(k-5);
    else
        y(k) = 0.9895*y(k-1)+0.0007667*u(k-5)+0.003172*u(k-6);    
    end

    % Execute programa DMC
    yRealk = y(k)*ones(Np,1);

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
    if k == 1
        u(k) = 0 + DeltaU(1);
    else
        u(k) = u(k-1) + DeltaU(1);
    end   
end

hold on;
plot(tempo,y);
plot(tempo,u);
plot(t,y_step);
legend('y','u','y Step');
xlabel('Tempo (s)');
ylabel('y');
