cnw = dsp.ColoredNoise('custom','InverseFrequencyPower',.5,'SamplesPerFrame',204800);
w = cnw(); w = w ./ mean(abs(w));
cnp = dsp.ColoredNoise('custom','InverseFrequencyPower',1,'SamplesPerFrame',204800);
p = cnp(); p = p ./ mean(abs(p));
cnb = dsp.ColoredNoise('custom','InverseFrequencyPower',1.5,'SamplesPerFrame',204800);
b = cnb(); b = b ./ mean(abs(b));

subplot(3,3,2)
plot(w(1:2048),'b')
axis off
subplot(3,3,5)
plot(p(1:2048),'r')
axis off
subplot(3,3,8)
plot(b(1:2048),'g')
axis off

subplot(1,3,3)
%yline(1./exp(1)), hold on
wa = autocorr(w,'NumLags',205);
wp = autocorr(p,'NumLags',205);
wb = autocorr(b,'NumLags',205);
[~,mip] = min(abs(wp - (1./exp(1)))); disp(mip./2048.*1000)
[~,mib] = min(abs(wb - (1./exp(1))));; disp(mib./2048.*1000)
xa = [(0./2048) : (1./2048) : (205./2048)].*1000; 
plot(xa, wa(1:end),'b'), box off, hold on, plot(xa, wp(1:end),'r'), box off, ...
    hold on, plot(xa, wb(1:end),'g'), box off
xlabel('Time Lag (ms)'), ylabel('Autocorrelation')
xlim([0 100])
set(gca,'ytick',[0 .5 1],'fontname','Arial','fontsize',20), ylim([0 1])

Fs = 2048;
[Pxxw,F] = pwelch(w,hamming(128),[],[],Fs,'psd');
[Pxxp,F] = pwelch(p,hamming(128),[],[],Fs,'psd');
[Pxxb,F] = pwelch(b,hamming(128),[],[],Fs,'psd');

subplot(1,3,1)
loglog((F(2:end)),(Pxxw(2:end)),'b'), xlim([16 1000]), hold on
loglog((F(2:end)),(Pxxp(2:end)),'r'), xlim([16 1000]), hold on
loglog((F(2:end)),(Pxxb(2:end)),'g'), xlim([16 1000])
set(gca,'ytick',[],'fontname','Arial','fontsize',20), xlabel('Frequency (Hz)'), ylabel('Power (AU)')
box off

set(gcf,'PaperSize',[20 20])
%%
clear
rng(1,'twister');

exps = 1:.025:1.925;

for k = 1:length(exps)
        cnw = dsp.ColoredNoise('custom','InverseFrequencyPower',exps(k),'SamplesPerFrame',204800);
        w = cnw(); w = w ./ mean(abs(w));

        w = autocorr(w,'NumLags',4000);

        [~,mi] = min(abs(w - (1./exp(1)))); mi = (mi./2048.*1000);

        mia(k) = mi;
        disp(k)
end

%f = fit(exps',mia','exp1');
scatter(exps,mia,80,'k','filled'), hold on
set(gca,'TickDir','Out','XTick',[1 1.5 2],'XLim',[1 2],'YTick',[0 350 700])
pbaspect([1 2 1])
%plot(f,exps',mia')
%%
% clear
% 
% exps = .5:.05:1.9;
% 
% for k = 1:length(exps)
%     mitmp = zeros(1,50);
%     for kk = 1: 50
%         cnw = dsp.ColoredNoise('custom','InverseFrequencyPower',exps(k),'SamplesPerFrame',204800);
%         w = cnw(); w = w ./ mean(abs(w));
% 
%         w = autocorr(w,'NumLags',1000);
% 
%         [~,mi] = min(abs(w - (1./exp(1)))); mi = (mi./2048.*1000); mitmp(kk) = mi;
%     end
%     mia(k) = mean(mitmp);
%     disp(k)
% end
% 
% scatter(exps,mia)
