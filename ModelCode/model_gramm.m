clear

load('C:\Users\Loomis\Documents\FOOOF_nu\ModelCode\r.mat')
load('C:\Users\Loomis\Documents\FOOOF_nu\ModelCode\slp.mat')
load('C:\Users\Loomis\Documents\FOOOF_nu\ModelCode\off.mat')

slp = [slp(1:88) nan slp(89:end)];
off = [off(1:88) nan off(89:end)];
r = [r(1:88) nan r(89:end)];

sub=[];
for k = 1 : 44
    sub = [sub k k k];
end
dpth = repmat([1:3],[1 44]);

slp(find(dpth==2)) = [];
off(find(dpth==2)) = [];
r(find(dpth==2)) = [];
sub(find(dpth==2)) = [];
dpth(find(dpth==2)) = [];

s1 = -slp(1:2:end);
s2 = -slp(2:2:end);
o1 = off(1:2:end);
o2 = off(2:2:end);
       
axis_x = (o2-o1)./(s1-s2);
axis_y = (s1.*axis_x) + o1;

[rm,pvm]=corr(slp',off');
disp(['model correlation and significance of slope and offset is ' num2str(rm.^2) ' and ' num2str(pvm)])
disp(['model axis of rotation is ' num2str(10.^median(axis_x)) ] )
%%
cmap = colormap(parula); cmap = cmap(round(linspace(1,256,44)),:);
close all
figure('units','normalized','outerposition',[0 0 1 1]);
g(1,1)=gramm('x',dpth,'y',slp,'color',sub);
g(1,1).set_continuous_color('active',false);
g(1,1).geom_line();
g(1,1).geom_point();
g(1,1).set_names('x','Estimated Cortical Layer','y','1/f Slope','color','Brodmann Area');
g(1,1).axe_property('FontSize',20);
g(1,1).set_title('1/f Slope and Cortical Depth','FontSize',23);
% g(1,1).set_text_options('legend_scaling',2,'legend_title_scaling',1.5)
g(1,1).set_point_options('base_size',25);
g(1,1).set_line_options('base_size',10);
% g(1,1).draw()
g(1,1).set_color_options('map',cmap);
g(1,1).update('color',ones(1,length(dpth)));

%g(1,1).axe_property('YLim',[.85 1.15]);
%g(1,1).axe_property('YTick',[.85 1 1.15]);
g(1,1).axe_property('XLim',[.5 3.5]);

%g.axe_property('XTickLabel',["superficial", "infragranular"]);
g(1,1).set_line_options();
g(1,1).stat_summary('geom','line');
g(1,1).set_color_options('map',[0 0 0]);
g(1,1).no_legend();
g(1,1).stat_summary('geom',{'point','black_errorbar'});
g(1,1).set_point_options('base_size',35);
g(1,1).set_line_options('base_size',15);
g(1,1).set_text_options('font','Arial'); 
% g(1,1).draw()
% pause(1)
% set(gcf,'PaperSize',[20 20],'renderer','painters')
% saveas(gcf,'C:\Users\Loomis\Documents\FOOOF_nu\final_figs\figscratch\modelslope.svg')
% %%
% figure('units','normalized','outerposition',[0 0 1 1])
g(1,2)=gramm('x',dpth,'y',off,'color',sub);
g(1,2).set_continuous_color('active',false);
g(1,2).geom_line();
g(1,2).geom_point();
g(1,2).set_names('x','Estimated Cortical Layer','y','1/f Offset','color','Brodmann Area');
g(1,2).axe_property('FontSize',20);
g(1,2).set_title('1/f Offset and Cortical Depth','FontSize',23);
%g(1,2).set_text_options('legend_scaling',2,'legend_title_scaling',1.5)
g(1,2).set_point_options('base_size',25);
g(1,2).set_line_options('base_size',10);
g(1,2).set_color_options('map',cmap);
% g(1,2).draw()
g(1,2).axe_property('XLim',[.5 3.5]);
g(1,2).axe_property('XTickLabel',["superficial", "infragranular"]);
g(1,2).update('color',ones(1,length(dpth)));

%g(1,2).axe_property('YLim',[-1.4 -.5]);
%g(1,2).axe_property('YTick',[-1.4 -.95 -.5]);

g(1,2).set_line_options();
g(1,2).no_legend();
g(1,2).stat_summary('geom','line');
g(1,2).set_color_options('map',[0 0 0]);
g(1,2).stat_summary('geom',{'point','black_errorbar'});
g(1,2).set_point_options('base_size',35);
g(1,2).set_line_options('base_size',15);
g(1,2).set_text_options('font','Arial');
g.draw();
pause(1);
set(gcf,'PaperSize',[20 20],'renderer','painters');
saveas(gcf,'C:\Users\Loomis\Documents\FOOOF_nu\final_figs\figscratch\modelslopeandoffset.svg')
%%
figure('units','normalized','outerposition',[0 0 1 1]);
g3=gramm('x',r);
g3.stat_bin('nbins',11);
g3.set_names('x','R^2','y','# of channels');
g3.axe_property('XLim',[.88 .95]);
g3.axe_property('XTick',[.88 .915 .95]);
g3.axe_property('YLim',[0 16]);
g3.axe_property('YTick',[0 8 16]);
g3.axe_property('TickDir','Out');
g3.set_color_options('map',[255 94 105]./255);
g3.set_text_options('font','Arial');
g3.draw();
pause(1)
set(gcf,'PaperSize',[20 20],'renderer','painters');
saveas(gcf,'C:\Users\Loomis\Documents\FOOOF_nu\final_figs\figscratch\modelr2.svg')