clc, clear, close all;

%% Definição do sistema
load('GPlanta.mat');
G = G(1,1);
% Controlador inicial
[G11Parametros(1), G11Parametros(2)] = Simc1Ordem(G(1,1),5); 
Kp          =     G11Parametros(1);
TiG11       =     G11Parametros(2);
Ki          =     Kp/TiG11;
%Kp = 20; Ki = 2;
k0          = [Kp; Ki];
K           = pid(Kp, Ki);

T = feedback(G*K,1);
figure();
step(T);

s = tf('s');
Gvy     = G / (1 + G*K);
Gwu     = K / (1 + G*K);
S       = 1 / (1+G*K);
T       = 1 - S;


JvSIMC = max(bode(Gvy/s));
JuSIMC = max(bode(Gwu));
MsSIMC = max(bode(S));
MtSIMC = max(bode(T));

% Restrições do problema de otimização
Ju = 20;
Ms = 1.7;
Mt = 1.3;
%PM = 60;

%{ Cálculo dos critérios de robustez para a condição inicial
% Jv0 = objfunJv(k0,G);
% C = nonLinCon(k0, G, Ms, Mt, Ju);
% Ju0 = C(1)+Ju;
% Ms0 = C(2)+Ms;
% Mt0 = C(3)+Mt;
% 


%% Busca do controlador ótimo
options = optimoptions('fmincon', 'Display', 'iter');
A = []; b = [];
Aeq = []; beq = [];
lb = [0;0]; ub = [];
x = fmincon(@(x) objfunJv(x,G),k0, A, b, Aeq, beq, lb, ub, @(x) nonLinCon(x, G, Ms, Mt, Ju), options);
Kopt = pid(x(1), x(2));

Topt = feedback(G*Kopt,1);
figure();
step(Topt);

% Cálculo dos critérios de robustez para o controlador final
JvOpt = objfunJv(x,G,w);
C = nonLinCon(x, G, Ms, Mt, Ju);
JuOpt = C(1)+Ju;
Msopt = C(2)+Ms;
Mtopt = C(3)+Mt;

% Função objetivo do problema de otimização
function Jv = objfunJv(k, G)
    K = pid(k(1), k(2));
    Gvy = G/(1+G*K);
    s = tf('s');
    Jv = max(bode(Gvy/s));
end

% restrições não lineares do problema de otimização
function [C, Ceq] = nonLinCon(k, G, Ms, Mt, Ju)
    K = pid(k(1), k(2));
    S = 1/(1 + G*K);
    T = G*K*S;
    Guw = K*S;
    JuNorm = max(bode(Guw));
    Snorm = max(bode(S));
    Tnorm = max(bode(T));
    %[gm,pm] = margin(G*K);
    C = [JuNorm - Ju; Snorm - Ms; Tnorm - Mt];%; 60-pm
    Ceq = [];
end