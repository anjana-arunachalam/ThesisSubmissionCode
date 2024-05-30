global forbiddenFlag;
for generationNumber=2:MaxIter

%change your inertial Coefficient
switch char(inertialCoeff)
            case 'linear'
                w=w-0.01;
            case 'exp'
                w=0.99*w;
            case 'const'
            otherwise
end      
    for particleNumber=1:popsize       
        %Step1: compute new velocity
        Popstruct(particleNumber,generationNumber,runCount).velocity=w*Popstruct(particleNumber,generationNumber-1,runCount).velocity+...
            c1*(rand(1,varNum).*(Popstruct(particleNumber,generationNumber-1,runCount).PersonalBest.Position-Popstruct(particleNumber,generationNumber-1,runCount).position))+...
            c2*(rand(1,varNum).*(GlobalBest.Position-Popstruct(particleNumber,generationNumber-1,runCount).position));
        
        %clamp the velocity
        for dim=1:varNum
            if Popstruct(particleNumber,generationNumber, runCount).velocity(dim)>MaxVelocity(dim)
                Popstruct(particleNumber,generationNumber, runCount).velocity(dim) =MaxVelocity(dim);
            elseif Popstruct(particleNumber,generationNumber, runCount).velocity(dim) <-MaxVelocity(dim)
                Popstruct(particleNumber,generationNumber, runCount).velocity(dim) =-MaxVelocity(dim);
            end
        end
        
        %Step 3: compute new position
        Popstruct(particleNumber,generationNumber, runCount).position=Popstruct(particleNumber,generationNumber-1, runCount).position+...
                                                                      Popstruct(particleNumber,generationNumber, runCount).velocity;
        
        %Ensure that it doesn't exceed the range
        for dim =1:varNum
            if Popstruct(particleNumber,generationNumber, runCount).position(dim)>UB(dim)
                Popstruct(particleNumber,generationNumber, runCount).position(dim)=UB(dim);
            elseif Popstruct(particleNumber,generationNumber, runCount).position(dim)<LB(dim)
                Popstruct(particleNumber,generationNumber, runCount).position(dim)=LB(dim);
            end %nested if
        end%for loop for the dimension
        
        %Step 4: compute corresponding fitness value
        ParticleVD = [a1,Popstruct(particleNumber,generationNumber, runCount).position,b1,b2];
        [Popstruct(particleNumber,generationNumber,runCount).Fitness, ...
         Popstruct(particleNumber,generationNumber,runCount).ControlSig1,...
         Popstruct(particleNumber,generationNumber,runCount).ControlSig2]= optimiseMovement(ts,alpha_vector,ParticleVD);
        %NOTE: The flag for the rejection is set only after the Cost
        %calculation function is called
        
        %% Check if rejection is necessary
        %Step 5: Rejection?
%         while(forbiddenFlag ==1)
%             %Step 1: Assign random positions- witihin the search space
%             Popstruct(particleNumber,generationNumber, runCount).position=LB+(UB-LB).*rand(1,varNum);
%             
%             % Evaluate cost for this set of parameters? Also check
%             %for the Imag number problem inside
%             [Popstruct(particleNumber,generationNumber,runCount).Fitness, ...
%              Popstruct(particleNumber,generationNumber,runCount).ControlSig1,...
%              Popstruct(particleNumber,generationNumber,runCount).ControlSig2]= optimiseMovement(Popstruct(particleNumber,generationNumber, runCount).position);
%         end %while loop for rejection
%        
        %Step 6: Update Personal best (upto this iteration)
        %fix it to be the previous one, change if necessary
        Popstruct(particleNumber,generationNumber,runCount).PersonalBest=Popstruct(particleNumber,generationNumber-1,runCount).PersonalBest;
        
        if Popstruct(particleNumber,generationNumber,  runCount).Fitness<Popstruct(particleNumber,generationNumber, runCount).PersonalBest.Fitness
            Popstruct(particleNumber,generationNumber, runCount).PersonalBest.Fitness=real(Popstruct(particleNumber,generationNumber, runCount).Fitness);
            Popstruct(particleNumber,generationNumber, runCount).PersonalBest.Position=Popstruct(particleNumber,generationNumber, runCount).position;
        end %personal best update
        
        %Step 7: Update global best if necessary
        if  GlobalBest.Fitness>Popstruct(particleNumber,generationNumber,runCount).PersonalBest.Fitness
            GlobalBest.Fitness=Popstruct(particleNumber,generationNumber,runCount).PersonalBest.Fitness;
            GlobalBest.Position=Popstruct(particleNumber,generationNumber,runCount).PersonalBest.Position;
        end %global best update
        
    end %particle loop   
    BestFitness(generationNumber,runCount)= GlobalBest.Fitness;
%     toc
%DEBUG statement
%disp('Done with one outer loop generation');
generationNumber
end %generation loop
%% Plot:
figure(2)
plot(BestFitness(:,runCount));
xlabel('Number of generations');
ylabel('Fitness value');
hold on;
