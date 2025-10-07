# Instructions for running the computational model of the Zebrafish heart in MATLAB
Working instructions for both 0D and 1D.

## Required Files
- `main.m` - Main simulation controller
- `initial_cond.m` - Sets initial conditions
- `mod_param.m` - Defines model parameters
- `computerates.m` - Computes derivatives and currents, contains all ODE's pertaining to model
- `APDcalc.m` - Calculates action potential duration
- `CaTDcalc.m` - Calculates calcium transient duration
- `savedata.m` - Saves simulation results

## Navigate to the Working Directory

In the **MATLAB** command window, run:

```matlab
cd 'path_to/Zebrafish-main/matlab_0D/0D'
```

## Protocol 0 — Steady-State Conditioning
Plots a normal, consistent AP. Specifically, it paces at a constant BCL until the cell reaches equilibrium.

To run, find the main.m script and run the following in the command window:

```matlab
 % change at user discretion
BCL = 1000;
nrepeat = 10;  
protocol = 0; % protocol must be 0 for steady-state conditing
BCLseq = []; % empty array for protocol 0
ICfile = ''; 

main(BCL, nrepeat, protocol, BCLseq, ICfile)
```

### Output
The expected output should be the following:
*Note:* the end value (ex, 1000) is detemrined by the BCL value input into main().

- `IC_SS_1000.mat` – preconditioned steady-state  
- `solution5AP_1000.mat` – 5 APs post-conditioning  
- `solution3sec_1000.mat` – 3 seconds with no pacing  
- `SS_1000.mat` – time series from conditioning

### Plot Result
To see the results in **MATLAB** use:

```matlab
plot_SS(1000);
```

*ISPEETA METHOD GOES HERE FOR ALL PLOTS IN ONE?*

## Protocol 1 - S1S2 Restitution Protocol
Delivers premature heart beat measuring AP change (?) (ie. how well it recovers after a premature beat).

```matlab
% change at user discretion
BCL = 800;          % S1 pacing interval
nrepeat = 10;       % Number of S1 beats before each S2
protocol = 1;       % protocol must be 1 for S1S2 restitution
BCLseq = [200, 300, 400, 500, 600, 700, 800]; % S2 intervals to test
ICfile = ''; 

main(BCL, nrepeat, protocol, BCLseq, ICfile)
```
### Output:
The expected output should be the following:
*Note* this keeps going depnding on what set BClseq you choose

- `S1S2_rest_800.mat` - Summary restitution data table
- `sol_S1S2_800_200.mat` - Individual S2 beat solution (S2=200ms)
- `sol_S1S2_800_300.mat` - Individual S2 beat solution (S2=300ms)
- `sol_S1S2_800_400.mat` - Individual S2 beat solution (S2=400ms)
- `sol_S1S2_800_500.mat` - Individual S2 beat solution (S2=500ms)
- `sol_S1S2_800_600.mat` - Individual S2 beat solution (S2=600ms)
- `sol_S1S2_800_700.mat` - Individual S2 beat solution (S2=700ms)
- `sol_S1S2_800_800.mat` - Individual S2 beat solution (S2=800ms)

### Plot Result
To see the results in **MATLAB** use:

```matlab
control = 0; % use 0 for control data
plot_currS1S2(1000, BCLseq, 1); % Plot change in dynamic AP's and currents for different BCL vals
plot_RestS1S2(1000, BCLseq, control); % Plot dynamic resitution curves
```

## Protocol 2 - Dynamic Restitution Protocol
Measures how steady-state APD changes while changing pace rate, allowing the cell to adapt.

```matlab
 % change at user discretion
BCL = 1000;
nrepeat = 10;  
protocol = 2; % protocol must be 2 for Dynamic resitution protocol
BCLseq = [1000, 800, 600, 400, 300]; % protocol calls for an array of differing BCL values.
ICfile = ''; 

main(BCL, nrepeat, protocol, BCLseq, ICfile)
```
### Output
The expected output should be the following:
*Note:* the end value (ex, 300, 400, 600, 800, 1000) is detemrined by the BCL value input into main().

- `sol_Dyn_300.mat` 
- `sol_Dyn_400.mat` 
- `sol_Dyn_600.mat` 
- `sol_Dyn_800.mat` 
- `sol_Dyn_1000.mat` 

### Plot Result
To see the results in **MATLAB** use:

```matlab
%dx = 1; % spatial position in tissue (1D)
control = 0; % use 0 for control data
plot_currDyn(1000, BCLseq, 1); % Plot change in dynamic AP's and currents for different BCL vals
plot_RestDyn(1000, BCLseq, control); % Plot dynamic resitution curves
%plotAPDyn(BCL,BCLseq,dx,Fsize); % use for multicellular analysis 
```