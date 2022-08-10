function [beam_column_stiff_ratio, Lcol] = getBeamColumnStiffRatio(bldgData, secProps)
% getBeamColumnStiffRatio creates a vector with the ratio of beam stiffness
% and column stiffness in each story.
% 
%% Read relevant variables 
storyNum = bldgData.storyNum;
bayNum   = bldgData.bayNum;
axisNum  = bldgData.axisNum;
colSize  = bldgData.colSize;
beamSize = bldgData.beamSize;
storyHgt = bldgData.storyHgt;
bayLgth  = bldgData.bayLgth;

IzBeam = secProps.IzBeam;
ICol   = secProps.ICol;

%% Story beam-to-column stiffness ratio
Lcol = getColumnLengths(colSize, beamSize, storyHgt);

beam_column_stiff_ratio = zeros(storyNum, 1);

for i = 1:storyNum
    % Beam stiffness
    sum_Kb = mmult(IzBeam(i,:),1./bayLgth);
    
    % Column stiffness
    sum_Kc = 0;    
    for j = 1:axisNum
        % Beam index
        if j == axisNum
            beam_idx = j - 1;
        else
            beam_idx = j;
        end
        % Identify column type
        if j == 1 || j == axisNum || isempty(beamSize{i, beam_idx - 1})
            ext_col = true;
        else
            ext_col = false;
        end
        % Identify if beam-to-column connection exist at this joint
        if i == 1
            BC_conn = true;
        elseif ext_col && ~isempty(beamSize{i, min(j, bayNum)})
            BC_conn = true;
        elseif ~ext_col && or(~isempty(beamSize{i, j}), ~isempty(beamSize{i, j-1}))
            BC_conn = true;
        else
            BC_conn = false;
        end
        % Only add columns framing in the story
        if BC_conn
            sum_Kc = sum_Kc + ICol(i, j)/Lcol(i, j);
        end
    end
    
    beam_column_stiff_ratio(i) = sum_Kb/sum_Kc;
end

end