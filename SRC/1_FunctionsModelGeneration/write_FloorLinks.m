%% This function writes the truss/link elements between the main and gravity frame
%
% Original from: Prof. Ahmed Elkady
% Adapted by: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
% 
function AllEle = write_FloorLinks (INP,AllEle,bldgData,addEGF)
%% Read relevant variables
storyNum  = bldgData.storyNum;
axisNum   = bldgData.axisNum;
frameType = bldgData.frameType;

AllEle.links = [];

if strcmp(frameType, 'Perimeter')
    %% Write links
    fprintf(INP,'####################################################################################################\n');
    fprintf(INP,'#                                              FLOOR LINKS                                         #\n');
    fprintf(INP,'####################################################################################################\n');
    fprintf(INP,'\n');
    
    fprintf(INP,'# Command Syntax \n');
    fprintf(INP,'# element truss $ElementID $iNode $jNode $Area $matID\n');
    
    for Floor=storyNum+1:-1:2
        % Write elements
        nodeID1=4000000+10000*Floor+100*axisNum+4;
        if addEGF
            % Equivalent gravity frame
            nodeID2=Floor*10000+(axisNum+1)*100;
        else
            % Leaning column
            nodeID2= (Floor-1)*10000 + (axisNum+1)*100 + 4;
        end
        eleID=1000+Floor;
        fprintf(INP,'element truss %d %d %d $A_Stiff $rigMatTag;\n',eleID, nodeID1, nodeID2);
        
        % Save data for plot
        nodeCL_i = Floor*10000+axisNum*100;
        nodeCL_j = Floor*10000+(axisNum + 1)*100;
        AllEle.links = [AllEle.links; eleID, nodeCL_i, nodeCL_j];
        
    end
    fprintf(INP,'\n');
end
end