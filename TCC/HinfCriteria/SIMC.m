clear;clc;
load("GPlanta.mat");
G11Parametros = zeros(1,2); %K,tauI
G22Parametros = zeros(1,2);
[G11Parametros(1), G11Parametros(2)] = Simc1Ordem(G(1,1),1); 
[G22Parametros(1), G22Parametros(2)] = Simc1Ordem(G(2,2),1); 

KpG11 =     G11Parametros(1);
TiG11 =     G11Parametros(2);
KiG11 =     KpG11/TiG11;


KpG22 =     G22Parametros(1);
TiG22 =     G22Parametros(2);
KiG22 =     KpG22/TiG22;

G11 = G(1,1);
G22 = G(2,2);

% s = tf('s');
% Controlador = KpG11+(KiG11/s);
% 
% feed = feedback(G11*Controlador,1);
% [a,b] = ss2tf(feed.A,feed.B,feed.C,feed.D);
% c =  tf(a,b);
% c.OutputDelay = feed.InternalDelay;
% bode(c);
% margin(a,b);
% nyquist(c);

plotoptions = nyquistoptions('cstprefs');
plotoptions.ShowFullContour = 'off';

nyquistplot(L,plotoptions,{1e-2 3.14});

