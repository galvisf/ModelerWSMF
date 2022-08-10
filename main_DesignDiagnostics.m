%%%%% POST-PROCESSING BUILDING DATABASE AND NONLINEAR MODEL GENERATOR %%%%%

close all; clear; clc;
addpath('0_functions_database_processing')
addpath('0_functions_model_generation')
currFolder = pwd;

font = 9;
color_specs = linspecer(4);
isPushover = false;

%% GENERAL INPUTS
% Import AISC section data
load('AISC_v14p1.mat'); % update to place inside 0_functions folder
AISC_info = AISC_v14p1(1, :)';

% Input files per building
addpath('1_InputFilesPerFrame');

% Import WSMF database %%%%%%%%
buildingInventory = readtable('_AutocompletedDatabase.csv');
nBuildings = height(buildingInventory);

% OpenSees functions folder
sourceFolder = '2_TemplateOpenSeesfiles';

% Folder to store results
modelFolderPath = '3_DesignDiagnostics';

%% Modeling considerations
%%% General %%%
TransformationX = 2; %1: linear; 2:pdelta; 3:corotational
rigidFloor      = false;
addSplices      = false;
dampingType     = 'Rayleigh_k0_beams_cols_springs'; % Rayleigh_k0_beams_cols_springs  Rayleigh_k0_all
outdir          = 'Output';
addBasicRecorders    = true;
addDetailedRecorders = true;
isRHA           = false; % does not add a dt to recorders to avoid issues with RSA output
explicitMethod  = false; % add small mass to all DOF for explicit solution method 
modelSetUp      = 'Generic'; % Generic    EE-UQ    Sherlock

%%% Equivalent Gravity Frame Stiffness %%%
addEGF = true; 

%%% Material properties %%%
Es     = 29000;
FyCol  = 47.3; % A572, Gr.50, based on SAC guidelines
FyBeam = 47.3; % A36, based on SAC guidelines

%%% Beams and Columns %%%
backbone  = 'Elastic'; % 'Elastic' 'NIST2017', 'ASCE41'
composite = true;
slabFiberMaterials.fc      = -3;
slabFiberMaterials.caRatio = 0.35; % fraction of composite action
slabFiberMaterials.La      = 5; % girder separation [ft]

%%% Panel zones %%%
panelZoneModel = 'Elastic'; % 'None', 'Gupta1999', NIST2017, 'Kim2015' 'Elkady2021' 'Elastic'
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

%% Building code constants
% UBC (1961, 1973)
Z   = 1.00; % Seismic zone factor
wpa = 25; % Wind pressure area

% UBC 1982
bws      = 80; % basic wind speed [mph]
exposure = 'C';
I        = 1.0;
Ts       = 2.5; % period of the soil column (UBC allow assuming 2.5 if the structural period T > 2.5s)

% ASCE7
Ss = 1.5;
S1 = 0.6;
TL = 12;
Ro = 8;
Cd = 5.5;
n_modes_RSA = 20;

%% Initialize results variables
buildingDiagnostics = struct;
buildingDiagnostics.Tx            = [];
buildingDiagnostics.mass_partX    = [];
buildingDiagnostics.CsEQdX        = [];
buildingDiagnostics.CsWLdX        = [];
buildingDiagnostics.CsEQ_ASCEX   = [];
buildingDiagnostics.CsFirstMpEQx  = [];
buildingDiagnostics.PZratioX      = []; % median of the interior pz's
buildingDiagnostics.SCWBx         = [];
buildingDiagnostics.PsRatioX      = [];
buildingDiagnostics.PIDReqX       = [];
buildingDiagnostics.PIDReq_ASCEX  = [];
buildingDiagnostics.PIDRwlX       = [];
buildingDiagnostics.DC_spliceX    = [];
buildingDiagnostics.stress_ratio_spliceX = [];

buildingDiagnostics.Ty            = [];
buildingDiagnostics.mass_partY    = [];
buildingDiagnostics.CsEQdY        = [];
buildingDiagnostics.CsWLdY        = [];
buildingDiagnostics.CsEQ_ASCEY   = [];
buildingDiagnostics.CsFirstMpEQy  = [];
buildingDiagnostics.PZratioY      = [];
buildingDiagnostics.SCWBy         = [];
buildingDiagnostics.PsRatioY      = [];
buildingDiagnostics.PIDReqY       = [];
buildingDiagnostics.PIDReq_ASCEY  = [];
buildingDiagnostics.PIDRwlY       = [];
buildingDiagnostics.DC_spliceY    = [];
buildingDiagnostics.stress_ratio_spliceY = [];
OBJECTID                          = [];

% load('buildingDiagnostics.mat')

%% Process each building

for bldg_i = [1:63, 65:nBuildings] % 64 does not run, need a fix on the podium interpretation
    
    if ~isempty(buildingInventory.Column_Location_Exterior{bldg_i}) && ...
            ~isempty(buildingInventory.Column_Location_Interior{bldg_i}) && ...
            ~isempty(buildingInventory.Beam_Location{bldg_i})
        
        disp('')
        disp(['---- Calculating building ', num2str(bldg_i), ' ----'])
        OBJECTID = [OBJECTID; buildingInventory.OBJECTID(bldg_i)];
        spl_ratio = buildingInventory.Column_Splice_Flange_penetration_ratio(bldg_i);
        
        % Create folder to store model
        bldgName = ['ID',num2str(buildingInventory.OBJECTID(bldg_i))];
        folderPath = [modelFolderPath,'/',bldgName];
        mkdir(folderPath);
        
        % Copy all necessary OpenSees helper files
        copyOpenSeesHelper(sourceFolder, folderPath, isPushover)
        
        for frameDir = ['X', 'Y']
            %%%%%%%% identify input.xls %%%%%%%%   
            modelFN = ['ElasticModel_',frameDir,'.tcl'];
            geomFN = ['inputs_', bldgName,'_dir',frameDir,'.xlsx'];
            
            %%%%%%% Generate elastic model per building and direction %%%%%%%%
            [AllNodes, AllEle, bldgData] = write_FrameModel(folderPath, geomFN, modelFN, ...
                AISC_v14p1, Es, mu_poisson, FyBeam, FyCol, ...
                TransformationX, backbone, SH_PZ, panelZoneModel, ...
                composite, Comp_I, Comp_I_GC, ...
                dampingType, DampModeI, DampModeJ, zeta, ...
                addEGF, addSplices, rigidFloor, g, ...
                outdir, addBasicRecorders, addDetailedRecorders, isRHA, explicitMethod, modelSetUp, ...
                compBackboneFactors, n, ...
                fractureElement, slabFiberMaterials, fracSecMaterials, ...                
                FI_lim_type, cvn_a0_type, flangeProp, cvn_col, ...
                generation, connType, degradation, c);            
            
            %%%%%%%% Design diagnostics %%%%%%%%
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
            frameType = buildingInventory.Lateral_System_Type{bldg_i};
            % Compute equivalent lateral load
            if buildingInventory.Code_Year(bldg_i) <= 1973
                Fx_EQ = EQ_UBC1961(bldgData, Z, frameType);
                EQ_pattern = 'EQ_UBC1961';
            elseif buildingInventory.Code_Year(bldg_i) <= 1982
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
            MRF_X = eval(buildingInventory.Moment_Resisting_Frames_X{bldg_i}); % frames parallel to X
            MRF_Y = eval(buildingInventory.Moment_Resisting_Frames_Y{bldg_i}); % frames parallel to Y
            frameLengthX = eval(buildingInventory.frameLengthX{bldg_i});
            frameLengthY = eval(buildingInventory.frameLengthY{bldg_i});
            % Compute lateral load
            if frameDir == 'X'
                if buildingInventory.Code_Year(bldg_i) <= 1973
                    Fx_WL = WL_UBC1961_1973(bldgData, MRF_X, frameLengthY, wpa);
                    WL_pattern = 'WL_UBC1961_1973';
                    WL_label = 'UBC1961';
                elseif buildingInventory.Code_Year(bldg_i) <= 1982
                    Fx_WL = WL_UBC1961_1973(bldgData, MRF_X, frameLengthY, wpa);
                    WL_pattern = 'WL_UBC1961_1973';
                    WL_label = 'UBC1973';
                else
                    Fx_WL = WL_UBC1982(bldgData, MRF_X, frameLengthY, bws, exposure, I);
                    WL_pattern = 'WL_UBC1982';
                    WL_label = 'UBC1982';
                end
            else
                if buildingInventory.Code_Year(bldg_i) <= 1973
                    Fx_WL = WL_UBC1961_1973(bldgData, MRF_Y, frameLengthX, wpa);
                    WL_pattern = 'WL_UBC1961_1973';
                    WL_label = 'UBC1961';
                elseif buildingInventory.Code_Year(bldg_i) <= 1982
                    Fx_WL = WL_UBC1961_1973(bldgData, MRF_Y, frameLengthX, wpa);
                    WL_pattern = 'WL_UBC1961_1973';
                    WL_label = 'UBC1973';
                else
                    Fx_WL = WL_UBC1982(bldgData, MRF_Y, frameLengthX, bws, exposure, I);
                    WL_pattern = 'WL_UBC1982';
                    WL_label = 'UBC1982';
                end
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
                getRSAresults('Output', bldgData, secProps, sum(Fx_ASCE7), spl_ratio, FyCol);
            SDR_EQ_ASCE7 = SDR_EQ_ASCE7*Cd; 
            
            
            cd(currFolder);
            %%% Diagnostics plot %%%
            H = figure('position', [0, 40, 800, 800]);

            output_dir = [folderPath, '/Output'];
            numModes = 3; % Number of modes
            scale = 500; % max length for deformed shapes
            
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
            x_limits = [0, 4]; %ceil(max(max(SDR_EQ))*100)
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
                figFileName = [folderPath, '/_Diagnostics_', bldgName,'_dir',frameDir,'_noComposite_noEGF'];
            elseif ~composite && addEGD
                figFileName = [folderPath, '/_Diagnostics_', bldgName,'_dir',frameDir,'_noComposite'];            
            else
                figFileName = [folderPath, '/_Diagnostics_', bldgName,'_dir',frameDir];
            end
%             savefig(H,figFileName,'compact')
%             saveas(H, [figFileName, '.svg'])
            exportgraphics(gcf,[figFileName, '.png'],'Resolution',300)
            set(gcf,'PaperOrientation','landscape');
            print(figFileName,'-dpdf','-bestfit')                   
            close all
            
            % Store in cell for comparisons across buildings
            weightFloor = (sum(bldgData.wgtOnBeam,2) + sum(bldgData.wgtOnCol,2) + bldgData.wgtOnEGF);
            totalWeigth = sum(weightFloor);
            if frameDir == 'X'
                buildingDiagnostics.Tx            = [buildingDiagnostics.Tx; T];
                buildingDiagnostics.mass_partX    = [buildingDiagnostics.mass_partX; mass_part];
                buildingDiagnostics.CsEQdX        = [buildingDiagnostics.CsEQdX; sum(Fx_EQ)/totalWeigth];
                buildingDiagnostics.CsWLdX        = [buildingDiagnostics.CsWLdX; sum(Fx_WL)/totalWeigth];
                buildingDiagnostics.CsEQ_ASCEX   = [buildingDiagnostics.CsEQ_ASCEX; sum(Fx_ASCE7)/totalWeigth];
                buildingDiagnostics.CsFirstMpEQx  = [buildingDiagnostics.CsFirstMpEQx; CsFirstMpEQ];
                buildingDiagnostics.PZratioX      = [buildingDiagnostics.PZratioX; median(pz_strength_min_max(:,2))];
                buildingDiagnostics.SCWBx         = [buildingDiagnostics.SCWBx; median(col_to_beam_story)];
                buildingDiagnostics.PsRatioX      = [buildingDiagnostics.PsRatioX; median(colMeanAxialRatio)];
                buildingDiagnostics.PIDReqX       = [buildingDiagnostics.PIDReqX; max(SDR_EQ)];
                buildingDiagnostics.PIDReq_ASCEX  = [buildingDiagnostics.PIDReq_ASCEX; max(SDR_EQ_ASCE7)];
                buildingDiagnostics.PIDRwlX       = [buildingDiagnostics.PIDRwlX; max(SDR_WL)];
                buildingDiagnostics.DC_spliceX    = [buildingDiagnostics.DC_spliceX; max(max(dc_ratio_spl))];
                buildingDiagnostics.stress_ratio_spliceX    = [buildingDiagnostics.stress_ratio_spliceX; max(max(stress_ratio_spl))];
            else
                buildingDiagnostics.Ty            = [buildingDiagnostics.Ty; T];
                buildingDiagnostics.mass_partY    = [buildingDiagnostics.mass_partY; mass_part];
                buildingDiagnostics.CsEQdY        = [buildingDiagnostics.CsEQdY; sum(Fx_EQ)/totalWeigth];
                buildingDiagnostics.CsWLdY        = [buildingDiagnostics.CsWLdY; sum(Fx_WL)/totalWeigth];
                buildingDiagnostics.CsEQ_ASCEY   = [buildingDiagnostics.CsEQ_ASCEY; sum(Fx_ASCE7)/totalWeigth];
                buildingDiagnostics.CsFirstMpEQy  = [buildingDiagnostics.CsFirstMpEQy; CsFirstMpEQ];
                buildingDiagnostics.PZratioY      = [buildingDiagnostics.PZratioY; median(pz_strength_min_max(:,2))];
                buildingDiagnostics.SCWBy         = [buildingDiagnostics.SCWBy; median(col_to_beam_story)];
                buildingDiagnostics.PsRatioY      = [buildingDiagnostics.PsRatioY; median(colMeanAxialRatio)];
                buildingDiagnostics.PIDReqY       = [buildingDiagnostics.PIDReqY; max(SDR_EQ)];
                buildingDiagnostics.PIDReq_ASCEY  = [buildingDiagnostics.PIDReq_ASCEY; max(SDR_EQ_ASCE7)];
                buildingDiagnostics.PIDRwlY       = [buildingDiagnostics.PIDRwlY; max(SDR_WL)];
                buildingDiagnostics.DC_spliceY    = [buildingDiagnostics.DC_spliceY; max(max(dc_ratio_spl))];
                buildingDiagnostics.stress_ratio_spliceY    = [buildingDiagnostics.stress_ratio_spliceY; max(max(stress_ratio_spl))];
            end
        end
    end
end

%% Convert to table and save as csv
% load('buildingDiagnostics_noEGF_composite');

buildingDiagnosticsTable = table;

buildingDiagnosticsTable.OBJECTID = OBJECTID;

fieldList = fields(buildingDiagnostics);
for i = 1:length(fieldList)
    try
        buildingDiagnosticsTable.(fieldList{i}) = buildingDiagnostics.(fieldList{i});
    catch        
        buildingDiagnosticsTable.(fieldList{i}) = buildingDiagnostics.(fieldList{i})';
    end
end

writetable(buildingDiagnosticsTable, [modelFolderPath,'\outputs_DesignDiagnostics.csv']);