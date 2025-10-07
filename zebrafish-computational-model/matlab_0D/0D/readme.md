# Instructions for running the computational model of the Zebrafish heart in MATLAB

## Navigate to the Working Directory

In the **MATLAB** command window, run:

```matlab
cd 'path_to/Zebrafish-main/matlab_0D/0D'
```

## Protocol 0 — Steady-State Conditioning
Find the main.m script and run the following in the command window:

```matlab
% Change these variables at user discretion
BCL = 1000; 
nrepeat = 10;
protocol = 0;
BCLseq = [];
ICfile = [];  

main(BCL, nrepeat, protocol, BCLseq, ICfile)
```

## Output
The expected output should be the following:

- `IC_SS_1000.mat` – preconditioned steady-state  
- `solution5AP_1000.mat` – 5 APs post-conditioning  
- `solution3sec_1000.mat` – 3 seconds with no pacing  
- `SS_1000.mat` – time series from conditioning

## Plot Result
To see the results in **MATLAB** use:

```matlab
plot_SS(1000)
```