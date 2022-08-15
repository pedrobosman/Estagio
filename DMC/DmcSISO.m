clear;clc;

load('GPlanta.mat');
G11 = G(1,1);
G22 = G(2,2);


opc = InicializarClienteOPC('localhost',48030);

while strcmp(opc{1}.Name,'Erro')
    disp('Solicitando nova conexão com o Servidor.');
   [opc] = InicializarClienteOPC('localhost',48030);
   pause(1);
end

t = 0:2:1000;

u = ones(1,length(t));

y_step = lsim(G11,u,t);
%plot(t,y_step,'k-');

Np = 500;    %H Predição
M = 5;      %H Controle


S_n = y_step; 
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


ySetPoint = 34*ones(Np,1);
yRealk = zeros(Np,1);
yPredicao = 0;
P = zeros(Np,1);
DeltaUPassados = zeros(Np-1,1);
R = 10*ones(M,M);
e = 0;
u = 0;
uAnterior = 0;


while(true)
PVS = ReceberPVs(opc); %Leitura da Planta yk
PV1 = PVS(1);          %Malha 1
PV2 = PVS(2);          %Malha 2
yRealk = PV1*ones(Np,1);


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


u = uAnterior + DeltaU(1);
uAnterior = u;

DefinirMVs(opc,1,u);

disp('**********************************************');
disp('PV:');
disp(PV1);
disp('MV:');
disp(u);
disp('**********************************************');
disp(yPredicao(1:10));
disp('**********************************************');

pause(2);
clc;
end














