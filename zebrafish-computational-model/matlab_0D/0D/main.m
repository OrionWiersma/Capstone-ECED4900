function main(BCL,nrepeat,protocol,BCLseq,ICfile)
        
% Input: 
% BCL:      Basic cycle length for preconditioning
% nrepeat:  Number of stimulations for preconditioning (Protocol=0)
%           Number of S1 stimulations                  (Protocol=1)
%           Number of stimulations for BCl             (Protocol=2)
% protocol: 0 Steady state protocol
%           1 S1S2 protocol
%           2 Dynamic protocol
% BCLseq:   Only for protocol=1 and protocol=2, array of S2 stimuli or dynamic protocol (BCLs) 
% ICfile:   Name of mat file with initial conditions. The initial 
%           conditions have to be save as a vector STATES0 
%
% Protocol 1: S1S2 rest File .mat with restitution data order as follow:
%
% Col  1: S2
% Col  2: APD90 S1
% Col  3: APD90 S2
% Col  4: APD20 S2
% Col  5: APD50 S2
% Col  6: APD80 S2
% Col  7: RMP S2
% Col  8: APA S2
% Col  9: dVdtmax S2
% Col 10: CaT20 S2
% Col 11: CaT50 S2
% Col 12: CaT80 S2

% Protocol 2: Dyn rest File .mat with restitution data order as follow:
%
% Col  1: BCL
% Col  2: APD90 n-1
% Col  3: APD90 n
% Col  4: APD20 n
% Col  5: APD50 n
% Col  6: APD80 n
% Col  7:   RMP n
% Col  8:   APA n
% Col  9: dVdtmax n
% Col 10: DI
% Col 11: CaT20
% Col 12: CaT50
% Col 13: CaT80

% Initializing cell models
STATES0 = initial_cond(ICfile);
% Loading model parameters
CONSTANTS = mod_param();
% Set numerical accuracy options for ODE solver
options = odeset('RelTol', 1e-06, 'AbsTol', 1e-06, 'MaxStep', 1);

switch protocol
    case 0
        tspan = [0 BCL];
        fprintf('Steady state protocol\n');  
        fprintf('Initiating temporal integration. Performing %d repetitions\n',nrepeat);
        flag = 1;    % Stimulating at BCL
        flagODE = 1; % Compute rates returns the derivatives of states
        tsave = [];
        STsave = [];              
        for j = 1:nrepeat
			fprintf('Beat %d/%d\n',j,nrepeat);
            % Solve model with ODE solver
            [t,STATES] = ode15s(@computerates,tspan,STATES0,options,CONSTANTS,flag,flagODE);
            % Integrating cellular model
            STATES0 = STATES(end,:); 
            tsave = [tsave; t+BCL*(j-1)];
            STsave = [STsave; STATES];               
        end
        fname = sprintf('SS_%d.mat',BCL);
        save(fname,'tsave','STsave');            
        clear tsave STsave;
        fprintf('Preconditioning finished ...\n');
        name2 = sprintf('IC_SS_%d.mat',BCL);
        save(name2,'STATES0');
        fprintf('Initial conditions saved\n');
        fprintf('Computing 5 stimulations to check for alternans\n');
        t5 = [];
        STATES5 = [];
        flag = 1;    % Stimulating at BCL
        flagODE = 1; % Compute rates returns the derivatives of states
        for j = 1:5
            [t,STATES] = ode15s(@computerates,tspan,STATES0,options,CONSTANTS,flag,flagODE);
            % Integrating cellular model
            STATES0 = STATES(end,:); 
            t5 = [t5; t+BCL*(j-1)];
            STATES5 = [STATES5; STATES];
        end
    
        % Compute the currents
        ntstp = length(t5);
        CURR5 = zeros(ntstp,14);
        flagODE = 0; % Compute currents
        for j = 1:ntstp
            output = computerates(t5(j),STATES5(j,:),CONSTANTS,flag,flagODE);
            CURR5(j,:) = output';
        end
        name3 = sprintf('solution5AP_%d.mat',BCL);
        savedata(name3,t5,STATES5,CURR5);
        
        fprintf('Computing 3 seconds without stimulation to check model stability\n');
        flag = 0;    % No stimulation
        flagODE = 1; % Compute rates returns the derivatives of states
        [t,STATES] = ode15s(@computerates,[0 3000],STATES0,options,CONSTANTS,flag,flagODE);
       
        % Compute the currents
        ntstp = length(t);
        CURR = zeros(ntstp,14);
        flagODE = 0; % Compute currents
        for j = 1:ntstp
            output = computerates(t(j),STATES(j,:),CONSTANTS,flag,flagODE);
            CURR(j,:) = output';
        end
        name4 = sprintf('solution3sec_%d.mat',BCL);
        savedata(name4,t,STATES,CURR);
    
    case 1
        tspan = [0 BCL];  
        fprintf('S1S2 restitution protocol\n');
        flag = 1;    % Stimulating at BCL
        flagODE = 1; % Compute rates returns the derivatives of states
        if(isempty(ICfile))
            fprintf('Initiating preconditioning. Performing %d repetitions\n',1000);
            for j = 1:500
                % Solve model with ODE solver
                [t, STATES] = ode15s(@computerates, tspan, STATES0, options,CONSTANTS,flag,flagODE);
                % Integrating cellular model
                STATES0 = STATES(end,:); 
            end
            fprintf('Preconditioning finished ...\n');
            name2 = sprintf('IC_%d.mat',sim_num);
            save(name2,'STATES0');
            fprintf('Initial conditions saved\n');
        else
            fprintf('Initial conditions provided. Preconditioning skipped\n');
        end
        fprintf('Starting S1-S2 protocol. Perforimng %d S2 stimuli\n',length(BCLseq));
        S1S2 = zeros(length(BCLseq),12);
        for i = 1:length(BCLseq)
            tspan = [0 BCL];
            for j = 1:nrepeat
              [t,STATES] = ode15s(@computerates,tspan,STATES0,options,CONSTANTS,flag,flagODE);
              STATES0 = STATES(end,:);
            end
            
            % Last S1
            tspan = [0 BCLseq(i)];
            [t,STATES] = ode15s(@computerates,tspan,STATES0,options,CONSTANTS,flag,flagODE);
            S1S2(i,1) = BCLseq(i);
            [APD,APA,Vmax,dVdtmax,t0,RMP,tpeak,flagOut] = APDcalc(t,STATES(:,1),[20 50 80 90]);
            S1S2(i,2) = APD(4);
            STATES1 = STATES(end,:);
           
            % S2
            tspan = [0 BCL];
            [t,STATES] = ode15s(@computerates,tspan,STATES1,options,CONSTANTS,flag,flagODE);
            [APD,APA,Vmax,dVdtmax,t0,RMP,tpeak,flagOut] = APDcalc(t,STATES(:,1),[20 50 80 90]);
            [CaT,tpeak] = CaTDcalc(t,STATES(:,2),[20 50 80]);
            S1S2(i,3:end) = [APD([4 1:3]) RMP APA dVdtmax CaT];
            STATES0 = STATES(end,:);        
            fprintf('S2: %4f DI: %5.2f APD90_S1: %5.2f APD90_S2: %5.2f\n',BCLseq(i),BCLseq(i)-S1S2(i,2),S1S2(i,2),S1S2(i,3));
            
            % Compute the currents
            ntstp = length(t);
            CURR = zeros(ntstp,14);
            for j = 1:ntstp
                output = computerates(t(j),STATES(j,:),CONSTANTS,flag,0);
                CURR(j,:) = output';
            end
            fname = sprintf('sol_S1S2_%.0f_%.0f.mat',BCL,BCLseq(i));
            savedata(fname,t,STATES,CURR);      
        end
        name5 = sprintf('S1S2_rest_%.0f.mat',BCL);
        save(name5,'S1S2');

    case 2
        tspan = [0 BCLseq(1)];  
        fprintf('Dynamic restitution protocol\n');
        flag = 1;    % Stimulating at BCL
        flagODE = 1; % Compute rates returns the derivatives of states
        if(isempty(ICfile))
            fprintf('Initiating preconditioning. Performing %d repetitions\n',1000);
            for j = 1:500
                % Solve model with ODE solver
                  [t, STATES] = ode15s(@computerates, tspan, STATES0, options,CONSTANTS,flag,flagODE);
                % Integrating cellular model
                  STATES0 = STATES(end,:); 
            end
            fprintf('Preconditioning finished ...\n');
            name2 = sprintf('IC_%d.mat',sim_num);
            save(name2,'STATES0');
            fprintf('Initial conditions saved\n');
        else
            fprintf('Initial conditions provided. Preconditioning skipped\n');
        end
        fprintf('Starting Dyn protocol. Performing %d frequencies\n',length(BCLseq));
        Dyn = zeros(length(BCLseq),13);
        for i = 1:length(BCLseq)
            tspan = [0 BCLseq(i)];
            Dyn(i,1) = BCLseq(i);
            for j = 1:(nrepeat-1)
               [t,STATES] = ode15s(@computerates,tspan,STATES0,options,CONSTANTS,flag,flagODE);
               STATES0 = STATES(end,:);
            end
            APDn = APDcalc(t,STATES(:,1),90);
            [t,STATES] = ode15s(@computerates,tspan,STATES0,options,CONSTANTS,flag,flagODE);
            STATES0 = STATES(end,:);
            [APD,APA,Vmax,dVdtmax,t0,RMP,tpeak,flagOut] = APDcalc(t,STATES(:,1),[20 50 80 90]);
            [APD_Ca] = CaTDcalc(t,STATES(:,2),[20 50 80]);
            fprintf('BCL: %4f APD(n-1): %5.2f APD(n): %5.2f\n',Dyn(i,1),APDn,APD(4));
            Dyn(i,2:end) = [APDn APD([4 1:3]) RMP APA dVdtmax Dyn(i,1)-APDn APD_Ca];
            
            % Compute the currents            
            ntstp = length(t);
            CURR = zeros(ntstp,14);
            for j = 1:ntstp
                output = computerates(t(j),STATES(j,:),CONSTANTS,flag,0);
                CURR(j,:) = output';
            end
            fname = sprintf('sol_Dyn_%.0f.mat',BCLseq(i));
            savedata(fname,t,STATES,CURR);      
        end
        name5 = sprintf('Dyn_rest_%d.mat',BCL);
        save(name5,'Dyn');
end
end