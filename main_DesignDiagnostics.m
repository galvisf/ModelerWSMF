%%%%% POST-PROCESSING BUILDING DATABASE AND NONLINEAR MODEL GENERATOR %%%%%

% Add functions
% close all; 
clear; clc;
currFolder = pwd;
addpath([currFolder filesep 'SRC'])
addpath([currFolder filesep 'SRC' filesep '0_Databases'])
addpath([currFolder filesep 'SRC' filesep '1_FunctionsModelGeneration'])
addpath([currFolder filesep 'SRC' filesep '3_FunctionsModelAnalyses'])

sourceFolder = ['SRC' filesep '2_TemplateOpenSeesfiles'];

scale = 500; % max length for deformed shapes for mode shape plots

%% USER INPUTS: GENERAL
isPushover = false;

% Import AISC section data
load('AISC_v14p1.mat');
AISC_info = AISC_v14p1(1, :)';

% Building input data
geomFN    = 'inputs_3storyFrameOakland.xlsx';
Code_Year = 2010;
spl_ratio = 1; % ratio of welded flange thickness on splice
frameType = 'Perimeter'; % 'Space' 'Perimeter' 'Intermediate'
MRF_X     = 1; % frames parallel to X resisting WL together
frameLengthY = 3*12; % [in] tributary width for WL to the MRF_X number of frames

% Basic paths
folderInputFiles = 'INPUTS'; % Input files per building
folderPath = ['OUTPUTS' filesep 'DESIGN_DIAGNOSTICS']; % Folder to store results
mkdir(folderPath)

% Figure inputs
font = 9;
color_specs = linspecer(4);

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
isRHA           = false; % does not add a dt to recorders to avoid issues with RSA output
explicitMethod  = false; % add small mass to all DOF for explicit solution method 
modelSetUp      = 'Generic'; % Generic    EE-UQ    Sherlock

%%% Equivalent Gravity Frame Stiffness %%%
addEGF = false; 

%%% Material properties %%%
Es     = 29000;
FyCol  = 50; % A572, Gr.50, based on SAC guidelines
FyBeam = 50; % A36, based on SAC guidelines

%%% Beams and Columns %%%
backbone  = 'Elastic'; % 'Elastic' 'NIST2017', 'ASCE41'
composite = false;
slabFiberMaterials.fc      = -3;
slabFiberMaterials.caRatio = 0.35; % fraction of composite action
slabFiberMaterials.La      = 5; % girder separation [ft]

%%% Panel zones %%%
panelZoneModel = 'None'; % 'None', 'Gupta1999', NIST2017, 'Kim2015' 'Elkady2021' 'Elastic'
SH_PZ = 0.015; % strain-hardening for the panel zone

%%% Rayleigth damping %%%
zeta      = 0.02;
DampModeI = 1;
DampModeJ = 3;

% Constants
g = 386.1;
Comp_I     = 1.40; % stiffness factor for composite actions
Comp_I_GC  = 1.40; % stiffness factor for composite actions (gravity frame)
mu_poisson = 0.30; % poisson modulus

% Inputs ignored for elastic model
compBackboneFactors = 0;
n                   = 0;
fractureElement     = 0;
fracSecMaterials    = 0;        
FI_lim_type         = 0;
cvn_a0_type         = 0;
flangeProp          = 0;
cvn_col             = 0;
generation          = 0;
connType            = 0;
degradation         = 0;
c                   = 0;

%% USER INPUTS: Building code constants
% UBC (1961, 1973)
Z   = 1.00; % Seismic zone factor
wpa = 25; % Wind pressure area

% UBC 1982
bws      = 80; % basic wind speed [mph]
exposure = 'C';
I        = 1.0;
Ts       = 2.5; % period of the soil column (UBC allow assuming 2.5 if the structural period T > 2.5s)

% ASCE7
Ss = 1.559;
S1 = 0.614;
TL = 8;
Ro = 8;
Cd = 5.5;
n_modes_RSA = 20;

%% Initialize results variables
buildingDiagnostics = struct;
buildingDiagnostics.T            = [];
buildingDiagnostics.mass_part    = [];
buildingDiagnostics.CsEQd        = [];
buildingDiagnostics.CsWLd        = [];
buildingDiagnostics.CsEQ_ASCE    = [];
buildingDiagnostics.CsFirstMpEQ  = [];
buildingDiagnostics.PZratio      = []; % median of the interior pz's
buildingDiagnostics.SCWB         = [];
buildingDiagnostics.PsRatio      = [];
buildingDiagnostics.PIDReq       = [];
buildingDiagnostics.PIDReq_ASCE  = [];
buildingDiagnostics.PIDRwl       = [];
buildingDiagnostics.DC_splice    = [];
buildingDiagnostics.stress_ratio_splice = [];

%% Process each building

% Copy all necessary OpenSees helper files
copyOpenSeesHelper(sourceFolder, folderPath, isPushover)

%%%%%%% Generate elastic model per building and direction %%%%%%%%
% Model filename
modelFN = 'ElasticModel.tcl';

% Generate model    
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

%% %%%%%% Design diagnostics %%%%%%%%
secProps = getSectionProps(bldgData, AISC_v14p1, Es, FyBeam, FyCol);

%%% Get Strong column - weak beam ratio
col_to_beam_story = getSCWB_ratio(bldgData, secProps);

%%% Get stiffness ratios
Icol_ratio = getIcol_ratio(bldgData, secProps);

%%% Get column axial load ratios
[~, colMeanAxialRatio] = getColAxial_ratio(bldgData, secProps, FyCol);

%%% Get panel zone ratios
[pz_demand_strength, pz_strength_min_max] = getPZ_ratio(bldgData, secProps, FyBeam, FyCol);

%%% Perform ELFP for Wind and EQ using original code %%%
cd(folderPath)

% %% EQ %%
% Compute equivalent lateral load
if Code_Year <= 1973
    Fx_EQ = EQ_UBC1961(bldgData, Z, frameType);
    EQ_pattern = 'EQ_UBC1961';
elseif Code_Year <= 1982 
    Fx_EQ = EQ_UBC1973(bldgData, Z, frameType);
    EQ_pattern = 'EQ_UBC1973';
else
    Fx_EQ = EQ_UBC1982(bldgData, Z, Ts, I, frameType);
    EQ_pattern = 'EQ_UBC1982';
end
% Create running file
analysisFile = 'ELFP_analysis.tcl';
ELFP(analysisFile, modelFN, EQ_pattern, bldgData)                        
% Run the analysis
cmd = sprintf(['OpenSees ',analysisFile]);
tic
system(cmd);
toc
% Collect the results
[SDR_EQ, ~, dcBeamsEQ, dcColsEQ] = ...
    getELFPresults('Output', bldgData, secProps);

SDR_EQ = SDR_EQ/0.67; % per UBC1982 SDR from prescriptive lateral loads should be increased by K (~R factor)
SDR_EQ = SDR_EQ*Cd;         

% %% WL %%
% Compute lateral load
if Code_Year <= 1973
    Fx_WL = WL_UBC1961_1973(bldgData, MRF_X, frameLengthY, wpa);
    WL_pattern = 'WL_UBC1961_1973';
    WL_label = 'UBC1961';
elseif Code_Year <= 1982
    Fx_WL = WL_UBC1961_1973(bldgData, MRF_X, frameLengthY, wpa);
    WL_pattern = 'WL_UBC1961_1973';
    WL_label = 'UBC1973';
else
    Fx_WL = WL_UBC1982(bldgData, MRF_X, frameLengthY, bws, exposure, I);
    WL_pattern = 'WL_UBC1982';
    WL_label = 'UBC1982';
end

% Create running file
analysisFile = 'ELFP_analysis.tcl';
ELFP(analysisFile, modelFN, WL_pattern, bldgData)                        
% Run the analysis
cmd = sprintf(['OpenSees ',analysisFile]);
tic
system(cmd);
toc
% Collect the results
[SDR_WL, CsFirstMpWL, dcBeamsWL, dcColsWL] = ...
    getELFPresults('Output', bldgData, secProps);                                     

% %% RSA for EQ load per ASCE7 %%
Fx_ASCE7 = EQ_ASCE7(bldgData, Ss, S1, TL, Ro, I, g);
% Create running file
analysisFile = 'RSA_analysis.tcl';
RSA(analysisFile, modelFN, 'RS_ASCE7', n_modes_RSA, bldgData);
% Run the analysis
cmd = sprintf(['OpenSees ',analysisFile]);
tic
system(cmd);
toc
% Collect the results
[SDR_EQ_ASCE7, CsFirstMpEQ, dc_ratio_beams, dc_ratio_cols, ...
    dc_ratio_spl, stress_ratio_spl, splice_relative_dc] = ...
    getRSAresults('Output', bldgData, secProps, sum(Fx_ASCE7), spl_ratio, FyCol, addSplices);
SDR_EQ_ASCE7 = SDR_EQ_ASCE7*Cd; 


cd(currFolder);
%% %%% Diagnostics plot %%%
%H = figure('position', [0, 40, 800, 800]);

figure('position', [0, 50, 1000, 700])
output_dir = [folderPath, '/Output'];
numModes = 3; % Number of modes

% Plot model view
subplot(3,4,1)
plot_nodes = false;
plot_gravity = true;
dispProfile = zeros(bldgData.floorNum, 1);
title_text = {'Structural model', ['$Cs_{1Mp}$ = ',num2str(CsFirstMpEQ, '%.3f')], ...
              ['$Vs_{design}/Vs_{ASCE/SEI7}$ = ',num2str(sum(Fx_EQ)/sum(Fx_ASCE7), '%.2f')]};
plotFrame(AllNodes, AllEle, dispProfile, plot_nodes, plot_gravity, [0,0,0], title_text, font)

% Collect modal results and plot mode shapes         
[T, mass_part] = ...
    getModalResults(bldgData, AllNodes, AllEle, output_dir, numModes, scale, font, 999);            

subplot(3,4,[5,9])
title_text = '';
x_label = 'Ratio';
x_limits = [0, ceil(max(max(col_to_beam_story)))];                       
plotStair(col_to_beam_story, color_specs(1,:), title_text, font, 0, x_label, x_limits);            
plotStair(Icol_ratio, color_specs(2,:), title_text, font, 0, x_label, x_limits);            
plot([1,1], [0, length(col_to_beam_story)], '--k')
figure_size =  get(gca, 'position');
legend_text = {'SCWB','$I^{col}_{ext}$/$I^{col}_{int}$', ''}; 
h_legend = legend(legend_text, 'Location', 'northoutside', 'box', 'off','interpreter','latex');
legend_size = get(h_legend, 'position');
figure_size(4) = 0.45 + legend_size(4);
set(gca, 'position', figure_size)


subplot(3,4,[6,10])
x_label = '$PZ_{ratio}$';
x_limits = [0, ceil(max(max(pz_strength_min_max)))];                   
plotStair(pz_strength_min_max(:,1), color_specs(1,:), title_text, font, 0, x_label, x_limits);                       
plotStair(pz_strength_min_max(:,2), color_specs(2,:), title_text, font, 0, x_label, x_limits);           
plot([1,1], [0, length(col_to_beam_story)], '--k')
figure_size =  get(gca, 'position');
legend_text = {'min', 'max', ''};      
h_legend = legend(legend_text, 'Location', 'northoutside', 'box', 'off','interpreter','latex');
%             legend_size = get(h_legend, 'position');
figure_size(4) = 0.45 + legend_size(4);
set(gca, 'position', figure_size)

subplot(3,4,[7,11])
x_label = {'mean($P_g/A_g$)'};
x_limits = [0, ceil(max(max(colMeanAxialRatio))*10)/10];
plotStair(colMeanAxialRatio, color_specs(1,:), title_text, font, 0, x_label, x_limits);
figure_size =  get(gca, 'position');
figure_size(4) = 0.45 + legend_size(4);
set(gca, 'position', figure_size)

subplot(3,4,[8,12])
title_text = '';            
x_label = ['Peak Story Drift ($C_d=',num2str(Cd),'$) [\%]'];
x_limits = [0, ceil(max(max(SDR_EQ))*100)];
plotStair(SDR_EQ*100, color_specs(1,:), title_text, font, 0, x_label, x_limits);
plotStair(SDR_EQ_ASCE7*100, color_specs(2,:), title_text, font, 0, x_label, x_limits);
plotStair(SDR_WL*100, color_specs(3,:), title_text, font, 0, x_label, x_limits);            
figure_size =  get(gca, 'position');
legend_text = {['EQ (',EQ_pattern(4:end),')'], 'EQ (ASCE7)', ['WL (',WL_label,')']};
h_legend = legend(legend_text, 'Location', 'northoutside', 'box', 'off','interpreter','latex');
%             legend_size = get(h_legend, 'position');
figure_size(4) = 0.45 + legend_size(4);
set(gca, 'position', figure_size)

% Save figure
if ~composite && ~addEGF
    figFileName = [folderPath, '/_Diagnostics_noComposite_noEGF'];
elseif ~composite && addEGF
    figFileName = [folderPath, '/_Diagnostics_noComposite'];            
else
    figFileName = [folderPath, '/_Diagnostics'];
end

%             savefig(H,figFileName,'compact')
%             saveas(H, [figFileName, '.svg'])
% exportgraphics(gcf,[figFileName, '.png'],'Resolution',300)
set(gcf,'PaperOrientation','landscape');
print(figFileName,'-dpdf','-bestfit')                   
% close all

%% Store in cell for comparisons across buildings
weightFloor = (sum(bldgData.wgtOnBeam,2) + sum(bldgData.wgtOnCol,2) + bldgData.wgtOnEGF);
totalWeigth = sum(weightFloor);

buildingDiagnostics.T            = T;
buildingDiagnostics.mass_part    = mass_part;
buildingDiagnostics.CsEQd        = sum(Fx_EQ)/totalWeigth;
buildingDiagnostics.CsWLd        = sum(Fx_WL)/totalWeigth;
buildingDiagnostics.CsEQ_ASCE    = sum(Fx_ASCE7)/totalWeigth;
buildingDiagnostics.CsFirstMpEQ  = CsFirstMpEQ;
buildingDiagnostics.PZratio      = median(pz_strength_min_max(:,2));
buildingDiagnostics.SCWB         = median(col_to_beam_story);
buildingDiagnostics.PsRatio      = median(colMeanAxialRatio);
buildingDiagnostics.PIDReq       = max(SDR_EQ);
buildingDiagnostics.PIDReq_ASCE  = max(SDR_EQ_ASCE7);
buildingDiagnostics.PIDRwl       = max(SDR_WL);
buildingDiagnostics.DC_splice    = max(max(dc_ratio_spl));
buildingDiagnostics.stress_ratio_splice = max(max(stress_ratio_spl));


