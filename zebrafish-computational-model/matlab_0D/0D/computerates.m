function dvdt = computerates(t,X,p,flag,flagODE)

% This function computes currents and concentrations

% Transform X vector in varaible names, easy to follow
V.V    = X(1);           % V
V.Cai  = X(2);           % Cai
V.CaSR = X(3);           % CaSR        
V.g    = X(4);           % g   
V.Nai  = X(5);           % Nai
V.Ki   = X(6);           % Ki
V.m    = X(7);           % m
V.h    = X(8);           % h
V.j    = X(9);           % j
V.xr1  = X(10);          % xr1       
V.xr2  = X(11);          % xr2
V.xs   = X(12);          % xs
V.dL   = X(13);          % dL
V.fL   = X(14);          % fL
V.fca  = X(15);          % fca
V.dT   = X(16);          % dT
V.fT   = X(17);          % fT

dvdt = zeros(17,1);

invRTF = 1.0/p.RTF;
EK = p.RTF*log(p.Ko./V.Ki);
ENa = p.RTF*log(p.Nao./V.Nai);
EKs = p.RTF*log((p.Ko + p.pKNa*p.Nao)./(V.Ki + p.pKNa*V.Nai));
ECa = 0.5*p.RTF*log(p.Cao./V.Cai);
atmp = V.V*invRTF;
rec_iNaK = 1./(1.0 + 0.1245*exp(-0.1*atmp) + 0.0353*exp(-atmp));

atmp1 = V.V - EK;
rec_iK1 = 1./(1 + exp((V.V + 87.0762)/13.5048)) + 0.02;
cur.IK1 = p.GK1*sqrt(p.Ko/4.85)*rec_iK1.*atmp1;                                % IK1

cur.IKr = p.GKr*sqrt(p.Ko/4.85)*V.xr1.*V.xr2.*atmp1;                           % IKr

atmp1 = V.V - ENa;
cur.INa = p.GNa*V.m.*V.m.*V.m.*V.h.*V.j.*atmp1;                                % INa
cur.IbNa = p.GbNa*atmp1;                                                       % IbNa

atmp1 = 2.0*(V.V)*invRTF;
if(abs(atmp1)<=1.0e-5)
  denICaL = exp(atmp1);
  ICaL = 2.0*p.GCaL*V.dL*V.fL*V.fca*p.F*(V.Cai*(1.0+atmp1)*exp(atmp1)-0.341*p.Cao);
else
  denICaL = exp(atmp1)-1.0;
  ICaL = 2.0*p.GCaL*V.dL*V.fL*V.fca*(atmp1*p.F)*(V.Cai*exp(atmp1)-0.341*p.Cao);
end
cur.ICaL = ICaL/denICaL;                                                       % ICaL

cur.ICaT = p.GCaT*V.dT.*V.fT.*(V.V - ECa);                                     % ICaT
cur.IKs = p.GKs*V.xs*(V.V - EKs);                                              % IKs

atmp1 = exp(p.gam*atmp);
atmp2 = exp((p.gam - 1.0)*atmp);
denINaCa1 = (p.KmNai^3 + p.Nao^3)*(p.KmCa + p.Cao)*(1.0 + p.ksat*atmp2);
cur.INaCa = p.kNaCa*(atmp1*V.Nai^3*p.Cao-atmp2*p.Nao^3*V.Cai*p.alf)/denINaCa1; % INaCa

denINaK = (p.Ko+p.KmK)*(V.Nai+p.KmNa);
cur.INaK = p.PNaK*p.Ko*V.Nai.*rec_iNaK./denINaK;                               % INaK

cur.IpCa = p.GpCa*V.Cai./(p.KpCa + V.Cai);                                     % IpCa
cur.IbCa = p.GbCa*(V.V-ECa);                                                   % IbCa

% Calculate the stimulus current, Istim
amp = -52.0;
duration = 1.0;

if ((t <= duration) && (flag > 0))
    Istim = amp;
else
    Istim = 0.0;
end

% Calculating total current
IK = cur.IKr + cur.IKs + cur.IK1;
INa = cur.INa + cur.IbNa + cur.INaK + cur.INaCa;
ICa = cur.ICaL + cur.IbCa + cur.IpCa + cur.ICaT;
dvdt(1) = -(IK + INa + ICa + Istim);

% Updating Concentrations

% Function to update Ion concentrations

invVcF  = 1.0/(p.Vc*p.F);
invVcF2 = 0.5*invVcF;

coefIrel = (p.arel*V.CaSR.*V.CaSR./(p.brel*p.brel+V.CaSR.*V.CaSR) + p.crel);                               
cur.Irel = p.gIrel*coefIrel.*V.dL.*V.g;
cur.Iup = p.Vmxu./(1.0 + ((p.Kup*p.Kup)./(V.Cai.*V.Cai)));
cur.Ileak = p.Vleak*(V.CaSR - V.Cai);

% Cai
coef = 1.0/(1.0 + (p.Bufc*p.Kbufc)/(V.Cai + p.Kbufc)^2);
dvdt(2) = p.coefCai*coef*((-(cur.IbCa + cur.IpCa - 2.0*cur.INaCa + cur.ICaL + cur.ICaT)*invVcF2*p.Cap*p.Ac) - ...
     (cur.Iup - cur.Irel - cur.Ileak));

% CaSR
coef = 1.0/(1.0+(p.Bufsr*p.Kbufsr)/(V.CaSR+p.Kbufsr)^2);
dvdt(3) = coef*p.Vc/p.Vsr*(cur.Iup - cur.Irel - cur.Ileak);

totINa = cur.INa + cur.IbNa + 3.0*(cur.INaK + cur.INaCa);
dvdt(5) = -totINa*invVcF*p.Cap*p.Ac;

totIK = Istim + cur.IK1 + cur.IKr + cur.IKs - 2.0*cur.INaK;
dvdt(6) = -totIK*invVcF*p.Cap*p.Ac;

% Updating Gates

% g Gate Calcium transient

if (V.Cai < p.gCai)
    gINF = 1./(1.0 + (V.Cai/p.gCai).^6);
else
    gINF = 1./(1.0 + (V.Cai/p.gCai).^16);
end
dg = (gINF-V.g)./p.taug;

% Fast Na+ current

AM = 1./(1.0 + exp(0.2*(-80.0 - V.V)));
BM = 1.95./(1.0 + exp((V.V + 45.0)/6.0)) + 0.1./(1.0 + exp(0.005*(V.V - 60.0)));
TAUM = AM.*BM.*0.9395;
MINF = 1./(1.0 + exp((-58.5 - V.V)/8.025));

if (V.V >= -40.0)
    AH1 = 0.0;
    BH1 = 0.77./(0.13*(1.0 + exp(-(V.V + 10.66)/11.1)));
    TAUH = 1./(AH1 + BH1);
else 
    AH2 = 0.057*exp(-(V.V + 80.0)/6.8);
    BH2 = 2.7*exp(0.079*V.V) + 3.1e5*exp(0.3485*V.V);
    TAUH = 1./(AH2 + BH2);
end

TAUH = TAUH*3.5;
HINF = 1./(1.0 + exp((V.V + 70.5727)/7.5));

if (V.V >= -31.0)
    AJ1 = 0.0;
    BJ1 = 0.6*exp(0.057*(V.V - 9.0))./(1.0 + exp(-0.1*(V.V - 9.0 + 32.0)));
    TAUJ = 1./(AJ1 + BJ1);
else
    c1 = -2.5428e+04*exp(0.2444*(V.V - 9.0)) - 6.948e-6*exp(-0.04391*(V.V - 9.0));
    AJ2 = c1.*(V.V - 9 + 37.78)./(1. + exp(0.311*(V.V - 9 + 79.23)));    
    BJ2 = 0.02424*exp(-0.01052*(V.V - 9.0))./(1. + exp(-0.1378*(V.V - 9.0 + 40.14)));
    TAUJ = 1./(AJ2 + BJ2);
end

TAUJ = TAUJ*0.8;
JINF = HINF;

% Rapid delay rectifier IKr

Xr1INF = 1./(1.0 + exp((8.87 - V.V)/6.56));
axr1 = 690./(1.0 + exp(0.1*(-42.0 - V.V)));
bxr1 = 6./(1.0 + exp((V.V + 49.0)/11.5)) + 0.09;							   
TAUXr1 = (axr1.*bxr1)*1.0798;

Xr2INF = 1./(1.0 + exp((V.V + 85.0664)/22.82));
axr2 = 65.*exp(-(V.V + 85.0).*(V.V + 85.0)/700);
bxr2 = 5.0./(1.0 + exp((V.V - 5.0)/15.0)) + 3.0;
TAUXr2 = (axr2 + bxr2).*0.9443;

% Slow delay rectifier IKs

XsINF = 1./(1.0 + exp((4.9182 - V.V)/30.0));
Axs = (670./(1.0 + exp((-35.0 - V.V)/6.0)));
Bxs = (1./(1.0 + exp((V.V - 5.0)/21.0)));
TAUXs = Axs.*Bxs;

% L-Type Ca2+ current ICaL

DLINF = 1./(1.0 + exp((-25.0011 - V.V)/5.478));
Ad = 2.8./(1.0 + exp((-20.0 - V.V)/13.0)) + 2.93;
Bd = 1.4./(1.0 + exp(0.2*(V.V + 5.0)));
Cd = 3.5./(1.0 + exp(0.1*(-5.0 - V.V)));
TAUDL = (Ad.*Bd + Cd)*0.756;

FLINF = 1./(1.0 + exp((V.V + 35.8779)/4.0));
Af = (310.5*exp(-(V.V + 38).^2./120));
Bf = (80./(1 + exp((8.0 - V.V)./10)));
Cf = (120./(1 + exp((35.0 + V.V)./10))) + 20;   
TAUFL = (Af + Bf + Cf);

afca = 1./(1 + (V.Cai./0.000325).^8);
bfca = 0.1./(1 + exp((V.Cai-0.0005)./0.0001));
cfca = 0.2./(1 + exp((V.Cai-0.00075)./0.0008));
FCaINF = (afca + bfca + cfca + 0.23)/1.45;
TAUFCa = 2.0;
dfCa = (FCaINF - V.fca)./TAUFCa;

% Gates ICaT

DTINF = 1.0./(1.0 + exp(-(V.V + 30.0)/8.5));
TAUDT = 1.0./(1.068*exp((V.V + 26.3)/30.0) + 1.068*exp(-(V.V + 26.3)/30.0));
FTINF = 1.0./(1.0 + exp((V.V + 71.0)/9.0));
TAUFT = 1000.0./(15.3*exp(-(V.V + 71.7)/83.3) + 15.0*exp((V.V + 71.7)/15.38));

% g Calcium transient

if((V.V >- 60) && (V.g <= gINF))
  dvdt(4) = 0.0;
else
  dvdt(4) = dg;
end

dvdt(7) = (MINF - V.m)/TAUM;
dvdt(8) = (HINF - V.h)/TAUH;
dvdt(9) = (JINF - V.j)/TAUJ;
dvdt(10) = (Xr1INF - V.xr1)/TAUXr1;
dvdt(11) = (Xr2INF - V.xr2)/TAUXr2;
dvdt(12) = (XsINF - V.xs)/TAUXs;
dvdt(13) = (DLINF - V.dL)/TAUDL;
dvdt(14) = (FLINF - V.fL)/TAUFL;

% V.fca 

if((V.V >- 60) && (V.fca <= FCaINF))
  dvdt(15) = 0.0;
else
  dvdt(15) = dfCa;
end

dvdt(16) = (DTINF-V.dT)/TAUDT;
dvdt(17) = (FTINF-V.fT)/TAUFT;

if(flagODE == 0)
  dvdt = [cur.INa cur.ICaL cur.ICaT cur.IpCa cur.INaK cur.INaCa ...
          cur.IKr cur.IKs cur.IK1 cur.IbNa cur.IbCa cur.Irel cur.Ileak cur.Iup]';
end
end