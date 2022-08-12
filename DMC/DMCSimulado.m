clear;clc;
load('GPlanta.mat');
G11 = G(1,1);
G22 = G(2,2);

t = 0:2:1000;
u = ones(1,length(t));
y_step = lsim(G11,u,t);
%plot(t,y_step,'k-');

Np = 20;    %H Predição
M = 4;      %H Controle

S_n = y_step(2:end); 
S = toeplitz(S_n(1:Np),[S_n(1) zeros(1,M-1)]);

h = zeros(Np,1);
h(1) = S(1);
for j = 2:Np
    h(j) = S(j) - S(j-1);
end

h = h';
H = h(1,2:end);
for i = 2:Np
    H = [H; h(1,i+1:end) zeros(1,i-1)];
end
h = h';

ySetPoint = 30*ones(Np,1);
yRealk = zeros(Np,1);
yPredicao = 0;
P = zeros(Np,1);
DeltaUPassados = zeros(Np-1,1);
k = 1;
R = 0;
e = 0;


yRealk = PV1*ones(Np,1);


e = ySetPoint - yRealk - P;

%Cálculo das ações de controle
DeltaU = (S'*S+R)\S'*e; 

disp(DeltaU(1));

DeltaUPassados = [DeltaU(1); DeltaUPassados(1:end-1)];

%Predição
yPredicao = S*DeltaU + yRealk;% + P; 
PV1 = yPredicao(1);

%Cálculo das ações passadas
P = H*DeltaUPassados;
P(Np) = 0;


