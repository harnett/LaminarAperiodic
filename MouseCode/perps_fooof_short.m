%Dependencies:
%fooof python library, numpy, scipy, matplotlib
%fooof_perps.py, in this folder

%Short ver: just for dpth vs. exp & dpth vs. offset viewing.
clear

cd('C:\Users\Loomis\Documents\FOOOF_nu\MouseCode')

p2_writer;

bad_num = [23.7500   47.5000   50.0000   95.2000   95.2500   113.3000  113.5000  114.3000  114.7500  142.8000  149.8000  150.2000  166.0000 ...
166.2500  166.6000  190.2500  190.4000  190.5000  200.0000  210.0000  214.2000  214.7500  214.9000  215.0000  238.0000 ...
249.4000  249.7500  250.6000  256.5000  261.9000  262.5000  273.8000  280.0000  285.7500  300.7500  310.3000 ...
333.2500  349.5000  350.7500  357.0000  360.0000  381.0000];
actual_bad = [];
for num=1:length(bad_num)
    actual_bad = [actual_bad, [bad_num(num)-.5:0.1:bad_num(num)+.5]];
end
bad_inds = round(actual_bad.*10) +1 ;
bad_inds = unique(bad_inds);

load ms_spctra.mat
p2(:,bad_inds,:) = nan;
for k = 1 : size(p2,3)
    tmp = p2(:,11:2901,k);
    p2(:,:,k) = p2(:,:,k)./nanmedian(tmp(:));
end

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

fx_regular = fx;
powa_regular = pow;
fx_regular(:,bad_inds) = [];
powa_regular(:,bad_inds) = [];%subs with noise at 50

save('perps_proper','fx_regular','powa_regular')

freq_band = [1 290];

system(['python C:\Users\Loomis\Documents\FOOOF_nu\MouseCode\fooof_perps.py' ' ' num2str(freq_band(1)) ' ' num2str(freq_band(2))])
% 
% load p_peakheight.mat
% load p_cfs.mat
% load p_exps.mat; scatter(sia,p_exps);title('dpth vs. exp in mice, [1 290]Hz')
% load p_offs.mat; scatter(sia,p_offs);title('dpth vs. off in mice, [1 290]Hz')


%if u wanna gramm gramm:
%make sure gramm is in ur path tho. lol
%addpath(GRAMM PATH)
mouse_plotting;