function secProps = getSectionProps(bldgData, AISC_v14p1, Es, FyBeam, FyCol)
%% Read relevant variables
storyNum    = bldgData.storyNum;
floorNum    = bldgData.floorNum;
bayNum      = bldgData.bayNum;
axisNum     = bldgData.axisNum;
colSize     = bldgData.colSize;
beamSize    = bldgData.beamSize;
storyHgt    = bldgData.storyHgt;
bayLgth     = bldgData.bayLgth;
beamBracing = bldgData.beamBracing;
colOrientations = bldgData.colOrientations;
Pu              = bldgData.colAxialLoad;

% inputs for flexural strength calculation
c     = 1; % factor for torsional stiffness (W sections use == 1)
Cb    = 2.27; % factor for moment redistribution (double curvature)

%% Get properties of all sections in the building
% Get column stiffness information
dbCol = zeros(storyNum, axisNum);
bfCol = zeros(storyNum, axisNum);
twCol = zeros(storyNum, axisNum);
tfCol = zeros(storyNum, axisNum);
IzCol = zeros(storyNum, axisNum);
ZzCol = zeros(storyNum, axisNum);
ZyCol = zeros(storyNum, axisNum);
AgCol = zeros(storyNum, axisNum);
MnCol = zeros(storyNum, axisNum);
lengthCol = zeros(storyNum, axisNum);
for i = 1:storyNum
    for j = 1:axisNum
        lengthCol(i, j) = storyHgt(i);
        Lb = lengthCol(i, j);
        
        if ~isempty(colSize{i, j})
            % column properties
            props = getSteelSectionProps(colSize(i, j), AISC_v14p1);            
            AgCol(i, j) = props.A;
            dbCol(i, j) = props.db;
            bfCol(i, j) = props.bf;
            twCol(i, j) = props.tw;
            tfCol(i, j) = props.tf;
            IzCol(i, j) = props.Iz; % around strong axis
            ZzCol(i, j) = props.Zz;
            ZyCol(i, j) = props.Zy; % around weak axis
            
            orientation = colOrientations(i, j);
            if contains(colSize{i, j}, 'BOX')
                isBox = true;
            else
                isBox = false;
            end
            [Mn, ~] = computeMnVnSteelProfile(Es,FyCol,props,Lb/12,c,Cb,orientation,isBox);            
            
            Pye = AgCol(i, j)*FyCol;
            if Pu(i, j)/Pye <= 0.20
                MnCol(i, j) = Mn*(1 - Pu(i, j)/Pye)*12; % kip-in
            else
                MnCol(i, j) = Mn*9/8*(1 - Pu(i, j)/Pye)*12; % kip-in
            end
            
        end
    end
end
            
% Get beam stiffness information
dbBeam = zeros(floorNum-1, bayNum);
tfBeam = zeros(floorNum-1, bayNum);
IzBeam = zeros(floorNum-1, bayNum);
ZzBeam = zeros(floorNum-1, bayNum);
ZyBeam = zeros(floorNum-1, bayNum);
MnBeam = zeros(floorNum-1, bayNum);
lengthBeam = zeros(floorNum-1, bayNum);

isBox = false; % only support wide-flange beam sections
orientation = 1; % strong always for beams

for i = 2:floorNum
    for j = 1:bayNum
        lengthBeam(i-1, j) = bayLgth(j);
        
        % Beam unbraced length
        if beamBracing
            Lb = 4.5/0.025; % [in]
        else
            Lb = lengthBeam(i-1, j);
        end
        
        % beam properties
        if ~isempty(beamSize{i-1, j})            
            props = getSteelSectionProps( beamSize(i-1, j), AISC_v14p1);                        
            dbBeam(i-1, j) = props.db;
            tfBeam(i-1, j) = props.tf;
            IzBeam(i-1, j) = props.Iz; % around strong axis
            ZzBeam(i-1, j) = props.Zz;
            ZyBeam(i-1, j) = props.Zy; % around weak axis
            
            [Mn, ~] = computeMnVnSteelProfile(Es,FyBeam,props,Lb/12,c,Cb,orientation,isBox);
            MnBeam(i-1, j) = Mn*12; % kip-in
        else
            IzBeam(i-1, j) = 0;
            ZzBeam(i-1, j) = 0;
            ZyBeam(i-1, j) = 0;
            
            MnBeam(i-1, j) = 0; % kip-in
        end                                
    end
end

%% Save variables to struct for later use
secProps.AgCol = AgCol;
secProps.ZzCol = ZzCol;
secProps.dbCol = dbCol;
secProps.bfCol = bfCol;
secProps.twCol = twCol;
secProps.tfCol = tfCol;
secProps.MnCol = MnCol;

secProps.IzBeam = IzBeam;
secProps.ZzBeam = ZzBeam;
secProps.ICol = IzCol;
secProps.ZCol = ZzCol;
secProps.ZyCol = ZyCol;
secProps.dbBeam = dbBeam;
secProps.tfBeam = tfBeam;
secProps.MnBeam = MnBeam;

end