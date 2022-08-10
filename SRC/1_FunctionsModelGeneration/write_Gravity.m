%% This function assigns the beam and column gravity loads including EGF
%
% Original from: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
% 
function write_Gravity(INP,bldgData,AISC_v14p1,addEGF,modelSetUp)
%% Read relevant variables
storyNum     = bldgData.storyNum;
bayNum       = bldgData.bayNum;
floorNum     = bldgData.floorNum;
axisNum      = bldgData.axisNum;
colSize      = bldgData.colSize;
beamSize     = bldgData.beamSize;
frameType    = bldgData.frameType;
bayLgth      = bldgData.bayLgth;
wgtOnCol     = bldgData.wgtOnCol;
wgtOnBeam    = bldgData.wgtOnBeam;
wgtOnEGF     = bldgData.wgtOnEGF;

%% Assign gravity loads to nodes and elements
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'#                                            GRAVITY LOAD                                         #\n');
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'\n');

patTag = 101;
fprintf(INP, 'pattern Plain %d Linear {\n\n', patTag);

% element loads on beams 
fprintf(INP, '\t# MR Frame: Distributed beam element loads\n');
for Floor = 2:floorNum
    baysDone = zeros(bayNum, 0);   
    fprintf(INP, '\t# Floor %d\n', Floor);
    
    for Bay = 1:bayNum
        
        if ~isempty(beamSize{Floor-1, Bay}) && ~ismember(Bay, baysDone)
            % Axis for left column
            Axis_i = Bay;                

            % Find axis for right column (in case of missing columns the beam spans multiple bays)
            Axis_j = 0;
            i = 1;
            while Axis_j == 0
                if ~isempty(colSize{Floor-1, Bay+i}) || ~isempty(colSize{min(Floor,storyNum), Bay+i})
                    Axis_j = Bay+i;
                else
                    i = i + 1;
                end
            end
            baysDone(Bay:Axis_j-1) = Bay:Axis_j-1;
                
            ElementID = 1e6 + Floor*1e4 + Bay*100;
            
            % assign gravity beam load as distributed loads
            total_load = -sum(wgtOnBeam(Floor-1, Bay:Axis_j-1));
            
            % Left column properties
            % (Takes the column below and if does not exist takes the
            % column above)
            section = colSize{Floor-1, Axis_i};
            if isempty(section)
                section = colSize{Floor, Axis_i};
            end
            props = getSteelSectionProps(section , AISC_v14p1);
            dc_i = props.db;
            
            % Right column properties
            % (Takes the column below and if does not exist takes the
            % column above)            
            section = colSize{Floor-1, Axis_j};            
            if isempty(section)
                section = colSize{Floor, Axis_j};
            end 
            props = getSteelSectionProps(section , AISC_v14p1);
            dc_j = props.db;

            % Beam clear length
            Lbeam = sum(bayLgth(Bay:Axis_j-1)) - dc_i/2 - dc_j/2;
            
            % Write distributed load on the beam
            if total_load ~= 0 
                lineLoad = total_load/Lbeam;
                fprintf(INP, '\teleLoad -ele %d -type -beamUniform %10.5f; ', ElementID, lineLoad);                        
                if Axis_j == Bay+1
                    fprintf(INP, '# Beam at floor %d bay %d\n', Floor, Bay);
                else
                    fprintf(INP, '# Beams at floor %d bays %d to %d\n', Floor, Bay, Axis_j-1);
                end
            end
        end
    end
end

% point loads on columns
fprintf(INP, '\n\t#  MR Frame: Point loads on columns\n');
% Load node at each intersection if:
%    (a) column in story above OR column in story below; AND
%    (b) beam in left bay OR beam in right bay
for Floor = 2:floorNum
    Story = Floor - 1;
    fprintf(INP,'\t# Floor%d\n', Floor);
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
        if existPZ && wgtOnCol(Floor-1, Axis) > 0
            % add nodal load to the top of the panel zone
            wgt = -wgtOnCol(Floor-1, Axis);
            ElementID = 4000000 + Floor*1e4 + Axis*100 + 3;
            fprintf(INP, '\tload %d 0.0 %0.4f 0.0;\n', ElementID, wgt);
        end
    end
end

% element loads on gravity frame columns 
if strcmp(frameType, 'Perimeter')
    fprintf(INP, '\n\t#  Gravity Frame: Point loads on columns\n');
    if addEGF
%%%%%%%%%%%%%%%%%%%%%%%%%%%    Load on EGF    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for Floor = 2:floorNum
            loadPerCol = -wgtOnEGF(Floor - 1)/2;
            nodeID_i=Floor*10000+(axisNum+1)*100;
            fprintf(INP, '\tload %d 0.0 %.4f 0.0;\n', nodeID_i, loadPerCol);
            nodeID_j=Floor*10000+(axisNum+2)*100;
            fprintf(INP, '\tload %d 0.0 %.4f 0.0;\n', nodeID_j, loadPerCol);
        end
    else
%%%%%%%%%%%%%%%%%%%%%%%    Load on Leaning column    %%%%%%%%%%%%%%%%%%%%%%
        for Story = 1:storyNum
            loadCol = -wgtOnEGF(Story);
            ElementID = Story*10000+(axisNum+1)*100+04;
            fprintf(INP, '\tload %d 0.0 %.4f 0.0;\n', ElementID, loadCol);
        end
    end
end
fprintf(INP, '\n}\n\n');

%% Write recorders for gravity analysis
if strcmp(modelSetUp, 'Generic')
    fprintf(INP, '# ----- RECORDERS ----- #\n\n');

    %%%%%% Reaction of bottom nodes %%%%%%
    fprintf(INP, 'recorder Node -file $outdir/Gravity.out -node');
    % base of the frame
    for Axis = 1:axisNum
        if ~isempty(colSize{1, Axis})
            nodeID = 1*10000+Axis*100;
            fprintf(INP, ' %d', nodeID);
        end
    end

    % base of the gravity system
    if strcmp(frameType, 'Perimeter')
        if addEGF
    %%%%%%%%%%%%%%%%%%%%%%%%%% Build EGF supports %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
            for Axis=bayNum+2:bayNum+3
                nodeID=10000+Axis*100;
                fprintf(INP, ' %d', nodeID);
            end
        else
    %%%%%%%%%%%%%%%%%%%%% Build leaning column supports %%%%%%%%%%%%%%%%%%%%%%%
            % 1st floor of leaning column
            nodeID = 10000+(axisNum+1)*100+2;
            fprintf(INP, ' %d', nodeID);
        end
    end
    fprintf(INP, ' -dof 1 2 3 reaction \n\n');

    % %%%%%% Internal forces of bottom columns %%%%%%
    % fprintf(INP, 'recorder Element -file $outdir/Gravity.out -ele ');
    % % base of the frame
    % for Axis = 1:axisNum
    %     if ~isempty(colSize{1, Axis})
    %         ElementID = 2000000+1*10000+Axis*100;
    %         fprintf(INP, ' %d', ElementID);
    %     end
    % end
    % 
    % % base of the gravity system
    % if strcmp(frameType, 'Perimeter')
    %     if addEGF
    % %%%%%%%%%%%%%%%%%%%%%%%%%% Build EGF supports %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %         for Axis=bayNum+2:bayNum+3
    %             ElementID=600000+1000*1+100*Axis;
    %             fprintf(INP, ' %d', ElementID);
    %         end
    %     else
    % %%%%%%%%%%%%%%%%%%%%% Build leaning column supports %%%%%%%%%%%%%%%%%%%%%%%
    %         % 1st floor of leaning column
    %         ElementID=2e6+1*10000+(axisNum+1)*100;
    %         fprintf(INP, ' %d', ElementID);
    %     end
    % end
    % fprintf(INP, ' globalForce;\n\n');
end

%% Write commands for gravity analysis

% define variables
stepNum = 10;
tol = 1e-5;
max_iter = 20; % the max number of iterations to check before returning failure condition

fprintf(INP, '# ----- Gravity analyses commands ----- #\n');
fprintf(INP, 'constraints Transformation;\n'); % Transformation
fprintf(INP, 'numberer RCM;\n');
fprintf(INP, 'system BandGeneral;\n');
fprintf(INP, 'test RelativeEnergyIncr %0.1e %d;\n', tol, max_iter); % RelativeEnergyIncr 1.0e-12 20
fprintf(INP, 'algorithm Newton;\n');
fprintf(INP, 'integrator LoadControl %0.2f;\n', 1/stepNum); % the load factor increment
fprintf(INP, 'analysis Static;\n');
fprintf(INP, 'if {[analyze %d]} {puts "Application of gravity load failed"};\n', stepNum);
fprintf(INP, 'loadConst -time 0.0;\n');
fprintf(INP, 'remove recorders;\n\n');

fprintf(INP, '###################################################################################################\n');
fprintf(INP, '###################################################################################################\n');
fprintf(INP, '                                        puts "Gravity Done"                                        \n'); 
fprintf(INP, '###################################################################################################\n');
fprintf(INP, '###################################################################################################\n');
fprintf(INP,'\n');
    
end