function plot_currDyn(BCL0,BCL_seq,Fsize)

n = length(BCL_seq);
clc = [0.0 0.0 0.0;...
       0.5 0.0 0.0;...
       1.0 0.0 0.0;...
       0.0 0.5 0.0;...
       0.0 1.0 0.0;...
       0.0 0.0 0.5;...
       0.0 0.0 1.0;...
       0.5 0.5 0.0;...
       0.5 1.0 0.0;...
       1.0 1.0 0.0;...
       0.5 0.0 0.5;...
       0.5 0.0 1.0;...
       1.0 0.0 1.0;...
       0.0 0.5 0.5;...
       0.0 0.5 1.0;...
       0.0 1.0 1.0;...
       1.0 1.0 1.0];
   
fp4 = figure(4);
fp4sp1 = subplot(2,2,1);hold;
fp4sp2 = subplot(2,2,2);hold;
fp4sp3 = subplot(2,2,3);hold;
fp4sp4 = subplot(2,2,4);hold;

fp5 = figure(5);
fp5sp1 = subplot(1,2,1); hold;
fp5sp2 = subplot(1,2,2); hold;

for i = 1:n
    fname = sprintf('sol_Dyn_%d.mat',BCL_seq(i));
    load(fname,'t','V','cur');
    legstr = sprintf('%d',BCL_seq(i));
    plot(fp4sp1,t,cur.ICaL,'LineWidth',2,'DisplayName',legstr,'Color',clc(i,:));
    plot(fp4sp2,t,cur.IKr,'LineWidth',2,'DisplayName',legstr,'Color',clc(i,:));
    plot(fp4sp3,t,cur.IKs,'LineWidth',2,'DisplayName',legstr,'Color',clc(i,:));
    plot(fp4sp4,t,cur.IK1,'LineWidth',2,'DisplayName',legstr,'Color',clc(i,:));
    plot(fp5sp1,t,V.V,'LineWidth',2,'DisplayName',legstr,'Color',clc(i,:));
    plot(fp5sp2,t,(V.Cai-min(V.Cai))./(max(V.Cai)-min(V.Cai)),'LineWidth',2,'DisplayName',legstr,'Color',clc(i,:));
end

xlabel(fp4sp1,'time (ms)');
ylabel(fp4sp1,'I_{CaL}');
set(fp4sp1,'xlim',[-10 300],'XGrid','on','YGrid','on');
legend(fp4sp1,'Location','best');

xlabel(fp4sp2,'time (ms)');
ylabel(fp4sp2,'I_{Kr}');
set(fp4sp2,'xlim',[-10 300],'XGrid','on','YGrid','on');

xlabel(fp4sp3,'time (ms)');
ylabel(fp4sp3,'I_{Ks}');
set(fp4sp3,'xlim',[-10 300],'XGrid','on','YGrid','on');

xlabel(fp4sp4,'time (ms)');
ylabel(fp4sp4,'I_{K1} (pA/pF)');
set(fp4sp4,'xlim',[-10 300],'XGrid','on','YGrid','on');

xlabel(fp5sp1,'time (ms)');
ylabel(fp5sp1,'V_m (mV)');
set(fp5sp1,'xlim',[-10 300],'XGrid','on','YGrid','on');
legend(fp5sp1,'Location','best');

xlabel(fp5sp2,'time (ms)');
ylabel(fp5sp2,'Cai (-)');
set(fp5sp2,'xlim',[-10 300],'XGrid','on','YGrid','on');

% Saving figures

% fp4.WindowState = 'maximized';
% fp5.WindowState = 'maximized';
% 
% sname=sprintf('curr_Dyn_%d',BCL0);
% print(fp4,sname, '-dpng', '-r300');
% sname=sprintf('AP_Ca_Dyn_%d',BCL0);
% print(fp5,sname, '-dpng', '-r300');
% 
% fp4.WindowState = 'normal';
% fp5.WindowState = 'normal';   

end