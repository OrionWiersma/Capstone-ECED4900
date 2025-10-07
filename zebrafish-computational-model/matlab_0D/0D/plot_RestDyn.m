function plot_RestDyn(BCL0,BCL_seq,control)

% File .mat with restitution data order as follow:
%
% Col  1: BCL
% Col  2: APD90 n-1
% Col  3: APD90 n
% Col  4: APD20 n
% Col  5: APD50 n
% Col  6: APD80 n
% Col  7: RMP n
% Col  8: APA n
% Col  9: dVdtmax n
% Col 10: DI
% Col 11: CaT20
% Col 12: CaT50
% Col 13: CaT80

% Restitution data
sname = sprintf('Dyn_rest_%d.mat',BCL0);
load(sname,'Dyn');

fp1 = figure(1);
sgtitle('Dynamic Restitution Curve');

% APD90
fp1sp1 = subplot(2,3,1); hold;
minDI = 50;
DImod = Dyn(:,10);
plot(DImod(DImod>=minDI),Dyn(DImod>=minDI,3),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlim([0 700]);
xlabel(fp1sp1,'DI (ms)');
ylabel(fp1sp1,'APD_{90} (ms)');
xlim(fp1sp1,[50 700]);
ylim(fp1sp1,[100 200]);
grid(fp1sp1,'on');

% APD80
fp1sp2 = subplot(2,3,2); hold;
plot(DImod(DImod>=minDI),Dyn(DImod>=minDI,6),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlim([0 700]);
xlabel(fp1sp2,'DI (ms)');
ylabel(fp1sp2,'APD_{80} (ms)');
xlim(fp1sp2,[50 700]);
ylim(fp1sp2,[100 200]);
grid(fp1sp2,'on');

% APD50
fp1sp3 = subplot(2,3,3); hold;
minDI = 50;
plot(DImod(DImod>=minDI),Dyn(DImod>=minDI,5),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlim([0 700]);
xlabel(fp1sp3,'DI (ms)');
ylabel(fp1sp3,'APD_{50} (ms)');
xlim(fp1sp3,[50 700]);
ylim(fp1sp3,[80 180]);
grid(fp1sp3,'on');

% RMP
fp1sp4 = subplot(2,3,4); hold;
plot(DImod(DImod>=minDI),Dyn(DImod>=minDI,7),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlim([0 700]);
ylim([-90 -70]);
xlabel('DI (ms)');
ylabel('RMP (mV)');
xlim(fp1sp4,[50 700]);
ylim(fp1sp4,[-85 -70]);
grid(fp1sp4,'on');

% APA
fp1sp5 = subplot(2,3,5); hold;
plot(DImod(DImod>=minDI),Dyn(DImod>=minDI,8),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlim([0 700]);
xlabel(fp1sp5,'DI (ms)');
ylabel(fp1sp5,'APA (mV)');
xlim(fp1sp5,[50 700]);
ylim(fp1sp5,[80 120]);
grid(fp1sp5,'on');

% dVdtmax
fp1sp6 = subplot(2,3,6); hold;
plot(DImod(DImod>=minDI),Dyn(DImod>=minDI,9),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlim([0 700]);
xlabel(fp1sp6,'DI (ms)');
ylabel(fp1sp6,'upstrooke (V/s)');
xlim(fp1sp6,[50 700]);
ylim(fp1sp6,[0 50]);
grid(fp1sp6,'on');

% Plotting Calcium
fp3 = figure(3);
sgtitle('Calcium Dynamic Restitution Curve');

% CaT80
fp3sp1 = subplot(2,3,1); hold;
plot(Dyn(1:end-2,1),Dyn(1:end-2,13),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlabel(fp3sp1,'BCL (ms)');
ylabel(fp3sp1,'CaTD_{80} (ms)');
xlim(fp3sp1,[200 900]);
ylim(fp3sp1,[100 400]);
grid(fp3sp1,'on');

% CaT50
fp3sp2 = subplot(2,3,2); hold;
plot(Dyn(1:end-2,1),Dyn(1:end-2,12),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlabel(fp3sp2,'BCL (ms)');
ylabel(fp3sp2,'CaTD_{50} (ms)');
xlim(fp3sp2,[200 900]);
ylim(fp3sp2,[50 300]);
grid(fp3sp2,'on');

% CaT20
fp3sp3 = subplot(2,3,3); hold;
plot(Dyn(1:end-2,1),Dyn(1:end-2,11),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlabel(fp3sp3,'BCL (ms)');
ylabel(fp3sp3,'CaTD_{20} (ms)');
xlim(fp3sp3,[200 900]);
ylim(fp3sp3,[50 250]);
grid(fp3sp3,'on');

% Plotting control curves
if (control == 1)
%     sname = sprintf('Dyn_rest_%d_control.mat',BCL0);
%     load(sname,'Dyn');
%     
%     % APD90
%     DImod = Dyn(:,10);
%     plot(fp1sp1,DImod(DImod>=minDI),Dyn(DImod>=minDI,3),'r','LineWidth',2,'DisplayName','control'); 
%     
%     % APD80
%     plot(fp1sp2,DImod(DImod>=minDI),Dyn(DImod>=minDI,6),'r','LineWidth',2,'DisplayName','control');
%     
%     % APD50
%     plot(fp1sp3,DImod(DImod>=minDI),Dyn(DImod>=minDI,5),'r','LineWidth',2,'DisplayName','control');
%     
%     % RMP
%     plot(fp1sp4,DImod(DImod>=minDI),Dyn(DImod>=minDI,7),'r','LineWidth',2,'DisplayName','control');
%     
%     % APA
%     plot(fp1sp5,DImod(DImod>=minDI),Dyn(DImod>=minDI,8),'r','LineWidth',2,'DisplayName','control');
%     
%     % dVdtmax
%     plot(fp1sp6,DImod(DImod>=minDI),Dyn(DImod>=minDI,9),'r','LineWidth',2,'DisplayName','control');
%     
%     % APD20
%     plot(axfp2,DImod(DImod>=minDI),Dyn(DImod>=minDI,4),'r','LineWidth',2,'DisplayName','control');
%     
%     % Cai
%     plot(fp3sp1,Dyn(:,1),Dyn(:,13),'Color','r','LineWidth',2,'DisplayName','control');
%     plot(fp3sp2,Dyn(:,1),Dyn(:,12),'Color','r','LineWidth',2,'DisplayName','control');
%     plot(fp3sp3,Dyn(:,1),Dyn(:,11),'Color','r','LineWidth',2,'DisplayName','control');  

end

% Saving figures

% fp1.WindowState = 'maximized';
% fp3.WindowState = 'maximized';
% 
% legend(fp1sp1,'Location','best');
% legend(axfp2,'Location','best');
% legend(fp3sp1,'Location','best');
% 
% sname1 = sprintf('RC_Dyn_%d',BCL0);
% print(fp1,sname1, '-dpng', '-r300');
% sname1 = sprintf('RC_Dyn_%d.fig',BCL0);
% savefig(fp1,sname1);
% 
% sname1 = sprintf('APD20_Dyn_%d',BCL0);
% print(fp2,sname1, '-dpng', '-r300');
% 
% sname1 = sprintf('RC_Ca_Dyn_%d',BCL0);
% print(fp3,sname1, '-dpng', '-r300');
% sname1 = sprintf('RC_Ca_Dyn_%d.fig',BCL0);
% savefig(fp3,sname1);
% 
% fp1.WindowState = 'normal';
% fp3.WindowState = 'normal';

end