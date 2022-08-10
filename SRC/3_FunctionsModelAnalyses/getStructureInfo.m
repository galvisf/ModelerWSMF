function [colArray,beamArray,storyHeight,bayLength,colOrientations, ...
            colSplice,DoublerPlates,basicInfo] = ...
            getStructureInfo(buildingInventory,bldg_i,frameDir,switchOrientation)
    
    % Get frame matrices 
    switch frameDir
        case 'X'
            [colArray,beamArray,colSplice,bayLength,colheight] = ...
                genStructureArray(buildingInventory.Stories_Above_Grade(bldg_i),...
                buildingInventory.Podium_Stories(bldg_i),...
                buildingInventory.Podium_Bay_Lengths_X{bldg_i},...
                buildingInventory.Tower_Bay_Lengths_X{bldg_i},...
                buildingInventory.Column_Sizes_Exterior{bldg_i},...
                buildingInventory.Column_Sizes_Interior{bldg_i},...
                buildingInventory.Beam_Sizes{bldg_i},...
                buildingInventory.Column_Location_Exterior(bldg_i),...
                buildingInventory.Column_Location_Interior(bldg_i),...
                buildingInventory.Beam_Location(bldg_i),...
                buildingInventory.Column_Splice_Location{bldg_i},...
                buildingInventory.Setbacks_X(bldg_i),...
                buildingInventory.Missing_column_x(bldg_i),...
                buildingInventory.Atrium_Stories(bldg_i),...
                buildingInventory.Atrium_Bays_x(bldg_i));
            
            DoublerPlates = getDoublerPlates(colArray, ...
                buildingInventory.Typ_Panel_Zone_Double_Plate_thick(bldg_i));
            colEGForientation = 'Strong';
        case 'Y'
            [colArray,beamArray,colSplice,bayLength,colheight] = ...
                genStructureArray(buildingInventory.Stories_Above_Grade(bldg_i),...
                buildingInventory.Podium_Stories(bldg_i),...
                buildingInventory.Podium_Bay_Lengths_Y{bldg_i},...
                buildingInventory.Tower_Bay_Lengths_Y{bldg_i},...
                buildingInventory.Column_Sizes_Exterior(bldg_i),...
                buildingInventory.Column_Sizes_Interior(bldg_i),...
                buildingInventory.Beam_Sizes(bldg_i),...
                buildingInventory.Column_Location_Exterior(bldg_i),...
                buildingInventory.Column_Location_Interior(bldg_i),...
                buildingInventory.Beam_Location(bldg_i),...
                buildingInventory.Column_Splice_Location{bldg_i},...
                buildingInventory.Setbacks_Y(bldg_i),...
                buildingInventory.Missing_column_y(bldg_i),...
                buildingInventory.Atrium_Stories(bldg_i),...
                buildingInventory.Atrium_Bays_y(bldg_i));
            
            DoublerPlates = getDoublerPlates(colArray, ...
                buildingInventory.Typ_Panel_Zone_Double_Plate_thick(bldg_i));
            colEGForientation = 'Weak';
    end
    % Get story heights
    storyHeight = genStoryHeight(buildingInventory.Stories_Above_Grade(bldg_i),...
        buildingInventory.Typ_Story_Height(bldg_i),...
        buildingInventory.Attyp_Story_Height(bldg_i));
    
    % Get column orientations
    colOrientations = getColOrientations(colArray, buildingInventory.Lateral_System_Type{bldg_i}, ...
                                         switchOrientation);
    
    % Store basic inputs for the frame
    nBays = length(bayLength);
    nStory = length(storyHeight);
    tSteelDeck = buildingInventory.Steel_Deck_Depth(bldg_i);    
    tConcreteSlab = buildingInventory.Floor_Slab_Topping_Depth(bldg_i);
    effectiveSlabWidth = min([3*12, mean(bayLength)/2]); % maximum 3ft of effective slab width    
    spliceLoc = colheight;
    spliceFraction = buildingInventory.Column_Splice_Flange_penetration_ratio(bldg_i);
    basicInfo.storiesAboveGrade = nStory;
    basicInfo.MaximumBayNumber = nBays;
    basicInfo.tTypicalContinuityPlate = buildingInventory.tTypicalContinuityPlate(bldg_i);
    basicInfo.colEGForientation = colEGForientation;
    basicInfo.tSteelDeckRib = tSteelDeck;
    basicInfo.tConcreteSlab = tConcreteSlab;
    basicInfo.effectiveSlabWidth = effectiveSlabWidth;
    basicInfo.AslabSteel = buildingInventory.AslabSteel(bldg_i);
    basicInfo.spliceLoc = spliceLoc;
    basicInfo.spliceFraction = spliceFraction;
    basicInfo.beamBracing = buildingInventory.beamBracing(bldg_i);
    
end

function colOrientations = getColOrientations(colArray, frameType, switchOrientation)
    
axisNum = size(colArray,2);
colOrientations = ones(size(colArray));

for Axis = 1:axisNum    
    % Define column orientation
    if strcmp(frameType, 'Perimeter') || ~switchOrientation
        % Columns in the moment frame are always assumed in STRONG ORIENTATION
        colOrientations(:,Axis) = ones(size(colArray,1),1);
    else
        % for space and intermediate frames columns in the moment frame in 
        % are stagged strong-weak
        if Axis > 1
            if colOrientations(1,Axis-1) == 1
                colOrientations(:,Axis) = zeros(size(colArray,1),1);
            elseif colOrientations(1,Axis-1) == 0
                colOrientations(:,Axis) = ones(size(colArray,1),1);
            end
        end
    end
end
end

function DoublerPlates = getDoublerPlates(colArray, Typ_Panel_Zone_Double_Plate_thick)
    DoublerPlates = ones(size(colArray))*Typ_Panel_Zone_Double_Plate_thick;
    
    % no doubler plates on exterior connections or conection on box columns
    DoublerPlates(:,1) = 0;
    DoublerPlates(:,end) = 0; % 
    for Story = 1:size(colArray,1)
        for Axis = 1:size(colArray,2)
            if isempty(colArray(Story,Axis)) || contains(colArray{Story,Axis}, 'BOX')
                DoublerPlates(Story,Axis) = 0;
            end
        end
    end
end

function [colArray,beamArray,colSplice,bayLength,colheight] = ...
    genStructureArray(nStories_total,nStories_podium,podiumBayLengths,...
    towerBayLengths,Column_Sizes_Exterior_i,Column_Sizes_Interior_i,...
    Beam_Sizes_i,Column_Location_Exterior_i,...
    Column_Location_Interior_i,Beam_Location_i,Column_Splice_Location_i,...
    Setbacks_i,Missing_column_i,Atrium_Stories_i,Atrium_Bays_i)

    %% Process Inputs
    % Exterior columns
    Column_Sizes_Exterior_i = strrep(Column_Sizes_Exterior_i,' ','');
    Column_Sizes_Exterior_i = strrep(Column_Sizes_Exterior_i, ']','');
    Column_Sizes_Exterior_i = strrep(Column_Sizes_Exterior_i, '[','');
    Column_Sizes_Exterior_i = split(Column_Sizes_Exterior_i,',');
    % Interior columns
    Column_Sizes_Interior_i = strrep(Column_Sizes_Interior_i, ' ','');
    Column_Sizes_Interior_i = strrep(Column_Sizes_Interior_i, ']','');
    Column_Sizes_Interior_i = strrep(Column_Sizes_Interior_i, '[','');    
    Column_Sizes_Interior_i = split(Column_Sizes_Interior_i,',');
    % Beams
    Beam_Sizes_i = strrep(Beam_Sizes_i, ' ','');
    Beam_Sizes_i = strrep(Beam_Sizes_i, ']','');
    Beam_Sizes_i = strrep(Beam_Sizes_i, '[','');
    Beam_Sizes_i = split(Beam_Sizes_i,',');
    % Column Splices
    colheight = split(Column_Splice_Location_i(2:end-1),',');
    nStorySplice = str2double(colheight{1});
    colheight = str2double(colheight{1});    
    % Setbacks
    Setbacks_i = Setbacks_i{1};
    if ~isempty(Setbacks_i)
        cellList = split(Setbacks_i,'],[');
        setbacks = zeros(length(cellList),2);
        for i = 1:length(cellList)
            setb = cellList{i};
            setb = erase(setb,'[');
            setb = erase(setb,']');
            setb = split(setb,',');
            setbacks(i,1) = str2double(setb{1});
            setbacks(i,2) = str2double(setb{2});
        end
        Setbacks_i = setbacks;
    else
        Setbacks_i = [];
    end
    % Bay lengths
    towerBayLengths = eval(towerBayLengths);
    if isempty(podiumBayLengths)
        podium = false;
    else
        podium = true;
        podiumBayLengths = eval(podiumBayLengths);
    end
    % Missing Column
    Missing_column_i = Missing_column_i{1};
    if ~isempty(Missing_column_i)
        cellList = split(Missing_column_i,'],[');
        mC = zeros(length(cellList),3);
        for i = 1:length(cellList)
            col = cellList{i};
            col = erase(col,'[');
            col = erase(col,']');
            col = split(col,',');
            mC(i,1) = str2double(col{1});
            mC(i,2) = str2double(col{2});
            mC(i,3) = str2double(col{3});
        end
        Missing_column_i = mC;
    end

    %% Get total number of bays for the frame grid
    if podium
        % tower and podium bays match
        podiumBaysStr = num2str(podiumBayLengths);
        podiumBaysStr = strrep(podiumBaysStr, '           ', '  ');
        podiumBaysStr = strrep(podiumBaysStr, '          ', '  ');
        podiumBaysStr = strrep(podiumBaysStr, '         ', '  ');
        podiumBaysStr = strrep(podiumBaysStr, '        ', '  ');
        podiumBaysStr = strrep(podiumBaysStr, '       ', '  ');
        podiumBaysStr = strrep(podiumBaysStr, '      ', '  ');
        podiumBaysStr = strrep(podiumBaysStr, '     ', '  ');
        podiumBaysStr = strrep(podiumBaysStr, '    ', '  ');
        
        towerBaysStr = num2str(towerBayLengths);
        towerBaysStr = strrep(towerBaysStr, '           ', '  ');
        towerBaysStr = strrep(towerBaysStr, '          ', '  ');
        towerBaysStr = strrep(towerBaysStr, '         ', '  ');
        towerBaysStr = strrep(towerBaysStr, '        ', '  ');
        towerBaysStr = strrep(towerBaysStr, '       ', '  ');
        towerBaysStr = strrep(towerBaysStr, '      ', '  ');
        towerBaysStr = strrep(towerBaysStr, '     ', '  ');
        towerBaysStr = strrep(towerBaysStr, '    ', '  ');
        
        if contains(podiumBaysStr,towerBaysStr)
            nBays = length(podiumBayLengths);
            bayLength = podiumBayLengths;
            % rearrange bay length to make sure the tower is to the left
            idx = strfind(podiumBaysStr, towerBaysStr);
            if length(idx) > 1
                idx = idx(1);
            end
            if idx == 1
                remaingBays = podiumBaysStr(idx+length(towerBaysStr):end);
            else
                remaingBays = [podiumBaysStr(1:idx+1), podiumBaysStr(idx+1+length(towerBaysStr):end)];
            end
            if isempty(remaingBays)
                podiumBayLengths = towerBayLengths;
            else
                podiumBayLengths = [towerBayLengths, str2num(remaingBays)];
            end
            % Add a setback that represents the podium
            if nBays - length(towerBayLengths) > 0
                Setbacks_i = [nStories_podium, nBays - length(towerBayLengths); Setbacks_i];
            end
            removeBaysPodium = false;
            removeBaysTower = false;
        else
            % tower and podium don't match
            cumLengthPodium = [0,cumsum(podiumBayLengths)];
            cumLengthTower = [0,cumsum(towerBayLengths)];
            gridLines = sort(unique([cumLengthPodium, cumLengthTower]));
            baysGrid = diff(gridLines);
            
            nBays = length(baysGrid);
            bayLength = baysGrid;
            
            % Add a setback that represents the podium
            if nBays - length(towerBayLengths) > 0 && cumLengthPodium(end) > cumLengthTower(end)
                Setbacks_i = [nStories_podium, nBays - length(towerBayLengths);Setbacks_i];
            end
            % Flag to remove columns at the podium or tower         
            if find(cumLengthPodium == cumLengthTower(end),1) <= length(cumLengthTower)
                % more bays in the tower for the same width
                removeBaysPodium = true;
                removeBaysTower = false;
            else
                % more bays in the podium for the same width
                removeBaysPodium = false;
                removeBaysTower = true;
            end
        end
    else
        removeBaysPodium = false;
        removeBaysTower = false;
        nBays = length(towerBayLengths);
        bayLength = towerBayLengths;
    end
    bayLength = bayLength*12; % ft to in
    
    %% Initialize Outputs
    colArray = cell(nStories_total,nBays+1);
    beamArray = cell(nStories_total,nBays);
    % colSplice = cell(nStories_total,nBays+1);
    nCols = ceil(nStories_total/nStorySplice);
    
    %% Column Splices
    singleCol = [zeros(nStorySplice-1,1);1];
    allCol = repmat(singleCol,nCols,nBays+1);
    colSplice = allCol(1:nStories_total,:);
    
    %% Internal Columns
    %%%% Assign column section to stories using the location vector
    colSecs = 1:length(Column_Sizes_Interior_i);    
    colMapping = repelem(colSecs, str2num(Column_Location_Interior_i{1}))';
    colMapping = repmat(colMapping, 1, nBays+1);
    
    colArray(:) = Column_Sizes_Interior_i(colMapping);
    
    %% Remove columns for podiums and towers that don't match bays
    if removeBaysPodium
        for i = 1:length(gridLines)
            if ~ismember(gridLines(i), cumLengthPodium)
                colArray(1:nStories_podium, i) = {''};
            end
        end
    end
    if removeBaysTower
        for i = 1:length(gridLines)
            if ~ismember(gridLines(i), cumLengthTower)
                colArray(nStories_podium+1:end, i) = {''};
            end
        end
    end
    
    %% Setbacks
    setbackLog = zeros(nStories_total,nBays+1);
    extColLog = [zeros(nStories_total,nBays),ones(nStories_total,1)];
    extCount = 1;
    setCount = 1;
    for i = 1:size(Setbacks_i,1)
        extColLog(extCount:Setbacks_i(i,1)-1,setCount) = 1;
        extCount = Setbacks_i(i,1);
        setbackLog(Setbacks_i(i,1):end,setCount:(setCount-1+Setbacks_i(i,2))) = 1;
        setCount = setCount+Setbacks_i(i,2);
    end
    extColLog(extCount:end,setCount) = 1;
    if sum(sum(setbackLog)) > 0
        colArray(setbackLog==1) = {''};
        colSplice(setbackLog==1) = 0;
    end

    %% External Columns
    %%%% Assign column section to stories using the location vector
    colSecs = 1:length(Column_Sizes_Exterior_i);       
    colMapping = repelem(colSecs, str2num(Column_Location_Exterior_i{1}))';
    colMapping = repmat(colMapping, 1, 2);
    
    colArray(extColLog==1) = Column_Sizes_Exterior_i(colMapping);

    %% Missing Columns
    if ~isempty(Missing_column_i)
        misColLog = zeros(nStories_total,nBays+1);
        misColCount = zeros(nStories_total,1);
        for i = 1:size(Missing_column_i,1)
            misColCount(Missing_column_i(i,1):Missing_column_i(i,2)) = misColCount(Missing_column_i(i,1):Missing_column_i(i,2)) + Missing_column_i(i,3);
        end
        centerAxis = ceil((nBays+1)/2);
        axisLeft = floor(misColCount/2);
        missStart = centerAxis-axisLeft;
        
        % Check that we are not deleting an external column
        for i = 1:length(missStart)
            if missStart(i) == 1           
                missStart = missStart + 1; % shifts the missing column to the next axis
            elseif ~isempty(Setbacks_i)
                if missStart(i) == sum(Setbacks_i(:,2)) + 1
                    missStart = missStart + 1; % shifts the missing column to the next axis
                end
            elseif  missStart(i) == nBays + 1
                missStart = missStart - 1; % shifts the missing column to the previous axis
            end
        end
        
        missEnd = missStart + misColCount;
        for i = 1:size(misColLog,1)            
            misColLog(i, missStart(i):missEnd(i)-1) = 1;
        end
        colArray(misColLog==1) = {''};
        colSplice(misColLog==1) = 0;
    end

    %% Beams
    %%%% Assign beam section to stories using the location vector
    beamSecs = 1:length(Beam_Sizes_i);       
    beamMapping = repelem(beamSecs, str2num(Beam_Location_i{1}))';
    beamMapping = repmat(beamMapping, 1, nBays);
    
    beamArray(:) = Beam_Sizes_i(beamMapping);
    if sum(sum(setbackLog)) > 0
        beamArray(setbackLog==1) = {''};
    end

    %% Atrium
    if ~isnan(Atrium_Stories_i) && Atrium_Stories_i>0
        atriumCenter = ceil(nBays/2)+1;        
        if nBays == 3
            atriumCenter = 2;
        end
        atriumBaysLeft = floor(Atrium_Bays_i/2);
        atriumBayStart = atriumCenter-atriumBaysLeft;
        atriumBayEnd = atriumBayStart + Atrium_Bays_i - 1;
        
        % if the right-most beam is part of the atrium shift the atrium one
        % bay to the left because all the beams must intercept to the last
        % column to connect with the EGF
        if atriumBayEnd == nBays
            atriumBayStart = atriumBayStart - 1;
            atriumBayEnd = atriumBayEnd - 1;
        end
        
        beamLog = zeros(nStories_total,nBays);
        beamLog(1:Atrium_Stories_i-1,atriumBayStart:atriumBayEnd) = 1; % this table has floors so use (Atrium_Stories_i - 1)
        beamArray(beamLog==1) = {''};
    end
end