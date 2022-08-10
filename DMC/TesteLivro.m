clear;clc;
load('GPlanta.mat');
G11 = G(1,1);
G22 = G(2,2);

G = poly2tfd(G11.num{1},G11.den{1},0,9);

model = tfd2step(1000,2,1,G);
figure(1);
plotstep(model);
plant = model;

Np = 11;
M = 4;

Kmpc= mpccon(model,1,0,M,Np);

tend = 1000;
r = 1;

[y,u] = cmpc(plant,model,1,0,M,Np,tend,r);
figure(2);
plotall(y,u,2);
