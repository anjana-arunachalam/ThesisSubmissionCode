%% Signal processing for the plot 
%this function stores the time series of the output so that we can actually
%plot it on the graph. 
%Note that the original signal processing function stores only the terminal
%values for the position and stuff - this one should output only the
%position state but the entire time series of it
function x=signalProc_plot(ts,EMG,coeff)
%ts=0.001;%sampling time used throughout the code

% a1=coeff(1); a2=coeff(2); 
% b1=coeff(3); b2=coeff(4); 

a3=coeff(1); a4=coeff(2); 
b3=coeff(3); b4=coeff(4); 


%% VD Defn
%I want the VD of the system to be: a3*x(1)^b3 + a4*EMG^b4= xdot; 
%This converts the problem into one where the powers have to found instead
%of the roots of an equation

%initialise the vector to save computational time
x=NaN(2,length(EMG));

x(:,1)=0;%initial values are zero - meaning you start from rest

for i=1:length(EMG) %I'll only be storing the terminal values in this case
    %%Am trying to the equations to be :
    %  a1 * x^b1 + a2* xdot^b2+ a3*xddot^1= EMG
%     x(1,i+1)=x(1,i)+x(2,i)*ts;
%     x(2,i+1)=x(2,i)+x(3,i)*ts;   
%     x(3,i+1)= 1/a3*(-a2*x(2,i)^b2-a1*x(1,i)^b1+EMG(i));

        %CASE 2: a1* x^b1 + a2 * xdot^b2 = EMG
%         x(1,i+1)=x(1,i)+x(2,i)*ts;
%         x(2,i+1)= nthroot((EMG(i)-a1*x(1,i)^b1)/a2,b2);

       % CASE 3: xdot = a3*x(1)^b3 + a4*EMG^b4;
       x(1,i+1)= x(1,i)+x(2,i)*ts;
       x(2,i+1)= a3*x(1,i)^b3 + a4*EMG(i)^b4;
end

%output only the position this time
x=x(1,:);%gives the entire time series of the position
end
