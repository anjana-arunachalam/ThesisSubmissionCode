%Feb 15, 2019
%Further edited 03 April, 2024
%We came to the conclusion that the hierarchical optimisation is the best
%way to go forward. Why?- optimising for 2 different targets will ensure
%that we don't have any passive dynamics- The VD will have to depend on the
%EMG input
%% Mainfile 2.0
%Basic set up
clear; close all;
rng(1);
tic

%Things do to:
%1. We'll have two separate optimisations-one for the VD and another one for
%the control signal
%2. The cost functions will change- ignore the noise when computing the
%cost of Effort, time, target reach, initial velocity and stopping
%criterion. the noise is only added for finding the cost of the risk
%3. Change the Normalisation based on the new set of costs
%% Set up global vars
global dis noisebank forbiddenFlag;
noisebank=randn(1000000,1);%used to add the additive and multiplicative gaussian noises added to the system
alpha_vector = [1,1,5]; %Use [1 1 1] for equal preference; 
                            % [5 1 1], [1 5 1] or [1 1 5] for 5x times individual cost preference 
                            
% %% Initial guess
% %VD=[ a1, a2, b1, b2];
% %params- will be the control signal for this code
% %Am gonna go with velocity control and a reasonable control signal to reach
% %10 cm target.
ts =0.001; %sampling time
% VD=[0,1, 1, 1];%Makes sure we dont have the 0^0 problem in Matlab
% t0 = [2 2.5];                                                     % Initial estimates for how long (s) each segment should take
% ic = [0 -10];                                                      % Initial estimates for initial slope of each spline
% fc = [10 0];                                                      % Initial estimates for final slope of each spline
% u0 = [0 6 0];                                                    % Initial estimates for magnitude of the spline
% 
% params = [t0 ic fc u0];
% clear t0 ic fc u0
% figure(1)
% 
% subplot(2,2,1)%control signal plot
% u = gen_spline(ts,params);
% plot(u)
% title('Initial control signal');
% hold on;
% EMG=gen_EMG(u);
% plot(EMG);
% 
% subplot(2,2,2)%device posiiton plot
% x=signalProc_plot(ts,EMG,VD);%set the initial target to be 10 units away
% plot(x)
% title('Initial position')
% dis = 1;   
% process_movement(ts,alpha_vector,params,VD,10);
% 
%% Optimize for the VD (the control signal is actaually optimised inside this loop)
dis=0; % we don't want the costs to be displayed for every iteration of the optimisation

inertialCoeff='exp'; %const, linear and exp are the different options
popsize=20;%20
c1=1; c2=2; %inertial, cognitive and social weights
MaxIter=60;%60%Number of function evals
%Changes for comparing u* when VD is optimised vs just a simple
%proportional Velocity control  version - where only the a2 gain is tuned
%and the other values are fixed
%[a1 =0, a2- tunable, b1 and b2 are set to 1]
MaxRuns=1;%3 %Number of times the algo is run
a1=0;b1=1;b2=1;

UB= 5;
LB=-5;

varNum=length(UB);%Defines the number of variables to be optimised
MaxVelocity= (UB-LB)./5;%sets the max step size for the particles

% PSO Stuff - Step 1: define empty particle
Emptyparticle= struct('position','','velocity','',...
                      'Fitness', '','PersonalBest','');
Emptyparticle.PersonalBest.Position='';
Emptyparticle.PersonalBest.Fitness=inf;
Emptyparticle.ControlSig1='';%this field stores the phenotype of control signal used to reach first target
Emptyparticle.ControlSig2='';%stores optimal control signal used to reach the second target

GlobalBest= struct('Position','','Fitness',inf);%will rewrite this variable at every generation
%These variables save the global best at every run
BestFitness= NaN(MaxIter,MaxRuns);%contains only the fitness values

%% Main PSO loop

%Initialise Population structure
Popstruct= repmat(Emptyparticle,popsize,MaxIter,MaxRuns);
runCount =1; 
clear Emptyparticle;
%main loop for different runs
while (runCount<MaxRuns+1)
    %PART I: Initial swarm for the first iteration/generation
        generationNumber=1; %reset generation number       
        w=1;%reset the inertial coeff weight for every run
        GlobalBest.Position ='';
        GlobalBest.Fitness=inf;
        %Create the initial population for the first generation
        forbiddenFlag= 0;
        for particleNumber=1:popsize 
            %Step 1: Assign random positions- within the search space
            Popstruct(particleNumber,generationNumber, runCount).position=LB+(UB-LB).*rand(1,varNum);
            
            %Step 2: Assign random velocities
            Popstruct(particleNumber,generationNumber, runCount).velocity= -MaxVelocity+(2*MaxVelocity).*rand(1,varNum);
            
            %Step 3: Evaluate cost for this set of parameters? Also check
            %for the Imag number problem inside
            a2 = Popstruct(particleNumber,generationNumber, runCount).position;
            ParticleVD = [a1,a2,b1,b2];

            [Popstruct(particleNumber,generationNumber,runCount).Fitness, ...
             Popstruct(particleNumber,generationNumber,runCount).ControlSig1,...
             Popstruct(particleNumber,generationNumber,runCount).ControlSig2]= optimiseMovement(ts,alpha_vector,ParticleVD);
 %% Skipping the rejection section to save time. Using a penalty instead of rejection           
%          %Check 3.5: Check for Rejection
%             while (forbiddenFlag==1)
%             %Step 1: Assign random positions- witihin the search space
%             Popstruct(particleNumber,generationNumber, runCount).position=LB+(UB-LB).*rand(1,varNum);
%             
%             %Step 3: Evaluate cost for this set of parameters? Also check
%             %for the Imag number problem inside
%            [Popstruct(particleNumber,generationNumber,runCount).Fitness, ...
%             Popstruct(particleNumber,generationNumber,runCount).ControlSig1,...
%             Popstruct(particleNumber,generationNumber,runCount).ControlSig2]= optimiseMovement(Popstruct(particleNumber,generationNumber, runCount).position); end %end of the while loop
%             
%             %Step 4: Define Personal Best
            Popstruct(particleNumber,generationNumber, runCount).PersonalBest.Position=Popstruct(particleNumber,generationNumber, runCount).position;
            Popstruct(particleNumber,generationNumber, runCount).PersonalBest.Fitness=Popstruct(particleNumber,generationNumber, runCount).Fitness;
            
            %Step 5: Check for Global best
            if GlobalBest.Fitness>Popstruct(particleNumber,generationNumber,runCount).PersonalBest.Fitness
               GlobalBest.Fitness=Popstruct(particleNumber,generationNumber, runCount).PersonalBest.Fitness;
               GlobalBest.Position=Popstruct(particleNumber,generationNumber, runCount).PersonalBest.Position;
            end %check if global best needs to be changed

            %this is an additional statement required when penalty is
            %applied for the unstable VD and imaginary costs
             if isempty(GlobalBest.Position)
                 GlobalBest.Position=Popstruct(particleNumber,generationNumber, runCount).PersonalBest.Position;
             end %the personal best solution of the last particle becomes the Global best solution at this point
        end %End of for loop for the swarm size
        
        %Step 6: Save the global best of the first Gen
        BestFitness(generationNumber,runCount)= real(GlobalBest.Fitness);       
%DEBUG LINE
disp('Starting the outer optimisation loop');
%PART II: Call the PSO algo repeatedly
%
   PSOAlgoOuter;%The iterative stuff is in here
   %DEBUG LINE 
disp('Finished one Run of outer loop');
   runCount=runCount+1;%increment the run count
end %end of the while loop for the PSO implementation
%% Result consolidation
%Step 1: convert the result variables to a matrix

    FitnessMatrix=NaN(popsize,MaxIter,MaxRuns);
    for jj=1:MaxRuns
        for kk=1:MaxIter
            for aa=1:popsize
                FitnessMatrix(aa,kk,jj)=Popstruct(aa,kk,jj).Fitness;
            end %all particles
        end %all generations
    end %all runs
    clear jj kk aa
%1. Best fitness of all times, its generation number and phenotype
    [s1 s2 s3] = size(FitnessMatrix);
    [minval, ind] = min(reshape(FitnessMatrix(:), s1*s2*s3, []));%makes it a single column
    [aa, jj,  kk] = ind2sub([s1 s2 s3], ind);
    MinFitness = [minval' aa' jj' kk'];
    MinFitness_phenotype=[a1,Popstruct(aa,jj,kk).position,b1,b2];  
   %this is the time it takes for the optimisation code to run
toc
%%
OptimalControlSig1=Popstruct(aa,jj,kk).ControlSig1;
OptimalControlSig2=Popstruct(aa,jj,kk).ControlSig2;

% Performance of optimized control signal ---------------------------------    
figure(1)  
subplot(1,2,1)
%control signal to reach target 1
        u = gen_spline(ts,OptimalControlSig1);
        plot(u);hold on;
        EMG1=gen_EMG(u);
        %plot(EMG1);
%control signal to reach target 2       
        u = gen_spline(ts, OptimalControlSig2);
        plot(u);hold on;
        EMG2=gen_EMG(u);
        %plot(EMG2);
        
        title('Optimized control signal');
    
    subplot(1,2,2)  
    %Reach target 1
        x = signalProc_plot(ts,EMG1,MinFitness_phenotype);
        plot(x);hold on;
        x = signalProc_plot(ts, EMG2,MinFitness_phenotype);
        plot(x);
        title('Optimized position');

        saveas(gcf,'Initial-and-Optimal-u.fig')
%%
    dis = 1;                                                                % Display costs
   disp('Target 1');
   process_movement(ts,alpha_vector, OptimalControlSig1,MinFitness_phenotype,10);
   disp('Target 2');
   process_movement(ts,alpha_vector,OptimalControlSig2,MinFitness_phenotype,15);
   toc
% clear ii jj kk ind varNum dis dim forbiddenFlag ic fc t0 u0 x w u EMG popsize particleNumber   
saveas(gcf,'TargetReach.fig')
%%
save('vars')