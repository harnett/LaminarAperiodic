%% axis of rotation
clear
dpth = repmat([1:23],[1 19]); 
load p_exps.mat
load p_offs.mat
load p_r2.mat
est_lyr_mid=[1.06 5.5275 10.0455 14.4280 20.35];
est_lyr_lab={'I', 'II/III','IV','V','VI'};
sub = [];
for k = 1 : 19
    sub = [sub ones(1,23).*k];
end
thr = .995
gs = intersect(find( p_r2 >= .94), find(p_r2 >= .96)); p_exps = p_exps(gs); p_offs = p_offs(gs); p_r2 = p_r2(gs);dpth = dpth(gs); sub = sub(gs);
[~,p]=corr(p_exps',p_r2')
[~,p]=corr(p_offs',p_r2')
[~,p]=corr(dpth',p_r2')
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

for k = 1 : length(g2.results.stat_glm)
    all_r(k) = g2.results.stat_glm(k).model.Rsquared.Ordinary;
end


pause(1)
set(gcf,'PaperSize',[20 20],'renderer','painters');

disp(['mean sing subj slope fit: ' num2str(mean(all_r))])
disp(['sem sing subj slope fit: ' num2str(std(all_r)./sqrt(19))])

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

for k = 1 : length(g5.results.stat_glm)
    all_roff(k) = g5.results.stat_glm(k).model.Rsquared.Ordinary;
end

disp(['mean sing subj offset fit: ' num2str(mean(all_roff))])
disp(['sem sing subj offset fit: ' num2str(std(all_roff)./sqrt(19))])
