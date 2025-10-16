function live_sim_main(BCL, nrepeat, protocol, ICfile)
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
    sim_data.all_Cai = [];
    sim_data.all_APD = [];
    sim_data.all_IKr_scale = [];
    sim_data.all_ICaL_scale = [];
    sim_data.all_INa_scale = [];
    sim_data.all_IKs_scale = [];
    sim_data.all_Irel_scale = [];
    sim_data.current_states = config.STATES0;
    sim_data.current_beat = 0;
    sim_data.is_running = false;
    sim_data.is_paused = false;
end

function [fig, controls] = create_gui_components()
    % Create main figure
    fig = uifigure('Name', 'Zebrafish Heart Live Simulation')
    
    % Create grid layout
    gl = uigridlayout(fig, [5, 6]);
    gl.RowHeight = {'1x', '1x', 'fit', 'fit', 'fit'};
    gl.ColumnWidth = {'fit', '1x', 'fit', 'fit', '1x', 'fit'};
    
    % Create axes
    controls.ax1 = create_axis(gl, 1, [1 6], 'Real-time Action Potential', 'Time (ms)', 'Voltage (mV)');
    controls.ax2 = create_axis(gl, 2, [1 3], 'Calcium Transient', 'Time (ms)', '[Ca]_{i} (mM)');
    controls.ax3 = create_axis(gl, 2, [4 6], 'APD Trends', 'Beat Number', 'APD (ms)');
    hold(controls.ax3, 'on');
    
    % Create controls
    controls = create_control_panel(gl, controls);
    
    % Create plot lines
    controls.voltage_line = plot(controls.ax1, nan, nan, 'b-', 'LineWidth', 1.5);
    controls.calcium_line = plot(controls.ax2, nan, nan, 'r-', 'LineWidth', 1.5);
    controls.apd_line = plot(controls.ax3, nan, nan, 'ro-', 'MarkerSize', 4, 'LineWidth', 1.5);
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
    % Create all sliders and buttons
    [controls.IKr_slider, controls.IKr_label] = create_slider_row(gl, 3, 1, 'IKr Scaling:', 0.1, 3.0, 1.0);
    [controls.ICaL_slider, controls.ICaL_label] = create_slider_row(gl, 3, 4, 'ICaL Scaling:', 0.1, 3.0, 1.0);
    [controls.INa_slider, controls.INa_label] = create_slider_row(gl, 4, 1, 'INa Scaling:', 0.5, 2.0, 1.0);
    [controls.IKs_slider, controls.IKs_label] = create_slider_row(gl, 4, 4, 'IKs Scaling:', 0.1, 3.0, 1.0);
    [controls.Irel_slider, controls.Irel_label] = create_slider_row(gl, 5, 1, 'Irel Scaling:', 0.1, 3.0, 1.0);
    
    % Create control buttons
    controls.start_btn = create_button(gl, 5, 4, 'Start Simulation');
    controls.pause_btn = create_button(gl, 5, 5, 'Pause');
    controls.reset_btn = create_button(gl, 5, 6, 'Reset');
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
    slider.Layout.Column = start_col + 1;
    slider.Limits = [min_val, max_val];
    slider.Value = default_val;
    
    % Create value label
    label = uilabel(gl);
    label.Text = sprintf('%.2f', default_val);
    label.Layout.Row = row;
    label.Layout.Column = start_col + 2;
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
    
    % Slider callbacks
    controls.IKr_slider.ValueChangedFcn = @(~,~) update_labels(controls);
    controls.ICaL_slider.ValueChangedFcn = @(~,~) update_labels(controls);
    controls.INa_slider.ValueChangedFcn = @(~,~) update_labels(controls);
    controls.IKs_slider.ValueChangedFcn = @(~,~) update_labels(controls);
    controls.Irel_slider.ValueChangedFcn = @(~,~) update_labels(controls);
    
    % Initialize labels
    update_labels(controls);
    
    fprintf('Enhanced zebrafish heart simulation ready.\n');
    fprintf('Controls:\n');
    fprintf('  - IKr: Rapid delayed rectifier K+ current (main repolarization)\n');
    fprintf('  - ICaL: L-type Ca2+ current (plateau and calcium-induced calcium release)\n');
    fprintf('  - INa: Fast Na+ current (depolarization)\n');
    fprintf('  - IKs: Slow delayed rectifier K+ current (late repolarization)\n');
    fprintf('  - Irel: Calcium release from SR\n');
end

function update_labels(controls)
    controls.IKr_label.Text = sprintf('%.2f', controls.IKr_slider.Value);
    controls.ICaL_label.Text = sprintf('%.2f', controls.ICaL_slider.Value);
    controls.INa_label.Text = sprintf('%.2f', controls.INa_slider.Value);
    controls.IKs_label.Text = sprintf('%.2f', controls.IKs_slider.Value);
    controls.Irel_label.Text = sprintf('%.2f', controls.Irel_slider.Value);
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
    
    for beat = sim_data.current_beat+1:config.nrepeat
        if ~sim_data.is_running || sim_data.is_paused
            sim_data.current_beat = beat - 1;
            return;
        end
        
        % Get current parameter values
        IKr_scale = controls.IKr_slider.Value;
        ICaL_scale = controls.ICaL_slider.Value;
        INa_scale = controls.INa_slider.Value;
        IKs_scale = controls.IKs_slider.Value;
        Irel_scale = controls.Irel_slider.Value;
        
        % Update constants with scaling
        CONSTANTS = mod_param();
        CONSTANTS.GKr = CONSTANTS.GKr * IKr_scale;
        CONSTANTS.GCaL = CONSTANTS.GCaL * ICaL_scale;
        CONSTANTS.GNa = CONSTANTS.GNa * INa_scale;
        CONSTANTS.GKs = CONSTANTS.GKs * IKs_scale;
        CONSTANTS.gIrel = CONSTANTS.gIrel * Irel_scale;
        
        % Simulate one beat
        [t_beat, STATES_beat, apd] = simulate_beat(local_STATES0, CONSTANTS, config);
        local_STATES0 = STATES_beat(end, :);
        
        % Extract voltage and calcium
        V_beat = STATES_beat(:, 1);
        Cai_beat = STATES_beat(:, 2);
        
        % Store data
        sim_data.all_t = [sim_data.all_t; t_beat + config.BCL*(beat-1)];
        sim_data.all_V = [sim_data.all_V; V_beat];
        sim_data.all_Cai = [sim_data.all_Cai; Cai_beat];
        sim_data.all_APD(beat) = apd;
        sim_data.all_IKr_scale(beat) = IKr_scale;
        sim_data.all_ICaL_scale(beat) = ICaL_scale;
        sim_data.all_INa_scale(beat) = INa_scale;
        sim_data.all_IKs_scale(beat) = IKs_scale;
        sim_data.all_Irel_scale(beat) = Irel_scale;
        
        % Update real-time plots (show last 3 beats)
        show_beats = min(3, beat);
        start_idx = max(1, length(sim_data.all_V) - length(t_beat)*show_beats);
        end_idx = length(sim_data.all_V);
        
        % Voltage plot
        set(controls.voltage_line, 'XData', sim_data.all_t(start_idx:end_idx), 'YData', sim_data.all_V(start_idx:end_idx));
        if ~isempty(sim_data.all_V(start_idx:end_idx))
            ylim(controls.ax1, [min(sim_data.all_V(start_idx:end_idx))-5, max(sim_data.all_V(start_idx:end_idx))+5]);
        end
        
        % Calcium plot
        set(controls.calcium_line, 'XData', sim_data.all_t(start_idx:end_idx), 'YData', sim_data.all_Cai(start_idx:end_idx));
        if ~isempty(sim_data.all_Cai(start_idx:end_idx))
            ylim(controls.ax2, [min(sim_data.all_Cai(start_idx:end_idx))*0.9, max(sim_data.all_Cai(start_idx:end_idx))*1.1]);
        end
        
        % APD plot
        set(controls.apd_line, 'XData', 1:beat, 'YData', sim_data.all_APD(1:beat));
        if ~isempty(sim_data.all_APD) && all(~isnan(sim_data.all_APD))
            ylim(controls.ax3, [min(sim_data.all_APD)*0.9, max(sim_data.all_APD)*1.1]);
        end
        
        % Update titles with current values
        title(controls.ax1, sprintf('Beat %d/%d - APD: %.1f ms', beat, config.nrepeat, apd));
        if ~isempty(Cai_beat)
            title(controls.ax2, sprintf('Calcium Transient - Max [Ca]_{i}: %.4f mM', max(Cai_beat)));
        end
        title(controls.ax3, sprintf('APD_{90} History - Current: %.1f ms', apd));
        
        % Display current information
        fprintf('Beat %d: APD = %.1f ms, IKr scale = %.2f, ICaL scale = %.2f\n', ...
                beat, apd, IKr_scale, ICaL_scale);
        
        drawnow;
        sim_data.current_beat = beat;
        sim_data.current_states = local_STATES0;
        
        % Brief pause to allow UI updates
        pause(0.01);
    end
    
    sim_data.is_running = false;
    controls.start_btn.Text = 'Start Simulation';
    fprintf('Simulation completed.\n');
    
    % Display final summary
    fprintf('\n=== Simulation Summary ===\n');
    fprintf('Final APD: %.1f ms\n', sim_data.all_APD(end));
    fprintf('Final IKr scaling: %.2f\n', sim_data.all_IKr_scale(end));
    fprintf('Final ICaL scaling: %.2f\n', sim_data.all_ICaL_scale(end));
    fprintf('Final INa scaling: %.2f\n', sim_data.all_INa_scale(end));
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
    sim_data.all_Cai = [];
    sim_data.all_APD = [];
    sim_data.all_IKr_scale = [];
    sim_data.all_ICaL_scale = [];
    sim_data.all_INa_scale = [];
    sim_data.all_IKs_scale = [];
    sim_data.all_Irel_scale = [];
    
    sim_data.current_states = config.STATES0;
    
    set(controls.voltage_line, 'XData', nan, 'YData', nan);
    set(controls.calcium_line, 'XData', nan, 'YData', nan);
    set(controls.apd_line, 'XData', nan, 'YData', nan);
    
    title(controls.ax1, 'Real-time Action Potential');
    title(controls.ax2, 'Calcium Transient');
    title(controls.ax3, 'APD Trends');
    
    controls.start_btn.Text = 'Start Simulation';
    controls.pause_btn.Text = 'Pause';
    
    % Reset sliders to default
    controls.IKr_slider.Value = 1.0;
    controls.ICaL_slider.Value = 1.0;
    controls.INa_slider.Value = 1.0;
    controls.IKs_slider.Value = 1.0;
    controls.Irel_slider.Value = 1.0;
    update_labels(controls);
    
    drawnow;
end