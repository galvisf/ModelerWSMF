%% This function creates node elements
%
% Original from: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
% Parts of the code from Prof. Ahmed Elkady
% 

function AllNodes = write_Nodes(INP, bldgData, addEGF)

%% Read relevant variables
storyNum = bldgData.storyNum;
bayNum = bldgData.bayNum;
floorNum = bldgData.floorNum;
axisNum  = bldgData.axisNum;
storyHgt = bldgData.storyHgt;
bayLgth  = bldgData.bayLgth;
colSize  = bldgData.colSize;
frameType = bldgData.frameType;

WBays = sum(bayLgth);

%% Create centerline node coordinates (for plots)

% beam and column connection centerline node for moment frame
% node label: floor + axis + 00
AllNodes.CL  = [];
idx = 1;
% Create panel zone at each intersection if:
%    (a) column in story above; or
%    (b) column in story below
for Floor = 1:floorNum
    for Axis = 1:axisNum
        if ~isempty(colSize{min(Floor, storyNum), Axis}) || ~isempty(colSize{max(Floor-1,1), Axis})
            % label
            AllNodes.CL(idx, 1) = Floor*10000+Axis*100;
            % X coordinate
            if Axis == 1
                AllNodes.CL(idx, 2) = 0;
            else
                AllNodes.CL(idx, 2) = sum(bayLgth(1:Axis-1));
            end
            % Y coodinate
            if Floor == 1
                AllNodes.CL(idx, 3) = 0;
            else
                AllNodes.CL(idx, 3) = sum(storyHgt(1:Floor-1));
            end
            idx = idx + 1;            
        end
    end
end

% beam and column centerline nodes for gravity frame
% node label: floor + axis + 00
if strcmp(frameType, 'Perimeter')
    AllNodes.EGF = [];
    idx = 1;
    for Floor = 1:floorNum
        if addEGF
            % Equivalente gravity frame center nodes
            axisEGF = 2;
        else
            % Leaning column
            axisEGF = 1;
        end

        for axisEGF_i = 1:axisEGF
            AllNodes.EGF(idx, 1) = Floor*10000+(axisNum+axisEGF_i)*100;
            AllNodes.EGF(idx, 2) = WBays + axisEGF_i*bayLgth(end);
            if Floor == 1
                AllNodes.EGF(idx, 3) = 0;
            else
                AllNodes.EGF(idx, 3) = sum(storyHgt(1:Floor-1));
            end
            idx = idx + 1;
        end        
    end
else
    AllNodes.EGF = [];
end

%% build nodes at the base
baseColumns = colSize(1, :);
basePlatesNum = 0;
for Floor = 1:length(baseColumns)
    if ~isempty(baseColumns{Floor})
        basePlatesNum = basePlatesNum + 1;
    end
end

fprintf(INP,'####################################################################################################\n');
fprintf(INP,'#                                                  NODES                                           #\n');
fprintf(INP,'####################################################################################################\n');
fprintf(INP,'\n');

fprintf(INP,'# COMMAND SYNTAX \n');
fprintf(INP,'# node $NodeID  $X-Coordinate  $Y-Coordinate;\n');

fprintf(INP, '\n# SUPPORT NODES\n');
% fprintf(INP,'#label: floor_i*10000+pier_j*100;\n');
% fprintf(INP, 'node %d %8.3f %8.3f;\n', AllNodes.CL(1:basePlatesNum, :)');
Floor = 1;
for Axis = 1:axisNum
    if ~isempty(colSize{Floor, Axis}) || ~isempty(colSize{max(Floor-1,1), Axis})
        nodeID = 1*10000+Axis*100;
        fprintf(INP,'node %d   $Axis%d  $Floor%d;\n',nodeID,Axis,Floor);
    end
end
fprintf(INP,'\n');

%% Build gravity system nodes
if strcmp(frameType, 'Perimeter')
    if addEGF
%%%%%%%%%%%%%%%%%%%%%%%%%%% Build EGF nodes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        fprintf(INP,'# EGF COLUMN GRID NODES\n');
        
        for Floor=1:floorNum
            for Axis=bayNum+2:bayNum+3
                nodeID=Floor*10000+Axis*100;
                fprintf(INP,'node %d   $Axis%d  $Floor%d; ',nodeID,Axis,Floor);
            end
            fprintf(INP,'\n');
        end
        fprintf(INP,'\n');              
        
        fprintf(INP,'# EGF BEAM NODES\n');
        for Floor=2:floorNum
            for Axis=bayNum+2:bayNum+3
                if Axis==bayNum+2
                    nodeID=Floor*10000+Axis*100+04;
                    fprintf(INP,'node %d  $Axis%d  $Floor%d; ',nodeID,Axis,Floor);
                end
                if Axis==bayNum+3
                    nodeID=Floor*10000+Axis*100+02;
                    fprintf(INP,'node %d  $Axis%d  $Floor%d; ',nodeID,Axis,Floor);
                end
            end
            fprintf(INP,'\n');
        end
        fprintf(INP,'\n');
        
    else
%%%%%%%%%%%%%%%%%%%%%% Build leaning column nodes %%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(INP, '\n#LEANING COLUMN NODES\n');
        fprintf(INP,'#column lower node label: story_i*10000+(axisNum+1)*100 + 2;\n');
        fprintf(INP,'#column upper node label: story_i*10000+(axisNum+1)*100 + 4;\n');
        AllNodes.leaning = [];
        for Floor = 1:storyNum
            
            % Location of leaning column (first bay away)
            x = sum(bayLgth) + bayLgth(1);
            
            % lower node of column
            label_low = Floor*10000 + (axisNum+1)*100 + 2;
            if Floor == 1
                y_low = 0;
            else
                y_low = sum(storyHgt(1:Floor-1));
            end
            
            % upper node of column
            label_up = Floor*10000 + (axisNum+1)*100 + 4;
            y_up = sum(storyHgt(1:Floor));
            
            % write column nodes to file
            tmp = [label_low, x, y_low; label_up, x, y_up];
            AllNodes.leaning = [AllNodes.leaning; tmp];
            
            fprintf(INP, 'node %d %8.3f %8.3f;\n', tmp');
            
        end
        
        % pin the nodes of the leaning column (equalDOF)
        for Floor = 2:floorNum-1
            
            % node of upper column
            label_up = Floor*10000 + (axisNum+1)*100 + 2;
            
            % node of lower column
            label_low = (Floor-1)*10000 + (axisNum+1)*100 + 4;
            
            fprintf(INP, '\n#Pin the nodes for leaning column, floor %d\n', Floor);
            fprintf(INP, 'equalDOF %d %d 1 2;\n', [label_up; label_low]);
            
        end
    end
end