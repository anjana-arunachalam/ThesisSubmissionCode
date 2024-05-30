function J = process_movement(ts,alpha_vector,params,VD,targ)
% This function:
%   Generates a spline of the control signal u for the given spline parameters p
%   Simulates q number of trials for the control signal u
%   Calculates average starting and endpoint error, variance, and how long the proposed motion-profile takes (n)
%   Sends that info to the objective function to calculate the cost

global forbiddenFlag;
    q = 20;                                                                
    xf=NaN(q,1);
   % targ = 10;                                                              
    u = gen_spline(ts,params);                                                      
% you can already compute 5 out of the total 6 cost function values
%1. Ju- can be computed from u directly, so nothing else would be required
%2. Jt-depends on length of u
 n = length(u); %Number of elements in the u vector?   
%3. J not reaching target
[x, Vel] = signal_proc(ts,u,VD); %not adding the noise yet. Directly computing for the cost
if (isnan(x))
            J=1e30;
            return;
end
p_er = x(1) - targ; % Error in final position (should be at target)
%4. J not stopping
v_er=x(2);%velocity at the end of the reach movement
%5. J not starting from rest
initVel=Vel^2;

%Now compute the cost of risk in the system- this needs the noise and hence
%the average should be obtained

    for i = 1:q %up to 20 times
        temp= gen_EMG(u); %Add additive nad multiplicative noise      
        [x,~] = signal_proc(ts,temp,VD);                                        
        if (isnan(x))
            break;%saves a bit of computational time
        end
        xf(i)=x(1);
    end % end of for loop
    %% Rejection?
    %Check for the forbidden Flag again
    if forbiddenFlag ==1
        J=1e30;%Changing this out of Infinite as 'bads' will only accept finitie Fitness values
        return;
    end     
    %else the rest of the code continues
    clear temp 
    vare = var(xf);% Variance of your final position
                                                         
    J = obj_fun(alpha_vector,u,p_er,v_er,vare,n,initVel);% Calculate the average cost of your movement
