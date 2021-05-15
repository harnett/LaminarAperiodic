% delete noise from power spectra before fooof
% 
% Args:
%     dpth: 1xtotal_count matrix of channel depth
%     bi_all: mostly manually detected + indices with outrageous CF for
%     peaks after first run
%     
% Returns:
%      all_expsnew: 1xtotal_count array of exps
%      fooof returns: all_exps, all_cfs, all_r2, all_offset
%     
clear

addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\piermorel-gramm-2.24-10-gb0fc592\piermorel-gramm-b0fc592'))

cd 'C:\Users\Loomis\Documents\FOOOF_nu\HumanCode'

load bad_indices_final.mat%new_bi_all.mat

load sub.mat
load HumanPwrSpctra.mat
load dpth_one_over_fv2.mat %files in directory

bi_manual = bi_all;

for k=1:length(bi_manual) %for each person
    tempbfrq = [];
    
    for j=1:length(bi_manual{1,k})
        tempbfrq = [tempbfrq,bi_manual{1,k}(1,j)-5:bi_manual{1,k}(1,j)+5];
    end
    tempbfrq = tempbfrq( tempbfrq>=1 );
    
    avgpwr(find(sub==k),tempbfrq) = nan;
end

%normalize spectra by the median
for k = 1 : 16
    tmp = avgpwr(find(sub==k),11:2901);
    avgpwr(find(sub==k),:) = avgpwr(find(sub==k),:) ./ nanmedian(tmp(:));
end

filename = 'indiv_';
for k=1:length(bi_manual) %for each person
    tempbfrq = [];
    
    for j=1:length(bi_manual{1,k})
        tempbfrq = [tempbfrq,bi_manual{1,k}(1,j)-5:bi_manual{1,k}(1,j)+5];
    end
    tempbfrq = tempbfrq( tempbfrq>=1 );
    
    indiv_file = append(filename,string(k));
    indiv_frq = frq(:,:);
    indiv_pow = avgpwr(find(sub==k),:); %well we actually only care about the channels that are this person's!!
    
    indiv_frq(:,tempbfrq) = [];
    indiv_pow(:,tempbfrq) = [];
    
    save(indiv_file,'indiv_frq','indiv_pow');
end

%as a result of ^, there should now be 16 .mat files in this directory.

freq_band = [1 290];

system(['python C:\Users\Loomis\Documents\FOOOF_nu\HumanCode\indiv_fooofcode.py' ' ' num2str(freq_band(1)) ' ' num2str(freq_band(2))]) % MAIN SCRIPT
%pause(20)

%as a result of ^, there are now files called all_exps, all_cfs, all_r2,
%and all_offset in this directory. Each is a cell array of each
%individual's results.
load all_exps.mat
all_expsnew = horzcat(all_exps{:});

human_plotting