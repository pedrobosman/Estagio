function Jv=objfun(x,s,G,Kinf)
Ki=x(1); 
tau=x(2); 
zeta=x(3); 
beta=Kinf/(Ki*tau);

Fd=tf(Ki*[tau^2 2*zeta*tau 1],[tau/beta 1]);

Jv=norm(feedback(G/s,Fd),inf);
return
