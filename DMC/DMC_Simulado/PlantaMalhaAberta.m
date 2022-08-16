y = zeros(3000,1);
u = ones(3000,1);


for k=1:(3000-1)
%% Ler Y /Simulado    
    if  k==1
        y(k) = 0;
    elseif k<=5
        y(k) = 0.9895*y(k-1);
    elseif k<=6
        y(k) = 0.9895*y(k-1)+0.0007667*u(k-5);
    else
        y(k) = 0.9895*y(k-1) + 0.0007667*u(k-5)+0.003172*u(k-6);    
    end
end