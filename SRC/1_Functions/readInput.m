%% This function reads input spread sheet
% 
% description:
% import information about the frame from spreadsheet
%

function bldgData = readInput(geomFN)

%% import data
basics = readtable(geomFN, 'Sheet', 'basics');
bayLgth = readtable(geomFN, 'Sheet', 'bayLgth');
storyHgt = readtable(geomFN, 'Sheet', 'storyHgt');
colSize = readtable(geomFN, 'Sheet', 'colSize');
colOrientations = readtable(geomFN, 'Sheet', 'colOrientations');
beamSize = readtable(geomFN, 'Sheet', 'beamSize');
colSplice = readtable(geomFN, 'Sheet', 'colSplice');
doublerPlates = readtable(geomFN, 'Sheet', 'DoublerPlates');
nColEGF = readtable(geomFN, 'Sheet', 'nColEGF');
nBeamsEGF = readtable(geomFN, 'Sheet', 'nBeamsEGF');
wgtOnBeam = readtable(geomFN, 'Sheet', 'wgtOnBeam');
wgtOnCol = readtable(geomFN, 'Sheet', 'wgtOnCol');
wgtOnEGF = readtable(geomFN, 'Sheet', 'wgtOnEGF');
webConnection = readtable(geomFN, 'Sheet', 'webConnection');

%% basics data
storyNum = basics.storiesAboveGrade;
bayNum = basics.MaximumBayNumber;

floorNum = storyNum+1;
axisNum  = bayNum+1;

tcont = basics.tTypicalContinuityPlate;

orientation = basics.colEGForientation;
if strcmp(orientation, 'Strong')
    orientation = 1;
else
    orientation = 0;
end

trib = basics.tSteelDeckRib;
tslab = basics.tConcreteSlab;
bslab = basics.effectiveSlabWidth;
AslabSteel = basics.AslabSteel;
beamBracing = basics.beamBracing;

% boltMaterial = basics.boltMaterial;
% tabMaterial = basics.tabMaterial;
spliceLoc = basics.spliceLoc; % Splice location from the bottom end of the column [in]
spliceFraction = basics.spliceFraction; % fraction of the flange welded in the column splice

%% Re-format inputs
bayLgth           = bayLgth.bayLength;
storyHgt          = storyHgt.storyHeight;
colSize           = table2cell(colSize(1:end,2:end));
colOrientations   = table2array(colOrientations(1:end,2:end));
beamSize          = table2cell(beamSize(1:end,2:end));
colSplice         = table2array(colSplice(1:end,2:end));
doublerPlates     = table2array(doublerPlates(1:end,2:end));
beamSizeEGF       = nBeamsEGF.beamSizeEGF;
nGB               = nBeamsEGF.nBeamsEGF;
colSizeEGF        = nColEGF.colSizeEGF;
nColMRForthogonal = nColEGF.nColMRForthogonal;
nGC               = nColEGF.nColEGF;
wgtOnBeam = table2array(wgtOnBeam(1:end,2:end));
wgtOnCol  = table2array(wgtOnCol(1:end,2:end));
wgtOnEGF  = wgtOnEGF.EGFweigth;

if sum(wgtOnEGF) == 0
    bldgData.frameType = 'Space';
else
    bldgData.frameType = 'Perimeter';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% check input file size
if size(bayLgth,1) ~= bayNum
    error('Review bayLgth tab on input file')
end
if size(storyHgt, 1) ~= storyNum
    error('Review storyHgt tab on input file')
end
if size(colSize, 2) ~= axisNum || size(colSize, 1) ~= storyNum
    error('Review colSize tab on input file')
end
if size(colSplice, 2) ~= axisNum || size(colSplice, 1) ~= storyNum
    error('Review colSplice tab on input file')
end
if size(beamSize, 2) ~= bayNum || size(beamSize, 1) ~= storyNum
    error('Review beamSize tab on input file')
end
if size(wgtOnBeam, 2) ~= bayNum || size(wgtOnBeam, 1) ~= storyNum
    error('Review wgtOnBeam tab on input file')
end
if size(wgtOnCol, 2) ~= axisNum || size(wgtOnCol, 1) ~= storyNum
    error('Review wgtOnCol tab on input file')
end
if size(wgtOnEGF, 1) ~= storyNum
    error('Review wgtOnEGF tab on input file')
end

%% Compute column axial loads (necesary for PZ and Column backbones)
% Accumulate loads on column nodes
wgtOnCol(isnan(wgtOnCol)) = 0;
colAxialLoad = flip(cumsum(flip(wgtOnCol),1));
% Accumulate tributary loads on adjacent beams
wgtOnBeam(isnan(wgtOnBeam)) = 0;
wgtOnBeamAux = wgtOnBeam;
wgtOnBeamAux(:, bayNum+1) = 0;
tribLoadPerFloor = zeros(size(colAxialLoad));
tribLoadPerFloor(:,1) = wgtOnBeamAux(:,1)/2;
for Axis = 2:axisNum
    tribLoadPerFloor(:,Axis) = (wgtOnBeamAux(:,Axis-1)+wgtOnBeamAux(:,Axis))/2;
end
% re-locate beam loads if missing columns
for Floor = 2:floorNum
    Story = Floor - 1;
    moveLoad = 0;
    for Axis = 1:axisNum        
        % Identify if the panel zone does not exist and accumulate the load
        % that will otherwise go to it
        if (isempty(colSize{min(Story+1, storyNum), Axis}) && ... % top column does not exist
                isempty(colSize{Story, Axis})) % bottom column does not exist
            if moveLoad == 0
                Axis_i = Axis - 1; % Axis of the left pz that exist
            end
            moveLoad = moveLoad + tribLoadPerFloor(Story,Axis);
            tribLoadPerFloor(Story,Axis) = 0;
        else
            % Found the other PZ that exist and assign load to them
            if moveLoad > 0
                Axis_j = Axis;
                tribLoadPerFloor(Story, Axis_i) = ...
                    tribLoadPerFloor(Story, Axis_i) + moveLoad/2;
                tribLoadPerFloor(Story, Axis_j) = ...
                    tribLoadPerFloor(Story, Axis_j) + moveLoad/2;
            end
        end
    end
end
colAxialLoad = colAxialLoad + flip(cumsum(flip(tribLoadPerFloor)));

% Distribute loads from columns that do not reach the ground to the other
% columns at the story
LoadColEnding = zeros(storyNum, 1);
for Floor = 2:floorNum
    % Get load on columns that end at this floor (if any)
    Story = Floor - 1;
    for Axis = 1:axisNum  
        if isempty(colSize{Story, Axis}) && ~isempty(colSize{min(Story+1, storyNum), Axis})
            LoadColEnding(1:Story) = LoadColEnding(1:Story) + colAxialLoad(Story, Axis);
            colAxialLoad(Story, Axis) = 0;
        elseif isempty(colSize{Story, Axis}) && isempty(colSize{min(Story+1, storyNum), Axis})
            colAxialLoad(Story, Axis) = 0;
        end
    end
end

% Distribute the load to the other columns
for Floor = 2:floorNum
    % Get load on columns that end at this floor (if any)
    Story = Floor - 1;
    if LoadColEnding(Story) > 0
        nColContinue = sum(colAxialLoad(Story, :) ~= 0);
        colAxialLoad(Story, colAxialLoad(Story, :) ~= 0) = ...
            colAxialLoad(Story, colAxialLoad(Story, :) ~= 0) + LoadColEnding(Story)/nColContinue;
    end
end

%% Save variables to struct for later use
bldgData.bayNum = bayNum;
bldgData.storyNum = storyNum;
bldgData.floorNum = floorNum;
bldgData.axisNum = axisNum;
bldgData.tcont = tcont;
bldgData.colSizeEGF = colSizeEGF;
bldgData.nGC = nGC;
bldgData.nColMRForthogonal = nColMRForthogonal;
bldgData.orientation = orientation;
bldgData.beamSizeEGF = beamSizeEGF;
bldgData.nGB = nGB;
bldgData.trib = trib;
bldgData.tslab = tslab;
bldgData.bslab = bslab;
bldgData.AslabSteel = AslabSteel;
bldgData.beamBracing = beamBracing;
% bldgData.boltMaterial = boltMaterial;
% bldgData.tabMaterial = tabMaterial;
bldgData.spliceLoc = spliceLoc; 
bldgData.spliceFraction = spliceFraction;

bldgData.bayLgth = bayLgth;
bldgData.storyHgt = storyHgt;
bldgData.colSize = colSize;
bldgData.colOrientations = colOrientations;
bldgData.beamSize = beamSize;
bldgData.colSplice = colSplice;
bldgData.doublerPlates = doublerPlates;
bldgData.wgtOnBeam = wgtOnBeam;
bldgData.wgtOnCol = wgtOnCol;
bldgData.colAxialLoad = colAxialLoad;
bldgData.wgtOnEGF = wgtOnEGF;
bldgData.webConnection = webConnection;

end
