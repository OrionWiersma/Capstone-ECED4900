function setup_simulation()
    % Setup simulation paths - connects control-loop with model code
    
    % Get the directory where this setup script is located
    setup_dir = fileparts(mfilename('fullpath'));
    
    % Go up one level to Capstone root, then into model directory
    root_dir = fileparts(setup_dir);
    model_dir = fullfile(root_dir, 'zebrafish-computational-model');
    
    % Add the main model directory AND the specific subdirectory
    if exist(model_dir, 'dir')
        addpath(model_dir);
        
        % Add the specific subdirectory where the actual model files are
        model_subdir = fullfile(model_dir, 'matlab_0D', '0D');
        if exist(model_subdir, 'dir')
            addpath(model_subdir);
            fprintf('Model directories added to path:\n');
            fprintf('  - %s\n', model_dir);
            fprintf('  - %s\n', model_subdir);
        else
            error('Model subdirectory not found: %s', model_subdir);
        end
    else
        error('Model directory not found: %s\nPlease check the directory structure.', model_dir);
    end
    
    
    % Verify essential model functions are available
    required_files = {'mod_param.m', 'computerates.m', 'initial_cond.m'};
    for i = 1:length(required_files)
        if ~exist(required_files{i}, 'file')
            error('Required model file not found: %s\nPlease check the model directory.', required_files{i});
        end
    end
    

    fprintf('All model functions loaded successfully.\n');
end