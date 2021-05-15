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

