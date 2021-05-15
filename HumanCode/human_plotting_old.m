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

% plotting *all* spectra; think it looks too noisy tho...
% for k = 1 : size(avgpwr,1)
%     if dpth(k) <= 11
%             plot(frq,avgpwr(k,:),'color',[[0 114 189]./255 .05]), hold on
%     elseif dpth(k) >= 16
%             plot(frq,avgpwr(k,:),'color',[[237 177 32]./255 .05]), hold on
%     else
%             plot(frq,avgpwr(k,:),'color',[[217 83 25]./255 .05]), hold on
%     end
% end
% set(gca,'XScale','Log','YScale','Log')
% xlim([30 290])
% hold on

% plot superficial / deep spctra meaned withn superficial / deep per
% subject
% for k = 1 : 16
% loglog(frq,nanmean(avgpwr(intersect(find(sub==k),find(dpth<=5)),:)),'color',[0 0 1 .2]), hold on, loglog(frq,nanmean(avgpwr(intersect(find(sub==k),find(dpth>=16)),:)),'color',[1 0 0 .2]), xlim([1 290])
% end, xlim([1 290])
% hold on
% loglog(frq,nanmean(avgpwr(find(dpth<=5),:)),'b','LineWidth',5), hold on
% loglog(frq,nanmean(avgpwr(find(dpth>=16),:)),'r','LineWidth',5)
% box off
% ylabel('Power (a.u.)'), xlabel('Frequency (Hz)')
% plot superficial / deep spctra all channels
figure
for k = 1 : 345
    if dpth(k) <=5
        c = [[0 114 189]./255 .15];
        loglog(frq,avgpwr(k,:),'color',c), hold on
    elseif dpth(k) >= 16
        c = [[237 177 32]./255 .15];
        loglog(frq,avgpwr(k,:),'color',c), hold on
    end
end, xlim([1 290])
hold on
loglog(frq,nanmean(avgpwr(find(dpth<=5),:)),'color',[0 114 189]./255,'LineWidth',10), hold on
loglog(frq,nanmean(avgpwr(find(dpth>=16),:)),'color',[237 177 32]./255,'LineWidth',10)
box off
ylabel('Power (a.u.)'), xlabel('Frequency (Hz)')
ylim([10^-1 10^5]), set(gca,'YTick',[10^-1 10^2 10^5])
% plot shaded errorbar superficial middle deep
% figure
% shadedErrorBar(frq,nanmean(avgpwr(find(dpth>=16),:)),nanstd(avgpwr(find(dpth>=16),:))./sqrt(345),'LineProps',{'color',[237 177 32]./255})
% hold on
% shadedErrorBar(frq,nanmean(avgpwr(intersect(find(dpth<16),find(dpth>11)),:)),nanstd(avgpwr(intersect(find(dpth<16),find(dpth>11)),:))./sqrt(345),'LineProps',{'color',[217 83 25]./255})
% hold on
% shadedErrorBar(frq,nanmean(avgpwr(find(dpth<=11),:)),nanstd(avgpwr(find(dpth<=11),:))./sqrt(345),'LineProps',{'color',[0 114 189]./255})
% set(gca,'XScale','Log','YScale','Log')
% xlim([1 290])%, ylim([2 38])
% xlabel('Frequency (Hz)'), ylabel('Power (a.u.)')
%%
clear
est_lyr_mid=[.05 .175 .4 .5875 .7125 .8875].*23;
est_lyr_lab={'I', 'II','III','IV','V','VI'};

load('all_exps')
load('all_offset')
offs = all_offset{3}; offs = offs - min(offs);
exps_and_offs_3 = [all_exps{3}./max(all_exps{3}); offs./max(offs)];

figure();
g=gramm('x',1:23,'y',exps_and_offs_3,'color',[1,2]);
g.stat_glm('geom', 'line','disp_fit',true,'r2',true);
g.set_color_options('map',[0 0 0; .6 .6 .6]);
g.set_title('1/f slope and offset vs. cortical depth','FontSize',23)
g.set_text_options('legend_scaling',2,'legend_title_scaling',1.5)
g.set_point_options('base_size',17)
g.axe_property('YLim',[0 1]);
g.axe_property('XTick',est_lyr_mid);
g.axe_property('XTickLabel',est_lyr_lab);
g.axe_property('YTick',[0 0.5 1.0])
%g.axe_property('YTickLabel',[0.5 1.0 1.4])
g.geom_point()
g.draw()
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
%^ just for debugging.

% 

% NORMALIZE 1/F WITHIN EACH SUBJECT & OFFSET IN EACH SUBJECT TOO
for k = 1 : 20
    h_exps(find(sub==k)) = h_exps(find(sub==k)) ./ max(h_exps(find(sub==k)));
    if min(h_offset(find(sub==k))) < 0
        h_offset(find(sub==k)) = h_offset(find(sub==k)) - min(h_offset(find(sub==k)));
    end
     h_offset(find(sub==k)) = h_offset(find(sub==k)) ./ max(h_offset(find(sub==k)));
end


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
g(1,1).set_continuous_color('active',false)
g(1,1).geom_point()
g(1,1).set_names('x','','y','1/f Slope','color','Pt')
g(1,1).axe_property('FontSize',20);
g(1,1).set_title('1/f Slope and Cortical Depth','FontSize',23)
g(1,1).set_text_options('legend_scaling',2,'legend_title_scaling',1.5)
g(1,1).set_point_options('base_size',20)
% g.draw()
g(1,1).axe_property('XTick',est_lyr_mid);
g(1,1).axe_property('XTickLabel',est_lyr_lab);
g(1,1).axe_property('YLim',[.3 1]);
g(1,1).axe_property('YTick',[.3 .65 1]);
g(1,1).axe_property('FontSize',25)
g(1,1).update('color',ones(1,length(dpth)))
g(1,1).set_line_options('base_size',20)
g(1,1).stat_summary('geom','line')
g(1,1).set_color_options('map',[0 0 0])  
g(1,1).set_text_options('label_scaling',20)
%g.draw()

g(2,1)=gramm('x',dpth,'y',h_offset,'color',sub);
g(2,1).set_continuous_color('active',false)
g(2,1).geom_point()
g(2,1).set_names('x','Estimated Cortical Layer','y','Offset','color','Pt')
g(2,1).axe_property('FontSize',20);
g(2,1).set_title('Offset vs. Cortical Depth','FontSize',23)
g(2,1).set_text_options('legend_scaling',2,'legend_title_scaling',1.5)
g(2,1).set_point_options('base_size',20)
% g.draw()
g(2,1).axe_property('XTick',est_lyr_mid);
g(2,1).axe_property('XTickLabel',est_lyr_lab);
g(2,1).axe_property('YLim',[.3 1]);
g(2,1).axe_property('YTick',[.3 .65 1]);
g(2,1).axe_property('FontSize',25)
g(2,1).update('color',ones(1,length(dpth)))
g(2,1).set_line_options('base_size',20)
g(2,1).stat_summary('geom','line')
g(2,1).set_color_options('map',[0 0 0])  
g.draw()

%% individual subs slope vs. depth
figure('units','normalized','outerposition',[0 0 1 1])

g2=gramm('x',dpth,'y',h_exps,'color',sub);
g2.set_continuous_color('active',false)
g2.facet_wrap(sub,'ncols',7,'scale','free')
g2.geom_point()
g2.axe_property('FontSize',8);
g2.stat_glm('r2','true')
g2.set_names('x','','y','1/f Slope','color','Pt','column', 'Pt')
g2.set_title('1/f Slope and Cortical Depth in Single Patients','FontSize',14.5)
g2.axe_property('XTick',est_lyr_mid([1 4 6]));
g2.axe_property('XTickLabel',est_lyr_lab([1 4 6]));

min_ylim = [];
seen = [1];
lowest_y = 1;
for k=2:length(sub)
    if h_exps(1,k) < lowest_y
        lowest_y = h_exps(1,k);
    end
    if not(ismember(sub(k,1),seen))
        seen = [seen,sub(k,1)];
        min_ylim = [min_ylim; (round(10*lowest_y)/10) - 0.1,1];
        lowest_y = 1;
    end
end
min_ylim = [min_ylim; (round(10*lowest_y)/10) - 0.1,1];

all_ylim = min_ylim(:,:);
all_ytick = [all_ylim(:,1) mean(all_ylim,2) all_ylim(:,2)];

%g2.axe_property('YLim',[.3 1])
g2.set_text_options('legend_scaling',1.2,'legend_title_scaling',3,'facet_scaling',1.5)
g2.set_layout_options('title_centering','plot','legend',0)
g2.set_point_options('base_size',8)
% Do the actual drawing
g2.draw()

for k = 1 : 16
    all_r(k) = g2.results.stat_glm(k).model.Rsquared.Ordinary;
end

for k = 1 : 16
    set(g2.facet_axes_handles(k),'YLim',all_ylim(k,:),'YTick',all_ytick(k,:));
    g2.update()
end
pause(1)
%% slope and r-squared histograms
figure('units','normalized','outerposition',[0 0 1 1])

% mean(all_r), std(all_r)/sqrt(16)
%OK: making histograms!
clear g3

g3(1,1)=gramm('x',h_exps_orig);
g3(1,1).stat_bin('nbins',11);
%g3(1,1).set_title('1/f slope');
g3(1,1).set_names('x','1/f Slope','y','# of channels')
g3(1,1).axe_property('XTick',[.5 1.4 2.3]);
g3(1,1).axe_property('XLim',[.5 2.3]);
g3(1,1).axe_property('YLim',[0 90]);
g3(1,1).axe_property('YTick',[0 45 90]);
g3(1,1).set_color_options('map',[19 159 255]./255);
g3(1,2)=gramm('x',h_r2);
g3(1,2).stat_bin('nbins',11);
g3(1,2).set_names('x','R^2','y','# of channels')
%g3(1,2).set_title('R^2');
g3(1,2).axe_property('XTick',[.7 .85 1]);
g3(1,2).axe_property('XLim',[.7 1]);
g3(1,2).axe_property('YLim',[0 90]);
g3(1,2).axe_property('YTick',[0 45 90]);
g3(1,2).set_color_options('map',[255 94 105]./255);
g3.draw();
%% individual offsets vs. depth
figure('units','normalized','outerposition',[0 0 1 1])

g5=gramm('x',dpth,'y',h_offset,'color',sub);
g5.set_continuous_color('active',false)
% Subdivide the data in subplots horizontally by region of origin
g5.facet_wrap(sub,'ncols',7,'scale','free')
% Plot raw data as points
g5.geom_point()
g5.axe_property('FontSize',8);
% Plot linear fits of the data with associated confidence intervals
g5.stat_glm('r2','true')
%g5.stat_fit('fun',@(alpha,beta,x)alpha*exp(x*beta),'disp_fit',true)

% Set appropriate names for legends
g5.set_names('x','','y','offset','color','Pt','column', 'Pt')
g5.set_title('1/f Offset and Cortical Depth in Single Patients','FontSize',14.5)
%Set figure title
g5.axe_property('XTick',est_lyr_mid([1 4 6]));
g5.axe_property('XTickLabel',est_lyr_lab([1 4 6]));
%g2.axe_property('FontSize',24);
%g2.axe_property('YTick',[.3 .65 1]);
%g2.set_text_options('title_scaling',0.8)

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

g5.set_text_options('legend_scaling',1.2,'legend_title_scaling',3,'facet_scaling',1.5)
g5.set_layout_options('title_centering','plot','legend',0)
g5.set_point_options('base_size',8)
% Do the actual drawing
g5.draw()

% for k = 1 : 16
%     all_roff(k) = g5.results.stat_glm(k).model.Rsquared.Ordinary;
% end
% mean(all_roff), std(all_roff)/sqrt(16);

for k = 1 : 16
    set(g5.facet_axes_handles(k),'YLim',all_ylim(k,:),'YTick',all_ytick(k,:));
    g5.update()
end
pause(1)
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

for k = 1 : 16
    h_exps(find(sub==k)) = h_exps(find(sub==k)) ./ max(h_exps(find(sub==k)));
    if min(h_offset(find(sub==k))) < 0
        h_offset(find(sub==k)) = h_offset(find(sub==k)) - min(h_offset(find(sub==k)));
    end
     h_offset(find(sub==k)) = h_offset(find(sub==k)) ./ max(h_offset(find(sub==k)));
end


% now plot overall slope and offset changes, copy-paste from other human plotting sections.

clear g
figure('units','normalized','outerposition',[.2 0 .6 1])

g(1,1)=gramm('x',dpth,'y',h_exps,'color',sub);
g(1,1).set_continuous_color('active',false)
g(1,1).geom_point()
g(1,1).set_names('x','','y','1/f Slope','color','Pt')
g(1,1).axe_property('FontSize',20);
g(1,1).set_title('1/f Slope and Cortical Depth','FontSize',23)
g(1,1).set_text_options('legend_scaling',2,'legend_title_scaling',1.5)
g(1,1).set_point_options('base_size',20)
% g.draw()
g(1,1).axe_property('XTick',est_lyr_mid);
g(1,1).axe_property('XTickLabel',est_lyr_lab);
g(1,1).axe_property('YLim',[.3 1]);
g(1,1).axe_property('YTick',[.3 .65 1]);
g(1,1).axe_property('FontSize',25)
g(1,1).update('color',ones(1,length(dpth)))
g(1,1).set_line_options('base_size',20)
g(1,1).stat_summary('geom','line')
g(1,1).set_color_options('map',[0 0 0])  
g(1,1).set_text_options('label_scaling',20)
%g.draw()

g(2,1)=gramm('x',dpth,'y',h_offset,'color',sub);
g(2,1).set_continuous_color('active',false)
g(2,1).geom_point()
g(2,1).set_names('x','Estimated Cortical Layer','y','Offset','color','Pt')
g(2,1).axe_property('FontSize',20);
g(2,1).set_title('Offset vs. Cortical Depth','FontSize',23)
g(2,1).set_text_options('legend_scaling',2,'legend_title_scaling',1.5)
g(2,1).set_point_options('base_size',20)
% g.draw()
g(2,1).axe_property('XTick',est_lyr_mid);
g(2,1).axe_property('XTickLabel',est_lyr_lab);
g(2,1).axe_property('YLim',[.3 1]);
g(2,1).axe_property('YTick',[.3 .65 1]);
g(2,1).axe_property('FontSize',25)
g(2,1).update('color',ones(1,length(dpth)))
g(2,1).set_line_options('base_size',20)
g(2,1).stat_summary('geom','line')
g(2,1).set_color_options('map',[0 0 0])  
g.draw()