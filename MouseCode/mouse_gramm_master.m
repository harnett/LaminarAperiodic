%%
% clear
% load ms_spctra.mat
% 
% for k = 1 : size(p2,3)
%     tmp = p2(:,11:2901,k);
%     p2(:,:,k) = p2(:,:,k)./nanmedian(tmp(:));
% end
% 
% sup = []; ifg = [];
% for k = 1 : size(p2,3)
% sup = [sup; p2(1:5,:,k)];
% ifg = [ifg; p2(16:23,:,k)];
% end
% for k = 1 : size(sup,1)
% loglog(fx,sup(k,:),'color',[0 0 1 .04]), hold on
% end
% for k = 1 : size(ifg,1)
% loglog(fx,ifg(k,:),'color',[1 0 0 .04]), hold on
% end
% loglog(fx,nanmean(sup),'b','LineWidth',5)
% loglog(fx,nanmean(ifg),'r','LineWidth',5)
% xlim([1 290])
%%
%addpath: gramm
clear

cd('C:\Users\Loomis\Documents\FOOOF_nu\MouseCode')

est_lyr_mid=[.05 .175 .4 .5875 .7125 .8875].*23;
est_lyr_lab={'I', 'II','III','IV','V','VI'};

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

%sub = sub_orig(:,:)
%dpth = dpth_orig(:,:)

%NORMALIZE 1/F WITHIN EACH SUBJECT & OFFSET IN EACH SUBJECT TOO
for k = 1 : 23
    p_exps(find(sub==k)) = p_exps(find(sub==k)) ./ max(p_exps(find(sub==k)));
    p_offs(find(sub==k)) = p_offs(find(sub==k)) ./ max(p_offs(find(sub==k)));
end

peoplewehate = [];%[5 15];%[4,5,14]

deleteindices = [];
count = 1;
for k=1:length(sub)
    if ismember(sub(k),peoplewehate) %if the subject rn is someone we donut like
        deleteindices(1,count) = k;
        count = count + 1;
    end
end

%deleteindices = [deleteindices,145,146,147,148,234,235,236,237,238]
%^ technically, make it the bottom 5 channels n ToBe

sub(deleteindices) = [];
dpth(deleteindices) = [];
p_exps(deleteindices) = [];
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
%%
figure('units','normalized','outerposition',[0 0 1 1])

g=gramm('x',dpth,'y',p_exps,'color',sub);
g.set_continuous_color('active',false)
g.set_line_options('base_size',1,'step_size',0.2,'style',{'--'})
g.geom_line()
g.set_names('x','Estimated Cortical Layer','y','1/f Slope','color','Pt')
g.axe_property('FontSize',20);
g.set_title('1/f Slope and Cortical Depth in Mice','FontSize',23)
g.set_text_options('legend_scaling',2,'legend_title_scaling',1.5)
g.set_point_options('base_size',10)
g.draw()
g.axe_property('XTick',est_lyr_mid);
g.axe_property('XTickLabel',est_lyr_lab);
g.axe_property('YLim',[.3 1]);
g.axe_property('YTick',[.3 .65 1]);
g.update('color',ones(1,length(dpth)))
g.set_line_options()
g.stat_summary('geom','line')
g.set_color_options('map',[0 0 0])  
g.draw()

% 
% ssl = []; isl = [];
% for k = 1 : 11
%     ss = p_exps(find(sub==k));
%     ssl(k) = mean(ss(1:11));
%     isl(k) = mean(ss(14:end));
% end

%%
figure('units','normalized','outerposition',[0 0 1 1])
g2=gramm('x',dpth,'y',p_exps,'color',sub);
g2.set_continuous_color('active',false)
g2.facet_wrap(sub,'ncols',7,'scale','free')
g2.geom_point()
g2.axe_property('FontSize',8);
g2.stat_glm('r2','true')
g2.set_names('x','','y','1/f Slope','color','Pt','column', 'Pt')
g2.set_title('1/f Slope and Cortical Depth in Single Mice','FontSize',14.5)
g2.axe_property('XTick',est_lyr_mid([1 4 6]));
g2.axe_property('XTickLabel',est_lyr_lab([1 4 6]));

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

g2.set_text_options('legend_scaling',1.2,'legend_title_scaling',3,'facet_scaling',1.5)
g2.set_layout_options('title_centering','plot','legend',0)
g2.set_point_options('base_size',8)
g2.draw()

for k = 1 : 16
    all_r(k) = g2.results.stat_glm(k).model.Rsquared.Ordinary;
end

for k = 1 : 16
    set(g2.facet_axes_handles(k),'YLim',all_ylim(k,:),'YTick',all_ytick(k,:));
    g2.update()
end
pause(1)
%%
%OK: making histograms!
figure('units','normalized','outerposition',[0 0 1 1])
clear g3

g3(1,1)=gramm('x',p_exps);
g3(1,1).stat_bin('nbins',10);
%g3(1,1).set_title('1/f slope');
g3(1,1).set_names('x','1/f Slope','y','# of channels')
g3(1,1).axe_property('XTick',[0 1 2]);
%g5.axe_property('XTickLabel',[0 1 2]);
g3(1,1).axe_property('XLim',[0 2]);
g3(1,1).axe_property('YLim',[0 140]);
g3(1,1).axe_property('YTick',[0 70 140]);

g3(1,2)=gramm('x',p_r2);
g3(1,2).stat_bin('nbins',20);
g3(1,2).set_names('x','R^2','y','# of channels')
%g3(1,2).set_title('R^2');
g3(1,2).axe_property('XTick',[0.7 0.85 1]);
g3(1,2).axe_property('XLim',[0.7 1]);
g3(1,2).axe_property('YLim',[0 140]);
g3(1,2).axe_property('YTick',[0 70 140]);
figure();
g3.draw();
%%
figure('units','normalized','outerposition',[0 0 1 1])
g4=gramm('x',dpth,'y',p_offs,'color',sub);
g4.set_continuous_color('active',false)
g4.set_line_options('base_size',1,'step_size',0.2,'style',{'--'})
g4.geom_line()
g4.set_names('x','Estimated Cortical Layer','y','offset','color','Pt')
g4.axe_property('FontSize',20);
g4.set_title('offset & cortical depth in mice','FontSize',23)
g4.set_text_options('legend_scaling',2,'legend_title_scaling',1.5)
g4.set_point_options('base_size',10)
% Do the actual drawing
g4.draw()

g4.axe_property('XTick',est_lyr_mid);
g4.axe_property('XTickLabel',est_lyr_lab);
g4.axe_property('YLim',[0 1]);
g4.axe_property('YTick',[0 .5 1]);
g4.update('color',ones(1,length(dpth)))
g4.set_line_options()
g4.stat_summary('geom','line')
g4.set_color_options('map',[0 0 0])  


g4.draw()


g5=gramm('x',dpth,'y',p_offs,'color',sub);
g5.set_continuous_color('active',false)
% Subdivide the data in subplots horizontally by region of origin
g5.facet_wrap(sub,'ncols',7,'scale','free')
% Plot raw data as points
g5.geom_point()
g5.axe_property('FontSize',8);
% Plot linear fits of the data with associated confidence intervals
g5.stat_glm('r2','true')
%g2.stat_glm('geom','area')

% Set appropriate names for legends
g5.set_names('x','','y','offset','color','Pt','column', 'Pt')
g5.set_title('1/f Offset and Cortical Depth in Single Mice','FontSize',14.5)
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


%g2.axe_property('YLim',[.3 1])
g5.set_text_options('legend_scaling',1.2,'legend_title_scaling',3,'facet_scaling',1.5)
g5.set_layout_options('title_centering','plot','legend',0)
g5.set_point_options('base_size',8)
% Do the actual drawing
figure('units','normalized','outerposition',[0 0 1 1])
g5.draw()

for k = 1 : 16
    all_roff(k) = g5.results.stat_glm(k).model.Rsquared.Ordinary;
end
%mean(all_roff), std(all_roff)/sqrt(16)

for k = 1 : 16
    set(g5.facet_axes_handles(k),'YLim',[0 1],'YTick',[0 0.5 1]);
    g5.update()
end
pause(1)
