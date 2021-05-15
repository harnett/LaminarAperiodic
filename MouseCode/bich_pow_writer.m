clear
addpath('C:\Users\Loomis\Documents\NeuropixelOneOverF')
cd('C:\Users\Loomis\Documents\NeuropixelOneOverF')

addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))

VISp={'Cori_2016-12-14','Cori_2016-12-18','Forssmann_2017-11-01',...
'Hench_2017-06-15','Hench_2017-06-17','Lederberg_2017-12-05',...
'Moniz_2017-05-16','Theiler_2017-10-11'};
SSp={'Moniz_2017-05-18','Radnitz_2017-01-12'};
MOp={'Moniz_2017-05-18','Radnitz_2017-01-12'};
RSP={'Lederberg_2017-12-07','Radnitz_2017-01-11'};%'Tatum_2017-12-06''Radnitz_2017-01-08' too but not lateral
MOs={'Muller_2017-01-07', 'Radnitz_2017-01-08', 'Radnitz_2017-01-09', 'Radnitz_2017-01-10'};
VISam = {'Moniz_2017-05-15','Radnitz_2017-01-10'};
VISa = {'Hench_2017-06-15','Moniz_2017-05-16','Richards_2017-10-29'};
%ars = {'VISp','SSp','MOp','RSP','MOs','VISam','VISa'};
ars = {'MOp','MOs','RSP','SSp','VISa','VISam','VISp'};


si=1; paa=[]; sess={}; allst={}; alsti=[]; nch = [];
for ari = 1 : length(ars)

eval(['fdirs = ' ars{ari} ';'])
ar = ars{ari};

for k = 1 : length(fdirs)

sdir = ['C:\Users\Loomis\Documents\NeuropixelOneOverF\GLADResultsv2\' ar '\' fdirs{k} '\'];
cd(sdir)

load([ar '_monodata.mat'])
load([ar '_gs.mat'])
load([ar '_unitdata.mat'])
ch = sort([unitdata(:).ch]);
topch = ch(1) - 2;
if topch <= 0
    topch = 1;
end
cfg=[]; cfg.channel = data.label(topch:end); data = ft_preprocessing(cfg,data);
dat = data.trial{1};
nch = [nch size(dat,1)];
t = 1:length(dat);
[xnu,ynu] = ndgrid(linspace(1,size(dat,1),24),t);
[x,y] = ndgrid(1:size(dat,1),t);%[x1,x2] = ndgrid(1:size(dat,1),tbasis);
F = griddedInterpolant(x,y,dat);%F = griddedInterpolant(x1,x2,dat);
clear y
dat2 = F(xnu,ynu);%dat2 = F(x1(:,1:length(t)),x2nu);

data = dat2fieldtrip(dat2,1000);

bi = data; bi.trial{1}(1:(end-1),:) = diff(bi.trial{1});
cfg=[]; cfg.channel = bi.label(1:(end-1)); bi = ft_preprocessing(cfg, bi);

[pow,fx] = LFP_FFT_gs(bi,gs,10);

paa = cat(3,paa,pow);

sess{si} = fdirs{k};
alst{si} = ars{ari};
alsti(si) = ari;

save([ar '_bidata_23ch.mat'],'bi')
save([ar '_pow_23ch.mat'],'pow')

disp(k)

disp(['DONE WITH' ' ' num2str(si)])
si = si + 1;
end

end

%4:6 16:17 19:20

p2 = paa;
p2(:,:,4) = nanmean(paa(:,:,4:6),3);
p2(:,:,16) = nanmean(paa(:,:,16:17),3);
p2(:,:,19) = nanmean(paa(:,:,19:20),3);
p2(:,:,[5:6 17 20]) = [];

plot(nch)

fx = linspace(0,400,4001);

cd('C:\Users\Loomis\Documents\FOOOF_nu\MouseCode')

save('ms_spctra.mat','fx','p2')
save('ms_spctra_mono_nch.mat','nch')