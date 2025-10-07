function V = initial_cond(ICfile)

% This function sets the initial conditions
%
% V is the main structure which contains the
% membrane potential, ioninc concentrations, and
% gate variables

if(~isempty(ICfile))
    load(ICfile,'STATES0');
    V = STATES0;
else
    V(1) = -80.5174;           % V
    V(2) = 0.0002;             % Cai      
    V(3) = 0.2;                % CaSR
    V(4) = 1.0;                % g  
    V(5) = 11.6;               % Nai
    V(6) = 109.0;              % Ki
    V(7) = 0.0;                % m
    V(8) = 0.75;               % h
    V(9) = 0.75;               % j   
    V(10) = 0.0;               % xr1
    V(11) = 0.1;               % xr2
    V(12) = 0.0;               % xs
    V(13) = 0.0;               % dL
    V(14) = 1.0;               % fL
    V(15) = 1.0;               % fca
    V(16) = 0.0026;            % dT
    V(17) = 0.7420;            % fT
end
