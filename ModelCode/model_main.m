clear

cd('C:\Users\Loomis\Documents\FOOOF_nu\ModelCode')

edit psc_sim
edit poissonSpikeGen
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\piermorel-gramm-2.24-10-gb0fc592\piermorel-gramm-b0fc592'))

FS = 1000;

load('zilles_receptor_database.mat')
        
% get receptor density for each area
rec_dens = nan(length(areas),length(receptors),3);
for k = 1 : 44
    for kk = 1 : 15
        rec_dens(k,kk,:) = [supragranular(intersect(find(receptor_ind==kk),find(area_ind==k))); granular(intersect(find(receptor_ind==kk),find(area_ind==k))); infragranular(intersect(find(receptor_ind==kk),find(area_ind==k)))];
    end
end

% FOR NOW, only use receptors where we know time constants
%rec_dens = rec_dens(:,[1:4 6 13 15],:);

%have to account for spike rates and number of neurons.

%select GABA and AMPA receptors
rec_ind = [1 4];
rec_dens = rec_dens(:,rec_ind,:);
%this would normalize overall receptor densities / offsets, but we want to
%see if this account for offset, so no normalization!
%rec_dens = squeeze(nanmean(rec_dens));
%rec_dens = rec_dens ./ repmat(sum(rec_dens,1),[size(rec_dens,1) 1]);

t_const = ...
    [.1 2;7 119.4;2.7 70;2 10; 200 800;168 440;7 11.5];%[.3 2;7 119.4;2.7 70;.4 15; 200 800;168 440;7 11.5];
t_const = t_const(rec_ind,:);

% generate 1-second long PSCs at 1000 HZ
psc=[];
for k = 1 : size(t_const,1)
    psc = [psc; psc_sim(FS,1000,t_const(k,1),t_const(k,2))]; %length of PSC, sample rate
end

% multiply by driving current
% psc(1,:) = psc(1,:).*.65;
% psc(2,:) = psc(2,:).*-.15;
% get firing rates; 20 and 50 Hz
firing_rate = [20 50];
%psc = psc ./ repmat(max(psc,[],2),[1 size(psc,2)]); % TO NORMALIZE PSCs
% each layer has 200 neurons

tl = 500; % sim length in seconds
lfpa = nan(3,44,tl*FS); % initialize LFP array

for a = 1 : 44 %loop thru areas
for k = 1 : 3 %loop thru layers
    lfptmp=[];
    for kk = 1 : size(t_const,1) %loop thru timeconstants
        if ~isnan(rec_dens(a,kk,k))
            [ spikeMat , tVec ] = poissonSpikeGen ( FS, firing_rate(kk) , tl , round(rec_dens(a,kk,k)) ); % generate a number of spikes for that area 
            lfptmp = [lfptmp; conv2(double(spikeMat),psc(kk,:),'same')];
        end
    end
    if ~isempty(lfptmp)
    lfpa(k,a,:) = sum(lfptmp);
    end
    disp(a)
end
end

clear lfptmp

lfpa = lfpa(:,:,1:490000);

lfpa = reshape(lfpa,[size(lfpa,1)*size(lfpa,2) size(lfpa,3)]);

data = dat2fieldtrip(lfpa,FS);
cfg=[]; cfg.length=10; data=ft_redefinetrial(cfg,data);

cfg=[]; cfg.method='mtmfft'; cfg.tapsmofrq=.1;
cfg.output='pow';
cfg.foilim=[0 500]; frq=ft_freqanalysis(cfg,data);
ffta=frq.powspctrm;

avgpwr = ffta;
fx = frq.freq;
save('ModelPowSpctra.mat','avgpwr','fx')
avgpwr = avgpwr([1:88 90:end],:);
save('ModelPowSpctraForFOOOF.mat','avgpwr','fx')
%%
clear
load('ModelPowSpctra.mat')

for k = 1 : size(avgpwr,1)
p = polyfit(log(fx(11:2901)),log(avgpwr(k,11:2901)),1);
s(k,1) = p(1);
s(k,2) = -p(2);
end

%%
fd = 'C:\Users\Loomis\Documents\HumanData';
system(['python C:\Users\Loomis\Documents\FOOOF_nu\ModelCode\fooofmodel.py '])
