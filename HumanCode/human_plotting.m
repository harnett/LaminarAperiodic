%% superficial middle deep power spectra
clear

cd('C:\Users\Loomis\Documents\FOOOF_nu\HumanCode')

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
avgpwr(:,2951:3021) = nan;
figure('units','normalized','outerposition',[0 0 1 1]);
for k = 1 : 345
    if dpth(k) <=5
        c = [[0 114 189]./255 .2];
        loglog(frq,avgpwr(k,:),'color',c), hold on
    elseif dpth(k) >= 16
        c = [[217 83 25]./255 .15];
        loglog(frq,avgpwr(k,:),'color',c), hold on
    end
end, xlim([1 300])
hold on
loglog(frq,nanmean(avgpwr(find(dpth<=5),:)),'color',[0 114 189]./255,'LineWidth',10); hold on
loglog(frq,nanmean(avgpwr(find(dpth>=16),:)),'color',[217 83 25]./255,'LineWidth',10);
set(gca,'TickDir','Out')
box off
ylabel('Power (a.u.)'), xlabel('Frequency (Hz)')
ylim([10^-1 10^5]), set(gca,'YTick',[10^-1 10^2 10^5],'XTick',[1 10 100 300]);
pause(1)
set(gcf,'PaperSize',[20 20],'renderer','painters');
saveas(gcf,'C:\Users\Loomis\Documents\FOOOF_nu\final_figs\figscratch\human_all_spctra.svg','svg');
%% axis of rotation
clear
cd C:\Users\Loomis\Documents\FOOOF_nu\HumanCode
load('all_exps')
load('all_offset')
load sub.mat
axis_list = {};
axis_big = [];
figure; 
count = 1;
for i=1:16
    for j=1:(length(all_exps{i})-1)
        
       s1 = -all_exps{i}(j);
       s2 = -all_exps{i}(j+1);
       o1 = all_offset{i}(j);
       o2 = all_offset{i}(j+1);
       
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
% rot_point(abs(rot_point)>10) = [];
% rot_poiint = (rot_point - mean(rot_point)) ./ std(rot_point);
% [H, pValue, KSstatistic, criticalValue] = kstest(rot_point);
subplot(1,2,2)
title('histogram of x coords per person');
[~,x] = sort(abs(rot_point)); x = rot_point(x(round(.05*length(rot_point)):round(.95*length(rot_point))));
disp(['median axis of rotation: ' num2str(10.^(median(rot_point)))])
histogram(x,20), xlim([-10 10])
%title('X coords of 1/f rotation axes with depth'); 
%xlabel('Depth'); ylabel('Intercecpt x-coord (hz)')
xlim([-10 10]);
xlabel('Frequency at Intersection (Hz)'), ylabel('Number of Intersections')
set(gca,'XTick',[-10 -2 0 2 10],'YTick',[0 70 140],'FontName','Arial','FontSize',24)
set(gca,'TickDir','Out')
box off

subjectno = 8;
selectchans = 3:5;

stringy = append('indiv_',string(subjectno),'.mat');

load(stringy); %this is subject 15. It should have been generated as a byproduct of the master human code.

subplot(1,2,1)
for i=selectchans
    loglog(indiv_frq,indiv_pow(i,:)); hold on;
end

slopes = -all_exps{subjectno}(1,selectchans);
offsets = all_offset{subjectno}(1,selectchans);

x=linspace(1,1000, 1000); % Adapt n for resolution of graph

for j=1:2
    y = x.^slopes(j)*(10^offsets(j));
    loglog(x,y,'LineWidth',5), hold on;
end
pbaspect([2 1 1])

axis_x = (o2-o1)/(s1-s2);

xlim([30 290]);% ylim([1E-5 1E-3]); %also modify ylim for diff peoples
title(append('Subject ',string(subjectno),' channels ',string(selectchans(1)), ':',string(selectchans(2))));
%xline(10.^mean(diff(offsets)./-diff(slopes)));
od = diff(offsets); sd = -diff(slopes);
%xline(10.^(od(1)/sd(1)));
xline(10.^(od(1)/sd(1)));
%%
clear
est_lyr_mid=[.05 .175 .4 .5875 .7125 .8875].*23;
est_lyr_lab={'I', 'II','III','IV','V','VI'};

load('all_exps')
load('all_offset')
offs = all_offset{3};
exps_and_offs_3 = [all_exps{3}./max(all_exps{3}); offs./max(offs)];

figure('units','normalized','outerposition',[.2 .2 .5 .65]);
g=gramm('x',1:23,'y',exps_and_offs_3,'color',[1,2]);
g.stat_glm('geom', 'line','disp_fit',true,'r2',true);
g.set_color_options('map',[0 0 0; .6 .6 .6],'n_lightness',1,'n_color',2);
g.set_names('x','Cortical Layer','y','Normalized Slope / Offset');
g.set_title('','FontSize',23);
g.set_text_options('label_scaling',4,'base_size',25);
g.set_line_options('base_size',6);
g.axe_property('YLim',[.4 1]);
g.axe_property('XTick',est_lyr_mid);
g.axe_property('XTickLabel',est_lyr_lab);
g.axe_property('YTick',[.4 .7 1.0]);
g.axe_property('TickDir','Out')
%g.axe_property('YTickLabel',[0.5 1.0 1.4])
g.geom_point();
g.set_point_options('base_size',13);
g.set_text_options('font','Arial','label_scaling',1.5,'base_size',25);
g.draw();
axis square;
pause(1)
set(gcf,'PaperSize',[20 20],'renderer','painters');
saveas(gcf,'C:\Users\Loomis\Documents\FOOOF_nu\final_figs\figscratch\human_ex_fits.svg');
%%
clear

est_lyr_mid=[.05 .175 .4 .5875 .7125 .8875].*23;
est_lyr_lab={'I', 'II','III','IV','V','VI'};

load all_exps.mat
load all_offset.mat
load all_cfs.mat
load all_r2.mat
load sub.mat
load dpth_one_over_fv2.mat

h_exps = horzcat(all_exps{:});
h_r2 = horzcat(all_r2{:});
h_offset = horzcat(all_offset{:});

h_exps_orig = h_exps;
dpth_orig = dpth;
sub_orig = sub;
r2_orig = h_r2;
offset_orig = h_offset;
% NORMALIZE 1/F WITHIN EACH SUBJECT & OFFSET IN EACH SUBJECT TOO
for k = 1 : 20
    h_exps(find(sub==k)) = h_exps(find(sub==k)) ./ max(h_exps(find(sub==k)));
    if min(h_offset(find(sub==k))) < 0
        h_offset(find(sub==k)) = h_offset(find(sub==k)) - min(h_offset(find(sub==k)));
    end
     h_offset(find(sub==k)) = h_offset(find(sub==k)) ./ max(h_offset(find(sub==k)));
end

disp(['exps range from ' num2str(min(h_exps_orig)) ' to ' num2str(max(h_exps_orig))])
[r,pv] = corr(dpth_orig(:),h_exps_orig(:));
disp(['overall slope fit: ' num2str(r.^2)])
disp(['overall slope pv: ' num2str(pv)])
[r,pv] = corr(dpth_orig(:),offset_orig(:));
disp(['overall offset fit: ' num2str(r.^2)])
disp(['overall offset pv: ' num2str(pv)])
for k = 1 : 16
exp_superficial(k) = mean(h_exps_orig(intersect(find(sub == k),find(dpth<=11))));
exp_deep(k) = mean(h_exps_orig(intersect(find(sub == k),find(dpth>=16))));
off_superficial(k) = mean(offset_orig(intersect(find(sub == k),find(dpth<=11))));
off_deep(k) = mean(offset_orig(intersect(find(sub == k),find(dpth>=16))));
end
[r,pv] = corr(h_exps_orig(:),offset_orig(:));
[r2,pv2] = partialcorr(h_exps_orig(:),offset_orig(:),dpth(:));
disp(['correlation between offset and slope r2: ' num2str(r.^2)])
disp(['correlation between offset and slope pv: ' num2str(pv)]) 
disp(['partial correlation between offset and slope r2: ' num2str(r2.^2)])
disp(['partial correlation between offset and slope pv: ' num2str(pv2)]) 
disp([num2str(100*mean((exp_superficial - exp_deep) ./ exp_superficial)) ' % change in slope from SG to IG'])
disp([num2str(100*mean((off_superficial - off_deep) ./ off_superficial)) ' % change in offset from SG to IG' ])
[rtmp,pvtmp] = corr(dpth,h_r2');
disp(['correlation between fit and depth r2: ' num2str(rtmp.^2)])
disp(['correlation between fit and depth pv: ' num2str(pvtmp)])
[rtmp,pvtmp] = corr(h_exps_orig(:),h_r2');
disp(['correlation between fit and slope r2: ' num2str(rtmp.^2)])
disp(['correlation between fit and slope pv: ' num2str(pvtmp)])
[rtmp,pvtmp] = corr(offset_orig(:),h_r2');
disp(['correlation between fit and offset r2: ' num2str(rtmp.^2)])
disp(['correlation between fit and offset pv: ' num2str(pvtmp)])
%% to exclude subs
excludesubs = [];%[4,5,14]

deleteindices = [];
count = 1;
for k=1:length(sub)
    if ismember(sub(k,1),excludesubs) %if the subject rn is someone we donut like
        deleteindices(1,count) = k;
        count = count + 1;
    end
end

%% overall slope vs. depth
clear g
figure('units','normalized','outerposition',[.2 0 .6 1])

g(1,1)=gramm('x',dpth,'y',h_exps,'color',sub);
g(1,1).set_continuous_color('active',false);
g(1,1).geom_point();
g(1,1).set_names('x','','y','1/f Slope','color','Pt');
g(1,1).axe_property('FontSize',20);
%g(1,1).set_title('Slope vs. Cortical Depth','FontSize',30);
g(1,1).set_text_options('legend_scaling',2,'legend_title_scaling',1.5);
g(1,1).set_point_options('base_size',10);
g(1,1).axe_property('XTick',est_lyr_mid);
g(1,1).axe_property('XTickLabel',est_lyr_lab);
g(1,1).axe_property('YLim',[.3 1]);
g(1,1).axe_property('YTick',[.3 .65 1]);
g(1,1).axe_property('FontSize',25);
g(1,1).axe_property('TickDir','Out')
g(1,1).update('color',ones(1,length(dpth)));
g(1,1).set_line_options('base_size',10);
g(1,1).stat_summary('geom','line');
g(1,1).set_color_options('map',[0 0 0],'n_lightness',1,'n_color',1);
g(1,1).set_text_options('label_scaling',25,'Font','Arial');
g(2,1)=gramm('x',dpth,'y',h_offset,'color',sub);
g(2,1).set_continuous_color('active',false);
g(2,1).geom_point();
g(2,1).set_names('x','','y','1/f Offset','color','Pt');
g(2,1).axe_property('FontSize',20);
%g(2,1).set_title('Offset vs. Cortical Depth','FontSize',30);
g(2,1).set_text_options('legend_scaling',2,'legend_title_scaling',1.5,'Font','Arial');
g(2,1).set_point_options('base_size',10);
g(2,1).axe_property('XTick',est_lyr_mid);
g(2,1).axe_property('XTickLabel',est_lyr_lab);
g(2,1).axe_property('YLim',[.3 1]);
g(2,1).axe_property('YTick',[.3 .65 1]);
g(2,1).axe_property('FontSize',25);
g(2,1).axe_property('TickDir','Out')
g(2,1).update('color',ones(1,length(dpth)));
g(2,1).set_line_options('base_size',10);
g(2,1).stat_summary('geom','line');
g(2,1).set_color_options('map',[0 0 0],'n_lightness',1,'n_color',1);
g(2,1).set_text_options('label_scaling',25,'Font','Arial');
g.draw();
pause(1)
set(gcf,'PaperSize',[20 20],'renderer','painters');
saveas(gcf,'C:\Users\Loomis\Documents\FOOOF_nu\final_figs\figscratch\human_slopeoffset_overall.svg');
%% individual subs slope vs. depth
figure('units','normalized','outerposition',[0 0 1 1]);

g2=gramm('x',dpth,'y',h_exps,'color',sub);
g2.set_continuous_color('active',false);
g2.facet_wrap(sub,'ncols',7,'scale','free');
g2.geom_point();
g2.axe_property('FontSize',8);
g2.stat_glm('r2','true','geom','line');
g2.set_line_options('base_size',4);
g2.set_names('x','','y','1/f Slope','color','Pt','column', 'Pt');
g2.set_title('1/f Slope and Cortical Depth in Single Patients','FontSize',30);
g2.axe_property('XTick',est_lyr_mid([1 4 6]));
g2.axe_property('XTickLabel',est_lyr_lab([1 4 6]));
g2.axe_property('TickDir','Out')
g2.set_text_options('Font','Arial');
min_ylim = [];
seen = [1];
lowest_y = 1;
for k=2:length(sub)
    if h_exps(k) < lowest_y
        lowest_y = h_exps(k);
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

for k = 1 : 16
    all_r(k) = g2.results.stat_glm(k).model.Rsquared.Ordinary;
end

for k = 1 : 16
    set(g2.facet_axes_handles(k),'YLim',all_ylim(k,:),'YTick',all_ytick(k,:),'FontSize',18,'FontName','Arial');
    g2.update();
end
pause(1)
set(gcf,'PaperSize',[20 20],'renderer','painters')
saveas(gcf,'C:\Users\Loomis\Documents\FOOOF_nu\final_figs\figscratch\human_indivslope.svg');

disp(['mean sing subj slope fit: ' num2str(mean(all_r))])
disp(['sem sing subj slope fit: ' num2str(std(all_r)./sqrt(16))])
%% slope and r-squared histograms
figure('units','normalized','outerposition',[0 0 1 1]);

%OK: making histograms!
clear g3

g3(1,1)=gramm('x',h_exps_orig);
g3(1,1).stat_bin('nbins',11);
%g3(1,1).set_title('1/f slope');
g3(1,1).set_names('x','1/f Slope','y','# of channels');
g3(1,1).axe_property('XTick',[.5 1.4 2.3]);
g3(1,1).axe_property('XLim',[.5 2.3]);
g3(1,1).axe_property('YLim',[0 90]);
g3(1,1).axe_property('YTick',[0 45 90]);
g3(1,1).set_color_options('map',[19 159 255]./255,'n_lightness',1,'n_color',1);
g3(1,1).set_text_options('Font','Arial');
g3(1,2)=gramm('x',h_r2);
g3(1,2).stat_bin('nbins',11);
g3(1,2).set_names('x','R^2','y','# of channels');
g3.axe_property('TickDir','Out')
%g3(1,2).set_title('R^2');
g3(1,2).axe_property('XTick',[.7 .85 1]);
g3(1,2).axe_property('XLim',[.7 1]);
g3(1,2).axe_property('YLim',[0 90]);
g3(1,2).axe_property('YTick',[0 45 90]);
g3(1,2).set_text_options('Font','Arial');
g3(1,2).set_color_options('map',[255 94 105]./255,'n_lightness',1,'n_color',1);
g3.draw();
pause(1)
set(gcf,'PaperSize',[20 20],'renderer','painters');
saveas(gcf,'C:\Users\Loomis\Documents\FOOOF_nu\final_figs\figscratch\human_r2andrawslope.svg');

disp(['mean channel r2 fit: ' num2str(mean(h_r2))])
disp(['sem channel r2 fit: ' num2str(std(h_r2)./sqrt(length(h_r2)))])
disp(['channel r2 fit ranges from ' num2str(min(h_r2)) ' to ' num2str(max(h_r2)) ] )
%% individual offsets vs. depth
figure('units','normalized','outerposition',[0 0 1 1]);

g5=gramm('x',dpth,'y',h_offset,'color',sub);
g5.set_continuous_color('active',false);
g5.facet_wrap(sub,'ncols',7,'scale','free');
g5.geom_point();
g5.axe_property('FontSize',8);
g5.stat_glm('r2','true','geom','line');
g5.set_line_options('base_size',4);
g5.set_names('x','','y','1/f Offset','color','Pt','column', 'Pt');
g5.set_title('1/f Offset and Cortical Depth in Single Patients','FontSize',30);
g5.axe_property('XTick',est_lyr_mid([1 4 6]));
g5.axe_property('XTickLabel',est_lyr_lab([1 4 6]));
g5.axe_property('TickDir','Out')
%g2.axe_property('FontSize',24);
%g2.axe_property('YTick',[.3 .65 1]);
%g2.set_text_options('title_scaling',0.8)
g5.set_text_options('Font','Arial');
min_ylim = [];
seen = [1];
lowest_y = 1;
for k=2:length(sub)
    if h_offset(k) < lowest_y
        lowest_y = h_offset(k);
    end
    if not(ismember(sub(k,1),seen))
        seen = [seen,sub(k,1)];
        min_ylim = [min_ylim; (round(10*lowest_y)/10) - 0.1,1];
        lowest_y = 1;
    end
end
min_ylim = [min_ylim; (round(10*lowest_y)/10),1];

all_ylim = min_ylim(:,:);
all_ytick = [all_ylim(:,1) mean(all_ylim,2) all_ylim(:,2)];

g5.set_text_options('base_size',15,'legend_scaling',1.2,'legend_title_scaling',3,'facet_scaling',1.5);
g5.set_layout_options('title_centering','plot','legend',0);
g5.set_point_options('base_size',10);
g5.draw();

for k = 1 : 16
    all_roff(k) = g5.results.stat_glm(k).model.Rsquared.Ordinary;
end

for k = 1 : 16
    set(g5.facet_axes_handles(k),'YLim',all_ylim(k,:),'YTick',all_ytick(k,:),'FontSize',18,'FontName','Arial');
    g5.update();
end
pause(1)
set(gcf,'PaperSize',[20 20],'renderer','painters');
saveas(gcf,'C:\Users\Loomis\Documents\FOOOF_nu\final_figs\figscratch\human_indivoffset.svg');

disp(['mean sing subj offset fit: ' num2str(mean(all_roff))])
disp(['sem sing subj offset fit: ' num2str(std(all_roff)./sqrt(16))])
%% simple r-square fit on data
clear
est_lyr_mid=[.05 .175 .4 .5875 .7125 .8875].*23;
est_lyr_lab={'I', 'II','III','IV','V','VI'};
load new_bi_all.mat
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

for k = 1 : 16
    tmp = avgpwr(find(sub==k),:);
    avgpwr(find(sub==k),:) = avgpwr(find(sub==k),:) ./ nanmedian(tmp(:));
end

fx = linspace(.1,1000,10001); fx = fx(11:2901);
avgpwr = avgpwr(:,11:2901);

p_all = zeros(size(avgpwr,1),2);
for k = 1 : size(avgpwr,1)
    fx2 = fx; pwr2 = avgpwr(k,:);  fx2(find(isnan(pwr2))) = []; pwr2(find(isnan(pwr2))) = [];
    [p_all(k,:) s] = polyfit(log(fx2),log(pwr2),1);
    r_fit(k) = 1 - (s.normr/norm(log(pwr2) - mean(log(pwr2))))^2;
end

slp = p_all(:,1);
offs = p_all(:,2);
slp = -slp;

h_exps = slp; h_offset = offs;

[r,pv] = corr(dpth(:),h_exps(:));
disp(['overall slope simple fit: ' num2str(r.^2)])
disp(['overall slope simple pv: ' num2str(pv)])
[r,pv] = corr(dpth(:),h_offset(:));
disp(['overall offset simple fit: ' num2str(r.^2)])
disp(['overall offset simple pv: ' num2str(pv)])

%normalize
for k = 1 : 16
    h_exps(find(sub==k)) = h_exps(find(sub==k)) ./ max(h_exps(find(sub==k)));
    if min(h_offset(find(sub==k))) < 0
        h_offset(find(sub==k)) = h_offset(find(sub==k)) - min(h_offset(find(sub==k)));
    end
     h_offset(find(sub==k)) = h_offset(find(sub==k)) ./ max(h_offset(find(sub==k)));
end

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
g(1,1).axe_property('FontSize',25);
g(1,1).axe_property('TickDir','Out')
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
g(2,1).axe_property('FontSize',25);
g(2,1).axe_property('TickDir','Out')
g(2,1).update('color',ones(1,length(dpth)));
g(2,1).set_line_options('base_size',20);
g(2,1).stat_summary('geom','line');
g(2,1).set_color_options('map',[0 0 0],'n_lightness',1,'n_color',1);
g(2,1).set_text_options('label_scaling',25);
g.draw();
pause(1)
set(gcf,'PaperSize',[20 20],'renderer','painters');
saveas(gcf,'C:\Users\Loomis\Documents\FOOOF_nu\final_figs\figscratch\human_slopeoffset_simplefit.svg');