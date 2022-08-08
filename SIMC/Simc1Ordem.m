function [Kp,Ti] = Simc1Ordem(G,MultiplicadorTauC_Theta)
%SIMC1ORDEM Summary of this function goes here
%   Detailed explanation goes here

K = G.num{1}(2);
tau1 = G.den{1}(1);
theta = G.OutputDelay;
tauC = MultiplicadorTauC_Theta*theta;%Equal Time Delay

Kp = (1/K)*(tau1/(tauC+theta));
Ti = min(tau1,4*(tauC+theta));
end

