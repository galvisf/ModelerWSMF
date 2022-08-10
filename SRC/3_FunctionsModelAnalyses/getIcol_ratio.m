%% This function computes the ratio of the second moment of area for 
%  exterior to interior columns in the frame
%
function Icol_ratio = getIcol_ratio(bldgData, secProps)
% getIcol_ratio creates a vector with the ratio of I for exterior to
% interior columns from the frame using the exterior column at the left and
% the next interior column
% 
%% Read relevant variables 
storyNum = bldgData.storyNum;
axisNum  = bldgData.axisNum;
colSize  = bldgData.colSize;
beamSize = bldgData.beamSize;

ICol   = secProps.ICol;

%% Story beam-to-column stiffness ratio
Icol_ratio = zeros(storyNum, 1);

for Story = 1:storyNum      
    for Axis = 1:axisNum
        if ~isempty(colSize{Story, Axis})
            % Beam index
            if Axis == axisNum
                beam_idx = Axis - 1;
            else
                beam_idx = Axis;
            end
            % Identify column type
            if Axis == 1 || Axis == axisNum || isempty(beamSize{Story, beam_idx - 1})
                ext_col = true;
            else
                ext_col = false;
            end
            if ext_col
                Iext = ICol(Story,Axis);
                % Find adjacent interior column
                Iint = 0;
                k = 1;
                while Iint == 0
                    Iint = ICol(Story,Axis+k);
                    k = k + 1;
                end
                % Compute I ratio
                Icol_ratio(Story) = Iext/Iint;
                break
            end
        end
    end   
end

end