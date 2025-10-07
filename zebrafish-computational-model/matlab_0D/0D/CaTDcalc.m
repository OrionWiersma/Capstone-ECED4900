function [APD,tpeak] = CaTDcalc(t,V,pREP)

% Calculates the AP duration at pREP% repolarization
%
% Input: 
% t:    time
% V:    Transmembrane potential
% pREP: Percentage of repolarization. pREP can be a vector in case we would
%       like to calculate different % of repolarization

nAPD = length(pREP);
APD = zeros(1,nAPD);
[m,I0] = max(diff(V));
dVdtmax = max(diff(V)./diff(t));
t0 = t(I0); % Time of max upstroke
[Vmax,Imax] = max(V);
[Vmin,Imin] = min(V);
APA = Vmax - Vmin;
RMP = V(end);
tpeak = t(Imax)-t(1);

for i = 1:nAPD    
    V1 = Vmax - (Vmax-V(1))*pREP(i)/100;
    t2 = t(Imax:end);
    V2 = V(Imax:end);
    dV = V2 - V1;
    I2 = find(dV <= 0);
    if (~isempty(I2))
        id2 = I2(1); 
        id1 = I2(1) - 1;
        if (id1 ~= 0)
            tAPD = t2(id1) + (t2(id2) - t2(id1))/(V2(id2) - V2(id1))*(V1 - V2(id1));  % Time of APD
            APD(i) = tAPD - t0;
        else
            APD(i) = 0;
            APA = 0;
            Vmax = 0;
            dVdtmax = 0;
            RMP = 0;
            flag = -1;
        end
    else
        APD(i) = 0;
        APA = 0;
        Vmax = 0;
        dVdtmax = 0;
        RMP = 0;
        flag = -1;
    end
end

end