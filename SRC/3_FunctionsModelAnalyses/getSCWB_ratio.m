% getSCWB_ratio computes a matrix of story*pier with the SCWB ratio for all
% beam-to-column interceptions.
% Also, creates a vector with the story column-to-beam strength ratio.
% 
% Original from: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
% 
function col_to_beam_story = getSCWB_ratio(bldgData, secProps)
%% Read relevant variables 
storyNum = bldgData.storyNum;
axisNum  = bldgData.axisNum;
bayNum   = bldgData.bayNum;
colSize  = bldgData.colSize;
beamSize = bldgData.beamSize;

MnBeam = secProps.MnBeam;
MnCol  = secProps.MnCol;

%% Strong column - weak beam (using expected Fy)

col_to_beam = zeros(storyNum, axisNum);
col_to_beam_story = zeros(storyNum, 1);
for Story = 1:storyNum
    sum_Mpc = 0;
    sum_Mpb = 0;
    
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
        
        if existPZ
            % Identify panel zone type
            if Axis==1 || Axis==axisNum || isempty(beamSize{Story, Axis-1}) ...
               || isempty(beamSize{Story, Axis})
                ext_col = true; % exterior panel zone
                
                if Axis==1 || Axis==axisNum
                    beam_idx = Bay;
                elseif isempty(beamSize{Story, Axis-1})
                    beam_idx = Bay + 1;
                else
                    beam_idx = Bay;
                end
            else
                ext_col = false; % interior panel zone
                beam_idx = Bay;
            end
            
            % Beams at the joint
            if ext_col
                % Exterior connection
                Mpb = MnBeam(Story, beam_idx);
            else
                % Interior connection
                Mpb = 2*MnBeam(Story, beam_idx);
            end
            sum_Mpb = sum_Mpb + Mpb;
            
            % Columns at the joint            
            if Story < storyNum && ~isempty(colSize{Story, Axis}) && ~isempty(colSize{Story+1, Axis})
                % Column at top and bottom
                Mpc = MnCol(Story, Axis) + MnCol(Story+1, Axis);
            else
                % Column at one side only
                if MnCol(Story, Axis) == 0
                    % only top column
                    Mpc = MnCol(Story+1, Axis);
                else
                    % only bottom column
                    Mpc = MnCol(Story, Axis);
                end
            end
            sum_Mpc = sum_Mpc + Mpc;
            
            col_to_beam(Story, Axis) = Mpc/Mpb;
        end
        
    end
    col_to_beam_story(Story) = sum_Mpc/sum_Mpb;
end

end