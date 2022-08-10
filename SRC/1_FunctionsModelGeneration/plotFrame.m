function plotFrame(AllNodes, AllEle, disp, plot_nodes, plot_gravity,...
    color_lines, title_text, fontSize)
% INPUTS
%   AllNodes     = structure with the coordinates of every node
%                   CL  -> center line of each interception beam-to-column
%                          of the main frame
%                   EGF -> center line of each interception of the EGF
%   AllEle       = structure with the nodes connecting every element
%   disp         = vector with lateral displacement at each story for
%                  plotting deformed frame
%   plot_nodes   = True/False
%   plot_gravity = True/False
%   color_lines  = vector with color specification: [rgb1, rgb2, rgb3] 
%   title_text   = string with the text to add as title in the plot
%   fontSize     = text size
% 
%% Plot frame
if isempty(AllNodes.EGF)
    plot_gravity = false;
end

hold on;

% Add disp to center line nodes
y_list = unique(AllNodes.CL(:, 3));
if length(y_list) == length(disp)
    for i = 1:length(y_list)
        idx = AllNodes.CL(:, 3) == y_list(i); % find nodes at floor i
        AllNodes.CL(idx, 2) = AllNodes.CL(idx, 2) + disp(i); % add horizontal disp at floor i
    end
else
    disp(['disp array has ',num2str(length(disp)),' lines and must have ',num2str(length(y_list))])
end

if plot_nodes
    scatter(AllNodes.CL(:, 2), AllNodes.CL(:, 3), 'r');    
end

if plot_gravity 
    if plot_nodes
        scatter(AllNodes.EGF(:, 2), AllNodes.EGF(:, 3), 'b');
    end
    AllNodes.all = [AllNodes.CL; AllNodes.EGF];
else
    AllNodes.all = [AllNodes.CL];
end

% build "allLine" variable
AllEle.allLine = [];
AllEle.allLine = AllEle.beam;
AllEle.allLine = [AllEle.allLine; AllEle.col];

% plot line elements
for i = 1:size(AllEle.allLine, 1)
    idx_node1 = find(AllNodes.all(:, 1) == AllEle.allLine(i, 2));
    idx_node2 = find(AllNodes.all(:, 1) == AllEle.allLine(i, 3));
    Xs = [AllNodes.all(idx_node1, 2), AllNodes.all(idx_node2, 2)];
    Ys = [AllNodes.all(idx_node1, 3), AllNodes.all(idx_node2, 3)];
    plot(Xs, Ys, 'Color', color_lines)
end

if plot_gravity
    % plot links
    for i = 1:size(AllEle.links, 1)
        idx_node1 = find(AllNodes.all(:, 1) == AllEle.links(i, 2));
        idx_node2 = find(AllNodes.all(:, 1) == AllEle.links(i, 3));
        Xs = [AllNodes.all(idx_node1, 2), AllNodes.all(idx_node2, 2)];
        Ys = [AllNodes.all(idx_node1, 3), AllNodes.all(idx_node2, 3)];
        plot(Xs, Ys, 'Color', color_lines, 'linestyle', ':')
    end    
    % plot columns
    for i = 1:size(AllEle.EGFcol, 1)
        idx_node1 = find(AllNodes.all(:, 1) == AllEle.EGFcol(i, 2));
        idx_node2 = find(AllNodes.all(:, 1) == AllEle.EGFcol(i, 3));
        Xs = [AllNodes.all(idx_node1, 2), AllNodes.all(idx_node2, 2)];
        Ys = [AllNodes.all(idx_node1, 3), AllNodes.all(idx_node2, 3)];
        plot(Xs, Ys, 'Color', color_lines, 'linewidth',2)
    end
    % Plot beams
    if ~isempty(AllEle.EGFbeam)
        for i = 1:size(AllEle.EGFbeam, 1)
            idx_node1 = find(AllNodes.all(:, 1) == AllEle.EGFbeam(i, 2));
            idx_node2 = find(AllNodes.all(:, 1) == AllEle.EGFbeam(i, 3));
            Xs = [AllNodes.all(idx_node1, 2), AllNodes.all(idx_node2, 2)];
            Ys = [AllNodes.all(idx_node1, 3), AllNodes.all(idx_node2, 3)];
            plot(Xs, Ys, 'Color', color_lines, 'linewidth',2)
        end
    end
end

% Add ground
dX = max(Xs)/4;
plot([- dX, max(Xs) + dX], [0, 0], 'LineWidth', 5, 'Color', [0.6350 0.0780 0.1840])

% Formatting
% titlePos = [0.5 1];
% uniformDigits = [1,1,1];
% yLabelDir = 'vertical';
% FormatNiceFigure(title_text, fontSize, titlePos, yLabelDir, uniformDigits, ...
%     color_lines)
PlotGrayScaleForPaper(-999,'vertical',title_text,[0.5 1],'normal',fontSize)
axis off
axis equal

end