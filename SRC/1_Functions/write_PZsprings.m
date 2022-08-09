%% This function writes the non-linear spring to capture the panel zone response
%
% Original from: Prof. Ahmed Elkady
% Adapted by: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
%
function AllEle = write_PZsprings(INP,bldgData,panelZoneModel,AISC_v14p1)

AllEle.pzSprings = []; % List of panel zone spring IDs

if ~strcmp(panelZoneModel, 'None')
    %% Read relevant variables
    storyNum  = bldgData.storyNum;
    floorNum  = bldgData.floorNum;
    axisNum   = bldgData.axisNum;
    bayNum   = bldgData.bayNum;
    colSize   = bldgData.colSize;
    beamSize  = bldgData.beamSize;
    doublerPlates  = bldgData.doublerPlates;
    colAxialLoad = bldgData.colAxialLoad;       
    
    %%
    fprintf(INP,'####################################################################################################\n');
    fprintf(INP,'#                                          PANEL ZONE SPRINGS                                      #\n');
    fprintf(INP,'####################################################################################################\n');
    fprintf(INP,'\n');
    
    fprintf(INP,'# COMMAND SYNTAX \n');
    fprintf(INP,'# PanelZoneSpring    eleID NodeI NodeJ Es mu Fy dc bc tcf tcw tdp db Ic Acol alpha Pr trib ts pzModelTag isExterior Composite\n');
    % Create panel zone at each intersection if:
    %    (a) column in story above OR column in story below; AND
    %    (b) beam in left bay OR beam in right bay
    for Floor = 2:floorNum
        Story = Floor - 1;
        fprintf(INP,'# Panel zones floor%d\n', Floor);
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
                % Column properties
                % (Takes the column below and if does not exist takes the
                % column above)            
                section = colSize{Story, Axis};            
                if isempty(section)
                    section = colSize{Floor, Axis};
                end            
                props = getSteelSectionProps(section, AISC_v14p1);
                dc = props.db;
                bc = props.bf;
                tcf = props.tf;
                tcw = props.tPZ_z; % important for box columns
                Ic = props.Iz;
                Acol = props.A;
                % Doubler plates
                tdp = doublerPlates(Story, Axis);
                % Column axial load
                Pr = colAxialLoad(Story, Axis);
                % Beam properties
                % (Takes the left beam and if does not exist takes the right beam)            
                section = beamSize{Story, Bay};            
                if isempty(section)
                    section = beamSize{Story, Axis};
                end            
                props = getSteelSectionProps(section, AISC_v14p1);
                db = props.db;
                % Identify if is exterior or interior panel zone
                if Axis==1 || Axis==axisNum || isempty(beamSize{Story, Axis-1}) ...
                        || isempty(beamSize{Story, Axis})
                    isExterior = 1;
                else
                    isExterior = 0;
                end
                % Set node and element labels             
                node1=4000000+Floor*10000+Axis*100+09;
                node2=4000000+Floor*10000+Axis*100+10;
                SpringID=9000000+Floor*10000+Axis*100+00;                
                % Call the function that creates the elements                                
                fprintf(INP,'PanelZoneSpring %d %d %d $Es $mu $FyCol %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f %5.3f $SH_PZ %5.3f $trib $tslab $pzModelTag %d $Composite;\n',...
                    SpringID,node1,node2,dc,bc,tcf,tcw,tdp,db,Ic,Acol,Pr,isExterior);
                % Save in database
                AllEle.pzSprings = [AllEle.pzSprings; SpringID];
            end
        end
    end
    fprintf(INP,'\n');
end
fprintf(INP,'\n');
end