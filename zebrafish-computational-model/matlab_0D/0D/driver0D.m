% Driver for solver
%
% INPUT: 
% BCL:      Basic cycle length for preconditioning
% nrepeat:  Number of stimulations for preconditioning (Protocol=0)
%           Number of S1 stimulations                  (Protocol=1)
%           Number of stimulations for BCl             (Protocol=2)
% protocol: 0 Steady state protocol
%           1 S1S2 protocol
%           2 Dynamic protocol
% BCLseq:   Only for protocol=1, array of S2 stimuli (BCLs)
% ICfile:   Name of mat file with initial conditions. The initial 
%           conditions have to be save as a vector STATES0 
% control:  0 does not plot control curves
%           1 plots control curves
% OUTPUT:
% Solution files
% SS_AP:    AP_features(1) RMP 
%           AP_features(2) APA 
%           AP_features(3) APD20
%           AP_features(4) APD50
%           AP_features(5) APD80
%           AP_features(6) APD90
%           AP_features(7) dV/dt
%           AP_features(8) Vmax
%           AP_features(9) tpeak
%           AP_features(10)triang

clear; clc; close all;

% ----------------------------------------------
%   MODIFIABLE PARAMETERS
% ----------------------------------------------

protocol = 0;
switch protocol
    case 0
        nrepeat = 300;
        BCL = 500;
        BCL_seq = [];
        control = 0;
    case 1
        nrepeat = 10;
        BCL = 500;
        BCL_seq = [450 400 375 350 325 300 280 260 240 220]; 
        name = sprintf('IC_SS_%d.mat',BCL);
        ICfile = name;
        control = 0;
    case 2
        nrepeat = 100;
        BCL = 800;
        BCL_seq = [800 600 500 400 300 250 225];      
        name = sprintf('IC_SS_%d.mat',BCL);
        ICfile = name;
        control = 0;
end

% ----------------------------------------------
% END of Modifiable parameters
% ----------------------------------------------

switch protocol
    case 0
        main(BCL,nrepeat,protocol,BCL_seq,[]);
    case 1
        main(BCL,nrepeat,protocol,BCL_seq,ICfile);
    case 2
        main(BCL,nrepeat,protocol,BCL_seq,ICfile);
end

switch protocol
    case 0 
        plot_SS(BCL,control);   
    case 1
        plot_RestS1S2(BCL,BCL_seq,control);    
        plot_currS1S2(BCL,BCL_seq);
    case 2
        plot_RestDyn(BCL,BCL_seq,control);    
        plot_currDyn(BCL,BCL_seq);
end