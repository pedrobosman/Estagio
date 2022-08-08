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


Np = 11;    %H Predição
M = 4;      %H Controle

S_n = y_step(2:end); 
S = toeplitz(S_n(1:Np),[S_n(1) zeros(1,M-1)]);

h = zeros(Np,1);
h(1) = S(1);
for j = 2:Np
    h(j) = S(j) - S(j-1);
end


ySetPoint = 35*ones(Np,1);
yRealk = 0*zeros(Np,1);
yPredicao = 0;
P = zeros(Np,1);
R = 0;
k = 1;
e = 0;

while(true)
PVS = ReceberPVs(opc); %Leitura da Planta yk
PV1 = PVS(1);          %Malha 1
PV2 = PVS(2);          %Malha 2
yRealk = PV1*ones(Np,1);


e = ySetPoint - yRealk - P;

%Cálculo das ações de controle
DeltaU = (S'*S)\S'*e; 
disp(DeltaU(1));
DefinirMVs(opc,1,DeltaU(1));

DeltaUPassado(k) = DeltaU(1);

%Predição
yPredicao = S*DeltaU + yRealk + P; 

%Cálculo das ações passadas
for n = 1:Np

    for i = n+1:Np
        if (k+n-i)>0
            P(n) = h(i)*DeltaUPassado(k+n-i);
        end
    end
end

disp(P);
k = k + 1;
pause(2);
end