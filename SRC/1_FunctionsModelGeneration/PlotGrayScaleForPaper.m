function [] = PlotGrayScaleForPaper(xoffset,ylabeldir,name,pos,color,fontsize,logScaleY)
%% Pablo Heresi
%%

if nargin < 7
    logScaleY = 0;
end

set(gca,'ticklabelinterpreter','latex')
set(get(gca,'xlabel'),'interpreter','latex')
set(get(gca,'ylabel'),'interpreter','latex')
set(get(gca,'zlabel'),'interpreter','latex')
% set(get(gca,'legend'),'interpreter','latex')


% set(get(gca,'legend'),'autoupdate','off')
p1 = findobj(gca,'linestyle','-');
p1 = p1(1:end);
p2 = findobj(gca,'linestyle','--');
p = [p1;p2];
% p = [p1(1) p2(1) p1(2) p2(2) p1(3)]; 

if fontsize ~= 0
    set(gca,'FontSize',fontsize);
    set(get(gca,'xlabel'),'fontsize',fontsize)
    set(get(gca,'ylabel'),'fontsize',fontsize)
    set(get(gca,'zlabel'),'fontsize',fontsize)
    set(findobj(gca,'fontsize',10),'fontsize',fontsize)
else
    fontsize = get(gca,'FontSize');
end

gray_grid = [0.9 0.9 0.9];
if strcmp(color,'gray') 
    for i = 1:length(p)
        if length(p) ~= 1
            set(p(i),'color',[0 0 0]+0.7/(length(p)-1)*(i-1));
        else
            set(p(i),'color',[0 0 0]);
        end
    end
end
%gridxy([get(gca,'xtick') 1000000],[get(gca,'ytick') 1000000],'color',gray_grid,'linestyle','-')
grid on
set(gca,'xminorgrid','off')
set(gca,'yminorgrid','off')
set(gca,'zminorgrid','off')

ticksX = get(gca,'xtick');
y = zeros(size(ticksX));
for i = 1:length(ticksX)
	y(i) = digits_debugged(ticksX(i));
end
MAX_Y = max(y(y<4));
labels_updated = cell(length(ticksX),1);
for i = 1:length(ticksX)
    labels_updated{i}= num2str(ticksX(i),['%0.' num2str(MAX_Y) 'f']);
end
% labels_updated{i} = sprintf(['%0.' num2str(MAX_Y) 'f|'], ticksX);
set(gca,'xticklabel',labels_updated);
% xtickformat(['%0.' num2str(MAX_Y) 'f'])
% xtickformat(['%0.0f'])

ticksY = get(gca,'ytick');
y = zeros(size(ticksY));
for i = 1:length(ticksY)
	y(i) = digits_debugged(ticksY(i));
end
MAX_Y = max(y(y<8));
labels_updated = cell(length(ticksY),1);
for i = 1:length(ticksY)
    labels_updated{i}= num2str(ticksY(i),['%0.' num2str(MAX_Y) 'f']);
end
% labels_updated = sprintf(['%0.' num2str(MAX_Y) 'f|'], ticksY);
% if ~(strcmp(get(gca,'Yscale'),'log') && logScaleY)
% %     set(gca,'yticklabel',labels_updated);
%     ytickformat(['%0.' num2str(MAX_Y) 'f'])
% %     ytickformat(['%0.1f'])
% end


ticksZ = get(gca,'ztick');
y = zeros(size(ticksZ));
for i = 1:length(ticksZ)
	y(i) = digits_debugged(ticksZ(i));
end
MAX_Y = max(y(y<4));
% ztickformat(['%0.' num2str(MAX_Y) 'f'])
labels_updated = cell(length(ticksZ),1);
for i = 1:length(ticksZ)
    labels_updated{i}= num2str(ticksZ(i),['%0.' num2str(MAX_Y) 'f']);
end


if strcmp('horizontal',ylabeldir)
    if xoffset ~= -999
        ytot = max(ticksY)-min(ticksY);
        xtot = max(ticksX)-min(ticksX);
        set(get(gca,'YLabel'),'Rotation',0,'position',[min(ticksX)-0.05*xtot+xoffset max(ticksY)+0.05*ytot 0])
    else
        ylab_h = get(gca,'YLabel');
        set(ylab_h,'units','normalized','rotation',0,'position',[0 1 0],'HorizontalAlignment','left')
        set(ylab_h,'units','pixels')
        auxPos = get(ylab_h,'position');
        yticks = get(gca,'yticklabel');
        last_ytick = yticks{end};    
        if strcmp(get(gca,'Yscale'),'log') && logScaleY
            UI_h = uicontrol('Style', 'text','units','pixels','string','10^ ','fontname','helvetica','fontsize',fontsize);
        else
            UI_h = uicontrol('Style', 'text','units','pixels','string',last_ytick,'fontname','helvetica','fontsize',fontsize);
        end
        ui_position = get(UI_h,'extent');
        set(ylab_h,'Rotation',0,'position',[auxPos(1)-ui_position(3) auxPos(2)+ui_position(4)/2 auxPos(3)])
        delete(UI_h);
        set(ylab_h,'units','normalized')
    end
elseif strcmp('z',ylabeldir)
    set(get(gca,'ZLabel'),'Rotation',0)
end

set(gcf,'color', 'w')
set(gca,'box','on')

if ~strcmp('NO',name)
%     export_fig([name '.eps'])
%     export_fig([name '.pdf'])

    if pos(1)>0.6
        allign = 'right';
    elseif pos(1)<0.4
        allign = 'left';
    else
        allign = 'center';
    end
    title(name, 'Units', 'normalized', 'Position', pos, ...
        'HorizontalAlignment', allign, 'fontsize', fontsize, ...
        'FontWeight', 'normal', 'interpreter', 'latex')
end

% set(get(gca,'legend'),'autoupdate','on')
% 
% if ~isempty(get(gca,'legend'))
%     hl = legend;
%     set(hl,'edgecolor','none')
% end

% set(gca,'FontName','times')


function hh = gridxy(x,varargin)
% GRIDXY - Plot grid lines
%   GRIDXY(X) plots vertical grid lines at the positions specified
%   by X. GRIDXY(X,Y) also plots horizontal grid lines at the positions
%   specified by Y. GRIDXY uses the current axes, if any. Lines outside
%   the plot area are plotted but not shown. When X or Y is empty no vertical
%   or horizontal lines are plotted.
%
%   The lines are plotted as a single graphics object. H = GRIDXY(..) returns
%   a graphics handle to that line object. 
%
%   GRIDXY(..., 'Prop1','Val1','Prop2','Val2', ...) uses the properties
%   and values specified for color, linestyle, etc. Execute GET(H), where H is
%   a line handle, to see a list of line object properties and their current values.
%   Execute SET(H) to see a list of line object properties and legal property values.
%
%   Examples
%     % some random plot
%       plot(10*rand(100,1), 10*rand(100,1),'bo') ; 
%     % horizontal red dashed grid
%       gridxy([1.1 3.2 4.5],'Color','r','Linestyle',':') ;
%     % vertical solid thicker yellowish grid, and store the handle
%       h = gridxy([],[2.1:0.7:5 8],'Color',[0.9 1.0 0.2],'linewidth',3) ;
%
%   GRIDXY can be used to plot a irregular grid on the axes.
%
%   See also PLOT, REFLINE, GRID, AXES, REFLINEXY

% NOTE: This function was previously known as XYREFLINE

% for Matlab R13
% version 2.2 (feb 2008)
% (c) Jos van der Geest
% email: jos@jasen.nl

% History
% Created (1.0) feb 2006
% 2.0 apr 2007 - renamed from reflinexy to gridxy, reflinexy is now used
%               for plotting intersection between X and Y axes
% 2.1 apr 2007 - add error check for line properties
% 2.2 feb 2008 - added set(gca,'layer','top') to put gridlines behind the
%                axis tick marks

error(nargchk(1,Inf,nargin)) ;

% check the arguments
if ~isnumeric(x),
    error('Numeric argument expected') ;
end

if nargin==1,
    y = [] ;
    va = [] ;
else
    va = varargin ;
    if ischar(va{1}),
        % optional arguments are
        y = [] ;
    elseif isnumeric(va{1})        
        y = va{1} ;
        va = va(2:end) ;
    else
        error('Invalid second argument') ;
    end
    if mod(size(va),2) == 1,
        error('Property-Value have to be pairs') ;
    end
end

% get the axes to plot in
hca=get(get(0,'currentfigure'),'currentaxes');
if isempty(hca),
    warning('No current axes found') ;
    return ;
end

% get the current limits of the axis
% used for limit restoration later on
xlim = get(hca,'xlim') ;
ylim = get(hca,'ylim') ;

% setup data for the vertical lines
xx1 = repmat(x(:).',3,1) ;
yy1 = repmat([ylim(:) ; nan],1,numel(x)) ;

% setup data for the horizontal lines
xx2 = repmat([xlim(:) ; nan],1,numel(y)) ;
yy2 = repmat(y(:).',3,1) ;


% create data for a single line object
xx1 = [xx1 xx2] ;
if ~isempty(xx1),     
    yy1 = [yy1 yy2] ;
    % add the line to the current axes
    np = get(hca,'nextplot') ;
    set(hca,'nextplot','add') ;
    h = line('xdata',xx1(:),'ydata',yy1(:)) ;          
    set(hca,'ylim',ylim,'xlim',xlim) ; % reset the limits
    
    uistack(h,'bottom') ; % push lines to the bottom of the graph
    set(hca,'nextplot',np,'Layer','top') ;    % reset the nextplot state

    if ~isempty(va),
        try
            set(h,va{:}) ; % set line properties        
        catch
            msg = lasterror ;
            error(msg.message(21:end)) ;
        end
    end

else
    h = [] ;
end

if nargout==1,     % if requested return handle
    hh = h ;
end





function y = digits_debugged(x)
x = abs(x); %in case of negative numbers
y = 0;

while (abs(floor(x))>x+0.00001 || abs(floor(x))<x-0.00001)
    y = y+1;
    x = x*10;
end

