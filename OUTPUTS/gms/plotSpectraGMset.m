function plotSpectraGMset(Te, IM, SF, T_max_plot, spectraMax, mean, geomean,...
    spectraName, spectraLabel, titleText, font)


%% 
NumberGM = length(IM);
plot(Te,mean,'LineWidth',2,'Color','k')
hold on
plot(Te,geomean,'LineWidth',2,'Color','r')
for gmIdx=1:NumberGM
    plot(Te,IM(gmIdx).(spectraName)*SF(gmIdx),'Color',[0.6 0.6 0.6])
end
plot(Te,mean,'LineWidth',2,'Color','k')
hold on
plot(Te,geomean,'LineWidth',2,'Color','r')
xlabel('Structural period, T [s]')
ylabel(spectraLabel)
set(gca, 'Color', 'None')
% legend('mean','geomean','Location','Northeast')
if T_max_plot > 0 
    xlim([0 T_max_plot])
end
if spectraMax > 0
    ylim([0 spectraMax])
end
PlotGrayScaleForPaper(-999,'horizontal',titleText,[1 1],'normal',font)

end