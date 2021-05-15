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
load([ar '_pow_23ch.mat'])
paa = cat(3,paa,pow);

%disp(k)

%disp(['DONE WITH' ' ' num2str(si)])
si = si + 1;
end

end

p2 = paa;
p2(:,:,4) = nanmean(paa(:,:,4:6),3);
p2(:,:,16) = nanmean(paa(:,:,16:17),3);
p2(:,:,19) = nanmean(paa(:,:,19:20),3);
p2(:,:,[5:6 17 20]) = [];

fx = linspace(0,400,4001);

cd('C:\Users\Loomis\Documents\FOOOF_nu\MouseCode')

save('ms_spctra.mat','fx','p2')
clear