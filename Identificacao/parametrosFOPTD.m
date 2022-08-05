function [G0, T1, L] = parametrosFOPTD(u,y,Deltat)

Theta = zeros(1,3);
R = zeros(size(Theta,2));
f = zeros(size(Theta,2),1);

h = max(u);
for k=1:length(y)
    Phi = [h*k*Deltat -h -y(k)]';
    R = R + Phi*Phi';
    A = sum(y(1:k)) * Deltat;
    f = f + Phi*A;
end
Theta = R\f;
G0 = Theta(1);
L = Theta(2)/G0;
T1 = Theta(3);
end

