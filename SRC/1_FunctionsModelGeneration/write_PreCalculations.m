%% This function writes necesaty precomputations to build the model
%
% Original from: Prof. Ahmed Elkady
% Adapted by: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
%
function write_PreCalculations (INP, bldgData, addEGF, fractureElement)

%% Read relevant variables
storyNum = bldgData.storyNum;
bayNum   = bldgData.bayNum;
floorNum = bldgData.floorNum;
HStory   = bldgData.storyHgt;
WBay     = bldgData.bayLgth;
frameType = bldgData.frameType;
beamSize = bldgData.beamSize;

%%
fprintf(INP,'####################################################################################################\n');
fprintf(INP,'#                                          PRE-CALCULATIONS                                        #\n');
fprintf(INP,'####################################################################################################\n');
fprintf(INP,'\n');

fprintf(INP,'# FRAME GRID LINES\n');
fprintf(INP,'set Floor1 0.0;\n');
for Floor=2:1:storyNum+1
    Story=Floor-1;
    fprintf(INP,'set Floor%d  %5.2f;\n', Floor,sum(HStory(1:Story)));
end
fprintf(INP,'\n');

fprintf(INP,'set Axis1 0.0;\n');
for Axis=2:bayNum+1
    Bay=Axis-1;
    fprintf(INP,'set Axis%d %5.2f;\n',Axis,sum(WBay(1:Bay)));
end

% grid lines for EGF
if strcmp(frameType, 'Perimeter')
    if addEGF
        fprintf(INP,'set Axis%d %5.2f;\n', bayNum+2,sum(WBay)+WBay(1));
        fprintf(INP,'set Axis%d %5.2f;\n', bayNum+3,sum(WBay)+2*WBay(1));
    end
end
fprintf(INP,'\n');

fprintf(INP,'set HBuilding %5.2f;\n',sum(HStory));
fprintf(INP,'set WFrame %5.2f;\n', sum(WBay));
fprintf(INP,'\n');

if fractureElement
    fprintf(INP,'# SIGMA CRITICAL PER FLANGE AND CONNECTION\n');
    for Floor = 2:floorNum
        Story = Floor - 1;
        for Bay = 1:bayNum
            if ~isempty(beamSize{Story,Bay})
                % Write FI limit for bottom flange left
                fprintf(INP,'set sigCrB_bay%d_floor%d_i [sigCrNIST2017 "bottom" $cvn_bay%d_floor%d_i $a0_bay%d_floor%d_i $alpha $T_service_F $Es $FyWeld];\n', Bay, Floor, Bay, Floor, Bay, Floor);
                %             fprintf(INP,'puts $sigCrB_bay%d_floor%d_i\n',Bay, Floor);
                % Write FI limit for top flange left
                fprintf(INP,'set sigCrT_bay%d_floor%d_i [sigCrNIST2017 "top" $cvn_bay%d_floor%d_i $a0_bay%d_floor%d_i $alpha $T_service_F $Es $FyWeld];\n', Bay, Floor, Bay, Floor, Bay, Floor);
                %             fprintf(INP,'puts $sigCrT_bay%d_floor%d_i\n',Bay, Floor);
                % Write FI limit for bottom flange right
                fprintf(INP,'set sigCrB_bay%d_floor%d_j [sigCrNIST2017 "bottom" $cvn_bay%d_floor%d_j $a0_bay%d_floor%d_j $alpha $T_service_F $Es $FyWeld];\n', Bay, Floor, Bay, Floor, Bay, Floor);
                %             fprintf(INP,'puts $sigCrB_bay%d_floor%d_j\n',Bay, Floor);
                % Write FI limit for top flange right
                fprintf(INP,'set sigCrT_bay%d_floor%d_j [sigCrNIST2017 "top" $cvn_bay%d_floor%d_j $a0_bay%d_floor%d_j $alpha $T_service_F $Es $FyWeld];\n', Bay, Floor, Bay, Floor, Bay, Floor);
                %             fprintf(INP,'puts $sigCrT_bay%d_floor%d_j\n',Bay, Floor);
            end
        end
    end
    fprintf(INP,'\n');
end

end