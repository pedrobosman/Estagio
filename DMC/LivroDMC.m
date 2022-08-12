clear;clc;

Kp      = 1;
taup    = 5;
td      = 5;
T       = 2.5;
N       = 22; 
R       = 11; %Horizonte de predição
L       = 4;  %Horizonte de controle
alpha   = 0;

Ntd     = fix(td/T);

t       = 0:T:55;

num     = [Kp];
den     = [taup 1];

[y,x]   = step(num,den,t);

y       = [zeros(Ntd,1); y(1:length(y)-Ntd)];

a       = y(2:length(y));

h(1)    = a(1);
for j=2:N
    h(j) = a(j) - a(j-1);
end

A = toeplitz(a(1:R),[a(1) zeros(1,L-1)]);
K = (A'*A)\A';
KT=K(1,:);
y(1) = 0;

time = 0;
for k=1:1+40
    
    time(k) = (k-1)*T;
    r(k)    = 1;
    
    for m = 1:R
        S(m) = 0;
        for i = m+1:N
            if k+m-i>0
                S(m) = S(m)+h(i)*deltau(k+m-i);
            end
        end
    end

    for i=1:R
        P(i) = 0;
        for m=1:i
            P(i) = P(i) + S(m);
        end
    end

    E(k) = r(k)-y(k);

    for i = 1:R
        El(i) = (1-alpha^i)*E(k)-P(i);
    end
    
    deltau(k) = KT*El';

    if k == 1
        u(k) = 0+deltau(k);
    else
        u(k) = u(k-1) + deltau(k);
    end

    if k>=3
        y(k+1) = 0.606530*y(k) + 0.393469*u(k-2);
    else
        y(k+1) = 0.606530*y(k);
    end
end


subplot(211)
matrix = [r' y(1:length(y)-1)];
plot(time,matrix);
xlabel('Tempo');
ylabel('y');
axis([0 100 0 1.5]);
subplot(212);
stairs(time,u);
xlabel('Tempo');
axis([0 100 0 3]);
ylabel('u');



















