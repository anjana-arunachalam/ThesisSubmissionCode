%THis file performs the inner optimisation for the control signal. In other
%words- this section simulated the behaviour of a human for a given virtual
%dynamics system. The sum of the costs to the two targets is the variable
%returned. SA is the optimiser of choice within this function
function [TotalCost,BestPhenotype1, BestPhenotype2] = optimiseMovement(ts,alpha_vector,VD)

target=[10, 15];%two target locations

%% Main PSO Loop- - this one adds up the cost of two target reachiing movements individually. The PSO algo finds the best VD for the system

%Reach for first target
[BestFitness1,BestPhenotype1]= simulateHumanReach(ts,alpha_vector,target(1),VD);
%Reach for second target
[BestFitness2,BestPhenotype2]= simulateHumanReach(ts,alpha_vector,target(2),VD);

%else continue with this piece of code
% J1=MinFitness(1,1); J2=MinFitness(2,1);


TotalCost=BestFitness1+BestFitness2;
