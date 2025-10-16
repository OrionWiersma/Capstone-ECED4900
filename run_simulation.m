function run_simulation(BCL, nrepeat, protocol, ICfile)
% Main entry point for zebrafish heart simulation
% Run this from the Capstone root directory to start the simulation
%
% Inputs:
%   BCL      - Basic cycle length in ms (default: 500)
%   nrepeat  - Number of stimulations (default: 50)
%   protocol - Simulation protocol (default: 0)
%   ICfile   - Initial condition file (default: [])

    if nargin < 1, BCL = 500; end
    if nargin < 2, nrepeat = 50; end
    if nargin < 3, protocol = 0; end
    if nargin < 4, ICfile = []; end
    
    fprintf('Starting Zebrafish Heart Simulation...\n');
    fprintf('BCL: %d ms, Beats: %d, Protocol: %d\n', BCL, nrepeat, protocol);
    
    % Get root directory
    root_dir = fileparts(mfilename('fullpath'));
    control_loop_dir = fullfile(root_dir, 'control-loop');
    model_dir = fullfile(root_dir, 'zebrafish-computational-model');
    
    % Add both directories to path
    addpath(control_loop_dir);
    addpath(model_dir);
    
    fprintf('Control-loop directory: %s\n', control_loop_dir);
    fprintf('Model directory: %s\n', model_dir);
    
    % Start the simulation with parameters
    live_sim_main(BCL, nrepeat, protocol, ICfile);
end