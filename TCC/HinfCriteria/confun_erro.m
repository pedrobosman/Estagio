function [C,Ceq] = confun(x,G,MS_max,MT_max,Kinf)
Ki=x(1); 
tau=x(2); 
zeta=x(3); 
beta=Kinf/(Ki*tau);

K=tf(Ki*[tau^2 2*zeta*tau 1],[tau/beta 1 0]);

MS=norm(feedback(1,G*K),inf);
MT=norm(feedback(G*K,1),inf);

stab=norm(feedback(G*K,1));
if stab<inf, C=[MS-MS_max; MT-MT_max];
else C =[1; 1]; 
end

Ceq=[];
return
