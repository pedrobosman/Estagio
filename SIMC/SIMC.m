clear;clc;
load("GPlanta.mat");
G11Parametros = zeros(1,2);
G22Parametros = zeros(1,2);
[G11Parametros(1), G11Parametros(2)] = Simc1Ordem(G(1,1)); 
[G22Parametros(1), G22Parametros(2)] = Simc1Ordem(G(2,2)); 

