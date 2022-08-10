%% This function computes the column axial load ratio using the default 
% combination for NL analysis
%
function [colAxialRatio, colMeanAxialRatio] = getColAxial_ratio(bldgData, secProps, FyCol)
%% Read relevant variables 
colAxialLoad = bldgData.colAxialLoad;
AgCol        = secProps.AgCol;

%% Story beam-to-column stiffness ratio
colAxialRatio = (colAxialLoad ./ AgCol) / FyCol;

% make NaN all divisions by zero (column does not exist)
colAxialRatio(isinf(colAxialRatio)) = NaN;

% Compute mean value across all columns of each story
colMeanAxialRatio = zeros(size(colAxialRatio,2), 1);
for Story = 1:size(colAxialRatio,1)
    storyValues = colAxialRatio(Story,:);
    colMeanAxialRatio(Story) = mean(storyValues(~isnan(storyValues)));
end

end
