%% This function assigns supports
%
% Original from: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
% Parts of the code from Prof. Ahmed Elkady
% 
function write_BCs(INP, bldgData, fixedBase, addEGF, rigidFloor)
%% Read relevant variables
storyNum  = bldgData.storyNum;
floorNum  = bldgData.floorNum;
bayNum    = bldgData.bayNum;
axisNum   = bldgData.axisNum;
frameType = bldgData.frameType;
colSize   = bldgData.colSize;
beamSize  = bldgData.beamSize;

%% Assign supports
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'#                                       BOUNDARY CONDITIONS                                       #\n');
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'\n');

%% Assign boundary condition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% base of the frame
fprintf(INP, '# FRAME BASE SUPPORTS\n');
for Axis = 1:axisNum
    if ~isempty(colSize{1, Axis})
        nodeID = 1*10000+Axis*100;
        if fixedBase
            fprintf(INP, 'fix %d 1 1 1;\n', nodeID);
        else
            fprintf(INP, 'fix %d 1 1 0;\n', nodeID);
        end
    end
end
fprintf(INP, '\n');

% base of the gravity system
if strcmp(frameType, 'Perimeter')
    if addEGF
%%%%%%%%%%%%%%%%%%%%%%%%%% Build EGF supports %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        fprintf(INP,'# EGF SUPPORTS\n');
        for Axis=bayNum+2:bayNum+3
            nodeID=10000+Axis*100;
            fprintf(INP,'fix %d 1 1 0; ', nodeID);
        end
        fprintf(INP,'\n\n');
    else
%%%%%%%%%%%%%%%%%%%%% Build leaning column supports %%%%%%%%%%%%%%%%%%%%%%%
        % 1st floor of leaning column
        fprintf(INP, '# LEANING COLUMN SUPPORT\n');
        fprintf(INP, 'fix %d 1 1 0;\n', 10000+(axisNum+1)*100+2);
    end
end

% constraint for rigid diaphragm
if rigidFloor
    
    % Moment frame
    fprintf(INP, '# RIGID DIAPHRAGM (MOMENT-FRAME)\n');
    for Floor = 2:floorNum
        nodeAnchor = [];
        nodeList = [];
        Story = Floor - 1;
        % Get list of nodes to contraint      
        for Axis = axisNum:-1:1
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
            
            % Add node of panel zone to constrait
            if existPZ 
                if isempty(nodeAnchor)
                    nodeAnchor = 4000000+Floor*10000+Axis*100+4;
                else
                    nodeList = [nodeList, 4000000+Floor*10000+Axis*100+4];
                end
            end            
        end 
        % Create constraints by pairs of nodes
        fprintf(INP,'# Floor %d\n', Floor);
        for i = 1:length(nodeList)
            fprintf(INP,'equalDOF %d %d 1\n', nodeAnchor, nodeList(i));
        end
    end
    fprintf(INP,'\n');
    
%     for Floor = 2:floorNum
%         Story = Floor - 1;
%         for Axis = 1:axisNum
%             Bay = max(1, Axis-1);            
%             % Identify if a beam and a column are intersecting
%             if (~isempty(colSize{min(Story+1, storyNum), Axis}) || ... % top column
%                     ~isempty(colSize{Story, Axis})) && ... % bottom column
%                     ~isempty(beamSize{Story, Bay}) % right beam in 1st intersection or left for the rest intersections
%                 node_i = 4000000 + Floor*1e4 + Axis*100 + 4; % left of beam
%                 node_j = 4000000 + Floor*1e4 + Axis*100 + 2; % right of beam 
%                 fprintf(INP,'equalDOF %d %d 1;\t', node_i, node_j);
%             elseif (~isempty(colSize{min(Story+1, storyNum), Axis}) || ... % top column
%                     ~isempty(colSize{Story, Axis})) && ... % bottom column
%                     ~isempty(beamSize{Story, min(Bay+1, bayNum)}) && Axis > 1 && Axis < axisNum % right beam for the rest of the grid intersections
%                 node_i = 4000000 + Floor*1e4 + Axis*100 + 4; % left of beam
%                 node_j = 4000000 + Floor*1e4 + Axis*100 + 2; % right of beam  
%                 fprintf(INP,'equalDOF %d %d 1;\t', node_i, node_j);
%             end
%         end
%         fprintf(INP,'\n');
%     end
%     fprintf(INP,'\n');
    
    % Gravity system
    if strcmp(frameType, 'Perimeter')
        if addEGF
            fprintf(INP, '# RIGID DIAPHRAGM (EGF)\n');
            for Floor=storyNum+1:-1:2
                nodeID0 = Floor*10000+(axisNum+1)*100;
                nodeID1 = Floor*10000+(axisNum+2)*100;
                fprintf(INP,'equalDOF %d %d 1;\t', nodeID0, nodeID1);
            end
            fprintf(INP,'\n');
        end
    end
end

fprintf(INP,'###################################################################################################\n');
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'                                         puts "\n\n"                                               \n');
fprintf(INP,'                                      puts "Model Built"                                           \n');
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'\n');

end