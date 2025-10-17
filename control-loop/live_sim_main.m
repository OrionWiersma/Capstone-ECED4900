function live_sim_main(BCL, nrepeat, protocol, ICfile)
% NEED TO CHECK TO SEE IF THIS UPDATES LIVE ACCURATELY
% Main live simulation GUI and manager for zebrafish heart model
% 
% Inputs:
%   BCL      - Basic cycle length in ms (default: 500)
%   nrepeat  - Number of stimulations (default: 50)
%   protocol - Simulation protocol (default: 0)
%   ICfile   - Initial condition file (default: [])
    
    %setup file paths
    setup_simulation();

    % Initialize simulation
    [config, sim_data] = initialize_simulation(BCL, nrepeat, ICfile);
    
    % Create GUI
    [fig, controls] = create_gui_components();
    
    % Set up callbacks and simulation functions
    setup_simulation_environment(fig, controls, config, sim_data);
    
    fprintf('Zebrafish Heart Live Simulation ready.\n');
end

function [config, sim_data] = initialize_simulation(BCL, nrepeat, ICfile)
    % Simulation configuration
    config.BCL = BCL;
    config.nrepeat = nrepeat;
    config.options = odeset('RelTol', 1e-6, 'AbsTol', 1e-6, 'MaxStep', 1);
    config.STATES0 = initial_cond(ICfile);
    
    % Simulation data storage
    sim_data.all_t = [];
    sim_data.all_V = [];
    sim_data.all_APD = [];
    sim_data.all_IKr_scale = [];
    sim_data.current_states = config.STATES0; % ensure updated final state becomes new initial state
    sim_data.current_beat = 0;
    sim_data.is_running = false;
    sim_data.is_paused = false;
end

function [fig, controls] = create_gui_components()
    % Create main figure
    fig = uifigure('Name', 'Zebrafish Heart Live Simulation');
    
    % Simpler grid layout
    gl = uigridlayout(fig, [4, 8]);
    gl.RowHeight = {'1x', '1x', 'fit', 'fit'};
    gl.ColumnWidth = {'fit', '1x', 'fit', '1x', 'fit', '1x', 'fit', '1x'};  % Alternating fit/1x
    
    % Create axes
    controls.ax1 = create_axis(gl, 1, [1, 8], 'Real-time Action Potential', 'Time (ms)', 'Voltage (mV)');
    controls.ax2 = create_axis(gl, 2, [1, 8], 'APD Trends', 'Beat Number', 'APD (ms)');
    hold(controls.ax2, 'on');
    
    % Create controls
    controls = create_control_panel(gl, controls);
    
    % Create plot lines
    controls.voltage_line = plot(controls.ax1, nan, nan, 'b-', 'LineWidth', 1.5);
    controls.apd_line = plot(controls.ax2, nan, nan, 'ro-', 'MarkerSize', 4, 'LineWidth', 1.5);
end

function ax = create_axis(parent, row, columns, title_text, xlabel_text, ylabel_text)
    ax = uiaxes(parent);
    ax.Layout.Row = row;
    ax.Layout.Column = columns;
    title(ax, title_text);
    xlabel(ax, xlabel_text);
    ylabel(ax, ylabel_text);
    grid(ax, 'on');
end

function controls = create_control_panel(gl, controls)
    % Create IKr and HcKCR1 controls with better spacing
    [controls.IKr_slider, controls.IKr_label] = create_slider_row(gl, 3, 1, 'IKr Scaling:', 0.1, 3.0, 1.0);
    [controls.HcKCR1_slider, controls.HcKCR1_label] = create_slider_row(gl, 3, 5, 'HcKCR1 Conductance:', 0.0, 0.5, 0.0);  % Changed to column 5
    
    % Create control buttons
    controls.start_btn = create_button(gl, 4, 3, 'Start Simulation');
    controls.pause_btn = create_button(gl, 4, 4, 'Pause');
    controls.reset_btn = create_button(gl, 4, 5, 'Reset');
end

function [slider, label] = create_slider_row(gl, row, start_col, text, min_val, max_val, default_val)
    % Create label
    label_obj = uilabel(gl);
    label_obj.Text = text;
    label_obj.HorizontalAlignment = 'right';
    label_obj.Layout.Row = row;
    label_obj.Layout.Column = start_col;
    
    % Create slider
    slider = uislider(gl);
    slider.Layout.Row = row;
    slider.Layout.Column = start_col + 1;  % Slider in next column
    slider.Limits = [min_val, max_val];
    slider.Value = default_val;
    
    % Create value label
    label = uilabel(gl);
    label.Text = sprintf('%.1f', default_val);
    label.Layout.Row = row;
    label.Layout.Column = start_col + 2;  % Value label in column after slider
end

function btn = create_button(gl, row, col, text)
    btn = uibutton(gl, 'push');
    btn.Text = text;
    btn.Layout.Row = row;
    btn.Layout.Column = col;
end

function setup_simulation_environment(fig, controls, config, sim_data)
    % Set up all callbacks
    controls.start_btn.ButtonPushedFcn = @(~,~) toggle_simulation(controls, config, sim_data);
    controls.pause_btn.ButtonPushedFcn = @(~,~) toggle_pause(controls, sim_data);
    controls.reset_btn.ButtonPushedFcn = @(~,~) reset_simulation(controls, config, sim_data);
    
    % Current callback
    controls.IKr_slider.ValueChangedFcn = @(~,~) update_labels(controls);
    controls.HcKCR1_slider.ValueChangedFcn = @(~,~) update_labels(controls);  % Placeholder

    
    % Initialize labels
    update_labels(controls);
    
    fprintf('Zebrafish heart simulation ready.\n');
    fprintf('Control: IKr scaling and HcKCR1 conductance\n');end

function update_labels(controls)
    controls.IKr_label.Text = sprintf('%.1f', controls.IKr_slider.Value);
    controls.HcKCR1_label.Text = sprintf('%.1f', controls.HcKCR1_slider.Value);
end

function apd = calculate_APD(t, V)
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

function [t_beat, STATES_beat, apd] = simulate_beat(STATES0, CONSTANTS, config)
    tspan = [0 config.BCL];
    [t_beat, STATES] = ode15s(@computerates, tspan, STATES0, config.options, CONSTANTS, 1, 1);
    V_beat = STATES(:, 1);
    apd = calculate_APD(t_beat, V_beat);
    STATES_beat = STATES;
end

function run_simulation(controls, config, sim_data)
    if ~sim_data.is_running, return; end
    
    local_STATES0 = sim_data.current_states;

    BASE_CONSTANTS = mod_param();
    
    for beat = sim_data.current_beat+1:config.nrepeat
        if ~sim_data.is_running || sim_data.is_paused
            sim_data.current_beat = beat - 1;
            return;
        end
        
        % Get current parameter values
        IKr_scale = controls.IKr_slider.Value;
        HcKCR1_light = controls.HcKCR1_slider.Value;  % 0-1 light intensity
        
        % Update constants with scaling (only IKr)
        CONSTANTS = BASE_CONSTANTS;
        %CONSTANTS = mod_param(); % mod_param reset for each beat
        CONSTANTS.GKr = CONSTANTS.GKr * IKr_scale;
        CONSTANTS.GHcKCR1 = 0.1*HcKCR1_light;  % Direct conductance control, scaled by 0.1 to avoid extreme effects

        
        % Simulate one beat
        [t_beat, STATES_beat, apd] = simulate_beat(local_STATES0, CONSTANTS, config);
        local_STATES0 = STATES_beat(end, :);
        
        % Extract voltage only
        V_beat = STATES_beat(:, 1);
        
        % Store data
        sim_data.all_t = [sim_data.all_t; t_beat + config.BCL*(beat-1)];
        sim_data.all_V = [sim_data.all_V; V_beat];
        sim_data.all_APD(beat) = apd;
        sim_data.all_IKr_scale(beat) = IKr_scale;
        sim_data.all_HcKCR1_conductance(beat) = HcKCR1_light;

        % Update real-time plots (show last 3 beats)
        show_beats = min(3, beat);
        start_idx = max(1, length(sim_data.all_V) - length(t_beat)*show_beats);
        end_idx = length(sim_data.all_V);
        
        % Voltage plot
        set(controls.voltage_line, 'XData', sim_data.all_t(start_idx:end_idx), 'YData', sim_data.all_V(start_idx:end_idx));
        if ~isempty(sim_data.all_V(start_idx:end_idx))
            ylim(controls.ax1, [min(sim_data.all_V(start_idx:end_idx))-5, max(sim_data.all_V(start_idx:end_idx))+5]);
        end
        
        % APD plot
        set(controls.apd_line, 'XData', 1:beat, 'YData', sim_data.all_APD(1:beat));
        if ~isempty(sim_data.all_APD) && all(~isnan(sim_data.all_APD))
            ylim(controls.ax2, [min(sim_data.all_APD)*0.9, max(sim_data.all_APD)*1.1]);
        end
        
        % Update titles with current values
        title(controls.ax1, sprintf('Beat %d/%d - APD: %.1f ms', beat, config.nrepeat, apd));
        title(controls.ax2, sprintf('APD_{90} History - Current: %.1f ms', apd));
        
        % Display current information
        fprintf('Beat %d: APD = %.1f ms, IKr scale = %.2f, HcKCR1 Light = %.2f\n', ...
                beat, apd, IKr_scale, HcKCR1_light);
        
        drawnow;
        sim_data.current_beat = beat;
        sim_data.current_states = local_STATES0;
        
        % use this if your pc sucks
        %pause(0.01);
    end
    
    sim_data.is_running = false;
    controls.start_btn.Text = 'Start Simulation';
    fprintf('Simulation completed.\n');
    
    % Display final summary
    fprintf('\n=== Simulation Summary ===\n');
    fprintf('Final APD: %.1f ms\n', sim_data.all_APD(end));
    fprintf('Final IKr scaling: %.2f\n', sim_data.all_IKr_scale(end));
    fprintf('Final HcKCR1 conductance: %.2f\n', sim_data.all_HcKCR1_conductance(end));
end

function toggle_simulation(controls, config, sim_data)
    if ~sim_data.is_running
        % Start or restart simulation
        if sim_data.current_beat >= config.nrepeat
            reset_simulation(controls, config, sim_data);
        end
        sim_data.is_running = true;
        sim_data.is_paused = false;
        controls.start_btn.Text = 'Stop';
        run_simulation(controls, config, sim_data);
    else
        % Stop simulation
        sim_data.is_running = false;
        controls.start_btn.Text = 'Start Simulation';
    end
end

function toggle_pause(controls, sim_data)
    sim_data.is_paused = ~sim_data.is_paused;
    if sim_data.is_paused
        controls.pause_btn.Text = 'Resume';
    else
        controls.pause_btn.Text = 'Pause';
        if sim_data.is_running
            run_simulation(controls, sim_data.config, sim_data);
        end
    end
end

function reset_simulation(controls, config, sim_data)
    sim_data.is_running = false;
    sim_data.is_paused = false;
    sim_data.current_beat = 0;
    sim_data.all_t = [];
    sim_data.all_V = [];
    sim_data.all_APD = [];
    sim_data.all_IKr_scale = [];
    
    sim_data.current_states = config.STATES0;
    
    set(controls.voltage_line, 'XData', nan, 'YData', nan);
    set(controls.apd_line, 'XData', nan, 'YData', nan);
    
    title(controls.ax1, 'Real-time Action Potential');
    title(controls.ax2, 'APD Trends');
    
    controls.start_btn.Text = 'Start Simulation';
    controls.pause_btn.Text = 'Pause';
    
    % Reset slider to default
    controls.IKr_slider.Value = 1.0;
    update_labels(controls);
    
    drawnow;
end