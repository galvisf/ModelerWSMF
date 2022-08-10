%% This function creates the elements that form the panel zone
%
% Original from: Prof. Ahmed Elkady
% Adapted by: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
%
function AllEle = write_PZelements(INP,bldgData,panelZoneModel,AISC_v14p1)

%% Read relevant variables
storyNum  = bldgData.storyNum;
floorNum  = bldgData.floorNum;
axisNum   = bldgData.axisNum;
bayNum   = bldgData.bayNum;
colSize   = bldgData.colSize;
beamSize  = bldgData.beamSize;

%%
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'#                                  PANEL ZONE NODES & ELEMENTS                                    #\n');
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'\n');

if strcmp(panelZoneModel, 'None')
    fprintf(INP,'# CROSS PANEL ZONE NODES AND ELASTIC ELEMENTS\n');    
else
    fprintf(INP,'# PANEL ZONE NODES AND ELASTIC ELEMENTS\n');
end
fprintf(INP,'# Command Syntax; \n');
if strcmp(panelZoneModel, 'None')
    fprintf(INP,'# ConstructPanel_Cross Axis Floor X_Axis Y_Floor E A_Panel I_Panel d_Col d_Beam transfTag \n\n');
else
    fprintf(INP,'# ConstructPanel_Rectangle Axis Floor X_Axis Y_Floor E A_Panel I_Panel d_Col d_Beam transfTag \n\n');
end
% Create panel zone at each intersection if:
%    (a) column in story above OR column in story below; AND
%    (b) beam in left bay OR beam in right bay
for Floor = 2:floorNum
    Story = Floor - 1;
    fprintf(INP,'# Panel zones floor%d\n', Floor);
    for Axis = 1:axisNum
        Bay = max(1, Axis-1);
        
        % Identify if beam and columns are intersecting
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
        
        % Create panel zone elements
        if existPZ                               
            % Column properties
            % (Takes the column below and if does not exist takes the
            % column above)            
            section = colSize{Story, Axis};            
            if isempty(section)
                section = colSize{Floor, Axis};
            end                          
            props = getSteelSectionProps(section, AISC_v14p1);
            dc = props.db;                     
            % Beam properties
            % (Takes the left beam and if does not exist takes the right beam)            
            section = beamSize{Story, Bay};            
            if isempty(section)
                section = beamSize{Story, Axis};
            end            
            props = getSteelSectionProps(section, AISC_v14p1);
            db = props.db;
            % Call the function that creates the elements
            if strcmp(panelZoneModel, 'None')
                fprintf(INP,'ConstructPanel_Cross      %d %d $Axis%d $Floor%d $Es $A_Stiff $I_Stiff %5.2f %5.2f $trans_selected;\n',Axis,Floor,Axis,Floor,dc,db);
            else
                fprintf(INP,'ConstructPanel_Rectangle  %d %d $Axis%d $Floor%d $Es $A_Stiff $I_Stiff %5.2f %5.2f $trans_selected;\n',Axis,Floor,Axis,Floor,dc,db);            
            end
            
        end
    end
    fprintf(INP,'\n');
end
fprintf(INP,'\n');