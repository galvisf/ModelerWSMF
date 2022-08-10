function plotStair(y, color_specs, title_text, fontSize, legend_text, x_label, x_limits)
% INPUTS
%   in           = structure with all information of the frame
%                  AllNodes
%                  AllEle
%   disp         = vector with lateral displacement at each story for
%                  plotting deformed frame
%   plot_nodes   = True/False
%   plot_leaning = True/False
%   fontSize     = text size
% 
%% Plot frame
hold on;

y = [y(1); y; y(end)];
storyList = 0:length(y)-1;
stairs(y, storyList, 'Color', color_specs, 'linewidth', 2)
xlabel(x_label)
ylabel('Floor number')
ylim([0, max(storyList)-1])
xlim(x_limits);
if iscell(legend_text)
    legend(legend_text, 'Location', 'northoutside'); % southoutside
end

% Formatting
% titlePos = [0.5 1];
% yLabelDir = 'vertical';
% uniformDigits = [1,1,1];
% FormatNiceFigure(title_text, fontSize, titlePos, yLabelDir, uniformDigits, color_specs)
PlotGrayScaleForPaper(-999,'vertical',title_text,[0.5 1],'normal',fontSize)
if iscell(legend_text)
    set(get(gca,'legend'),'box','off')
end

end