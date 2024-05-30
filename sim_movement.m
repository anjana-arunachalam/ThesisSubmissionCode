function x = sim_movement(ts,u,coeff)
% This function simulates a stochastic movement in response to a control signal

% Typically, it involves two steps (or subfunctions):
% 1) Generate EMG signals in response to u. We will use a simplified version of Clancy's model
% 2) Use some sort of filter to process the EMG signals. We will evaluate
% various models here, such as position control, velocity control, Bayesian filters, One-Euro filters, etc.
%
% flag determines which filter we are using
    EMG = gen_EMG(ts,u);% for now, this just adds the additive and multiplicative noise to the system
    x = signal_proc(ts,EMG,coeff); 
    