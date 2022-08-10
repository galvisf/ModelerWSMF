%% This function writes the code to call the procedure that builds the beams
%
% Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
%
function AllNodes = write_Mass(INP, AllNodes, bldgData, addEGF, ...
                    fractureElement, panelZoneModel, backbone, ...
                    addSplices, explicitMethod, g)
%% Read relevant variables
floorNum  = bldgData.floorNum;
storyNum  = bldgData.storyNum;
bayLgth   = bldgData.bayLgth;
bayNum    = bldgData.bayNum;
axisNum   = bldgData.axisNum;
colSize   = bldgData.colSize;
beamSize  = bldgData.beamSize;
colAxialLoad = bldgData.colAxialLoad;
wgtOnEGF  = bldgData.wgtOnEGF;
frameType = bldgData.frameType;

AllNodes.mass = []; % Matrix with element data for plots

% Compute mass to per node
massPerNode = zeros(size(colAxialLoad));    
for Story = 1:storyNum
    if Story == storyNum
        massPerNode(Story,:) = colAxialLoad(Story,:)/g;
    else
        massPerNode(Story,:) = abs(colAxialLoad(Story+1,:) - colAxialLoad(Story,:))/g;
    end
end
massOnEGF = wgtOnEGF/g;
smallMassRatio = 1e-2;
    
%%
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'#                                              NODAL MASS                                         #\n');
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'\n');

fprintf(INP,'# MASS ON THE MOMENT FRAME\n\n');

% Add mass to existing panel zone
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

        % Add mass to top panel zone node
        if existPZ && massPerNode(Story,Axis) ~= 0
            % OPTION 1: Mass on the top of the PZ
            nodeID = 4000000+Floor*10000+Axis*100+03;   
            mass   = massPerNode(Story,Axis);
            
            b = bayLgth(max(Axis-1, 1)); % tributary width to the node
            smallMassDOF3 = smallMassRatio*1/12*mass*b^2; % moment of intertia flat plate = 1/12*m*b^2
            
            fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', nodeID, mass, smallMassRatio*mass, smallMassDOF3);
            AllNodes.mass = [AllNodes.mass; nodeID];

            % OPTION 2: Mass on both sides of the PZ            
%             mass   = massPerNode(Story,Axis)/2;            
%             b = bayLgth(max(Axis-1, 1)); % tributary width to the node
%             smallMassDOF3 = smallMassRatio*1/12*mass*b^2; % moment of intertia flat plate = 1/12*m*b^2
%             
%             nodeID = 4000000+Floor*10000+Axis*100+04;
%             fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', nodeID, mass, smallMassRatio*mass, smallMassDOF3);
%             AllNodes.mass = [AllNodes.mass; nodeID];
%             
%             nodeID = 4000000+Floor*10000+Axis*100+02;
%             fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', nodeID, mass, smallMassRatio*mass, smallMassDOF3);
%             AllNodes.mass = [AllNodes.mass; nodeID];
        end
    end           
end
fprintf(INP,'\n');

if strcmp(frameType, 'Perimeter')
    fprintf(INP,'# MASS ON THE GRAVITY SYSTEM\n\n');
    for Floor = 2:floorNum
        Story = Floor - 1;

        if addEGF
%%%%%%%%%%%%%%%%%%%%%%%%%%% Build EGF elements %%%%%%%%%%%%%%%%%%%%%%%%%%%%  
            nodeID_left = 10000*Story+100*(axisNum+1); 
            nodeID_right = 10000*Story+100*(axisNum+2);
            mass = massOnEGF(Story)/2;
            fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\t', nodeID_left, mass, mass, smallMassDOF3);
            fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', nodeID_right, mass, mass, smallMassDOF3);
%             AllNodes.mass = [AllNodes.mass; nodeID_left; nodeID_right];
        else
%%%%%%%%%%%%%%%%%%%%%%%% Build leaning elements %%%%%%%%%%%%%%%%%%%%%%%%%%%
            nodeID = Story*10000 + (axisNum+1)*100 + 4;  
            mass = massOnEGF(Story);
            
            b = mean(bayLgth); % tributary width to the node
            smallMassDOF3 = smallMassRatio*1/12*mass*b^2; % moment of intertia flat plate = 1/12*m*b^2
            
            fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', nodeID, mass, smallMassRatio*mass, smallMassDOF3);
%             AllNodes.mass = [AllNodes.mass; nodeID];
        end
    end
end
fprintf(INP,'\n');

if explicitMethod
    fprintf(INP,'# SMALL MASS ON ALL DOF FOR EXPLICIT SOLUTION METHOD\n\n');
    % panel zone nodes
    fprintf(INP,'# Panel zone nodes\n');
    for Floor = 2:floorNum
        Story = Floor - 1;  

        mass   = mean(massPerNode(Story));
        b = mean(bayLgth); % tributary width to the node
        smallMassDOF3 = smallMassRatio*1/12*mass*b^2; % moment of intertia flat plate = 1/12*m*b^2
        smallMass = smallMassRatio*mass;

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

            % Add mass to top panel zone node
            if existPZ && massPerNode(Story,Axis) ~= 0
                nodeID = 4000000+Floor*10000+Axis*100;   

                if strcmp(panelZoneModel, 'None')                
                    for i = [1,2,4]                    
                        fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', nodeID+i, smallMass, smallMass, smallMassDOF3);
                    end
                else
                    for i = [1,2,4,5,6,7,8,9,10,88,99]
                        fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', nodeID+i, smallMass, smallMass, smallMassDOF3);
                    end
                end
            end
        end           
    end
    % beam nodes
    fprintf(INP,'# Beam nodes\n');
    for Floor = 2:floorNum       
        baysDone = zeros(bayNum, 0);
        Story = Floor - 1;
        for Bay = 1:bayNum
            if ~isempty(beamSize{Floor-1, Bay}) && ~ismember(Bay, baysDone)
                % Add mass to beam nodes in model file
                if ~strcmp(backbone, 'Elastic')
                    mass   = mean(massPerNode(Story));
                    b = mean(bayLgth); % tributary width to the node
                    smallMassDOF3 = smallMassRatio*1/12*mass*b^2; % moment of intertia flat plate = 1/12*m*b^2
                    smallMass = smallMassRatio*mass;

                    Axis_i = Bay;
                    node_i = 4000000 + Floor*1e4 + Axis_i*100 + 4; % left of beam
                    if fractureElement
                        fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', node_i+10, smallMass, smallMass, smallMassDOF3);
                        fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', node_i+20, smallMass, smallMass, smallMassDOF3);
                        fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', node_i+30, smallMass, smallMass, smallMassDOF3);
                        fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', node_i+40, smallMass, smallMass, smallMassDOF3);                
                    else                    
                        fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', node_i+10, smallMass, smallMass, smallMassDOF3);
                        fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', node_i+20, smallMass, smallMass, smallMassDOF3);
                    end
                end            
            end
        end
    end
    fprintf(INP,'\n');
    % column nodes
    fprintf(INP,'# Column nodes\n');
    for Axis = 1:axisNum
        storiesDone = zeros(storyNum, 0);
        for Story = 1:storyNum
            if ~isempty(colSize{Story, Axis}) && ~ismember(Story, storiesDone)
                % Add mass to beam nodes in model file
                if ~strcmp(backbone, 'Elastic')
                    mass   = mean(massPerNode(Story));
                    b = mean(bayLgth); % tributary width to the node
                    smallMassDOF3 = smallMassRatio*1/12*mass*b^2; % moment of intertia flat plate = 1/12*m*b^2
                    smallMass = smallMassRatio*mass;

                    Floor_i = Story;
                    if Floor_i == 1
                        node_i = 1*10000+Axis*100; % bottom end (ground)
                    else
                        node_i = 4000000 + Floor_i*1e4 + Axis*100 + 3; % bottom end
                    end
                    if addSplices
                        fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', node_i+10, smallMass, smallMass, smallMassDOF3);
                        fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', node_i+20, smallMass, smallMass, smallMassDOF3);
                        fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', node_i+30, smallMass, smallMass, smallMassDOF3);
                        fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', node_i+40, smallMass, smallMass, smallMassDOF3);                                
                    else
                        fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', node_i+10, smallMass, smallMass, smallMassDOF3);
                        fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', node_i+20, smallMass, smallMass, smallMassDOF3);                
                    end
                end
            end
        end
    end
    % EGF nodes
    if strcmp(frameType, 'Perimeter')
        if addEGF
            for Floor=1:floorNum
                Story = max(Floor - 1, 1);
                mass   = mean(massPerNode(Story));
                b = mean(bayLgth); % tributary width to the node
                smallMassDOF3 = smallMassRatio*1/12*mass*b^2; % moment of intertia flat plate = 1/12*m*b^2
                smallMass = smallMassRatio*mass;
                for Axis=bayNum+2:bayNum+3                                
                    nodeID=Floor*10000+Axis*100;
                    fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', nodeID, smallMass, smallMass, smallMassDOF3);                    
                end
            end
            for Floor=2:floorNum
                Story = Floor - 1;
                mass   = mean(massPerNode(Story));
                b = mean(bayLgth); % tributary width to the node
                smallMassDOF3 = smallMassRatio*1/12*mass*b^2; % moment of intertia flat plate = 1/12*m*b^2
                smallMass = smallMassRatio*mass;
                for Axis=bayNum+2:bayNum+3                
                    if Axis==bayNum+2
                        nodeID=Floor*10000+Axis*100+04;
                        fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', nodeID, smallMass, smallMass, smallMassDOF3);                                
                    end
                    if Axis==bayNum+3
                        nodeID=Floor*10000+Axis*100+02;
                        fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', nodeID, smallMass, smallMass, smallMassDOF3);                                
                    end
                end
            end
            for Story=1:storyNum
                Fi=Story;
                iNode=10000*Fi+100*(axisNum+1);
                fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', iNode+10, smallMass, smallMass, smallMassDOF3);
                fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', iNode+20, smallMass, smallMass, smallMassDOF3);                

                iNode=10000*Fi+100*(axisNum+2);
                fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', iNode+10, smallMass, smallMass, smallMassDOF3);
                fprintf(INP,'mass %d %6.4f  %6.4f %6.4f;\n', iNode+20, smallMass, smallMass, smallMassDOF3);                
            end
        else
            for Floor = 1:storyNum
                mass   = massPerNode(Story,Axis);            
                b = mean(bayLgth); % tributary width to the node
                smallMassDOF3 = smallMassRatio*1/12*mass*b^2; % moment of intertia flat plate = 1/12*m*b^2
                smallMass = smallMassRatio*mass;

                % lower node of column
                label_low = Floor*10000 + (axisNum+1)*100 + 2;

                % upper node of column
                label_up = Floor*10000 + (axisNum+1)*100 + 4;

                % write column nodes to file
                tmp = [label_low, smallMass, smallMass, smallMassDOF3; label_up, smallMass, smallMass, smallMassDOF3];
                AllNodes.leaning = [AllNodes.leaning; tmp];

                fprintf(INP, 'mass %d %6.4f %6.4f %6.4f;\n', tmp');            
            end
        end
    end
    fprintf(INP,'\n');
end
end
