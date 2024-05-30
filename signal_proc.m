function [x, initVel] = signal_proc(ts,EMG,coeff)

%AGA: In my opinion this function defines the virtual dynamics for the
%system
%This bascally explains how the position is related to the emg signal value
% ts=0.001;%sampling time used throughout the code
x=[0,0]';
a3=coeff(1); a4=coeff(2);
b3=coeff(3); b4=coeff(4);
% global forbiddenFlag

% CASE 3: switching the equations so that we have to compute powers instead
% of the roots of equations
% VD is now: xdot = a3*x(1)^b3 + a4*EMG^b4;
global forbiddenFlag;

for ii=1:length(EMG) %I'll only be storing the terminal values in this case
    x(1)= x(1)+ x(2)*ts;
    
    %% Rejection?
    %Check 1: If the position is imaginary- get out of the loop
    if (imag(x(1)~=0) || isinf(x(1)))
    forbiddenFlag=1;
    initVel=NaN;
    break;
    end
    
    %Check 2: If the position is Real, compute the velocity
    if(x(1)==0)%This is so that Matlab doesn't freak out with negative powers of zero
       x(2) = a4*(EMG(ii)^b4);
    else
        x(2)= a3*x(1)^b3 + a4*(EMG(ii)^b4);
    end
    
    %Check 3: Did the velocity turn to imag numbers? 
    if (imag(x(2))|| isinf(x(2)))
        forbiddenFlag=1;
        break;       
    else
        forbiddenFlag=0;
    end
    
    %% Return the initial veocity so that I can penalise it
    if ii==1
        initVel=x(2);
    end 
    
end% for loop ends here

%If the computaion was giving imaginary numbers, return NaN
if forbiddenFlag==1
    x=NaN;initVel=NaN;
    return;
    
end





