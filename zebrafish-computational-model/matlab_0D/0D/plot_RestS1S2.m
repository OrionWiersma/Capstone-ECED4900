function plot_RestS1S2(BCL0,BCL_seq,control)

% File .mat with restitution data order as follow:
%
% Col  1: S2
% Col  2: APD90 S1
% Col  3: APD90 S2
% Col  4: APD20 S2
% Col  5: APD50 S2
% Col  6: APD80 S2
% Col  7: RMP S2
% Col  8: APA S2
% Col  9: dVdtmax S2
% Col 10: CaT20
% Col 11: CaT50
% Col 12: CaT80

% Restitution data
sname = sprintf('S1S2_rest_%d.mat',BCL0);
load(sname,'S1S2');

fp1 = figure(1);
sgtitle('S1S2 Restitution Curve');

% APD90
sp1 = subplot(2,3,1);
hold(sp1,'on');
minDI = 80;
DI = S1S2(:,1)-S1S2(:,2);
plot(DI(DI>=minDI),S1S2(DI>=minDI,3),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlabel(sp1,'DI (ms)');
ylabel(sp1,'APD_{90} (ms)');
xlim(sp1,[50 300]);
ylim(sp1,[100 200]);
grid (sp1,'on');

% APD80
sp2 = subplot(2,3,2);
hold(sp2,'on');
minDI = 80;
DI = S1S2(:,1)-S1S2(:,2);
plot(DI(DI>=minDI),S1S2(DI>=minDI,6),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlabel(sp2,'DI (ms)');
ylabel(sp2,'APD_{80} (ms)');
xlim(sp2,[50 300]);
ylim(sp2,[100 200]);
grid (sp2,'on');

% APD50
sp3 = subplot(2,3,3);
hold(sp3,'on');
minDI = 80;
DI = S1S2(:,1)-S1S2(:,2);
plot(DI(DI>=minDI),S1S2(DI>=minDI,5),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlabel(sp3,'DI (ms)');
ylabel(sp3,'APD_{50} (ms)');
xlim(sp3,[50 300]);
ylim(sp3,[80 180]);
grid (sp3,'on');

% RMP
sp4 = subplot(2,3,4);
hold(sp4,'on');
minDI = 80;
DI = S1S2(:,1)-S1S2(:,2);
plot(DI(DI>=minDI),S1S2(DI>=minDI,7),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
ylim([-90 -70]);
xlabel(sp4,'DI (ms)');
ylabel(sp4,'RMP (mV)');
xlim(sp4,[50 300]);
ylim(sp4,[-85 -70]);
grid (sp4,'on');

% APA
sp5 = subplot(2,3,5);
hold(sp5,'on');
minDI = 80;
DI = S1S2(:,1)-S1S2(:,2);
plot(DI(DI>=minDI),S1S2(DI>=minDI,8),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlabel(sp5,'DI (ms)');
ylabel(sp5,'APA (mV)');
xlim(sp5,[50 300]);
ylim(sp5,[80 120]);
grid (sp5,'on');

% dVdtmax
sp6 = subplot(2,3,6);
hold(sp6,'on');
minDI = 80;
DI = S1S2(:,1)-S1S2(:,2);
plot(DI(DI>=minDI),S1S2(DI>=minDI,9),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlabel(sp6,'DI (ms)');
ylabel(sp6,'upstrooke (V/s)');
xlim(sp6,[50 300]);
ylim(sp6,[0 50]);
grid (sp6,'on');

% Plotting Calcium

fp3 = figure(3);
sgtitle('Calcium S1S2 Restitution Curve');

% CaTD80
spCa1 = subplot(2,3,1); 
hold(spCa1,'on');
plot(S1S2(1:end-1,1),S1S2(1:end-1,12),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlabel(spCa1,'BCL (ms)');
ylabel(spCa1,'CaTD_{80} (ms)');
xlim(spCa1,[200 500]);
ylim(spCa1,[100 400]);
grid (spCa1,'on');

% CaTD50
spCa2 = subplot(2,3,2); 
hold(spCa2,'on');
plot(S1S2(1:end-1,1),S1S2(1:end-1,11),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlabel(spCa2,'BCL (ms)');
ylabel(spCa2,'CaTD_{50} (ms)');
xlim(spCa2,[200 500]);
ylim(spCa2,[50 300]);
grid (spCa2,'on');

% CaTD20
spCa3 = subplot(2,3,3); 
hold(spCa3,'on');
plot(S1S2(1:end-1,1),S1S2(1:end-1,10),'Color',[0.07,0.62,1.00],'LineWidth',2,'DisplayName','Model 0D');
xlabel(spCa3,'BCL (ms)');
ylabel(spCa3,'CaTD_{20} (ms)');
xlim(spCa3,[200 500]);
ylim(spCa3,[50 250]);
grid (spCa3,'on');

% Plotting control curves

if(control == 1)
%     sname = sprintf('S1S2_rest_%d_control.mat',BCL0);
%     load(sname,'S1S2'); 
%     
%     % APD90
%     minDI = 80;
%     DI = S1S2(:,1)-S1S2(:,2);
%     plot(sp1,DI(DI>=minDI),S1S2(DI>=minDI,3),'r','LineWidth',2,'DisplayName','control');
%     
%     % APD80
%     plot(sp2,DI(DI>=minDI),S1S2(DI>=minDI,6),'r','LineWidth',2,'DisplayName','control');
%     
%     % APD50
%     plot(sp3,DI(DI>=minDI),S1S2(DI>=minDI,5),'r','LineWidth',2,'DisplayName','control');
%     
%     % RMP
%     plot(sp4,DI(DI>=minDI),S1S2(DI>=minDI,7),'r','LineWidth',2,'DisplayName','control'); 
%     
%     % APA
%     plot(sp5,DI(DI>=minDI),S1S2(DI>=minDI,8),'r','LineWidth',2,'DisplayName','control');  
%     
%     % dVdtmax
%     plot(sp6,DI(DI>=minDI),S1S2(DI>=minDI,9),'r','LineWidth',2,'DisplayName','control');
%     
%     % APD20
%     figure(2);
%     plot(DI(DI>=minDI),S1S2(DI>=minDI,4),'r','LineWidth',2,'DisplayName','control');
%     
%     % Calcium
%     figure(3)
%     plot(spCa1,S1S2(:,1),S1S2(:,12),'Color','r','LineWidth',2,'DisplayName','control');
%     plot(spCa2,S1S2(:,1),S1S2(:,11),'Color','r','LineWidth',2,'DisplayName','control');
%     plot(spCa3,S1S2(:,1),S1S2(:,10),'Color','r','LineWidth',2,'DisplayName','control');
end

legend(sp1,'Location','best');
legend(spCa1,'Location','best');

% Saving figures

% fp1.WindowState = 'maximized';
% fp3.WindowState = 'maximized';
% 
% sname1 = sprintf('RC_S1S2_%d',BCL0);
% sname2 = sprintf('RC_S1S2_%d.fig',BCL0);
% print(fp1,sname1,'-dpng','-r300');
% savefig(fp1,sname2);
% 
% sname1 = sprintf('RC_Ca_S1S2_%d',BCL0);
% sname2 = sprintf('RC_Ca_S1S2_%d.fig',BCL0);
% print(fp3, sname1,'-dpng','-r300')
% savefig(fp3,sname2);
% 
% fp1.WindowState = 'normal';
% fp3.WindowState = 'normal';

end