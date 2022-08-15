clear;clc;
load('GPlanta.mat');

Kp      = 1;
taup    = 5;
td      = 5;
T       = 2;

Ntd     = fix(td/T);

t       = 0:T:1000;

num     = [Kp];
den     = [taup 1];

[y,x]   = step(num,den,t);

y_step       = [zeros(Ntd,1); y(1:length(y)-Ntd)];


plot(t,y_step,'k-');

Np = 25;    %H Predição
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
%h = h';


ySetPoint = 30*ones(Np,1);

yRealk = zeros(Np,1);
yPredicao = 0;

P = zeros(Np,1);

DeltaUPassados = zeros(Np-1,1);
DeltaUyk = zeros(Np,1);

k = 1;
R = 0;
e = 0;

for k=1:3000
y(k) = h*DeltaUyk;
yRealk = y(k)*ones(Np,1);


e = ySetPoint - yRealk - P;

%Cálculo das ações de controle
DeltaU = (S'*S+R)\(S'*e); 

%DefinirMVs(opc,1,DeltaU(1));

DeltaUPassados = [DeltaU(1); DeltaUPassados(1:end-1)];
DeltaUyk = [DeltaU(1); DeltaUyk(1:end-1)];
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

end

plot(y);
