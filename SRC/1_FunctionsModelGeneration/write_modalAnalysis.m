%% This function creates the control node vector and the eigen value analysis commands
%
% Original from: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
% 
function write_modalAnalysis(INP,bldgData,numModes,modelSetUp)
%% Read relevant variables
storyNum     = bldgData.storyNum;
floorNum     = bldgData.floorNum;
axisNum      = bldgData.axisNum;
storyHgt     = bldgData.storyHgt;
beamSize     = bldgData.beamSize;

%% Build control nodes (for IDR)
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'#                                            CONTROL NODES                                        #\n');
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'\n');

% first floor: 1*10000+3*100+00
% other floors: floor*10000+3*100+02

fprintf(INP, 'set ctrl_nodes {\n');

% control nodes (top node of panel zone)
for Floor = 1:floorNum
%     for Axis = axisNum - 1 % select second to last pier as locations for control nodes
%         if Floor == 1
%             nodeID = Floor*10000+Axis*100;
%             fprintf(INP, '\t%d\n', nodeID);
%         else
%             if ~isempty(beamSize{Floor-1,Axis})
%                 nodeID = 4000000 + Floor*1e4 + Axis*100 + 4;
%                 fprintf(INP, '\t%d\n', nodeID);
%             elseif ~isempty(beamSize{Floor-1,Axis-1})
%                 nodeID = 4000000 + Floor*1e4 + Axis*100 + 2;
%                 fprintf(INP, '\t%d\n', nodeID);
%             end
%         end        
%     end
    for Axis = 2%axisNum % select second pier as locations for control nodes
        if Floor == 1
            nodeID = Floor*10000+Axis*100;
            fprintf(INP, '\t%d\n', nodeID);
        else
            nodeID = 4000000 + Floor*1e4 + Axis*100 + 3; %(top node PZ)
            fprintf(INP, '\t%d\n', nodeID);
        end
    end
end
fprintf(INP, '};\n\n');

% Story height vector
fprintf(INP, 'set hVector {\n');
for Floor = 1:storyNum
    fprintf(INP, '\t%d\n', storyHgt(Floor));
end
fprintf(INP, '};\n');
fprintf(INP,'\n');

%% Create dynamic properties file and output mode shapes
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'#                                        EIGEN VALUE ANALYSIS                                     #\n');
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'\n');

if strcmp(modelSetUp, 'Generic')
    fprintf(INP, 'set num_modes %d\n', numModes);
    fprintf(INP, 'set dof 1\n');
    fprintf(INP, 'set ctrl_nodes2 $ctrl_nodes\n');
    fprintf(INP, 'set filename_eigen "$outdir/modal_results.txt"\n');
    fprintf(INP, 'set omegas [modal $num_modes $filename_eigen]\n');
    fprintf(INP, 'set filename_modes "$outdir/mode_shapes.txt"\n');
    fprintf(INP, 'print_modes $num_modes $ctrl_nodes2 $dof $filename_modes\n\n');
else
    fprintf(INP, 'set num_modes %d\n', numModes);
    fprintf(INP, 'set dof 1\n');
    fprintf(INP, 'set ctrl_nodes2 $ctrl_nodes\n');
    fprintf(INP, 'set filename_eigen ""\n');
    fprintf(INP, 'set omegas [modal $num_modes $filename_eigen]\n\n');    
end
fprintf(INP, '###################################################################################################\n');
fprintf(INP, '###################################################################################################\n');
fprintf(INP, '                                   puts "Eigen Analysis Done"                                      \n'); 
fprintf(INP, '###################################################################################################\n');
fprintf(INP, '###################################################################################################\n');
fprintf(INP,'\n');

end



