% This script simulates the change of rectifier potassium current (IKr),
% and its effect on AP's within single cardiac cells. Since IKr contributes 
% to the repolarization phase of the cardiac action potential, decreasing
% this value will increase the length of the AP.

function live_sim(BCL, nrepeat, protocol, ICfile)
% Simulates live APs with IKr scaling input and supports protocol switching.
% 
% Inputs:
%   BCL      - Basic cycle length in ms
%   nrepeat  - Number of stimulations
%   protocol - 0: steady-state (currently supported)
%   ICfile   - optional, initial condition MAT-file (use [] for default)

% Set default if not enough values input
    if nargin < 1, BCL = 500; end
    if nargin < 2, nrepeat = 10; end
    if nargin < 3, protocol = 0; end
    if nargin < 4, ICfile = []; end

    % Solver options
    options = odeset('RelTol', 1e-6, 'AbsTol', 1e-6, 'MaxStep', 1); %using same ode solver as main
    %CONSTANTS = mod_param();
    STATES0 = initial_cond(ICfile);
    IKr_scale = 1;

    % Time span for each beat
    tspan = [0 BCL];

    % For plotting
    figure;
    h_line = plot(nan, nan, 'b', 'LineWidth', 1.5);
    xlabel('Time (ms)');
    ylabel('Voltage (mV)');
    title('Live AP Simulation');
    grid on;
    xlim([0 BCL]);
    ylim([-100 50]);
    drawnow;

    all_t = [];
    all_V = [];

    % currently only have logic for protocol 0
    switch protocol
        case 0  % Steady state protocol
            for j = 1:nrepeat
                fprintf('Beat %d/%d\n', j, nrepeat);

                CONSTANTS = mod_param();
                CONSTANTS.GKr = CONSTANTS.GKr * IKr_scale;

                [t, STATES] = ode15s(@computerates, tspan, STATES0, options, CONSTANTS, 1, 1);
                STATES0 = STATES(end, :);

                all_t = [all_t; t + BCL*(j-1)];
                all_V = [all_V; STATES(:, 1)];

                % Plot only the current beat
                set(h_line, 'XData', t, 'YData', STATES(:, 1));
                title(sprintf('Live AP Beat %d - IKr scale %.2f', j, IKr_scale));
                drawnow;

                % Prompt user for new IKr scale
                prompt = sprintf('Current IKr scale = %.2f. Enter new IKr scale (or press Enter to keep): ', IKr_scale);
                user_input = input(prompt, 's');
                if ~isempty(user_input)
                    val = str2double(user_input);
                    if ~isnan(val) && val > 0
                        IKr_scale = val;
                    else
                        fprintf('Invalid input, keeping previous value %.2f\n', IKr_scale);
                    end
                end
            end

        otherwise
            error('Protocol %d is not yet implemented in live_sim_protocol.', protocol);
    end

    % Final plot
    figure;
    plot(all_t, all_V, 'k');
    xlabel('Time (ms)');
    ylabel('Voltage (mV)');
    title('Full AP Simulation');
    xlim([0 BCL * nrepeat]);
    ylim([-100 50]);
    grid on;

    % Save output
    save(sprintf('live_sim_protocol%d.mat', protocol), 'all_t', 'all_V');
    fprintf('Simulation finished and saved.\n');
end

