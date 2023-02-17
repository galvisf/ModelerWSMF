%%%%% POST-PROCESSING BUILDING DATABASE AND NONLINEAR MODEL GENERATOR %%%%%

% Add functions
close all; clear; clc;
currFolder = pwd;
addpath([currFolder filesep 'SRC'])
addpath([currFolder filesep 'SRC' filesep '0_Databases'])
addpath([currFolder filesep 'SRC' filesep '1_FunctionsModelGeneration'])
addpath([currFolder filesep 'SRC' filesep '3_FunctionsModelAnalyses'])

sourceFolder = ['SRC' filesep '2_TemplateOpenSeesfiles'];

%% USER INPUTS: GENERAL
isPushover = true;
plot_pushover = true;

% Import AISC section data
load('AISC_v14p1.mat');
AISC_info = AISC_v14p1(1, :)';

% Building input data
geomFN    = 'inputs_8storyFrameOakland.xlsx';
Code_Year = 1986;
spl_ratio = 0.3; % ratio of welded flange thickness
frameType = 'Perimeter'; % 'Space' 'Perimeter' 'Intermediate'
MRF_X     = 1; % frames parallel to X resisting WL together
frameLengthY = 3*12; % [in] tributary width for WL to the MRF_X number of frames

% Basic paths
folderInputFiles = 'INPUTS'; % Input files per building
folderPath = ['OUTPUTS' filesep 'PUSHOVER']; % Folder to store results
mkdir(folderPath)

% Figure inputs
font = 9;
color_specs = linspecer(4);

%% USER INPUTS: Pushover parameters 
roofDrift = 0.02; % ENTER IN ABSOLUTE VALUE
signPush = 1;

% Lateral load pattern
LatLoadPattern = 'ASCE_ELF'; % 'ASCE_ELF' 'Manual'
% ASCE7 ELF
Ss = 1.22;
S1 = 0.6934;
TL = 8;
Cv = 5.5;
Ro = 8; 
% Manual
Fx_norm = ones(35, 1)*100;

%% USER INPUTS: Modeling considerations
%%% General %%%
TransformationX = 2; %1: linear; 2:pdelta; 3:corotational
fixedBase       = true; % false = pin
rigidFloor      = false;
addSplices      = true;
dampingType     = 'Rayleigh_k0_beams_cols_springs'; % Rayleigh_k0_beams_cols_springs  Rayleigh_k0_all
outdir          = 'Output';
addBasicRecorders    = true;
addDetailedRecorders = false;
isRHA           = true; % add dt for recorders (to avoid large output files when analysis reduces dt)
explicitMethod  = false; % add small mass to all DOF for explicit solution method 
modelSetUp      = 'Generic'; % Generic    EE-UQ    Sherlock

%%% Equivalent Gravity Frame %%%
addEGF = false; 

%%% Material properties %%%
Es     = 29000;
FyCol  = 44; % A572, Gr.50, based on SAC guidelines
FyBeam = 44; % A36, based on SAC guidelines

%%% Beams and Columns %%%
fractureElement = false;
generation      = 'Pre_Northridge'; %'Pre_Northridge' 'Post_Northridge'
backbone        = 'ASCE41'; % 'Elastic' 'NIST2017', 'ASCE41'
connType        = 'non_RBS'; % 'non_RBS', 'RBS'
degradation     = false;
composite       = true;
switchOrientation = false; % True: space frames switch the columns on weak-strong orientation
                           % False: assume columns always in strong orientation, even for space frames
%%% Panel zones %%%
panelZoneModel = 'Elkady2021'; % 'None', 'Gupta1999', NIST2017, 'Kim2015' 'Elkady2021' 'Elastic'
SH_PZ = 0.015; % strain-hardening for the panel zone

%%% Connection information %%%
cvn_a0_type = 'Constant'; % Constant Uniform  byFloor  byConnection
cvn = 12; % 16 12 8
a0  = 0.1; % 0.1 0.2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch cvn_a0_type
    case 'Constant'
        flangeProp.cvn      = cvn; % Fracture thougness of all beam flanges in the building
        flangeProp.a0_tf    = a0;         
    otherwise
        flangeProp.cvn      = cvn; % median
        flangeProp.betaCVN  = 0.3; % dispersion
        
        flangeProp.a0_tf    = a0; % median
        flangeProp.beta_a0  = 0.3; % dispersion
        flangeProp.a0_limit = 0.5; % upper bound
end
cvn_col   = flangeProp.cvn*1.5; % Fracture thougness of all column splices in the building

%%% Rayleigth damping %%%
zeta      = 0.015;
DampModeI = 1;
DampModeJ = 3;

% Constants
g = 386.1;
n = 10; % Stiffness multiplier for elements with springs at both ends
Comp_I     = 1.40; % stiffness factor for composite actions
Comp_I_GC  = 1.40; % stiffness factor for composite actions (gravity frame)
mu_poisson = 0.30; % poisson modulus
c          = 1.00; % Exponent for degradation in plastic hinges

compBackboneFactors.MpP_Mp = 1.35;
compBackboneFactors.MpN_Mp = 1.25;
compBackboneFactors.Mc_MpP = 1.30;
compBackboneFactors.Mc_MpN = 1.05;
compBackboneFactors.Mr_MpP = 0.30;
compBackboneFactors.Mr_MpN = 0.20;
compBackboneFactors.D_P    = 1.15;
compBackboneFactors.D_N    = 1.00;
compBackboneFactors.theta_p_P_comp  = 1.80;
compBackboneFactors.theta_p_N_comp  = 0.95;
compBackboneFactors.theta_pc_P_comp = 1.35;
compBackboneFactors.theta_pc_N_comp = 0.95;

slabFiberMaterials.fc     = -3;
slabFiberMaterials.epsc0  = -0.002;
slabFiberMaterials.epsU   = -0.01;
slabFiberMaterials.fy     = 60;
slabFiberMaterials.degrad = -0.10;
slabFiberMaterials.caRatio = 0.35; % fraction of composite action
slabFiberMaterials.La      = 5; % girder separation [ft]

fracSecMaterials.FyFiber = 150;
fracSecMaterials.EsFiber = 29000;
if strcmp(generation, 'Pre_Northridge')
    fracSecMaterials.betaC_B = 0.5;
    fracSecMaterials.betaC_T = 0.8;
else
    fracSecMaterials.betaC_B = 0.5;
    fracSecMaterials.betaC_T = 0.5;
end
fracSecMaterials.sigMin = 0.40;
fracSecMaterials.FuBolt = 68;
fracSecMaterials.FyTab  = 47;
fracSecMaterials.FuTab  = 70;

FI_lim_type = 'Random'; % Constant  Random
if strcmp(FI_lim_type, 'Constant')
    flangeProp.FI_lim = 1.0;
else
    flangeProp.FI = 1.0;
    if strcmp(generation, 'Pre_Northridge')        
        flangeProp.betaFI_bot = 0.24;
        flangeProp.betaFI_top = 0.22;
    else
        flangeProp.betaFI_bot = 0.37;
        flangeProp.betaFI_top = 0.16;
    end
end

%% Create model

% Copy all necessary OpenSees helper files
copyOpenSeesHelper(sourceFolder, folderPath, isPushover)

%%%%%%%% identify input.xls %%%%%%%%
modelFN = 'InelasticModel_ph.tcl';

%%%%%%% Generate elastic model per building and direction %%%%%%%%
[AllNodes, AllEle, bldgData] = write_FrameModel(folderPath, [folderInputFiles filesep geomFN], modelFN, ...
    AISC_v14p1, Es, mu_poisson, FyBeam, FyCol, ...
    TransformationX, backbone, SH_PZ, panelZoneModel, ...
    composite, Comp_I, Comp_I_GC, ...
    dampingType, DampModeI, DampModeJ, zeta, ...
    fixedBase, addEGF, addSplices, rigidFloor, g, ...
    outdir, addBasicRecorders, addDetailedRecorders, isRHA, explicitMethod, modelSetUp, ...
    compBackboneFactors, n, ...
    fractureElement, slabFiberMaterials, fracSecMaterials, ...                
    FI_lim_type, cvn_a0_type, flangeProp, cvn_col, ...
    generation, connType, degradation, c); 

% modelFN = 'InelasticModel.tcl';

%% %%%%%% Run pushover %%%%%%%%
cd(folderPath)

% Compute lateral load pattern
if strcmp(LatLoadPattern, 'ASCE_ELF')
    Fx_EQ = EQ_ASCE7(bldgData, Ss, S1, TL, Cv, Ro, g);
    EQ_pattern = 'EQ_ASCE7';
else
    % Save lateral load patter file 
    fid_r = fopen('EQ_Mode1.tcl', 'wt');
    fprintf(fid_r, 'set iFi {\n');
    for i = 1:length(Fx_norm)
        fprintf(fid_r, '\t%f\n', Fx_norm(i));
    end
    fprintf(fid_r,'}');
    fclose(fid_r);
    EQ_pattern = 'EQ_Mode1';
end

% Create running file
analysisFile = 'Pushover_analysis.tcl';
pushoverAnalysis(analysisFile, modelFN, EQ_pattern, roofDrift, signPush, bldgData)
% Run the analysis
cmd = sprintf(['OpenSees ',analysisFile]);
tic
system(cmd);
toc

%% Collect and plot results
H = figure;%('position', [0, 40, 800, 400]);
[baseShearCoeff, RoofDisp] = getPushoverResults(outdir, bldgData, plot_pushover, EQ_pattern);
cd(currFolder);

%% Save figure
if ~composite && ~addEGF
    figFileName = [folderPath, '/_Pushover_noComposite_noEGF_', EQ_pattern];
elseif ~composite && addEGD
    figFileName = [folderPath, '/_Pushover_noComposite_',EQ_pattern];            
else
    figFileName = [folderPath, '/_Pushover_',EQ_pattern];
end
%             savefig(H,figFileName,'compact')
%             saveas(H, [figFileName, '.svg'])
% exportgraphics(gcf,[figFileName, '.png'],'Resolution',300)
set(gcf,'PaperOrientation','landscape');
print(figFileName,'-dpdf','-bestfit')  
