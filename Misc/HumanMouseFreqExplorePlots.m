    clear
    cd('C:\Users\Loomis\Documents\FOOOF_nu\HumanCode')

    figure('units','normalized','outerposition',[0 0 1 1]);
    load('human_freqexplorer_resv2.mat')
    %imagesc(squeeze(nanmean(sub_slp_r.^2,3)))

    subplot(2,2,1)
    imagesc(hfrq,lfrq,all_slps_r.^2,[0 .2])
    ylabel('Lower Frequency Bound (Hz)'), xlabel('Upper Frequency Bound (Hz)')
    set(gca,'YTick',[10 140 270], 'XTick',[30 160 290],'FontSize',14,'FontName','Arial')
    box off
    axis square
    cbr = colorbar; set(cbr,'YTick',[0 .1 .2],'FontSize',14,'FontName','Arial')
    title('1/f Slope','FontWeight','Normal','FontSize',17)
    subplot(2,2,3)
    imagesc(hfrq,lfrq,all_offs_r.^2,[0 .2])
    ylabel('Lower Frequency Bound (Hz)'), xlabel('Upper Frequency Bound (Hz)')
    set(gca,'YTick',[10 140 270], 'XTick',[30 160 290],'FontSize',13,'FontName','Arial')
    box off
    axis square
    cbr = colorbar; set(cbr,'YTick',[0 .1 .2],'FontSize',14,'FontName','Arial')
    title('1/f Offset','FontWeight','Normal','FontSize',17)

    clear
    cd('C:\Users\Loomis\Documents\FOOOF_nu\MouseCode')
    load('mouse_freqexplorer_resv2.mat')

    subplot(2,2,2)
    imagesc(hfrq,lfrq,all_slps_r.^2,[0 .3])
    ylabel('Lower Frequency Bound (Hz)'), xlabel('Upper Frequency Bound (Hz)')
    set(gca,'YTick',[10 140 270], 'XTick',[30 160 290],'FontSize',14,'FontName','Arial')
    box off
    axis square
    cbr = colorbar; set(cbr,'YTick',[0 .15 .3],'FontSize',14,'FontName','Arial')
    title('1/f Slope','FontWeight','Normal','FontSize',17)
    subplot(2,2,4)
    imagesc(hfrq,lfrq,all_offs_r.^2,[0 .3])

    ylabel('Lower Frequency Bound (Hz)'), xlabel('Upper Frequency Bound (Hz)')
    set(gca,'YTick',[10 140 270], 'XTick',[30 160 290],'FontSize',14,'FontName','Arial')
    box off
    axis square
    cbr = colorbar; set(cbr,'YTick',[0 .15 .3],'FontSize',14,'FontName','Arial')
    title('1/f Offset','FontWeight','Normal','FontSize',17)

    set(gcf,'PaperSize',[20 20],'renderer','painters');
    saveas(gcf,'C:\Users\Loomis\Documents\FOOOF_nu\final_figs\figscratch\freqexplore.svg');