%%%%% POST-PROCESSING BUILDING DATABASE AND NONLINEAR MODEL GENERATOR %%%%%

close all;
clear; clc;

addpath(['SRC' filesep '0_Databases'])
addpath(['SRC' filesep '1_FunctionsModelGeneration'])
addpath(['SRC' filesep '2_TemplateOpenSeesfiles'])
folderInputFiles = 'INPUTS';
currFolder = pwd;

sourceFolder = ['SRC' filesep '2_TemplateOpenSeesfiles'];

%% USER INPUTS: GENERAL
% Import AISC section data
load('AISC_v14p1.mat'); % update to place inside 0_functions folder
AISC_info = AISC_v14p1(1, :)';

% Number of model clones per building
n_models = 1;

% Building input file
modelName = 'inputs_8storyFrameOakland';
folderPath = ['OUTPUTS' filesep 'NLRHA'];
mkdir(folderPath)
geomFN = 'inputs_8storyFrameOakland.xlsx';
isPushover = false;

%% USER INPUTS: Modeling considerations
%%% General %%%
TransformationX = 2; %1: linear; 2:pdelta; 3:corotational
fixedBase       = true; % false = pin
rigidFloor      = false;
addSplices      = false;
dampingType     = 'Rayleigh_k0_beams_cols_springs'; % Rayleigh_k0_beams_cols_springs  Rayleigh_k0_all
outdir          = 'Output';
addBasicRecorders    = true;
addDetailedRecorders = false;
isRHA           = true; % add dt for recorders (to avoid large output files when analysis reduces dt)
explicitMethod  = false; % add small mass to all DOF for explicit solution method 
modelSetUp      = 'Sherlock'; % Generic    EE-UQ    Sherlock

%%% Equivalent Gravity Frame %%%
addEGF = true; 

%%% Material properties %%%
Es     = 29000;
FyCol  = 50*1.1; % Column steel yield stress [amplified by Ry]
FyBeam = 50*1.1; % Beam steel yield stress [amplified by Ry]

%%% Beams and Columns %%%
fractureElement = false;
generation      = 'Post_Northridge'; %'Pre_Northridge' 'Post_Northridge'
backbone        = 'NIST2017'; % 'Elastic' 'NIST2017', 'ASCE41'
connType        = 'RBS'; % 'non_RBS', 'RBS'
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
zeta      = 0.02;
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

%% Generate NL-model

% Copy all necessary OpenSees helper files
copyOpenSeesHelper(sourceFolder, folderPath, isPushover)

for model_i = 1:n_models
    % Model filename
    modelFN = [modelName,'_',num2str(model_i),'.tcl'];
    
    % Generate model
    [AllNodes, AllEle, bldgData] = write_FrameModel(folderPath, [folderInputFiles,'\',geomFN], modelFN, ...
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

end

%% Plot frame
disp = zeros(bldgData.floorNum,1);
plot_nodes = false;
plot_gravity = true;
color_lines = 'k';
title_text = modelName;
font = 12;
figure
plotFrame(AllNodes, AllEle, disp, plot_nodes, plot_gravity, color_lines, title_text, font)
