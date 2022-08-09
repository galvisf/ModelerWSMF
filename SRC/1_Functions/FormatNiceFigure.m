function [] = FormatNiceFigure(titleText, fontSize, titlePos, yLabelDir, uniformDigits, color)
% FormatNiceFigure(titleText, fontSize, titlePos, yLabelDir, uniformDigits, color)
%
% Formats the current figure in several ways in order to make it nice for
% publication. The function can be called with any number of inputs, and
% the subsequent inputs will take the default values. For example, 
% FormatNiceFigure() uses all the default values.
% 
% 
% Inputs:
%   - titleText    : String with the title. Default: ''.
%   - fontSize     : Number with fontsize for labels, ticks, and legend.
%                    Default: 12. If fontSize = [], then no change is made.
%   - titlePos     : Position of the title, in normalized units. 
%                    Default = [1 1].
%   - yLabelDir    : Direction of the Y-axis label. 
%                    If yLabelDir = 'horizontal', then the Y-axis label is 
%                    moved to be horizontal and on top of the Y-axis.
%                    If yLabelDir = 'z', then the Z-axis label is rotated 
%                    to be horizontal (useful for 3D plots).
%                    Any other value for yLabelDir will leave the Y-axis 
%                    label direction unchanged.
%                    Default = 'horizontal'.
%   - uniformDigits: Vector with three 0/1 values. Each value of 0 or 1 
%                    applies to axes X, Y, and Z, respectively. In each 
%                    axis, if uniformDigits(i) = 1 (with i = 1, 2, or 3 for
%                    axes X, Y and Z), then the number of digits after the 
%                    decimal point is uniformized across all the ticklabels 
%                    of the axis. 
%                    Default = [1 1 1].
%   - color        : If color = 'gray', it changes the color of the lines 
%                    in the figure to be in gray scale.
%                    Any other value for color will leave the color sceheme
%                    unchanged.
%                    Default = 'normal'. (i.e., colors unchanged)
%
% For nice and distinguishable color schemes, the following functions are 
% recommended:
% - linspecer(N)
% (https://www.mathworks.com/matlabcentral/fileexchange/42673-beautiful-and-distinguishable-line-colors-colormap)
% 
% - brewermap(N,scheme)
% (https://www.mathworks.com/matlabcentral/fileexchange/45208-colorbrewer-attractive-and-distinctive-colormaps)
%
% 
% coded by Pablo Heresi
% Stanford University
% 2014-2020
%

%% Default input values

switch nargin
    case 0
        titleText = '';
        fontSize = 12;
        titlePos = [1 1];
        yLabelDir = 'horizontal';
        uniformDigits = [1 1 1];
        color = 'normal';
    case 1
        fontSize = 12;
        titlePos = [1 1];
        yLabelDir = 'horizontal';
        uniformDigits = [1 1 1];
        color = 'normal';
    case 2
        titlePos = [1 1];
        yLabelDir = 'horizontal';
        uniformDigits = [1 1 1];
        color = 'normal';
    case 3
        yLabelDir = 'horizontal';
        uniformDigits = [1 1 1];
        color = 'normal';
    case 4
        uniformDigits = [1 1 1];
        color = 'normal';
    case 5
        color = 'normal';
end

%% Font size

if ~isempty(fontSize)
    set(gca,'FontSize',fontSize);
    set(get(gca,'xlabel'),'fontsize',fontSize)
    set(get(gca,'ylabel'),'fontsize',fontSize)
    set(get(gca,'zlabel'),'fontsize',fontSize)
    set(findobj(gca,'fontsize',10),'fontsize',fontSize)
else
    fontSize = get(gca,'FontSize');
end

%% Uniform number of digits

if uniformDigits(1)
    ticksX = get(gca,'xtick');
    y = zeros(size(ticksX));
    for i = 1:length(ticksX)
        y(i) = digits_debugged(ticksX(i));
    end
    MAX_Y = max(y(y<5));
    
%     xtickformat(['%0.' num2str(MAX_Y) 'f'])
    labels_updated = cell(length(ticksX),1);
    for i = 1:length(ticksX)
        labels_updated{i}= num2str(ticksX(i),['%0.' num2str(MAX_Y) 'f']);
    end
    % labels_updated{i} = sprintf(['%0.' num2str(MAX_Y) 'f|'], ticksX);
    set(gca,'xticklabel',labels_updated);
end
if uniformDigits(2)
    ticksY = get(gca,'ytick');
    y = zeros(size(ticksY));
    for i = 1:length(ticksY)
        y(i) = digits_debugged(ticksY(i));
    end
    MAX_Y = max(y(y<5));
    
%     ytickformat(['%0.' num2str(MAX_Y) 'f'])
    labels_updated = cell(length(ticksY),1);
    for i = 1:length(ticksY)
        labels_updated{i}= num2str(ticksY(i),['%0.' num2str(MAX_Y) 'f']);
    end
    % labels_updated = sprintf(['%0.' num2str(MAX_Y) 'f|'], ticksY);
end
if uniformDigits(3)
    ticksZ = get(gca,'ztick');
    y = zeros(size(ticksZ));
    for i = 1:length(ticksZ)
        y(i) = digits_debugged(ticksZ(i));
    end
    MAX_Y = max(y(y<5));
%     ztickformat(['%0.' num2str(MAX_Y) 'f'])
    labels_updated = cell(length(ticksY),1);
    for i = 1:length(ticksZ)
        labels_updated{i}= num2str(ticksY(i),['%0.' num2str(MAX_Y) 'f']);
    end
end

%% Y-Label direction

if strcmpi('horizontal',yLabelDir)
    % Get how much we have to move it to the left (size of the last ytick)
    set(gca,'units','pixel')
    set(get(gca,'ylabel'),'visible','off')
    set(get(gca,'title'),'visible','off')
    
    yticks = get(gca,'ytick');
    set(gca,'ytick',yticks(end))
    ti = get(gca,'tightinset');
    
    set(gca,'ytick',yticks,'ytickmode','auto')
    set(get(gca,'ylabel'),'visible','on')
    set(get(gca,'title'),'visible','on')
    set(gca,'units','normalized')
    
    % Rotate label and put it on top
    ylab_h = get(gca,'YLabel');
    set(ylab_h,'rotation',0,'units','normalized','position',[0 1 0],'HorizontalAlignment','left')
    set(ylab_h,'units','pixel')
    pos_label = get(ylab_h,'position');
    set(ylab_h,'rotation',0,'position',...
        [pos_label(1)-ti(1) pos_label(2)+ti(4)+1 0],'HorizontalAlignment','left')
    set(ylab_h,'units','normalized')

elseif strcmp('z',yLabelDir)    % Special option
    % Rotate Z-Label only
    set(get(gca,'ZLabel'),'Rotation',0)

end

%% Color scheme

% set(get(gca,'legend'),'autoupdate','off')
% p1 = findobj(gca,'linestyle','-');
% p1 = p1(1:end);
% p2 = findobj(gca,'linestyle','--');
% p = [p1;p2];
% if strcmp(color,'gray') 
%     for i = 1:length(p)
%         if length(p) ~= 1
%             set(p(i),'color',[0 0 0]+0.7/(length(p)-1)*(i-1));
%         else
%             set(p(i),'color',[0 0 0]);
%         end
%     end
% end

%% Title

if titlePos(1)>0.6
    allign = 'right';
elseif titlePos(1)<0.4
    allign = 'left';
else
    allign = 'center';
end
title(titleText, 'Units', 'normalized', 'Position', titlePos, ...
    'HorizontalAlignment', allign, 'fontsize', fontSize, ...
    'FontWeight', 'normal')


%% Others

% set(gcf,'color', 'w')
% set(gca,'box','on')
% if ~isempty(get(gca,'legend'))
%     hl = legend;
%     set(hl,'edgecolor','none')
% end


function y = digits_debugged(x)
x = abs(x); %in case of negative numbers
y = 0;

while (abs(floor(x))>x+1E-10 || abs(floor(x))<x-1E-10)
    y = y+1;
    x = x*10;
end

