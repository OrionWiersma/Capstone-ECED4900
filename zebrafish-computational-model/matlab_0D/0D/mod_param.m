function p = mod_param()

% This function returns the model parameters

% Constants
p.R = 8314.472;        % J/(kmol*K)
p.T = 301.0;           % K
p.F = 96485.3415;      % C/mol
p.RTF = p.R*p.T/p.F;   % kJ/C

% Capacitance
p.Cap = 1.0;           % microF/cm^2

% Intracellular Volume and Capacitive Area
p.Vc = 390.0e-9;       % micro_L
p.Ac = 3000.0e-8;      % cm^2
p.Vsr = 0.05*p.Vc;     % micro_L

% External concentrations
p.Ko = 4.85;           % mM
p.Nao = 142.0;         % mM
p.Cao = 1.8;           % mM

% Parameters for IKr
p.GKr = 0.7776;        % mS/microF
%p.GKr = 0.1;        % mS/microF

% Parameters for IKs
p.pKNa = 0.03; 
p.GKs = 0.0648;        % mS/microF

% Parameters for IK1
p.GK1 = 0.3490;        % mS/microF

% Parameters for INa
p.GNa = 1.0;           % mS/microF

% Parameter for IbNa
p.GbNa = 3.8137e-4;    % mS/microF

% Parameters for INaK
p.KmK = 1.0;           % mM
p.KmNa = 40.0;         % mM
p.PNaK = 4.086;        % microA/microF

% Parameters for ICaL
p.GCaL = 2.3843e-4;    % cm^3/(s*microF)

% Parameter for ICaT
p.GCaT = 0.066;        % mS/microF

% Parameter for IbCa
p.GbCa = 6.6387e-4;    % mS/microF

% Parameter for INaCa
p.kNaCa = 1000.0;      % microA/microF
p.KmNai = 87.5;        % mM
p.KmCa = 1.38;         % mM
p.ksat = 0.1;
p.gam = 0.35;   
p.alf = 2.5;        

% Parameter for IpCa
p.GpCa = 0.0456;       % mS/microF
p.KpCa = 5.0e-4;       % mM

% Intracellular calcium flux dynamics
p.Vmxu = 0.000425;     % mM/ms
p.arel = 0.0132;       % mM/ms
p.brel = 0.25;         % mM
p.crel = 0.0066;       % mM/ms
p.Kup = 0.00025;       % mM
p.Vleak = 8.0e-5;      % 1/ms			  
p.taug = 3.0;          % ms
p.gIrel = 1.0;         % Irel scaling factor
p.gCai = 0.00035;      % dimensionless

% Calcium buffering dynamics
p.Bufc = 0.19;         % mM
p.Kbufc = 0.001;       % mM
p.Bufsr = 10.0;        % mM
p.Kbufsr = 0.3;        % mM
p.coefCai = 1.0;       % dimensionless

end