function [numSingleBeam, numDoubleBeam, numColSplices] = ...
                        countConnections(colSize,beamSize,colSplice,MRFnum)
    
% Read relevant variables
[storyNum, axisNum] = size(colSize);
floorNum = storyNum + 1;
bayNum = axisNum - 1;

% Count beam-to-columns connections
numSingleBeam = zeros(storyNum,1);
numDoubleBeam = zeros(storyNum,1);
for Floor = 2:floorNum
    
    Story = Floor - 1;
    for Axis = 1:axisNum
        Bay = max(1, Axis-1);
        
        % Identify if a beam and a column are intersecting
        if (~isempty(colSize{min(Story+1, storyNum), Axis}) || ... % top column
                ~isempty(colSize{Story, Axis})) && ... % bottom column
                ~isempty(beamSize{Story, Bay}) % right beam in 1st intersection or left for the rest intersections
            existPZ = true;
        elseif (~isempty(colSize{min(Story+1, storyNum), Axis}) || ... % top column
                ~isempty(colSize{Story, Axis})) && ... % bottom column
                ~isempty(beamSize{Story, min(Bay+1, bayNum)}) && Axis > 1 && Axis < axisNum % right beam for the rest of the grid intersections
            existPZ = true;
        else
            existPZ = false;
        end
        % Count
        if existPZ
            if Axis == 1 || Axis == axisNum 
                numSingleBeam(Story) = numSingleBeam(Story) + 1;
            elseif isempty(beamSize{Story, Axis-1}) || isempty(beamSize{Story, Axis})
                numSingleBeam(Story) = numSingleBeam(Story) + 1;                
            else
                numDoubleBeam(Story) = numDoubleBeam(Story) + 1;
            end
        end
    end   
end
numSingleBeam = numSingleBeam.*MRFnum;
numSingleBeam = ['[', regexprep(mat2str(numSingleBeam'), {'\[', '\]', '\s+'}, {'', '', ','}), ']'];
numDoubleBeam = 2*numDoubleBeam.*MRFnum; % by 2 because losses are computed for each side separetely
numDoubleBeam = ['[', regexprep(mat2str(numDoubleBeam'), {'\[', '\]', '\s+'}, {'', '', ','}), ']'];

% Count columns splices
colExist = (cellfun(@isempty,colSize) == 0);
spliceExist = colExist.*colSplice.*MRFnum;
numColSplices = sum(spliceExist,2);
numColSplices = ['[', regexprep(mat2str(numColSplices'), {'\[', '\]', '\s+'}, {'', '', ','}), ']'];

end