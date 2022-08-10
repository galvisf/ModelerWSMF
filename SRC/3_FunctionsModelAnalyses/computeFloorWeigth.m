% computeFloorWeigth returns the total weight per floor for a building
% building assuming a generic occupancy type (office) and considering the
% area and perimeter of each floor
% 
% INPUTS
%   bldg_i            = Index of the building
%   buildingInventory = table with the information of all the buildings
% 
% OUTPUT
%   floorWeigth       = vector with the total weigth per floor [kips]
%   floorWeigthPerSf  = vector with the weigth per area [kips/sqf]
%
function [floorWeigth, floorWeigthPerSf] = computeFloorWeigth(bldg_i, buildingInventory)

% Get necesary data from the building
tslab = buildingInventory.Floor_Slab_Topping_Depth(bldg_i); 
tdeck = buildingInventory.Steel_Deck_Depth(bldg_i);
claddingType = buildingInventory.Facade_Material{bldg_i}; 
concreteType = buildingInventory.Concrete_Weight{bldg_i};
MEP_levels = eval(buildingInventory.MEP_levels{bldg_i});
storyNum = buildingInventory.Stories_Above_Grade(bldg_i);
Area = buildingInventory.Area_per_floor{bldg_i};
Perimeter = buildingInventory.Perimeter_per_floor{bldg_i};
floor_changes = buildingInventory.Area_per_floor_change_Location{bldg_i};
Stairs_Area = buildingInventory.Stairs_Area(bldg_i);
Elevator_Area = buildingInventory.Elevator_Area(bldg_i);

% Re-format story height vector
typicalStoryHeight = buildingInventory.Typ_Story_Height(bldg_i);
AtypicalStoryHeight = buildingInventory.Attyp_Story_Height(bldg_i);
storyHgt = genStoryHeight(storyNum,typicalStoryHeight,AtypicalStoryHeight);

% Re-format area and perimeter vectors
Area = formatInputByFloor(Area,floor_changes);
Perimeter = formatInputByFloor(Perimeter,floor_changes);
if length(Area) ~= storyNum || length(Perimeter) ~= storyNum
    error(['Check the Area_per_floor_change_Location: building ', num2str(bldg_i)])
end

% Remove stairs and elevator voids
Area = Area - Stairs_Area - Elevator_Area;
if any(Area < 0)
    error(['Area of elevator and stairs larger than floor area']);
elseif any(isnan(Area))
    error(['Area of elevator or stairs not defined']);
end

% Compute total vertical load per floor
floorWeigth = zeros(storyNum, 1);
for Floor = 1:storyNum
    if ismember(Floor, MEP_levels)
        MEC = true;
    else
        MEC = false;
    end
    [DL, SDL, LL_red, ~, GL, CL] = getFloorWeigths(MEC, concreteType, claddingType, tslab, tdeck);
    floorWeigth(Floor) = (1.05*(DL+SDL) + 0.25*LL_red + 1.05*GL)*Area(Floor) + ...
                            Perimeter(Floor)*(storyHgt(Floor)/12)*CL; % lb
    floorWeigth(Floor) = floorWeigth(Floor)/1000; % kips
end

floorWeigthPerSf = floorWeigth./Area;

end