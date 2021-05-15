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

load new_bi_all.mat

load sub.mat
load HumanPwrSpctra.mat
load dpth_one_over_fv2.mat %files in directory

bi_manual = bi_all;

filename = 'indiv_';
for k=1:length(bi_manual) %for each person
    tempbfrq = [];
    
    for j=1:length(bi_manual{1,k})
        tempbfrq = [tempbfrq,bi_manual{1,k}(1,j)-5:bi_manual{1,k}(1,j)+5];
    end
    tempbfrq = tempbfrq( tempbfrq>=1 );
    
    indiv_file = append(filename,string(k));
    indiv_frq = frq;
    indiv_pow = avgpwr(find(sub==k),:); %well we actually only care about the channels that are this person's!!
    
    indiv_frq(:,tempbfrq) = nan;
    indiv_pow(:,tempbfrq) = nan;
    
    tmp = indiv_pow(:,11:2901);
    indiv_pow= indiv_pow ./ nanmedian(tmp(:));
    
    indiv_frq(:,tempbfrq) = [];
    indiv_pow(:,tempbfrq) = [];
    
    save(indiv_file,'indiv_frq','indiv_pow')
 %   cleanfrqs_all{1,k} = indiv_frq
 %   cleanpow_all{1,k} = indiv_pow
end

%as a result of ^, there should now be 16 .mat files in this directory.

lfrq = 10 : 20: 270;

k_counter = 1; 
kk_counter = 1;
all_slps_r = nan(length(lfrq), length(lfrq));
all_offs_r = all_slps_r;
all_slps_p = all_slps_r;
all_offs_p = all_slps_r;
all_gof = all_slps_r;
sub_slp_r = nan(length(lfrq), length(lfrq),3);
sub_slp_p = sub_slp_r;
sub_off_r = sub_slp_r;
sub_off_p = sub_slp_r;
tot_num_iters = 0;

for k = lfrq
    for kk = (k + 20) : 20 : 290 
        tot_num_iters = tot_num_iters + 1;
    end
end

num_iters = 0; ta = nan(1,tot_num_iters);
for k = lfrq
    for kk = (k + 20) : 20 : 290 
    tic
    freq_band = [k kk];
   
    system(['python C:\Users\Loomis\Documents\FOOOF_nu\HumanCode\indiv_fooofcode.py' ' ' num2str(freq_band(1)) ' ' num2str(freq_band(2))])
    
    load all_exps.mat
    load all_offset.mat
    load all_r2.mat
    p_exps = horzcat(all_exps{:});
    p_offs = horzcat(all_offset{:});
    r2 = horzcat(all_r2{:});
    %unlogging offsets:
%     for s=1:length(p_offs)
%         p_offs(1,s) = 10^(p_offs(1,s));
%     end

    %NORMALIZE 1/F WITHIN EACH SUBJECT & OFFSET IN EACH SUBJECT TOO
%     for s = 1 : 20
%         p_exps(find(sub==s)) = p_exps(find(sub==s)) ./ max(p_exps(find(sub==s)));
%         p_offs(find(sub==s)) = p_offs(find(sub==s)) ./ max(p_offs(find(sub==s)));
%     end
    
    [r,pv] = corr(dpth,p_exps');
    all_slps_r(k_counter,kk_counter) = r;
    all_slps_p(k_counter,kk_counter) = pv;
    [r,pv] = corr(dpth,p_offs');
    all_offs_r(k_counter,kk_counter) = r;
    all_offs_p(k_counter,kk_counter) = pv;
    all_gof(k_counter,kk_counter) = mean(r2);
    for kkk = 1 : 16 
        [rtmp, pvtmp] = corr(dpth(find(sub==kkk)),p_exps(find(sub==kkk))');
        sub_slp_r(k_counter,kk_counter,kkk) = rtmp;
        sub_slp_p(k_counter,kk_counter,kkk) = pvtmp;
        [rtmp, pvtmp] = corr(dpth(find(sub==kkk)),p_offs(find(sub==kkk))');
        sub_off_r(k_counter,kk_counter,kkk) = rtmp;
        sub_off_p(k_counter,kk_counter,kkk) = pvtmp;
    end
    kk_counter = kk_counter + 1; 
    t = toc;
    num_iters = num_iters+1;
    ta(num_iters) = t;
    disp((tot_num_iters - num_iters) .* nanmean(ta) ./ 60) 
    end
    k_counter = k_counter+1; kk_counter = k_counter;
end
%pause(20)
hfrq = 30:20:290; save('human_freqexplorer_resv2.mat','lfrq','hfrq','all_offs_r',...
    'all_offs_p','all_slps_r','all_slps_p','all_gof','sub_slp_r','sub_slp_p','sub_off_r','sub_off_p')