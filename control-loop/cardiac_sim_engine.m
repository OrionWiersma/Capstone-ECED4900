function results = cardiac_sim_engine(parameters, initial_states, config)
% Cardiac simulation engine - runs zebrafish heart model
%
% Inputs:
%   parameters     - Structure with scaling parameters
%   initial_states - Initial state vector
%   config         - Simulation configuration (BCL, options, etc.)
%
% Outputs:
%   results        - Structure with simulation results

    % Apply parameter scaling to constants
    CONSTANTS = apply_parameter_scaling(parameters);
    
    % Run single beat simulation
    [t_beat, STATES_beat] = simulate_single_beat(initial_states, CONSTANTS, config);
    
    % Calculate metrics
    metrics = calculate_beat_metrics(t_beat, STATES_beat);
    
    % Package results
    results.t = t_beat;
    results.STATES = STATES_beat;
    results.V = STATES_beat(:, 1);
    results.APD = metrics.APD;
    results.final_states = STATES_beat(end, :);
end

function CONSTANTS = apply_parameter_scaling(parameters)
    % Get base constants
    CONSTANTS = mod_param();
    
    % Apply scaling (only IKr)
    if isfield(parameters, 'IKr_scale')
        CONSTANTS.GKr = CONSTANTS.GKr * parameters.IKr_scale;
    end
end

function [t_beat, STATES_beat] = simulate_single_beat(initial_states, CONSTANTS, config)
    % Simulate a single cardiac beat
    tspan = [0 config.BCL];
    [t_beat, STATES_beat] = ode15s(@computerates, tspan, initial_states, config.options, CONSTANTS, 1, 1);
end

function metrics = calculate_beat_metrics(t, STATES)
    % Calculate APD and other metrics for a single beat
    V = STATES(:, 1);
    
    % Calculate APD90
    metrics.APD = calculate_APD(t, V);
    
    % Calculate voltage metrics only
    metrics.V_max = max(V);
    metrics.V_min = min(V);
end

function apd = calculate_APD(t, V)
    % Need to confirm this
    % Find APD at 90% repolarization
    V_max = max(V);
    V_min = min(V);
    V_90 = V_max - 0.9 * (V_max - V_min);
    
    % Find depolarization and repolarization times
    above_90 = V > V_90;
    depol_idx = find(above_90, 1, 'first');
    repol_idx = find(above_90, 1, 'last');
    
    if isempty(depol_idx) || isempty(repol_idx) || depol_idx >= repol_idx
        apd = NaN;
    else
        apd = t(repol_idx) - t(depol_idx);
    end
end