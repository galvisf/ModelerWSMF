function webConnection = createWebConnection(buildingInventory,bldg_i,beamSize,AISC_v14p1)

% Get unique beam sections
sections = unique(beamSize);
sections = sections(cellfun(@isempty,sections) == 0); % remove empty cells
nSec = length(sections);

% Get connection type
Connection_Type = buildingInventory.Connection_Type{bldg_i};

% Add to structure
webConnection.Size             = sections;
if strcmp(Connection_Type, 'Welded')
    webConnection.BoltNumber   = zeros(nSec,1);
    webConnection.BoltDiameter = zeros(nSec,1);
    webConnection.tabThickness = 1/2*ones(nSec,1); % assumed
    webConnection.tabLength    = 5*ones(nSec,1); % assumed
    webConnection.bolSpacing   = zeros(nSec,1);
    webConnection.Lc           = zeros(nSec,1);
    
    hw = zeros(nSec,1);
    for sec_i = 1:nSec
        props = getSteelSectionProps(sections{sec_i}, AISC_v14p1);
        hw(sec_i) = props.db - 2*props.tf;
    end    
    webConnection.dtab         = round(max(hw-4, 0.7*hw)); % assumed
    
    webConnection.Type         = cell(nSec,1);
    webConnection.Type(:)      = {Connection_Type};
else    
    boltSpacing     = buildingInventory.Typ_Bolt_Separation_Moment(bldg_i);
    boltPerDepth    = buildingInventory.Typ_Bolts_Per_Beam_Depth(bldg_i);
    BoltDiameter    = buildingInventory.Typ_Bolt_Diameter(bldg_i);        
    
    db = zeros(nSec,1);
    for sec_i = 1:nSec
        props = getSteelSectionProps(sections{sec_i}, AISC_v14p1);
        db(sec_i) = props.db;
    end
    BoltNumber = round(db.*boltPerDepth);        
    
    webConnection.BoltNumber   = BoltNumber;
    webConnection.BoltDiameter = BoltDiameter*ones(nSec,1);
    webConnection.tabThickness = 1/2*ones(nSec,1); % assumed
    webConnection.tabLength    = 5*ones(nSec,1); % assumed
    webConnection.bolSpacing   = boltSpacing*ones(nSec,1);
    webConnection.Lc           = 2*ones(nSec,1); % assumed
    webConnection.dtab         = BoltNumber*boltSpacing+4;
    
    % Check that the row of bolts is not larger than the beam depth
    % if it is, reduce the number of bolts to half (assuming to parallel
    % row of bolts)
    boltRowLength = BoltNumber.*webConnection.bolSpacing;
    for sec_i = 1:length(boltRowLength)
        if boltRowLength(sec_i) > 0.9*db(sec_i)
            webConnection.BoltNumber(sec_i) = round(boltPerDepth/2*db(sec_i));
        end
    end
    
    webConnection.Type         = cell(nSec,1);
    webConnection.Type(:)      = {Connection_Type};
end

end