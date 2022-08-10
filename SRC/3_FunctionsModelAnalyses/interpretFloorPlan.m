% interpretFloorPlan computes the relevant information of the floor plan
% for each floor considering setbacks and podiums. The interpreted
% information is the following:
%   Area_per_floor
%   Area_per_floor_change_Location
%   Perimeter_per_floor
%   Number_gravity_columns
%   Number_gravity_beams_X
%   Number_gravity_beams_Y
% These information is computed only for those building that don't have any
% information.
%
% INPUTS
%   buildingInventory = table with the information of all the buildings
%   bldg_i            = index of the building to be interpreted
% 
% OUTPUTS
%   buildingInventory = table with the information of all the buildings
%                       enhanced with the values described above
%
function buildingInventory = interpretFloorPlan(buildingInventory, bldg_i)

% Read available data
Podium_Stories       = buildingInventory.Podium_Stories;
Podium_Bay_Lengths_X = buildingInventory.Podium_Bay_Lengths_X;
Podium_Bay_Lengths_Y = buildingInventory.Podium_Bay_Lengths_Y;
Tower_Bay_Lengths_X  = buildingInventory.Tower_Bay_Lengths_X;
Tower_Bay_Lengths_Y  = buildingInventory.Tower_Bay_Lengths_Y;
Setbacks_X           = buildingInventory.Setbacks_X;
Setbacks_Y           = buildingInventory.Setbacks_Y;
Stories_Above_Grade  = buildingInventory.Stories_Above_Grade;

Lateral_System_Type            = buildingInventory.Lateral_System_Type;
Number_gravity_columns_at_base = buildingInventory.Number_gravity_columns_at_base;

% Read and format necesary variables
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
story_list = [];
if podium
    story_list = [story_list; Podium_Stories(bldg_i)];
end
if ~isempty(setbacksX)
    story_list = [story_list; setbacksX(:,1)-1];
end
if ~isempty(setbacksY)
    story_list = [story_list; setbacksY(:,1)-1];
end

story_list = unique(story_list);
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

story_list = sort(story_list);
for i = 2:length(story_list)
    story_list(i) = story_list(i) - sum(story_list(1:i-1));
end
story_list = [story_list; Stories_Above_Grade(bldg_i) - sum(story_list)];

% Area and perimeter vector (Area_per_floor and Perimeter_per_floor)
area_list = [];
perimeter_list = [];
nbaysX_list = [];
nbaysY_list = [];
if podium
    area_list = [area_list; sum(podiumX)*sum(podiumY)];
    perimeter_list = [perimeter_list; sum(podiumX)*2 + sum(podiumY)*2];
    nbaysX_list = [nbaysX_list; length(podiumX)];
    nbaysY_list = [nbaysY_list; length(podiumY)];
end
tower_area = sum(towerX)*sum(towerY);
area_list = [area_list; tower_area];
perimeter_list = [perimeter_list; sum(towerX)*2 + sum(towerY)*2];
nbaysX_list = [nbaysX_list; length(towerX)];
nbaysY_list = [nbaysY_list; length(towerY)];

Nsetbacks = length(story_list) - length(area_list);
for i = 1:Nsetbacks
    if n_bays_setbackX(i) ~= 0
        towerX = towerX(1:end-n_bays_setbackX(i));
    end
    if n_bays_setbackY(i) ~= 0
        towerY = towerY(1:end-n_bays_setbackY(i));
    end
    tower_area = sum(towerX)*sum(towerY);
    area_list = [area_list; tower_area];
    perimeter_list = [perimeter_list; sum(towerX)*2 + sum(towerY)*2];
    nbaysX_list = [nbaysX_list; length(towerX)];
    nbaysY_list = [nbaysY_list; length(towerY)];
end

% Save area and perimeter when not available
if isempty(buildingInventory.Area_per_floor{bldg_i})
    
    buildingInventory.Area_per_floor{bldg_i} = ['[', regexprep(mat2str(area_list'), {'\[', '\]', '\s+'}, {'', '', ','}), ']'];
    buildingInventory.Area_per_floor_change_Location{bldg_i} = ['[', regexprep(mat2str(story_list'), {'\[', '\]', '\s+'}, {'', '', ','}), ']'];
    buildingInventory.Perimeter_per_floor{bldg_i} = ['[', regexprep(mat2str(perimeter_list'), {'\[', '\]', '\s+'}, {'', '', ','}), ']'];
    
end

% Compute and save number of gravity columns and beams
if strcmp(Lateral_System_Type{bldg_i}, 'Space')
    buildingInventory.Number_gravity_columns{bldg_i} = '[0]';
    buildingInventory.Number_gravity_beams_X{bldg_i} = '[0]';
    buildingInventory.Number_gravity_beams_Y{bldg_i} = '[0]';
    
elseif strcmp(Lateral_System_Type{bldg_i}, 'Perimeter')
    
    if isempty(buildingInventory.Number_gravity_beams_X{bldg_i})
        
        % Number of gravity columns
        NgCol_list = [];
        NgColBase = Number_gravity_columns_at_base(bldg_i);
        % Add gravity columns for podiums
        if podium
            NgCol_list = [NgCol_list; ceil(NgColBase/area_list(2)*area_list(1))];
        end
        % Assign the collected value to the base of the tower
        NgCol_list = [NgCol_list; NgColBase];
        % Reduce No. gravity columns based on avg trib. area
        for i = 1:Nsetbacks
            NgCol_list = [NgCol_list; ceil(NgColBase/area_list(1+podium)*...
                (area_list(i+1+podium)))];
        end
        % replacing negative prediction with 0
        for j = 1:length(NgCol_list)
            if NgCol_list(j) < 0
                NgCol_list(j) = 0;
            end
        end
        % Number of gravity beams
        NgBeamX_list = NgCol_list + 2*(nbaysY_list + 1);
        NgBeamY_list = NgCol_list + 2*(nbaysX_list + 1);
        % Save values
        buildingInventory.Number_gravity_columns{bldg_i} = ...
            ['[', regexprep(mat2str(NgCol_list'), {'\[', '\]', '\s+'}, {'', '', ','}), ']'];
        buildingInventory.Number_gravity_beams_X{bldg_i} = ...
            ['[', regexprep(mat2str(NgBeamX_list'), {'\[', '\]', '\s+'}, {'', '', ','}), ']'];
        buildingInventory.Number_gravity_beams_Y{bldg_i} = ...
            ['[', regexprep(mat2str(NgBeamY_list'), {'\[', '\]', '\s+'}, {'', '', ','}), ']'];
    else
        buildingInventory.Number_gravity_columns{bldg_i} = '[0]';
    end
    
elseif strcmp(Lateral_System_Type{bldg_i}, 'Intermediate')
    
    % Reduce No. gravity columns based on avg trib. area
    if isempty(buildingInventory.Number_gravity_beams_X{bldg_i})
        
        % Number of gravity columns
        NgCol_list = [];
        NgColBase = Number_gravity_columns_at_base(bldg_i);
        % Add gravity columns for podiums
        if podium
            NgCol_list = [NgCol_list; ceil(NgColBase/area_list(2)*area_list(1))];
        end
        % Assign the collected value to the base of the tower
        NgCol_list = [NgCol_list; NgColBase];
        % Reduce No. gravity columns based on avg trib. area
        for i = 1:Nsetbacks
            NgCol_list = [NgCol_list; ceil(NgColBase/area_list(2)*...
                (area_list(i+1+podium)))];
        end
        % replacing negative prediction with 0
        for j = 1:length(NgCol_list)
            if NgCol_list(j) < 0
                NgCol_list(j) = 0;
            end
        end
        
        % Number of gravity beams
        NgBeamX_list = 2*NgCol_list + (nbaysY_list + 1);
        NgBeamY_list = 2*NgCol_list + (nbaysX_list + 1);
        % Save values
        buildingInventory.Number_gravity_columns{bldg_i} = ...
            ['[', regexprep(mat2str(NgCol_list'), {'\[', '\]', '\s+'}, {'', '', ','}), ']'];
        buildingInventory.Number_gravity_beams_X{bldg_i} = ...
            ['[', regexprep(mat2str(NgBeamX_list'), {'\[', '\]', '\s+'}, {'', '', ','}), ']'];
        buildingInventory.Number_gravity_beams_Y{bldg_i} = ...
            ['[', regexprep(mat2str(NgBeamY_list'), {'\[', '\]', '\s+'}, {'', '', ','}), ']'];
    else
        buildingInventory.Number_gravity_columns{bldg_i} = '[0]';
    end
    
end