% distributeFloorWeight distriuted the weigth per floor to the moment
% resistent frame and the equivalent gravity system. 
% This function also computes the number of elements for the EGF
% corresponding to the frame to be modeled in each direction
%
% INPUTS
%   bldg_i            = Index of the building
%   buildingInventory = table with the information of all the buildings
%   floorWeigth       = vector with the total weigth per floor [kips]
%   floorWeigthPerSf  = vector with the weigth per area [kips/sqf]
%
% OUTPUT
%   frameWeigthX  = vector with the weigths per floor corresponding to the
%                   MRF in X [kip]
%   EGFweigthX    = vector with the weigths per floor corresponding to the
%                   EGF in X [kip]
%   frameWeigthY  = vector with the weigths per floor corresponding to the
%                   MRF in Y [kip]
%   EGFweigthY    = vector with the weigths per floor corresponding to the
%                   EGF in Y [kip]
%   nColMRForthoX = number of columns of the MRFs ortogonal to X
%   nColMRForthoY = number of columns of the MRFs ortogonal to Y
%   nColEGFX      = number of column on the EGF that works with the frame
%                   in X
%   nColEGFY      = number of column on the EGF that works with the frame
%                   in Y
%   nBeamsEGFX    = number of beams on the EGF that works with the frame
%                   in X
%   nBeamsEGFY    = number of beams on the EGF that works with the frame
%                   in Y
%   MRF_X         = Vector with the number of parallel MRF in X for every floor
%   MRF_Y         = Vector with the number of parallel MRF in Y for every floor
%   frameLengthX  = Vector with length of the frame parallel to X for every story [ft]
%   frameLengthY  = Vector with length of the frame parallel to Y for every story [ft]
% 
function [frameWeigthX, EGFweigthX, frameWeigthY, EGFweigthY, nColMRForthoX, ...
            nColMRForthoY, nColEGFX, nColEGFY, nBeamsEGFX, nBeamsEGFY, ...
            MRF_X, MRF_Y, frameLengthX, frameLengthY] = ...
            distributeFloorWeight(bldg_i, buildingInventory, floorWeigth, floorWeigthPerSf)

% Get necesary data from the building 
Lateral_System_Type = buildingInventory.Lateral_System_Type{bldg_i};
Podium_Stories = buildingInventory.Podium_Stories;
Podium_Bay_Lengths_X = buildingInventory.Podium_Bay_Lengths_X;
Podium_Bay_Lengths_Y = buildingInventory.Podium_Bay_Lengths_Y;
Tower_Bay_Lengths_X = buildingInventory.Tower_Bay_Lengths_X;
Tower_Bay_Lengths_Y = buildingInventory.Tower_Bay_Lengths_Y;
Setbacks_X = buildingInventory.Setbacks_X;
Setbacks_Y = buildingInventory.Setbacks_Y;

floor_changes = buildingInventory.Area_per_floor_change_Location{bldg_i};
nColEGF_total = buildingInventory.Number_gravity_columns{bldg_i};
nBeamsEGFX_total = buildingInventory.Number_gravity_beams_X{bldg_i};
nBeamsEGFY_total = buildingInventory.Number_gravity_beams_Y{bldg_i};

% Read and format necesary variables
if strcmp(Lateral_System_Type, 'Space')
    nColEGF_total = zeros(length(floor_changes),1);
    nBeamsEGFX_total = zeros(length(floor_changes),1);
    nBeamsEGFY_total = zeros(length(floor_changes),1);
else
    if strcmp(nColEGF_total, '[0]')
        nColEGF_total = formatInputByFloor(zeros(length(floor_changes),1),floor_changes);
    else
        nColEGF_total = formatInputByFloor(nColEGF_total,floor_changes);
    end
    nBeamsEGFX_total = formatInputByFloor(nBeamsEGFX_total,floor_changes);
    nBeamsEGFY_total = formatInputByFloor(nBeamsEGFY_total,floor_changes);
end
if Podium_Stories(bldg_i) ~= 0
    podium = true;
    podiumX = eval(Podium_Bay_Lengths_X{bldg_i});
    podiumY = eval(Podium_Bay_Lengths_Y{bldg_i});
else
    podium = false;
end
towerX = eval(Tower_Bay_Lengths_X{bldg_i});
towerY = eval(Tower_Bay_Lengths_Y{bldg_i});

if ~isempty(Setbacks_X{bldg_i})
    setbacksX = Setbacks_X{bldg_i};
    if ~isempty(setbacksX)
        cellList = split(setbacksX,'],[');
        setbacks = zeros(length(cellList),2);
        for i = 1:length(cellList)
            setb = cellList{i};
            setb = erase(setb,'[');
            setb = erase(setb,']');
            setb = split(setb,',');
            setbacks(i,1) = str2double(setb{1});
            setbacks(i,2) = str2double(setb{2});
        end
        setbacksX = setbacks;
    end
else
    setbacksX = [];
end

if ~isempty(Setbacks_Y{bldg_i})
    setbacksY = Setbacks_Y{bldg_i};
    if ~isempty(setbacksY)
        cellList = split(setbacksY,'],[');
        setbacks = zeros(length(cellList),2);
        for i = 1:length(cellList)
            setb = cellList{i};
            setb = erase(setb,'[');
            setb = erase(setb,']');
            setb = split(setb,',');
            setbacks(i,1) = str2double(setb{1});
            setbacks(i,2) = str2double(setb{2});
        end
        setbacksY = setbacks;
    end
else
    setbacksY = [];
end

% Compute story list (Area_per_floor_change_Location)
aux = eval(floor_changes);
story_list = cumsum(aux(1:end-1)); 
% floors where a setbacks occurs (last entry in floor_changes is the number
% of floors from last setback to the roof so ignores it)

if podium
    story_setbacks = story_list(2:end);
else
    story_setbacks = story_list;
end
n_bays_setbackX = zeros(length(unique(story_setbacks)),1);
n_bays_setbackY = zeros(length(unique(story_setbacks)),1);
for i = 1:length(n_bays_setbackX)
    if ~isempty(setbacksX)
        if ismember(story_setbacks(i), setbacksX(:,1)-1)
            idx = find(story_setbacks(i) == setbacksX(:,1)-1);
            n_bays_setbackX(i) = setbacksX(idx,2);
        end
    end
    if ~isempty(setbacksY)
        if ismember(story_setbacks(i), setbacksY(:,1)-1)
            idx = find(story_setbacks(i) == setbacksY(:,1)-1);
            n_bays_setbackY(i) = setbacksY(idx,2);
        end
    end
end

% Compute number of bays and length of the frame per direction and floor
nbaysX_list = [];
nbaysY_list = [];
frameLengthX = [];
frameLengthY = [];
if podium
    nbaysX_list = [nbaysX_list; length(podiumX)];
    nbaysY_list = [nbaysY_list; length(podiumY)];
    frameLengthX = [frameLengthX; sum(podiumX)];
    frameLengthY = [frameLengthY; sum(podiumY)];
end
nbaysX_list = [nbaysX_list; length(towerX)];
nbaysY_list = [nbaysY_list; length(towerY)];
frameLengthX = [frameLengthX; sum(towerX)];
frameLengthY = [frameLengthY; sum(towerY)];

for i = 1:length(n_bays_setbackX)
    if n_bays_setbackX(i) ~= 0
        towerX = towerX(1:end-n_bays_setbackX(i));
    end
    if n_bays_setbackY(i) ~= 0
        towerY = towerY(1:end-n_bays_setbackY(i));
    end
    nbaysX_list = [nbaysX_list; length(towerX)];
    nbaysY_list = [nbaysY_list; length(towerY)];
    frameLengthX = [frameLengthX; sum(towerX)];
    frameLengthY = [frameLengthY; sum(towerY)];
end
nbaysX = formatInputByFloor(nbaysX_list,floor_changes);
nbaysY = formatInputByFloor(nbaysY_list,floor_changes);
frameLengthX = formatInputByFloor(frameLengthX,floor_changes);
frameLengthY = formatInputByFloor(frameLengthY,floor_changes);

% Compute the number of frames per direction
if strcmp(Lateral_System_Type, 'Perimeter')
    MRF_X = 2*ones(length(floorWeigth),1);
    MRF_Y = 2*ones(length(floorWeigth),1);
elseif strcmp(Lateral_System_Type, 'Space')
    MRF_X = nbaysY + 1;
    MRF_Y = nbaysX + 1;
elseif strcmp(Lateral_System_Type, 'Intermediate')
    MRF_X = buildingInventory.Moment_Resisting_Frames_X(bldg_i)*ones(length(floorWeigth),1);
    MRF_Y = buildingInventory.Moment_Resisting_Frames_Y(bldg_i)*ones(length(floorWeigth),1);
elseif strcmp(Lateral_System_Type, 'PerimeterX-SpaceY')
    MRF_X = 2;
    MRF_Y = nbaysX + 1;
end

% Compute tributary load per frame
floorWeigthX = floorWeigth./MRF_X;
floorWeigthY = floorWeigth./MRF_Y;

% Differentiate between load directly on the frame and on the gravity system
if strcmp(Lateral_System_Type, 'Perimeter') || strcmp(Lateral_System_Type, 'Intermediate')
    % Load per floor in X
    tribWidthX   = mean(towerY)/2;    
    frameWeigthX = floorWeigthPerSf*tribWidthX.*frameLengthX;
    EGFweigthX   = floorWeigthX - frameWeigthX;
    if any(EGFweigthX < 0)
        bldg_name = ['ID',num2str(buildingInventory.OBJECTID(bldg_i))];
        disp(['The weight on the EGF is negative for X: bldg ', bldg_name])
        EGFweigthX(EGFweigthX < 0) = 0;
    end
    % Load per floor in Y
    tribWidthY   = mean(towerX)/2;
    frameWeigthY = floorWeigthPerSf*tribWidthY.*frameLengthY;
    EGFweigthY   = floorWeigthY - frameWeigthY;
    if any(EGFweigthY < 0)
        bldg_name = ['ID',num2str(buildingInventory.OBJECTID(bldg_i))];
        disp(['The weight on the EGF is negative for Y: bldg ', bldg_name])
        EGFweigthY(EGFweigthY < 0) = 0;
    end
    % EGF in X
    nColMRForthoX = round(MRF_Y.*(nbaysY + 1)./MRF_X);
    nColEGFX      = round(nColEGF_total./MRF_X);
    nBeamsEGFX    = round(nBeamsEGFX_total./MRF_X);
    % EGF in Y
    nColMRForthoY = round(MRF_X.*(nbaysX + 1)./MRF_Y);
    nColEGFY      = round(nColEGF_total./MRF_Y);
    nBeamsEGFY    = round(nBeamsEGFY_total./MRF_Y);

elseif strcmp(Lateral_System_Type, 'Space')
    % Load per floor in X
    frameWeigthX = floorWeigthX;
    EGFweigthX   = zeros(length(floorWeigthX),1);
    % Load per floor in Y
    frameWeigthY = floorWeigthY;
    EGFweigthY   = zeros(length(floorWeigthY),1);
    % EGF in X
    nColMRForthoX = zeros(length(floorWeigthX),1);
    nColEGFX      = zeros(length(floorWeigthX),1);
    nBeamsEGFX    = zeros(length(floorWeigthX),1);
    % EGF in Y
    nColMRForthoY = zeros(length(floorWeigthX),1);
    nColEGFY      = zeros(length(floorWeigthX),1);
    nBeamsEGFY    = zeros(length(floorWeigthX),1);

elseif strcmp(Lateral_System_Type, 'PerimeterX-SpaceY')
    % Load per floor in X
    tribWidthX   = mean(towerY)/2;    
    frameWeigthX = floorWeigthPerSf*tribWidthX.*frameLengthX;
    EGFweigthX   = floorWeigthX - frameWeigthX;
    if any(EGFweigthX < 0)
        bldg_name = ['ID',num2str(buildingInventory.OBJECTID(bldg_i))];
        disp(['The weight on the EGF is negative for X: bldg ', bldg_name])
        EGFweigthX(EGFweigthX < 0) = 0;
    end
    % Load per floor in Y
    frameWeigthY = floorWeigthY;
    EGFweigthY   = zeros(length(floorWeigthY),1);
    % EGF in X
    nColMRForthoX = round(2.*(nbaysY + 1)./2);
    nColEGFX      = round(nColEGF_total./2);
    nBeamsEGFX    = round(nBeamsEGFX_total./2);
    % EGF in Y
    nColMRForthoY = zeros(length(floorWeigthX),1);
    nColEGFY      = zeros(length(floorWeigthX),1);
    nBeamsEGFY    = zeros(length(floorWeigthX),1);

end

end