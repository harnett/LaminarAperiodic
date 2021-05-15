%Dependencies:
%fooof python library, numpy, scipy, matplotlib
%fooof_perps.py, in this folder

%Short ver: just for dpth vs. exp & dpth vs. offset viewing.
clear

cd 'C:\Users\Loomis\Documents\FOOOF_nu\MouseCode'

load ms_spctra.mat 
%addpath('fooof_mat-master/fooof_mat')

pow = [];
for w=1:19
    pow((23*(w-1)+1):23*w,1:4001) = p2(:,:,w);
end
sia = [];
sub = [];
for i=0:(size(pow,1)-1) %here, 23 is the number of chans.
    sia(1,i+1) = mod(i,23)+1;
    sub(i+1,1) = floor(i/23)+1;
end
bad_num = [23.7500   47.5000   50.0000   95.2000   95.2500   113.3000  113.5000  114.3000  114.7500  142.8000  149.8000  150.2000  166.0000 ...
166.2500  166.6000  190.2500  190.4000  190.5000  200.0000  210.0000  214.2000  214.7500  214.9000  215.0000  238.0000 ...
249.4000  249.7500  250.6000  256.5000  261.9000  262.5000  273.8000  280.0000  285.7500  300.7500  310.3000 ...
333.2500  349.5000  350.7500  357.0000  360.0000  381.0000];
actual_bad = [];
for num=1:length(bad_num)
    actual_bad = [actual_bad, [bad_num(num)-1:0.25:bad_num(num)+1]];
end
bad_inds = floor(actual_bad.*4) +1 ;

fx_regular = fx(:,:);
powa_regular = pow(:,:);
fx_regular(:,bad_inds) = [];
powa_regular(:,bad_inds) = [];%subs with noise at 50

save('perps_proper','fx_regular','powa_regular')

lfrq = 10 : 20: 270;

k_counter = 1; kk_counter = 1;
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

    system(['python C:\Users\Loomis\Documents\FOOOF_nu\MouseCode\fooof_perps.py' ' ' num2str(freq_band(1)) ' ' num2str(freq_band(2))])
    
    load p_exps.mat
    load p_offs.mat;
    load p_r2.mat;
    
    [r,pv] = corr(sia',p_exps');
    all_slps_r(k_counter,kk_counter) = r;
    all_slps_p(k_counter,kk_counter) = pv;
    [r,pv] = corr(sia',p_offs');
    all_offs_r(k_counter,kk_counter) = r;
    all_offs_p(k_counter,kk_counter) = pv;
    all_gof(k_counter,kk_counter) = mean(p_r2);
    for kkk = 1 : 19
        [rtmp, pvtmp] = corr(sia(find(sub==kkk))',p_exps(find(sub==kkk))');
        sub_slp_r(k_counter,kk_counter,kkk) = rtmp;
        sub_slp_p(k_counter,kk_counter,kkk) = pvtmp;
        [rtmp, pvtmp] = corr(sia(find(sub==kkk))',p_offs(find(sub==kkk))');
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

%save everything
hfrq = 30:20:290;
save('mouse_freqexplorer_resv2.mat','lfrq','hfrq','all_offs_r','all_offs_p','all_slps_r','all_slps_p','all_gof',...
    'sub_slp_r','sub_slp_p','sub_off_r','sub_off_p')