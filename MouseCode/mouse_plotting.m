clear

cd('C:\Users\Loomis\Documents\FOOOF_nu\MouseCode')

est_lyr_mid=[1.06 5.5275 10.0455 14.4280 20.35];
est_lyr_lab={'I', 'II/III','IV','V','VI'};

load p_exps.mat
load p_offs.mat
load p_cfs.mat
load p_r2.mat
load pow_spctra_bi.mat

dpth = repmat([1:23],[1 19]); 
sub = [];
for k = 1 : 19
    sub = [sub ones(1,23).*k];
end

p_exps_orig = p_exps;
p_offs_orig = p_offs;
%Normalize 1/f slope and offset within each patient
for k = 1 : 23
    p_exps(find(sub==k)) = p_exps(find(sub==k)) ./ max(p_exps(find(sub==k)));
    p_offs(find(sub==k)) = p_offs(find(sub==k)) ./ max(p_offs(find(sub==k)));
end

exclude_ms = [];%[5 15];%[4,5,14]

deleteindices = [];
count = 1;
for k=1:length(sub)
    if ismember(sub(k),exclude_ms) %if the subject rn is someone we donut like
        deleteindices(1,count) = k;
        count = count + 1;
    end
end

sub(deleteindices) = [];
dpth(deleteindices) = [];
p_exps(deleteindices) = [];
p_exps_orig(deleteindices) = [];
p_offs_orig(deleteindices) = [];
p_r2(deleteindices) = [];
p_offs(deleteindices) = [];

%correct sub no's:
c = 1;
seen = [1];
for k=2:length(sub)
    if not(ismember(sub(k),seen))
        c = c + 1;
        seen(c,1) = sub(k);
    end
    sub(k) = c;
end

disp(['exps range from ' num2str(min(p_exps_orig)) ' to ' num2str(max(p_exps_orig))])
[r,pv] = corr(dpth(:),p_exps_orig(:));
disp(['overall slope fit: ' num2str(r.^2)])
disp(['overall slope pv: ' num2str(pv)])
[r,pv] = corr(dpth(:),p_offs_orig(:));
disp(['overall offset fit: ' num2str(r.^2)])
disp(['overall offset pv: ' num2str(pv)])
for k = 1 : 19
exp_superficial(k) = mean(p_exps_orig(intersect(find(sub == k),find(dpth<=9))));
exp_deep(k) = mean(p_exps_orig(intersect(find(sub == k),find(dpth>=11))));
off_superficial(k) = mean(p_offs_orig(intersect(find(sub == k),find(dpth<=9))));
off_deep(k) = mean(p_offs_orig(intersect(find(sub == k),find(dpth>=11))));
end
[r,pv] = corr(p_exps_orig(:),p_offs_orig(:));
[r2,pv2] = partialcorr(p_exps_orig(:),p_offs_orig(:),dpth(:));
disp(['correlation between offset and slope r2: ' num2str(r.^2)])
disp(['correlation between offset and slope pv: ' num2str(pv)]) 
disp(['partial correlation between offset and slope r2: ' num2str(r2.^2)])
disp(['partial correlation between offset and slope pv: ' num2str(pv2)]) 
disp([num2str(100*mean((exp_superficial - exp_deep) ./ exp_superficial)) ' % change in slope from SG to IG'])
disp([num2str(100*mean((off_superficial - off_deep) ./ off_superficial)) ' % change in offset from SG to IG' ])
[rtmp,pvtmp] = corr(dpth',p_r2');
disp(['correlation between fit and depth r2: ' num2str(rtmp.^2)])
disp(['correlation between fit and depth pv: ' num2str(pvtmp)])
[rtmp,pvtmp] = corr(p_exps_orig(:),p_r2');
disp(['correlation between fit and slope r2: ' num2str(rtmp.^2)])
disp(['correlation between fit and slope pv: ' num2str(pvtmp)])
[rtmp,pvtmp] = corr(p_offs_orig(:),p_r2');
disp(['correlation between fit and offset r2: ' num2str(rtmp.^2)])
disp(['correlation between fit and offset pv: ' num2str(pvtmp)])

%% overall slope vs. depth
clear g
figure('units','normalized','outerposition',[.2 0 .6 1])

g(1,1)=gramm('x',dpth,'y',p_exps,'color',sub);
g(1,1).set_continuous_color('active',false);
g(1,1).geom_point();
g(1,1).set_names('x','','y','1/f Slope','color','Pt');
g(1,1).axe_property('FontSize',20);
g(1,1).set_title('1/f Slope vs. Cortical Depth','FontSize',30);
g(1,1).set_text_options('legend_scaling',2,'legend_title_scaling',1.5);
g(1,1).set_point_options('base_size',10);
g(1,1).axe_property('XTick',est_lyr_mid);
g(1,1).axe_property('XTickLabel',est_lyr_lab);
g(1,1).axe_property('YLim',[.4 1]);
g(1,1).axe_property('YTick',[.4 .7 1]);
g(1,1).axe_property('FontSize',25);
g(1,1).axe_property('TickDir','out');
g(1,1).update('color',ones(1,length(dpth)));
g(1,1).set_line_options('base_size',10);
g(1,1).stat_summary('geom','line');
g(1,1).set_color_options('map',[0 0 0],'n_lightness',1,'n_color',1);
g(1,1).set_text_options('label_scaling',20);
g(1,1).set_text_options('label_scaling',25,'Font','Arial');
g(2,1)=gramm('x',dpth,'y',p_offs,'color',sub);
g(2,1).set_continuous_color('active',false);
g(2,1).geom_point();
g(2,1).set_names('x','','y','1/f Offset','color','Pt');
%g(2,1).set_names('x','Estimated Cortical Layer','y','1/f Offset','color','Pt');
g(2,1).axe_property('FontSize',20);
g(2,1).set_title('1/f Offset vs. Cortical Depth','FontSize',30);
g(2,1).set_text_options('legend_scaling',2,'legend_title_scaling',1.5);
g(2,1).set_point_options('base_size',10);
g(2,1).axe_property('XTick',est_lyr_mid);
g(2,1).axe_property('XTickLabel',est_lyr_lab);
g(2,1).axe_property('YLim',[.4 1]);
g(2,1).axe_property('YTick',[.4 .7 1]);
g(2,1).axe_property('FontSize',25);
g(2,1).axe_property('TickDir','out');
g(2,1).update('color',ones(1,length(dpth)));
g(2,1).set_line_options('base_size',10);
g(2,1).stat_summary('geom','line');
g(2,1).set_color_options('map',[0 0 0],'n_lightness',1,'n_color',1);
g(1,1).set_text_options('font','Arial');  
g(2,1).set_text_options('font','Arial');
g(2,1).set_text_options('label_scaling',25,'Font','Arial');

g.draw();
pause(1)
set(gcf,'PaperSize',[20 20],'renderer','painters');
saveas(gcf,'C:\Users\Loomis\Documents\FOOOF_nu\final_figs\figscratch\mouse_slopedepthoverall.svg');
%% individual subs slope vs. depth
figure('units','normalized','outerposition',[0 0 1 1]);

g2=gramm('x',dpth,'y',p_exps,'color',sub);
g2.set_continuous_color('active',false);
g2.facet_wrap(sub,'ncols',7,'scale','free');
g2.geom_point();
g2.axe_property('FontSize',8);
g2.stat_glm('r2','true','geom','line');
g2.set_line_options('base_size',4);
g2.set_names('x','','y','1/f Slope','color','Expt','column', 'Expt');
g2.set_title('1/f Slope and Cortical Depth in Single Mice','FontSize',30);
g2.axe_property('XTick',est_lyr_mid([1 3 5]));
g2.axe_property('XTickLabel',est_lyr_lab([1 3 5]));
g2.axe_property('TickDir','out');
g2.set_text_options('font','Arial');

min_ylim = [];
seen = [1];
lowest_y = 1;
for k=2:length(sub)
    if p_exps(1,k) < lowest_y
        lowest_y = p_exps(1,k);
    end
    if not(ismember(sub(k),seen))
        seen = [seen,sub(k)];
        min_ylim = [min_ylim; (round(10*lowest_y)/10) - 0.1,1];
        lowest_y = 1;
    end
end
min_ylim = [min_ylim; (round(10*lowest_y)/10) - 0.1,1];

all_ylim = min_ylim(:,:);
all_ytick = [all_ylim(:,1) mean(all_ylim,2) all_ylim(:,2)];

g2.set_text_options('base_size',15,'legend_scaling',1.2,'legend_title_scaling',3,'facet_scaling',1.5);
g2.set_layout_options('title_centering','plot','legend',0);
g2.set_point_options('base_size',10);
g2.draw();

for k = 1 : 19
    all_r(k) = g2.results.stat_glm(k).model.Rsquared.Ordinary;
end

for k = 1 : 19
    set(g2.facet_axes_handles(k),'YLim',all_ylim(k,:),'YTick',all_ytick(k,:),'FontSize',18,'FontName','Arial');
    g2.update();
end

pause(1)
set(gcf,'PaperSize',[20 20],'renderer','painters');
saveas(gcf,'C:\Users\Loomis\Documents\FOOOF_nu\final_figs\figscratch\mouse_indivslope.svg');

disp(['mean sing subj slope fit: ' num2str(mean(all_r))])
disp(['sem sing subj slope fit: ' num2str(std(all_r)./sqrt(19))])
%% slope and r-squared histograms
figure('units','normalized','outerposition',[0 0 1 1]);

clear g3

g3(1,1)=gramm('x',p_exps_orig);
g3(1,1).stat_bin('nbins',11);
g3(1,1).set_names('x','1/f Slope','y','# of channels');
g3(1,1).axe_property('XTick',[.7 1.6 2.5]);
g3(1,1).axe_property('XLim',[.7 2.5]);
g3(1,1).axe_property('YLim',[0 200]);
g3(1,1).axe_property('YTick',[0 100 200]);
g3(1,1).axe_property('TickDir','out');
g3(1,1).set_color_options('map',[19 159 255]./255,'n_lightness',1,'n_color',1);
g3(1,2)=gramm('x',p_r2);
g3(1,2).stat_bin('nbins',11);
g3(1,2).set_names('x','R^2','y','# of channels');
g3(1,2).axe_property('XTick',[.95 .975 1]);
g3(1,2).axe_property('XLim',[.95 1]);
g3(1,2).axe_property('YLim',[0 200]);
g3(1,2).axe_property('YTick',[0 100 200]);
g3(1,2).axe_property('TickDir','out');
g3(1,2).set_color_options('map',[255 94 105]./255,'n_lightness',1,'n_color',1);
g3(1,1).set_text_options('font','Arial');
g3(1,2).set_text_options('font','Arial');
g3.draw();
pause(1);
set(gcf,'PaperSize',[20 20],'renderer','painters');
saveas(gcf,'C:\Users\Loomis\Documents\FOOOF_nu\final_figs\figscratch\mouse_r2andrawslopes.svg');
disp(['mean channel r2 fit: ' num2str(mean(p_r2))])
disp(['sem channel r2 fit: ' num2str(std(p_r2)./sqrt(length(p_r2)))])
disp(['channel r2 fit ranges from ' num2str(min(p_r2)) ' to ' num2str(max(p_r2)) ] )
%% individual offsets vs. depth
figure('units','normalized','outerposition',[0 0 1 1]);

g5=gramm('x',dpth,'y',p_offs,'color',sub);
g5.set_continuous_color('active',false);
g5.facet_wrap(sub,'ncols',7,'scale','free');
g5.geom_point();
g5.axe_property('FontSize',8);
g5.stat_glm('r2','true','geom','line');
g5.set_line_options('base_size',4);
g5.set_names('x','','y','1/f Offset','color','Expt','column', 'Expt');
g5.set_title('1/f Offset and Cortical Depth in Single Mice','FontSize',30);
g5.axe_property('XTick',est_lyr_mid([1 3 5]));
g5.axe_property('XTickLabel',est_lyr_lab([1 3 5]));
g5.axe_property('TickDir','out');
g5.set_text_options('font','Arial');
min_ylim = [];
seen = [1];
lowest_y = 1;
for k=2:length(sub)
    if p_exps(1,k) < lowest_y
        lowest_y = p_exps(1,k);
    end
    if not(ismember(sub(k),seen))
        seen = [seen,sub(k)];
        min_ylim = [min_ylim; (round(10*lowest_y)/10) - 0.1,1];
        lowest_y = 1;
    end
end
min_ylim = [min_ylim; (round(10*lowest_y)/10) - 0.1,1];

all_ylim = min_ylim(:,:);
all_ytick = [all_ylim(:,1) mean(all_ylim,2) all_ylim(:,2)];

g5.set_text_options('base_size',15,'legend_scaling',1.2,'legend_title_scaling',3,'facet_scaling',1.5);
g5.set_layout_options('title_centering','plot','legend',0);
g5.set_point_options('base_size',10);
g5.draw();

for k = 1 : 19
    all_roff(k) = g5.results.stat_glm(k).model.Rsquared.Ordinary;
end

disp(['mean sing subj offset fit: ' num2str(mean(all_roff))])
disp(['sem sing subj offset fit: ' num2str(std(all_roff)./sqrt(19))])

for k = 1 : 19
    set(g5.facet_axes_handles(k),'YLim',all_ylim(k,:),'YTick',all_ytick(k,:),'FontSize',18,'FontName','Arial');
    g5.update();
end
pause(1)
set(gcf,'PaperSize',[20 20],'renderer','painters');
saveas(gcf,'C:\Users\Loomis\Documents\FOOOF_nu\final_figs\figscratch\mouse_indivoffset.svg');
%% axis of rotation
clear

load p_exps.mat
load p_offs.mat
sub = [];
for k = 1 : 19
    sub = [sub ones(1,23).*k];
end

axis_list = {};
axis_big = [];
figure; 
count = 1;

for i=1:19
    k = find(sub==i);
    for j=k(1):k(end)-1
        
       s1 = -p_exps(1,j);
       s2 = -p_exps(1,j+1);
       o1 = p_offs(1,j);
       o2 = p_offs(1,j+1);
       
       axis_x = (o2-o1)/(s1-s2);
       axis_y = (s1*axis_x) + o1;
       axis_list{i}(j,1) = axis_x;
       axis_list{i}(j,2) = axis_y;
       
       axis_big(count,1) = axis_x;
       axis_big(count,2) = axis_y;
       count = count + 1;
       
    end
end
rot_point = axis_big(:,1);

title('mouse histogram of x coords per person');
[~,x] = sort(abs(rot_point)); x = rot_point(x(round(.05*length(rot_point)):round(.95*length(rot_point))));
histogram(x,20); box off
set(gca,'TickDir','out');
disp(['median axis of rotation: ' num2str(10.^(median(rot_point)))])
title('X coords of 1/f rotation axes with depth'); 
xlabel('Depth'); ylabel('Intercecpt x-coord (hz)');xlim([-10 10]);
%% simple r-square fit on data
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
dpth = repmat([1:23],[1 19]); 

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

fx(bad_inds) = nan;
pow = pow(:,11:2901); fx = fx(11:2901);
pow(:,find(isnan(fx))) = []; fx(find(isnan(fx))) = [];
avgpwr = pow;

est_lyr_mid=[1.06 5.5275 10.0455 14.4280 20.35];
est_lyr_lab={'I', 'II/III','IV','V','VI'};

p_all = zeros(size(avgpwr,1),2);
for k = 1 : size(avgpwr,1)
    fx2 = fx; pwr2 = avgpwr(k,:);
    [p_all(k,:) s] = polyfit(log(fx2),log(pwr2),1);
    r_fit(k) = 1 - (s.normr/norm(log(pwr2) - mean(log(pwr2))))^2;
end

slp = p_all(:,1);
offs = p_all(:,2);
slp = -slp;

[r,pv]=corr(slp,dpth');
[r,pv]=corr(offs,dpth');

h_exps = slp; h_offset = offs;

for k = 1 : 19
    h_exps(find(sub==k)) = h_exps(find(sub==k)) ./ max(h_exps(find(sub==k)));
    if min(h_offset(find(sub==k))) < 0
        h_offset(find(sub==k)) = h_offset(find(sub==k)) - min(h_offset(find(sub==k)));
    end
     h_offset(find(sub==k)) = h_offset(find(sub==k)) ./ max(h_offset(find(sub==k)));
end

for k = 1 : 19
    [roff(k),~] = corr(dpth(find(sub==k))', h_offset(find(sub==k)));
    [rslp(k),~] = corr(dpth(find(sub==k))', h_exps(find(sub==k)));
end

disp(['mean sing subj slope fit w/ simple linear: ' num2str(mean(rslp.^2))])
disp(['sem sing subj slope fit w/ simple linear: ' num2str(std(slp.^2)./sqrt(19))])
disp(['mean sing subj offset fit w/ simple linear: ' num2str(mean(roff.^2))])
disp(['sem sing subj offset fit w/ simple linear: ' num2str(std(roff.^2)./sqrt(19))])
% now plot overall slope and offset changes, copy-paste from other human plotting sections.

clear g
figure('units','normalized','outerposition',[.2 0 .6 1]);

g(1,1)=gramm('x',dpth,'y',h_exps,'color',sub);
g(1,1).set_continuous_color('active',false);
g(1,1).geom_point();
g(1,1).set_names('x','','y','1/f Slope','color','Pt');
g(1,1).axe_property('FontSize',20);
g(1,1).set_title('Slope vs. Cortical Depth','FontSize',30);
g(1,1).set_text_options('legend_scaling',2,'legend_title_scaling',1.5,'Font','Arial');
g(1,1).set_point_options('base_size',20);
g(1,1).axe_property('XTick',est_lyr_mid);
g(1,1).axe_property('XTickLabel',est_lyr_lab);
g(1,1).axe_property('YLim',[.3 1]);
g(1,1).axe_property('YTick',[.3 .65 1]);
g(1,1).axe_property('FontSize',25,'FontName','Arial');
g(1,1).axe_property('TickDir','out');
g(1,1).update('color',ones(1,length(dpth)));
g(1,1).set_line_options('base_size',20);
g(1,1).stat_summary('geom','line');
g(1,1).set_color_options('map',[0 0 0],'n_lightness',1,'n_color',1);
g(1,1).set_text_options('label_scaling',25);
g(2,1)=gramm('x',dpth,'y',h_offset,'color',sub);
g(2,1).set_continuous_color('active',false);
g(2,1).geom_point();
g(2,1).set_names('x','Estimated Cortical Layer','y','1/f Offset','color','Pt');
g(2,1).axe_property('FontSize',20);
g(2,1).set_title('Offset vs. Cortical Depth','FontSize',30);
g(2,1).set_text_options('legend_scaling',2,'legend_title_scaling',1.5,'Font','Arial');
g(2,1).set_point_options('base_size',20);
g(2,1).axe_property('XTick',est_lyr_mid);
g(2,1).axe_property('XTickLabel',est_lyr_lab);
g(2,1).axe_property('YLim',[.3 1]);
g(2,1).axe_property('YTick',[.3 .65 1]);
g(2,1).axe_property('FontSize',25,'FontName','Arial');
g(2,1).axe_property('TickDir','out');
g(2,1).update('color',ones(1,length(dpth)));
g(2,1).set_line_options('base_size',20);
g(2,1).stat_summary('geom','line');
g(2,1).set_color_options('map',[0 0 0],'n_lightness',1,'n_color',1);
g(2,1).set_text_options('label_scaling',25);
g.draw();
pause(1)
set(gcf,'PaperSize',[20 20],'renderer','painters');
saveas(gcf,'C:\Users\Loomis\Documents\FOOOF_nu\final_figs\figscratch\mouse_slopeoffset_simplefit.svg');