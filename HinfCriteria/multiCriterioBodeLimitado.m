clc, clear, close all;

%% Frequeências limites do gráfico de bode
% Bode Utilizado p/ encontrar a norma do inf
bodeFreqMin = 1e-10;
bodeFreqMax = 20;
bodeFreq = {bodeFreqMin,bodeFreqMax};

%% Definição do sistema
load('GPlanta.mat');
G = G(1,1);

%% Controlador inicial
[G11Parametros(1), G11Parametros(2)] = Simc1Ordem(G(1,1),1); 
Kp          =     G11Parametros(1);
TiG11       =     G11Parametros(2);
Ki          =     Kp/TiG11;
%Kp = 20; Ki = 2;
kIniciais	= [Kp; Ki];
K           = pid(Kp, Ki);

% Gráfico: Resposta do sistema com controlador inicial
sysInicial = feedback(G*K,1);
subplot(2,1,1);
step(sysInicial);
[MargemGanhoInicial,MargemFaseInicial] = margin(sysInicial);
MargemGanhoInicial = 20*log10(MargemGanhoInicial);

%% Funções de transferência - vy, wu, S e T do controlador Inicial
%Utilizado para cálculo dos critérios de robustez da condição inicial
s = tf('s');
Gvy     = G / (1 + G*K);
Gwu     = K / (1 + G*K);
S       = 1 / (1+G*K);
T       = 1 - S;


%% Cálculo dos critérios de robustez para a condição inicial
% Jv0 = objfunJv(kIniciais,G);
% C = nonLinCon(kIniciais, G, Ms, Mt, Ju);
% Ju0 = C(1)+Ju;
% Ms0 = C(2)+Ms;
% Mt0 = C(3)+Mt;
JvSIMC = max(bode(Gvy/s,bodeFreq));
JuSIMC = max(bode(Gwu,bodeFreq));
MsSIMC = max(bode(S,bodeFreq));
MtSIMC = max(bode(T,bodeFreq));

%% Restrições do problema de otimização - Jv otimizado
Ju = 20;    %JuSIMC;
Ms = 1.2;     %MsSIMC;
Mt = 1.3;     %MtSIMC;
%PM = 60;


%% Busca do controlador ótimo
options = optimoptions('fmincon', 'Display', 'iter');
A   = [];       b	= [];
Aeq = [];       beq	= [];
lb  = [0;0];    ub	= [];

GanhosK = fmincon(@(GanhosK) objfunJv(GanhosK,G,bodeFreq),kIniciais, A, b, Aeq, beq, lb, ub, @(GanhosK) nonLinCon(GanhosK, G, Ms, Mt, Ju,bodeFreq), options);
Kopt    = pid(GanhosK(1), GanhosK(2));

% Gráfico: Resposta do sistema com controlador ótimo
sysOpt = feedback(G*Kopt,1);
subplot(2,1,2); 
step(sysOpt);
[MargemGanhoOpt,MargemFaseOpt] = margin(sysOpt);
MargemGanhoOpt = 20*log10(MargemGanhoOpt);
%% Cálculo dos critérios de robustez para o controlador final
JvOpt = objfunJv(GanhosK,G,bodeFreq);
C       = nonLinCon(GanhosK, G, Ms, Mt, Ju,bodeFreq);
JuOpt   = C(1)+Ju;
MsOpt   = C(2)+Ms;
MtOpt   = C(3)+Mt;

%%Apresentar Resultados
fprintf('\n\n\n');
fprintf('JvOpt = %.4f , JvInicial  = %.4f\n',JvOpt,JvSIMC);
fprintf('JuOpt = %.4f, JuDefinido = %.4f, JuCInicial: %.4f\n',JuOpt,Ju,JuSIMC);
fprintf('MsOpt = %.4f , MsDefinido = %.4f , MsCInicial: %.4f\n',MsOpt,Ms,MsSIMC);
fprintf('MtOpt = %.4f , MtDefinido = %.4f , MtCInicial: %.4f\n\n',MtOpt,Mt,MtSIMC);
fprintf('Controlador Inicial: Kp = %.4f, Ki: %.4f\n',kIniciais(1),kIniciais(2));
fprintf('Controlador Ótimo:   Kp = %.4f, Ki: %.4f\n\n',GanhosK(1),GanhosK(2));

fprintf('Gm Pm Controlador Inicial: Gm = %.2f, Pm: %.2f\n',MargemGanhoInicial,MargemFaseInicial);
fprintf('Gm Pm Controlador Ótimo  : Gm = %.2f, Pm: %.2f\n',MargemGanhoOpt,MargemFaseOpt);

%% Funções Utilizadas

% Função objetivo do problema de otimização
function Jv = objfunJv(k, G,bodeFreq)
    K	= pid(k(1), k(2));
    Gvy	= G/(1+G*K);
    s   = tf('s');
    Jv  = max(bode(Gvy/s,bodeFreq));
end

% Restrições não lineares do problema de otimização
function [C, Ceq] = nonLinCon(k, G, Ms, Mt, Ju,bodeFreq)
    K       = pid(k(1), k(2));
    S       = 1/(1 + G*K);
    T       = G*K*S;
    Guw     = K*S;
    JuNorm  = max(bode(Guw,bodeFreq));
    Snorm   = max(bode(S,bodeFreq));
    Tnorm   = max(bode(T,bodeFreq));
    %[gm,pm] = margin(G*K);
    C       = [JuNorm - Ju; Snorm - Ms; Tnorm - Mt];%; 60-pm
    Ceq     = [];
end