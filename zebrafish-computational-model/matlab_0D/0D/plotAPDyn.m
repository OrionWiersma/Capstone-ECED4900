function plotAPDyn(BCL,BCLseq,dx,Fsize)
%
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
% Col 11: CaT20 n
% Col 12: CaT50 n
% Col 13: CaT80 n

n=length(BCLseq);

fp1=figure(1);
fp1sp1=subplot(1,2,1); hold;
fp1sp2=subplot(1,2,2); hold;
%
fp2=figure(2);
fp2sp1=subplot(2,2,1); hold;
fp2sp2=subplot(2,2,2); hold;
fp2sp3=subplot(2,2,3); hold;
fp2sp4=subplot(2,2,4); hold;
Dyn = zeros(n,13);

for i=1:n
    fname = sprintf('Dyn_%d.mat',BCLseq(i));
    load(fname,'x','out');
    nId = ceil(length(x)*dx)+1;
    t = out.V(:,1);
    V = out.V(:,nId);
    Ca = out.Cai(:,nId);
    Ca = (Ca-min(Ca))./(max(Ca)-min(Ca));
    tag=sprintf('%d',BCLseq(i));
    plot(fp1sp1,t,V,'LineWidth',2,'DisplayName',tag);
    plot(fp1sp2,t,Ca,'LineWidth',2,'DisplayName',tag);
%
% Processing results
%
% Finding Peaks
%
   [PKS,LOC]=findpeaks(V);
   LOC = LOC(PKS>-20);
   [PKSCa,LOCCa]=findpeaks(Ca);
   if(length(PKS)<3)
       fprintf('1) BCL: %d. No propagating\n',BCLseq(i));
       Dyn(i,end) = -1;
   else
       fprintf('Procesing BCL: %d\n',BCLseq(i));
       %
       % Separating n and n-1
       %
       Dyn(i,1) = BCLseq(i);
       tp = t(LOC);
       tendS1 = t(LOC(2))-50;
       tendS2 = t(LOC(3))-50;
       IS1 = t<tendS1;       
       IS2 = (t>=tendS1)&(t<tendS2);
       tS1 = t(IS1); 
       VS1 = V(IS1);
       [APDS1,APAS1,VmaxS1,dVdtmaxS1,t0S1,RMPS1,tpeakS1,flagOutS1] = ...
           APDcalc(tS1,VS1,[20 50 80 90]);
       Dyn(i,2) = APDS1(4);
       plot(fp2sp1,tS1-t0S1,VS1,'Displayname',tag);
       tS2 = t(IS2);
       VS2 = V(IS2);
       [APD,APA,Vmax,dVdtmax,t0,RMP,tpeak,flagOut] = APDcalc(tS2,VS2,[20 50 80 90]);
       plot(fp2sp2,tS2-t0,VS2,'DisplayName',tag);
       Dyn(i,10) = t0 - (t0S1 + APDS1(4));
       Dyn(i,3:9) = [APD([4 1:3]) RMP APA dVdtmax];
       %
       % Processing Cai
       %
       tpCa = t(LOCCa);
       tendS1Ca = t(LOCCa(2))-75;
       tendS2Ca = t(LOCCa(3))-75;
       IS1Ca = t<tendS1Ca;       
       IS2Ca = (t>=tendS1Ca)&(t<tendS2Ca);
       tS1Ca = t(IS1Ca); 
       VS1Ca = Ca(IS1Ca);
       [APDCa,tpeakCa,t0Ca] = CaTDcalc(tS1Ca,VS1Ca,[20 50 80]);
       plot(fp2sp3,tS1Ca-t0Ca+25,VS1Ca,'Displayname',tag);
       tS2Ca = t(IS2Ca);
       VS2Ca = Ca(IS2Ca);
       [APDCa,tpeakCa,t0Ca] = CaTDcalc(tS2Ca,VS2Ca,[20 50 80]);
       plot(fp2sp4,tS2Ca-t0Ca+25,VS2Ca,'DisplayName',tag);
       Dyn(i,11:13) = APDCa;       
   end
end
Dyn = Dyn(Dyn(:,end)>=0,:);
%
xlabel(fp1sp1,'time (ms)');
ylabel(fp1sp1,'V_m (m)');
xlabel(fp1sp2,'time (ms)');
ylabel(fp1sp2,'Cai (-)');
legend(fp1sp1,'location','best');
%
xlabel(fp2sp1,'time (ms)');
ylabel(fp2sp1,'V_m (m)');
xlabel(fp2sp2,'time (ms)');
ylabel(fp2sp2,'V_m (m)');
xlabel(fp2sp3,'time (ms)');
ylabel(fp2sp3,'Cai (-)');
xlabel(fp2sp4,'time (ms)');
ylabel(fp2sp4,'Cai (-)');
title(fp2sp1,'n^{th}-1 beat');
title(fp2sp2,'n^{th} beat');
legend(fp2sp1,'location','best');
%
set(fp1sp1,'FontSize',Fsize,'Xgrid','on','Ygrid','on');
set(fp1sp2,'FontSize',Fsize,'Xgrid','on','Ygrid','on');
set(fp2sp1,'FontSize',Fsize,'Xgrid','on','Ygrid','on');
set(fp2sp2,'FontSize',Fsize,'Xgrid','on','Ygrid','on');
set(fp2sp3,'FontSize',Fsize,'Xgrid','on','Ygrid','on');
set(fp2sp4,'FontSize',Fsize,'Xgrid','on','Ygrid','on');

fname=sprintf('Dynrest_%d.mat',BCL);
save(fname,'Dyn');
end