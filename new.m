function run_simulation()
% Main entry point for zebrafish heart simulation
% Run this from the Capstone root directory to start the simulation
    
    fprintf('Starting Zebrafish Heart Simulation...\n');
    
    % Add both directories to path
    root_dir = fileparts(mfilename('fullpath'));
    control_loop_dir = fullfile(root_dir, 'control-loop');
    model_dir = fullfile(root_dir, 'zebrafish-computational-model');
    
    addpath(control_loop_dir);
    addpath(model_dir);
    
    fprintf('Control-loop directory: %s\n', control_loop_dir);
    fprintf('Model directory: %s\n', model_dir);
    
    % Start the simulation
    live_sim_main();
end