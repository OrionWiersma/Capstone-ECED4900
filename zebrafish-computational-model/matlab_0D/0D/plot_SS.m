function plot_SS(BCL,control)

% Function to plots SS resutls

sname = sprintf('solution5AP_%d.mat',BCL);
load(sname);
t1 = t(t>=4*BCL)-4*BCL;
[APD,APA,Vmax,dVdtmax,t0,RMP,tpeak,flag] = APDcalc(t1,V.V(t>=4*BCL)',[20 50 80 90]);
AP_features = [RMP;APA;APD(1);APD(2);APD(3);APD(4);dVdtmax;Vmax;tpeak; APD(4)-APD(2)];
sname1 = sprintf('SS_AP_%d.mat',BCL);
save(sname1,'AP_features');
sname2 = sprintf('AP_features_%d.mat',BCL);
save(sname2,'AP_features');

Cainorm = V.Cai(t>=4*BCL);
Cainorm = Cainorm./(max(Cainorm));
tCa = t(t>=4*BCL) - t0;
[dmax,Ica] = max(diff(Cainorm)./diff(tCa));
[CaTD,tpeak_Ca] = CaTDcalc(tCa-tCa(Ica),Cainorm,[20 50 80]);
CaT_features = [CaTD(1);CaTD(2);CaTD(3);tpeak_Ca;];
sname2 = sprintf('CaT_features_%d.mat',BCL);
save(sname2,'CaT_features');

% Plot AP
fp1 = figure(1);
axfp1 = axes('Parent',fp1);
hold(axfp1,'on');
plot(t1,V.V(t>=4*BCL),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlabel(axfp1,'time (ms)');
ylabel(axfp1,'Vm (mV)');
xlim(axfp1,[-10 300]);
grid(axfp1,'on');
title('Action Potential');

% Plot CaT
Ca_norm = V.Cai(t>=4*BCL);
minCa = min(Ca_norm);
maxCa = max(Ca_norm);
Ca_norm = (Ca_norm - minCa)/(maxCa - minCa);
fp2 = figure(2);
axfp2 = axes('Parent',fp2);
hold(axfp2,'on');
plot(t1,Ca_norm,'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlabel(axfp2,'time (ms)');
ylabel(axfp2,'[Ca]_i (-)');
xlim(axfp2,[0 500]);
grid(axfp2,'on');
title('Calcium Transient');

% Concentrations
sname = sprintf('SS_%d.mat',BCL);
load(sname);
fp3 = figure(3);
fp3sp1 = subplot(1,2,1);
plot(tsave/1000,STsave(:,5),'Color',[0.07,0.62,1.00],'LineWidth',1);
xlabel(fp3sp1,'time (s)');
ylabel(fp3sp1,'[Na^+]_i (mM)');
grid(fp3sp1,'on');
fp3sp2 = subplot(1,2,2);
plot(tsave/1000,STsave(:,6),'Color',[0.07,0.62,1.00],'LineWidth',1);
xlabel(fp3sp2,'time (s)');
ylabel(fp3sp2,'[K^+]_i (mM)');
grid(fp3sp2,'on');

% Currents
fp4 = figure(4);   
axfp4 = axes('Parent',fp4);
hold(axfp4,'on');
plot(t1,cur.IKs(t>=4*BCL),'LineWidth',2,'DisplayName','IKs');
plot(t1,cur.IKr(t>=4*BCL),'LineWidth',2,'DisplayName','IKr');
plot(t1,cur.IK1(t>=4*BCL),'LineWidth',2,'DisplayName','IK1');
plot(t1,cur.ICaL(t>=4*BCL),'LineWidth',2,'DisplayName','ICaL');
xlabel(axfp4,'time (ms)');
ylabel(axfp4,'current (pA/pF)');
grid(axfp4,'on');
legend(axfp4,'Location','best');
hold(axfp4,'off');

% Gates
fp5 = figure(5);   
fp5sp1 = subplot(3,2,1);
plot(t1,V.dL(t>=4*BCL),'LineWidth',2);
xlabel(fp5sp1,'time (ms)');
ylabel(fp5sp1,'d gate');
grid(fp5sp1,'on');

fp5sp2 = subplot(3,2,2);
plot(t1,V.fL(t>=4*BCL),'LineWidth',2);
xlabel(fp5sp2,'time (ms)');
ylabel(fp5sp2,'f gate');
grid(fp5sp2,'on');

fp5sp3 = subplot(3,2,3);
plot(t1,V.fca(t>=4*BCL),'LineWidth',2);
xlabel(fp5sp3,'time (ms)');
ylabel(fp5sp3,'fcass gate');
grid(fp5sp3,'on');

fp5sp4 = subplot(3,2,4);
plot(t1,V.Cai(t>=4*BCL),'LineWidth',2);
xlabel(fp5sp4,'time (ms)');
ylabel(fp5sp4,'[Ca]_i');
grid(fp5sp4,'on');

fp5sp5 = subplot(3,2,5);
plot(t1,V.V(t>=4*BCL),'LineWidth',2);
xlabel(fp5sp5,'time (ms)');
ylabel(fp5sp5,'V (mV)');
grid(fp5sp5,'on');

fp5sp6 = subplot(3,2,6);
plot(t1,cur.ICaL(t>=4*BCL),'LineWidth',2);
xlabel(fp5sp6,'time (ms)');
ylabel(fp5sp6,'ICaL');
grid(fp5sp6,'on');

% Plot single currents
figure(6);
plot(t1,cur.INa(t>=4*BCL),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','I_{Na}');
xlabel('time (ms)');
ylabel('I_{Na} (pA/pF)');
xlim([-10 500]);
grid on;

figure(7);
plot(t1,cur.ICaT(t>=4*BCL),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','I_{CaT}');
xlabel('time (ms)');
ylabel('I_{CaT} (pA/pF)');
xlim([-10 500]);
grid on;

figure(8);
plot(t1,cur.ICaL(t>=4*BCL),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','I_{CaL}');
xlabel('time (ms)');
ylabel('I_{CaL} (pA/pF)');
xlim([-10 500]);
grid on;

figure(9);
plot(t1,cur.IKs(t>=4*BCL),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','I_{Ks}');
xlabel('time (ms)');
ylabel('I_{Ks} (pA/pF)');
xlim([-10 500]);
grid on;

figure(10);
plot(t1,cur.IKr(t>=4*BCL),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','I_{Kr}');
xlabel('time (ms)');
ylabel('I_{Kr} (pA/pF)');
xlim([-10 500]);
grid on;

figure(11);
plot(t1,cur.IK1(t>=4*BCL),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','I_{K1}');
xlabel('time (ms)');
ylabel('I_{K1} (pA/pF)');
xlim([-10 500]);
grid on;

fprintf('AP features       Model\n');
fprintf('RMP     (mV)    = %7.3f\n',RMP);
fprintf('APA     (mV)    = %7.3f\n',APA);
fprintf('APD20   (ms)    = %7.3f\n',APD(1));
fprintf('APD50   (ms)    = %7.3f\n',APD(2));
fprintf('APD80   (ms)    = %7.3f\n',APD(3));
fprintf('APD90   (ms)    = %7.3f\n',APD(4));
fprintf('dVdt (mV/ms)    = %7.3f\n',dVdtmax);
fprintf('Vmax    (mV)    = %7.3f\n',Vmax);
fprintf('triang  (ms)    = %7.3f\n',APD(4)-APD(2));
fprintf('Ca features       Model\n');
fprintf('CaTD20   (ms)   = %7.3f\n',CaTD(1));
fprintf('CaTD50   (ms)   = %7.3f\n',CaTD(2));
fprintf('CaTD80   (ms)   = %7.3f\n',CaTD(3));

legend(axfp1,'Location','best');
hold(axfp1,'off');
legend(axfp2,'Location','best');
hold(axfp2,'off');

end