%function that gets called by optimiseMovement to find the best control
%signal
function[BestFitness,BestPhenotype]= simulateHumanReach(ts,alpha_vector,target,VD)
%Declare global variables used
global dis
dis=0;
% Bounds =[time time slope slope slope slope amp amp amp]
% ub=[10 10 200 200 200 200 35 35 35];
% lb=[0.0001 0.0001 -200 -200 -200 -200 -35 -35 -35];
% 
% %define the Plausible bounds
% pub=[5 4 80 80 80 80 30 30 30];
% plb=[0.01 0.01 -80 -80 -80 -80 -30 -30 -30];
% 
% %choose initial seed location
% X0=plb+(pub-plb).*rand(1,length(pub));
% %Define the function Handle 
% ObjFcn=@(controlSig)process_movement(controlSig,VD,target);
% options.Display='iter';
% options.MaxIter=1000;
% options.UncertaintyHandling=1;%as the system is noisy
% 
% [BestPhenotype,BestFitness,exitflag]=bads(ObjFcn,X0,lb,ub,plb,pub,options);

ub=[10 10 200 200 200 200 35 35 35];
lb=[0.0001 0.0001 -200 -200 -200 -200 -35 -35 -35];
%Define the function Handle 
ObjFcn=@(controlSig)process_movement(ts,alpha_vector,controlSig,VD,target);
options =optimoptions('particleswarm','SwarmSize',20,'MaxIterations',500,'Display','none','SelfAdjustmentWeight',1.5,'SocialAdjustmentWeight',2.75);
[BestPhenotype,BestFitness,exitflag]=particleswarm(ObjFcn,length(lb),lb,ub,options);


