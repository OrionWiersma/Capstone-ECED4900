function live_sim_enhanced(BCL, nrepeat, protocol, ICfile)
% Enhanced live simulation with UI controls for real-time parameter manipulation
% 
% Inputs:
%   BCL      - Basic cycle length in ms
%   nrepeat  - Number of stimulations
%   protocol - 0: steady-state (currently supported)
%   ICfile   - optional, initial condition MAT-file (use [] for default)

    if nargin < 1, BCL = 500; end
    if nargin < 2, nrepeat = 50; end  % More beats for better visualization
    if nargin < 3, protocol = 0; end
    if nargin < 4, ICfile = []; end

    % Initialize parameters
    options = odeset('RelTol', 1e-6, 'AbsTol', 1e-6, 'MaxStep', 1);
    STATES0 = initial_cond(ICfile);
    
    % Create UI figure
    fig = uifigure('Name', 'Zebrafish Heart Live Simulation') 
    
    % Create grid layout
    gl = uigridlayout(fig, [5, 6]);
    gl.RowHeight = {'1x', '1x', 'fit', 'fit', 'fit'};
    gl.ColumnWidth = {'fit', '1x', 'fit', 'fit', '1x', 'fit'};
    
    % Create axes for real-time plotting
    ax1 = uiaxes(gl);
    ax1.Layout.Row = 1;
    ax1.Layout.Column = [1, 6];
    title(ax1, 'Real-time Action Potential');
    xlabel(ax1, 'Time (ms)');
    ylabel(ax1, 'Voltage (mV)');
    grid(ax1, 'on');
    
    % Create secondary axes for calcium and currents
    ax2 = uiaxes(gl);
    ax2.Layout.Row = 2;
    ax2.Layout.Column = [1, 3];
    title(ax2, 'Calcium Transient');
    xlabel(ax2, 'Time (ms)');
    ylabel(ax2, '[Ca]_{i} (mM)');
    grid(ax2, 'on');
    
    % Create third axes for APD analysis
    ax3 = uiaxes(gl);
    ax3.Layout.Row = 2;
    ax3.Layout.Column = [4, 6];
    title(ax3, 'APD Trends');
    xlabel(ax3, 'Beat Number');
    ylabel(ax3, 'APD (ms)');
    grid(ax3, 'on');
    hold(ax3, 'on');

    % Major Current Controls - Row 3
    label1 = uilabel(gl);
    label1.Text = 'IKr Scaling:';
    label1.HorizontalAlignment = 'right';
    label1.Layout.Row = 3;
    label1.Layout.Column = 1;
    
    IKr_slider = uislider(gl);
    IKr_slider.Layout.Row = 3;
    IKr_slider.Layout.Column = 2;
    IKr_slider.Limits = [0.1, 3.0];
    IKr_slider.Value = 1.0;
    
    IKr_label = uilabel(gl);
    IKr_label.Text = '1.00';
    IKr_label.Layout.Row = 3;
    IKr_label.Layout.Column = 3;
    
    label2 = uilabel(gl);
    label2.Text = 'ICaL Scaling:';
    label2.HorizontalAlignment = 'right';
    label2.Layout.Row = 3;
    label2.Layout.Column = 4;
    
    ICaL_slider = uislider(gl);
    ICaL_slider.Layout.Row = 3;
    ICaL_slider.Layout.Column = 5;
    ICaL_slider.Limits = [0.1, 3.0];
    ICaL_slider.Value = 1.0;
    
    ICaL_label = uilabel(gl);
    ICaL_label.Text = '1.00';
    ICaL_label.Layout.Row = 3;
    ICaL_label.Layout.Column = 6;
    
    % Row 4
    label3 = uilabel(gl);
    label3.Text = 'INa Scaling:';
    label3.HorizontalAlignment = 'right';
    label3.Layout.Row = 4;
    label3.Layout.Column = 1;
    
    INa_slider = uislider(gl);
    INa_slider.Layout.Row = 4;
    INa_slider.Layout.Column = 2;
    INa_slider.Limits = [0.5, 2.0];
    INa_slider.Value = 1.0;
    
    INa_label = uilabel(gl);
    INa_label.Text = '1.00';
    INa_label.Layout.Row = 4;
    INa_label.Layout.Column = 3;
    
    label4 = uilabel(gl);
    label4.Text = 'IKs Scaling:';
    label4.HorizontalAlignment = 'right';
    label4.Layout.Row = 4;
    label4.Layout.Column = 4;
    
    IKs_slider = uislider(gl);
    IKs_slider.Layout.Row = 4;
    IKs_slider.Layout.Column = 5;
    IKs_slider.Limits = [0.1, 3.0];
    IKs_slider.Value = 1.0;
    
    IKs_label = uilabel(gl);
    IKs_label.Text = '1.00';
    IKs_label.Layout.Row = 4;
    IKs_label.Layout.Column = 6;
    
    % Row 5
    label5 = uilabel(gl);
    label5.Text = 'Irel Scaling:';
    label5.HorizontalAlignment = 'right';
    label5.Layout.Row = 5;
    label5.Layout.Column = 1;
    
    Irel_slider = uislider(gl);
    Irel_slider.Layout.Row = 5;
    Irel_slider.Layout.Column = 2;
    Irel_slider.Limits = [0.1, 3.0];
    Irel_slider.Value = 1.0;
    
    Irel_label = uilabel(gl);
    Irel_label.Text = '1.00';
    Irel_label.Layout.Row = 5;
    Irel_label.Layout.Column = 3;
    
    % Control buttons
    start_btn = uibutton(gl, 'push');
    start_btn.Text = 'Start Simulation';
    start_btn.Layout.Row = 5;
    start_btn.Layout.Column = 4;
    
    pause_btn = uibutton(gl, 'push');
    pause_btn.Text = 'Pause';
    pause_btn.Layout.Row = 5;
    pause_btn.Layout.Column = 5;
    
    reset_btn = uibutton(gl, 'push');
    reset_btn.Text = 'Reset';
    reset_btn.Layout.Row = 5;
    reset_btn.Layout.Column = 6;
    
    % Simulation control variables
    isRunning = false;
    isPaused = false;
    currentBeat = 0;
    
    % Data storage
    all_t = [];
    all_V = [];
    all_Cai = [];
    all_APD = [];
    all_IKr_scale = [];
    all_ICaL_scale = [];
    all_INa_scale = [];
    all_IKs_scale = [];
    all_Irel_scale = [];
    
    % Real-time plot handles
    voltage_line = plot(ax1, nan, nan, 'b-', 'LineWidth', 1.5);
    calcium_line = plot(ax2, nan, nan, 'r-', 'LineWidth', 1.5);
    apd_line = plot(ax3, nan, nan, 'ro-', 'MarkerSize', 4, 'LineWidth', 1.5);
    
    % Calculate APD from voltage trace
    function apd = calculate_APD(t, V)
        % How do we calculate APD?
        % Find APD at 90% repolarization % NEED TO LOOK INTO THIS
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
    
    % Single beat simulation function
    function [t_beat, STATES_beat, apd] = simulate_beat(STATES0, CONSTANTS)
        tspan = [0 BCL];
        [t_beat, STATES] = ode15s(@computerates, tspan, STATES0, options, CONSTANTS, 1, 1);
        
        V_beat = STATES(:, 1);
        apd = calculate_APD(t_beat, V_beat);
        STATES_beat = STATES;
    end
    
    % Update parameter labels
    function update_labels()
        IKr_label.Text = sprintf('%.2f', IKr_slider.Value);
        ICaL_label.Text = sprintf('%.2f', ICaL_slider.Value);
        INa_label.Text = sprintf('%.2f', INa_slider.Value);
        IKs_label.Text = sprintf('%.2f', IKs_slider.Value);
        Irel_label.Text = sprintf('%.2f', Irel_slider.Value);
    end
    
    % Main simulation loop
    function run_simulation(~, ~)
        if ~isRunning, return; end
        
        local_STATES0 = STATES0;
        
        for beat = currentBeat+1:nrepeat
            if ~isRunning || isPaused
                currentBeat = beat - 1;
                return;
            end
            
            % Get current parameter values
            IKr_scale = IKr_slider.Value;
            ICaL_scale = ICaL_slider.Value;
            INa_scale = INa_slider.Value;
            IKs_scale = IKs_slider.Value;
            Irel_scale = Irel_slider.Value;
            
            % Update constants with scaling
            CONSTANTS = mod_param();
            CONSTANTS.GKr = CONSTANTS.GKr * IKr_scale;
            CONSTANTS.GCaL = CONSTANTS.GCaL * ICaL_scale;
            CONSTANTS.GNa = CONSTANTS.GNa * INa_scale;
            CONSTANTS.GKs = CONSTANTS.GKs * IKs_scale;
            CONSTANTS.gIrel = CONSTANTS.gIrel * Irel_scale;
            
            % Simulate one beat
            [t_beat, STATES_beat, apd] = simulate_beat(local_STATES0, CONSTANTS);
            local_STATES0 = STATES_beat(end, :);
            
            % Extract voltage and calcium
            V_beat = STATES_beat(:, 1);
            Cai_beat = STATES_beat(:, 2);
            
            % Store data
            all_t = [all_t; t_beat + BCL*(beat-1)];
            all_V = [all_V; V_beat];
            all_Cai = [all_Cai; Cai_beat];
            all_APD(beat) = apd;
            all_IKr_scale(beat) = IKr_scale;
            all_ICaL_scale(beat) = ICaL_scale;
            all_INa_scale(beat) = INa_scale;
            all_IKs_scale(beat) = IKs_scale;
            all_Irel_scale(beat) = Irel_scale;
            
            % Update real-time plots (show last 3 beats)
            show_beats = min(3, beat);
            start_idx = max(1, length(all_V) - length(t_beat)*show_beats);
            end_idx = length(all_V);
            
            % Voltage plot
            set(voltage_line, 'XData', all_t(start_idx:end_idx), 'YData', all_V(start_idx:end_idx));
            if ~isempty(all_V(start_idx:end_idx))
                ylim(ax1, [min(all_V(start_idx:end_idx))-5, max(all_V(start_idx:end_idx))+5]);
            end
            
            % Calcium plot
            set(calcium_line, 'XData', all_t(start_idx:end_idx), 'YData', all_Cai(start_idx:end_idx));
            if ~isempty(all_Cai(start_idx:end_idx))
                ylim(ax2, [min(all_Cai(start_idx:end_idx))*0.9, max(all_Cai(start_idx:end_idx))*1.1]);
            end
            
            % APD plot
            set(apd_line, 'XData', 1:beat, 'YData', all_APD(1:beat));
            if ~isempty(all_APD) && all(~isnan(all_APD))
                ylim(ax3, [min(all_APD)*0.9, max(all_APD)*1.1]);
            end
            
            % Update titles with current values
            title(ax1, sprintf('Beat %d/%d - APD: %.1f ms', beat, nrepeat, apd));
            if ~isempty(Cai_beat)
                title(ax2, sprintf('Calcium Transient - Max [Ca]_{i}: %.4f mM', max(Cai_beat)));
            end
            title(ax3, sprintf('APD_{90} History - Current: %.1f ms', apd));
            
            % Display current information
            fprintf('Beat %d: APD = %.1f ms, IKr scale = %.2f, ICaL scale = %.2f\n', ...
                    beat, apd, IKr_scale, ICaL_scale);
            
            drawnow;
            currentBeat = beat;
            
            % Brief pause to allow UI updates
            pause(0.01);
        end
        
        isRunning = false;
        start_btn.Text = 'Start Simulation';
        fprintf('Simulation completed.\n');
        
        % Display final summary
        fprintf('\n=== Simulation Summary ===\n');
        fprintf('Final APD: %.1f ms\n', all_APD(end));
        fprintf('Final IKr scaling: %.2f\n', all_IKr_scale(end));
        fprintf('Final ICaL scaling: %.2f\n', all_ICaL_scale(end));
        fprintf('Final INa scaling: %.2f\n', all_INa_scale(end));
    end
    
    % Button callbacks
    start_btn.ButtonPushedFcn = @(~,~) toggle_simulation();
    pause_btn.ButtonPushedFcn = @(~,~) toggle_pause();
    reset_btn.ButtonPushedFcn = @(~,~) reset_simulation();
    
    % Slider callbacks - update labels immediately
    IKr_slider.ValueChangedFcn = @(~,~) update_labels();
    ICaL_slider.ValueChangedFcn = @(~,~) update_labels();
    INa_slider.ValueChangedFcn = @(~,~) update_labels();
    IKs_slider.ValueChangedFcn = @(~,~) update_labels();
    Irel_slider.ValueChangedFcn = @(~,~) update_labels();
    
    function toggle_simulation()
        if ~isRunning
            % Start or restart simulation
            if currentBeat >= nrepeat
                reset_simulation();
            end
            isRunning = true;
            isPaused = false;
            start_btn.Text = 'Stop';
            run_simulation();
        else
            % Stop simulation
            isRunning = false;
            start_btn.Text = 'Start Simulation';
        end
    end
    
    function toggle_pause()
        isPaused = ~isPaused;
        if isPaused
            pause_btn.Text = 'Resume';
        else
            pause_btn.Text = 'Pause';
            if isRunning
                run_simulation();
            end
        end
    end
    
    function reset_simulation()
        isRunning = false;
        isPaused = false;
        currentBeat = 0;
        all_t = [];
        all_V = [];
        all_Cai = [];
        all_APD = [];
        all_IKr_scale = [];
        all_ICaL_scale = [];
        all_INa_scale = [];
        all_IKs_scale = [];
        all_Irel_scale = [];
        
        STATES0 = initial_cond(ICfile);
        
        set(voltage_line, 'XData', nan, 'YData', nan);
        set(calcium_line, 'XData', nan, 'YData', nan);
        set(apd_line, 'XData', nan, 'YData', nan);
        
        title(ax1, 'Real-time Action Potential');
        title(ax2, 'Calcium Transient');
        title(ax3, 'APD Trends');
        
        start_btn.Text = 'Start Simulation';
        pause_btn.Text = 'Pause';
        
        % Reset sliders to default
        IKr_slider.Value = 1.0;
        ICaL_slider.Value = 1.0;
        INa_slider.Value = 1.0;
        IKs_slider.Value = 1.0;
        Irel_slider.Value = 1.0;
        update_labels();
        
        drawnow;
    end
    
    % Initialize labels
    update_labels();
    
    fprintf('Enhanced zebrafish heart simulation ready.\n');
    fprintf('Controls:\n');
    fprintf('  - IKr: Rapid delayed rectifier K+ current (main repolarization)\n');
    fprintf('  - ICaL: L-type Ca2+ current (plateau and calcium-induced calcium release)\n');
    fprintf('  - INa: Fast Na+ current (depolarization)\n');
    fprintf('  - IKs: Slow delayed rectifier K+ current (late repolarization)\n');
    fprintf('  - Irel: Calcium release from SR\n');
end