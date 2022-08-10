% getPZ_ratio computes a matrix of story*pier with the panel zone strength
% ratio assuming that beams yield first than columns.
% 
% 
% INPUTS
%   bldgData = structure with all the information for the current building
%   secProps = structure with matrices of all the geometrical properties of
%              the beams and columns in the current building [in unitis]
%   FyBeam   = Yielding stress of the beams [ksi]
%   FyCol    = Yielding stress of the columns [ksi]
%
% OUTPUTS
%   pz_demand_strength  = matrix with the PZ ratio for each existing panel zone
%   pz_strength_min_max = 2-column matrix with the [min, max] PZ ratio per floor
% 
function [pz_demand_strength, pz_strength_min_max] = getPZ_ratio(bldgData, secProps, FyBeam, FyCol)
%% Assumptions of PZ strength
pzStrengthToCompare = 'yielding'; % 'ultimate' -> considers plastification of column flanges
                                  % 'yielding' -> only yielding of the column web
pzFormula           = 'FEMA355D'; % 'FEMA355D' -> general equation per FEMA355D
                                  % 'Equilibrium' -> equilbrium on subassemblies

%% Read relevant variables 
storyNum = bldgData.storyNum;
floorNum = bldgData.floorNum;
bayNum   = bldgData.bayNum;
axisNum  = bldgData.axisNum;
colSize  = bldgData.colSize;
beamSize = bldgData.beamSize;
storyHgt = bldgData.storyHgt;
bayLgth  = bldgData.bayLgth;
doublerPlates  = bldgData.doublerPlates;
colOrientations = bldgData.colOrientations;

ZzBeam = secProps.ZzBeam;
IzBeam = secProps.IzBeam;
dbBeam = secProps.dbBeam;
dbCol  = secProps.dbCol;
bfCol  = secProps.bfCol;
twCol  = secProps.twCol;
tfCol  = secProps.tfCol;

% Replace columns properties for weak axis properties when applicable
dbCol(colOrientations == 0) = bfCol(colOrientations == 0);
bfCol(colOrientations == 0) = dbCol(colOrientations == 0);
twCol(colOrientations == 0) = 2*tfCol(colOrientations == 0);
tfCol(colOrientations == 0) = twCol(colOrientations == 0)/2;

%% Strong column - weak beam (using expected Fy)

pz_demand_strength = zeros(storyNum, axisNum);

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

        % Create panel zone spring
        if existPZ             
            % Find axis for right column (in case of missing columns the beam spans multiple bays)
            Axis_j = 0;
            i = 1;
            while Axis_j == 0
                if ~isempty(colSize{Floor-1, Bay+i}) || ~isempty(colSize{min(Floor, floorNum-1), Bay+i})
                    Axis_j = Bay+i;
                else
                    i = i + 1;
                end
            end
            
            % Identify panel zone type
            if Axis==1 || Axis==axisNum || isempty(beamSize{Floor-1, Axis-1}) ...
               || isempty(beamSize{Floor-1, Axis})
                nBeams_i = 1; % exterior panel zone
                
                if Axis==1 || Axis==axisNum
                    beam_idx = Bay;
                elseif isempty(beamSize{Floor-1, Axis-1})
                    beam_idx = Bay + 1;
                else
                    beam_idx = Bay;
                end
            else
                nBeams_i = 2; % interior panel zone
                beam_idx = Bay;
            end
            
            % Get average story height (needed for ASCE41 backbone calculations)
            if Floor < floorNum
                LcolAvg = mean(storyHgt(Floor-1), storyHgt(Floor));
            else
                LcolAvg = storyHgt(Floor-1);
            end
            
            % Beam length framing into the panel zone
            Lbeam = sum(bayLgth(Bay:Axis_j-1)); % right beam in 1st intersection or left for the rest intersections
            if Lbeam == 0 && Axis > 1 && Axis < axisNum
                Lbeam = bayLgth(min(Bay+1, bayNum)); % right beam for the rest of the grid intersections
            end
            
            % Column properties
            section = colSize{Floor-1, Axis};            
            if isempty(section)
                col_idx = Floor;
            else
                col_idx = Floor-1;
            end             
            dc = dbCol(col_idx, Axis);
            bcf = bfCol(col_idx, Axis);
            tcf = tfCol(col_idx, Axis);
            
            % Doubler plates
            tdp = doublerPlates(Floor-1, Axis);                    
            tPZ = twCol(col_idx, Axis) + tdp;
            
            % Beam properties
            db = dbBeam(Story, beam_idx);
            Zz = ZzBeam(Story, beam_idx);   
            Sz = IzBeam(Story, beam_idx) / (db / 2);
            
            % Compute panel zone ratio
            pz_demand_strength(Story, Axis) = panelZoneRatio(nBeams_i, pzStrengthToCompare, ...
                                pzFormula, FyCol, FyBeam, dc, bcf, tcf, ...
                                tPZ, db, Zz, Sz, LcolAvg, Lbeam);
        end
    end
end

pz_strength_min_max = zeros(storyNum, 2);
for Story = 1:storyNum
    nonZeroIdx = pz_demand_strength(Story, :) ~= 0;
    pz_strength_min_max(Story, 1) = min(pz_demand_strength(Story, nonZeroIdx));
    pz_strength_min_max(Story, 2) = max(pz_demand_strength(Story, nonZeroIdx));
end

% pz_strength_int_mean = zeros(storyNum, 1);
% for i = 1:storyNum
%     idx = pz_demand_strength(i,:) > 0; % ideces of connections that exist at given floor
%     
%     idx_int = idx; % indeces of the interior connections only at given floor
%     idx_int(1) = false;
%     idx_int(end) = false;
%     
%     if length(idx) > 2
%         % If there are at leas 3 connections, gets the mean of interior
%         % connections
%         pz_strength_int_mean(i) = mean(pz_demand_strength(i,idx_int));
%     else
%         % if only 2 connections, gets the mean of those
%         pz_strength_int_mean(i) = mean(pz_demand_strength(i,:));
%     end
% end

end