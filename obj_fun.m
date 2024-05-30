function J = obj_fun(alpha_multiplier,u,p_er,v_er,vare,n,meanInitVel)
% This function calculates the cost of a movement
global dis individualJflag;                                                             % Global variables are bad - try not to use them
%Define constants
beta=0.09;%hyperbolic discounting rate for undergraduate students
ts = .001;%sampling rate of system                                                               % Sampling rate - should be consistent throughout code

%Normalisation after eliminating the effect of noise on position and
%velocity error
%EFfort-time and accuracy cost coefficients
L=1/(4.9799e+04);
Ta=1/(3.5708);
lambda=1/(0.0826);

%Constraint cost coefficients- Mean target, Stopping condition and inital
%velocity condition
Tper= 1/(9.7034e-09);
Tver = 1/(9.7034e-05);
TinVel=1/(9.7034e-05);
%% Compute the final costs
Ju= L*sum(u.^2);
Jt= lambda*(1-1/(1+beta*n*ts));
Ja=Ta*vare;

Jper=Tper*p_er^2;
Jver=Tver*v_er^2;
JinVel= TinVel*meanInitVel;

coeff=[alpha_multiplier, 100 10 10];%this will be the set of weights

J=dot(coeff,[Ju Jt Ja Jper Jver JinVel]);

if individualJflag ==1
    J = [Ju Jt Ja];
end 
%     J = Ju + Jper + Jver + Juer + Jvar + Jt;                                % Total cost

if dis                                                                  % Display the costs
    Ju=Ju*coeff(1)
    Jt=Jt*coeff(2)
    Ja=Ja*coeff(3)
    
    Jper=Jper*coeff(4)
    Jver=Jver*coeff(5)
    JinVel=JinVel*coeff(6)
    
    J
    meanInitVel
    v_er
    p_er
end

