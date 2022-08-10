% getLoadsOnMRF computes the load that should be directly applied to the 
% beams and columns of a moment resisting frame using.
% current implementation applies all the load directly to the columns as
% nodal loads and avoids distributed loads to ease convergence of NL
% analyses.
%
% INPUTS
%   colSize        = matrix with the column size in each story and axis
%   beamSize       = matrix with the beam size in each bay and floor segment
%   frameWeigthDir = vector with the total tributary load that should be
%                    distributed to beams and columns in each floor [kips]
% 
% OUTPUTS
%   wgtOnCol       = matrix with the load [kips] for each column-to-beam
%                    interseption node
%   wgtOnBeam      = matrix with the distributed load [kips/in] for each
%                    beam segment
%
function [wgtOnCol, wgtOnBeam] = getLoadsOnMRF(colSize,beamSize,frameWeigthDir)
       
%% Read relevant variables
[storyNum, axisNum] = size(colSize);
floorNum = storyNum + 1;
bayNum = axisNum - 1;

%% Create arrays with the loads on beams and columns
wgtOnCol = zeros(size(colSize));
for Floor = 2:floorNum
    
    Story = Floor - 1;
    nPZ = 0;
    for Axis = 1:axisNum
        Bay = max(1, Axis-1);
        
        % Identify if a beam and a column are intersecting
        if (~isempty(colSize{min(Story+1, storyNum), Axis}) || ... % top column
                ~isempty(colSize{Story, Axis})) && ... % bottom column
                ~isempty(beamSize{Story, Bay}) % right beam in 1st intersection or left for the rest intersections
            nPZ = nPZ + 1;
        elseif (~isempty(colSize{min(Story+1, storyNum), Axis}) || ... % top column
                ~isempty(colSize{Story, Axis})) && ... % bottom column
                ~isempty(beamSize{Story, min(Bay+1, bayNum)}) && Axis > 1 && Axis < axisNum % right beam for the rest of the grid intersections
            nPZ = nPZ + 1;
        end
    end
    loadPerPZ = frameWeigthDir(Story)/nPZ;
    for Axis = 1:axisNum
        Bay = max(1, Axis-1);
        
        % Identify if a beam and a column are intersecting
        if (~isempty(colSize{min(Story+1, storyNum), Axis}) || ... % top column
                ~isempty(colSize{Story, Axis})) && ... % bottom column
                ~isempty(beamSize{Story, Bay}) % right beam in 1st intersection or left for the rest intersections
            wgtOnCol(Story,Axis) = loadPerPZ;
        elseif (~isempty(colSize{min(Story+1, storyNum), Axis}) || ... % top column
                ~isempty(colSize{Story, Axis})) && ... % bottom column
                ~isempty(beamSize{Story, min(Bay+1, bayNum)}) && Axis > 1 && Axis < axisNum % right beam for the rest of the grid intersections
            wgtOnCol(Story,Axis) = loadPerPZ;
        end
    end    
end

wgtOnBeam = zeros(size(beamSize));
                                            
end
        