
clear
cd C:\Users\Loomis\Documents\MacaqueNPXL

addpath(genpath('C:\Users\Loomis\Documents\Scripts'))

fid = fopen('pacman-task_c_210318_neu_settling__g0_t0.imec0.lf.bin', 'r');
dat = fread(fid, [385 Inf],'int16');
dat = dat(1:384,:);

bch = [89 253 316 361];

dat(bch,:) = nan;
for kk = 1 : ( length(1:4:size(dat,1)) - 1 )
    dat(kk,:) = nanmean(dat( (kk-1) * 4 + 1 : (kk*4) , : ) );
    mk = kk;
end
dat = dat(1:mk,:);

dat = double(dat);
data = dat2fieldtrip(dat,2500);
cfg=[]; cfg.hpfilter='yes'; cfg.hpfreq=[.05]; cfg.bpinstabilityfix='reduce'; cfg.hpinstabilityfix='reduce'; data=ft_preprocessing(cfg,data);
cfg=[]; cfg.resamplefs=1000; data = ft_resampledata(cfg,data);
data.trial{1} = imgaussfilt(data.trial{1}, [1.7 .0000000001]);
dat = data.trial{1};
clear data

% t = 1:length(dat);
% [xnu,ynu] = ndgrid(linspace(1,size(dat,1),24),t);
% [x,y] = ndgrid(1:size(dat,1),t);%[x1,x2] = ndgrid(1:size(dat,1),tbasis);
% F = griddedInterpolant(x,y,dat);%F = griddedInterpolant(x1,x2,dat);
% clear y
% dat2 = F(xnu,ynu);%dat2 = F(x1(:,1:length(t)),x2nu);
% dat = dat2; clear dat2
dat = [dat; nan(1,size(dat,2))];

for kk = 1 : ( length(1:4:size(dat,1)))
    dat(kk,:) = nanmean(dat( (kk-1) * 4 + 1 : (kk*4) , : ) );
    mk = kk;
end
dat = dat(1:mk,:);

dat = flipud(dat);

data = dat2fieldtrip(dat,1000);

bi = data; bi.trial{1}(1:(end-1),:) = diff(bi.trial{1});
cfg=[]; cfg.channel = bi.label(1:(end-1)); bi = ft_preprocessing(cfg, bi);
    
csd = bi; csd.trial{1}(2:(end-1),:) = pg2csdv3(bi.trial{1});
cfg=[]; cfg.channel = csd.label(2:(end-1)); csd = ft_preprocessing(cfg, csd);

gs = 3539177 : length(data.trial{1});
[avgpwr,fx] = LFP_FFT_gs(bi,gs,5);
%%
bi = [189 413 601 789 1012 1389 1296 1612 1800]; bia = []; for k = 1 : length(bi), bia = [bia (bi(k)-3):(bi(k)+3)]; end;

fx_regular = fx; fx_regular(bia) = [];
powa_regular = avgpwr; powa_regular(:,bia) = [];%subs with noise at 50

save('perps_proper','fx_regular','powa_regular')

freq_band = [1 290];

system(['python C:\Users\Loomis\Documents\MacaqueNPXL\fooof_perps_macaque.py' ' ' num2str(freq_band(1)) ' ' num2str(freq_band(2))])

%%
load('p_exps')
load('p_offs')
figure(1)
subplot(1,2,1)
plot(linspace(0,1,23),p_exps)
title('1/f slope vs. depth')
xlabel('normalized depth')
ylabel('1/f slope')
subplot(1,2,2)
plot(linspace(0,1,23),p_offs)
title('1/f offset vs. depth')
xlabel('normalized depth')
ylabel('1/f offset')
%%
bi = [189 413 601 789 1012 1389 1296 1612 1800]; bia = []; for k = 1 : length(bi), bia = [bia (bi(k)-3):(bi(k)+3)]; end;
p_all = zeros(size(avgpwr,1),2);
lb = 200;
for k = 1 : size(avgpwr,1)
    fx2 = fx; pwr2 = avgpwr(k,:); fx2(bia) = nan; pwr2(bia) = nan;
    fx2 = fx2(lb:end); pwr2 = pwr2(lb:end);
    fx2(isnan(fx2)) = []; pwr2(isnan(pwr2)) = [];
    [p_all(k,:), s] = polyfit(log(fx2),log(pwr2),1);
    r_fit(k) = 1 - (s.normr/norm(log(pwr2) - mean(log(pwr2))))^2;
end

slp = p_all(:,1);
offs = p_all(:,2);
slp = -slp;

figure(2)
subplot(1,2,1)
plot(linspace(0,1,23),slp)
title('1/f slope vs. depth')
xlabel('normalized depth')
ylabel('1/f slope')
box off, set(gca,'TickDir','Out','FontSize',20)
subplot(1,2,2)
plot(linspace(0,1,23),offs)
title('1/f offset vs. depth')
xlabel('normalized depth')
ylabel('1/f offset')
box off, set(gca,'TickDir','Out','FontSize',20)

%%

axis_big = [];

for j=1 : 23
        
       s1 = -slp(j);
       s2 = -slp(j+1);
       o1 = offs(j);
       o2 = offs(j+1);
       
       axis_x = (o2-o1)/(s1-s2);
       axis_y = (s1*axis_x) + o1;

       axis_big(j,1) = axis_x;
       axis_big(j,2) = axis_y;

end
rot_point = axis_big(:,1);

title('mouse histogram of x coords per person');
%[~,x] = sort(abs(rot_point));% x = rot_point(x(round(.05*length(rot_point)):round(.95*length(rot_point))));
figure; 
histogram(rot_point,20); box off
set(gca,'TickDir','out');
disp(['median axis of rotation: ' num2str(10.^(median(rot_point)))])
title('X coords of 1/f rotation axes with depth'); 
xlabel('Depth'); ylabel('Intercecpt x-coord (hz)');xlim([-10 10]);