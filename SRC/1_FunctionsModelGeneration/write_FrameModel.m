%% This function creates an OpenSees .tcl model of a 2D frame
%
% INPUTS
%   folderPath          = 
%   geomFN              = 
%   AISC_v14p1          = Matlab database with the geometric properties of
%                         steel sections
%   n                   = Stiffness multiplier for elements with springs at
%                         both ends (=10)
%   Es                  = Steel elastic modulus [ksi]
%   mu_poisson          = Steel poisson ratio (=0.30)
%   FyBeam              = Yielding strengths of the beam steel [ksi]
%   FyCol               = Yielding strengths of the column steel [ksi]
%   c                   = Exponent for degradation in plastic hinges
%   TransformationX     = Geometric nonlinearity formulation
%                         1: linear
%                         2: pdelta
%                         3: corotational
%   SH_PZ               = strain-hardening for the panel zone
%   panelZoneModel      = 'None', 'Gupta1999', NIST2017, 'Kim2015', 'Elkady2021', 'Elastic'
%   composite           = true / false (consider composite section effects)
%   Comp_I              = stiffness factor for composite actions (=1.40)
%   Comp_I_GC           = stiffness factor for composite actions (gravity
%                         frame) (=1.40)
%   compBackboneFactors = matlab struct with the following fields that
%                         modify the bare section backbone
%                         compBackboneFactors.MpP_Mp = 1.35;
%                         compBackboneFactors.MpN_Mp = 1.25;
%                         compBackboneFactors.Mc_MpP = 1.30;
%                         compBackboneFactors.Mc_MpN = 1.05;
%                         compBackboneFactors.Mr_MpP = 0.30;
%                         compBackboneFactors.Mr_MpN = 0.20;
%                         compBackboneFactors.D_P    = 1.15;
%                         compBackboneFactors.D_N    = 1.00;
%                         compBackboneFactors.theta_p_P_comp  = 1.80;
%                         compBackboneFactors.theta_p_N_comp  = 0.95;
%                         compBackboneFactors.theta_pc_P_comp = 1.35;
%                         compBackboneFactors.theta_pc_N_comp = 0.95;
%   fractureElement     = true / false (add fracture fiberSections)
%   slabFiberMaterials  = matlab struct with the following fields that
%                         define the slab fibers within the fracture fiber section
%                         slabFiberMaterials.fc     = -3;
%                         slabFiberMaterials.epsc0  = -0.002;
%                         slabFiberMaterials.epsU   = -0.01;
%                         slabFiberMaterials.fy     = 78;
%                         slabFiberMaterials.degrad = -0.10;
%   fracSecMaterials    = matlab struct with the following fields that
%                         define the properties for the fracture fiber
%                         section
%                         fracSecMaterials.FyFiber = 150;
%                         fracSecMaterials.EsFiber = 29000;
%                         fracSecMaterials.betaC_B = 0.5;
%                         fracSecMaterials.betaC_T = 0.8 or 0.50;
%                         fracSecMaterials.sigMin = 0.40;
%                         fracSecMaterials.FuBolt = 68;
%                         fracSecMaterials.FyTab = 47;
%                         fracSecMaterials.FuTab = 70;
%   dampingType         = 'Rayleigh_k0_beams_cols_springs'
%                         'Rayleigh_k0_beams_cols_springs'
%                         'Rayleigh_k0_all'
%   DampModeI           = i-Mode for Raylegth damping definition
%   DampModeJ           = j-Mode for Raylegth damping definition
%   zeta                = constant damping ratio at the i-mode and j-mode
%   fixedBase           = true/false (boundary condition of base columns)
%   FI_lim_type         = 'Constant' (unique limit of FI to predict fracture)
%                         'Random' (sample the limit of FI from appropiate distributions)
%   cvn_a0_type         = 'Constant' constant given value
%                         'Uniform': random unique value for the entire
%                                    building
%                         'byFloor': random value resampled for each floor
%                         'byConnection': random value resampled for each
%                                         connection
%   flangeProp          = matlab struct with the following fields depending
%                         on the assumption of CVN and a0 distribution
%                         cvn_a0_type == 'Uniform'
%                             flangeProp.cvn      = 8; % Fracture thougness of all beam flanges in the building
%                             flangeProp.a0_tf    = 0.10;         
%                         cvn_a0_type == (any other)
%                             flangeProp.cvn      = 8; % median
%                             flangeProp.betaCVN  = 0.3; % dispersion
%                             flangeProp.a0_tf    = 0.10; % median
%                             flangeProp.beta_a0  = 0.3; % dispersion
%                             flangeProp.a0_limit = 0.5; % upper bound
%
%                         FI_lim_type == 'Constant'
%                             flangeProp.FI_lim = 1.0;
%                         FI_lim_type == 'Random'
%                             flangeProp.FI = 1.0;
%                            generation == 'Pre_Northridge'        
%                                  flangeProp.betaFI_bot = 0.24;
%                                  flangeProp.betaFI_top = 0.22;
%                            generation == 'Post_Northridge' 
%                                  flangeProp.betaFI_bot = 0.37;
%                                  flangeProp.betaFI_top = 0.16;
%   cvn_col             = CVN for the column splices (=1.5*CVN_beamWelds)
%   g                   = gravity constant (=386 in/s2)
%   addEGF              = true/false (add the stiffness of the gravity system or a leaning column)
%   addSplices          = true/false (add explicetely the column splices)
%   rigidFloor          = true/false (add constraints to represent rigid diaphragm action)
%   generation          = 'Pre-Northridge' 
%                         'Post-northridge'
%   connType            = 'non_RBS'
%                         'RBS'
%   backbone            = 'Elastic'
%                         'NIST2017'
%                         'ASCE41'
%   degradation         = true/false (consider the monotonic backbone and cyclic degradation rules)
%   outdir              = path to the folder to save recorder results
%   addBasicRecorders   = true/false (add minimum recorders to plot animation of the frame)
%   addDetailedRecorders= true/false (add all other recorders of any possible output)
%   isRHA               = true/false (add dt for recorders)
%   explicitMethod      = true/false (add small mass to all DOF for explicit solution method)
%   modelSetUp          = 'Sherlock'
%                         'Generic'
%                         'EE-UQ' 
%
% By: Francisco A. Galvis
% Portions of the code were adapted from originals of Prof. Ahmed Elkady (FM2D code)
% John A. Blume Earthquake engineering center
% Stanford University
%
function [AllNodes, AllEle, bldgData] = write_FrameModel(folderPath, geomFN, modelFN, ...
                AISC_v14p1, Es, mu_poisson, FyBeam, FyCol, ...
                TransformationX, backbone, SH_PZ, panelZoneModel, ...
                composite, Comp_I, Comp_I_GC, ...
                dampingType, DampModeI, DampModeJ, zeta, ...
                fixedBase, addEGF, addSplices, rigidFloor, g, ...
                outdir, addBasicRecorders, addDetailedRecorders, isRHA, explicitMethod, modelSetUp, ...
                compBackboneFactors, n, ...
                fractureElement, slabFiberMaterials, fracSecMaterials, ...                
                FI_lim_type, cvn_a0_type, flangeProp, cvn_col, ...
                generation, connType, degradation, c)
                
bldgData = readInput(geomFN);

% Name of the input file (delete existing files with same name)                   
filename = [folderPath,'/',modelFN];
if exist(filename, 'file')
    delete(filename)
end
INP = fopen(filename,'w+');

[backbone, degradation, connType, addEGF] = write_OpenArguments(INP, bldgData, composite, fractureElement, ...
                    addEGF, addSplices, rigidFloor, generation, ...
                    connType, backbone, degradation, panelZoneModel);

write_SourceSubroutine(INP,backbone,panelZoneModel,fractureElement,addSplices,addEGF);

write_BasicInput (INP, bldgData,AISC_v14p1,Es,mu_poisson,FyBeam,FyCol,...
                    TransformationX, backbone, SH_PZ, panelZoneModel, ...
                    composite, Comp_I, Comp_I_GC,...
                    DampModeI, DampModeJ, zeta, ...
                    addEGF, addSplices, g, outdir, addBasicRecorders, addDetailedRecorders, ...
                    modelSetUp, compBackboneFactors, n, ...
                    fractureElement, slabFiberMaterials, fracSecMaterials, ...
                    FI_lim_type, cvn_a0_type, flangeProp, degradation, c)

write_PreCalculations (INP, bldgData, addEGF, fractureElement)

AllNodes = write_Nodes(INP, bldgData, addEGF);

write_PZelements(INP,bldgData,panelZoneModel,AISC_v14p1)

AllEle = write_PZsprings(INP,bldgData,panelZoneModel,AISC_v14p1);

AllEle = write_Beams(INP,AllEle,bldgData,AISC_v14p1,connType,backbone,...
                    generation,degradation,fractureElement,Es,FyBeam,FyCol,slabFiberMaterials);                

AllEle = write_Columns(INP,AllEle,bldgData,AISC_v14p1,addSplices,backbone,...
                    degradation,Es,FyCol,cvn_col);

AllEle = write_FloorLinks (INP,AllEle,bldgData,addEGF);               

AllEle = write_EGFelements(INP,AllEle,bldgData,AISC_v14p1,addEGF,Es,FyCol,...
                        backbone,degradation);

write_EGFsprings (INP,bldgData,AISC_v14p1,addEGF,composite,FyBeam,backbone)

write_BCs(INP, bldgData, fixedBase, addEGF, rigidFloor)

AllNodes = write_Mass(INP, AllNodes, bldgData, addEGF, fractureElement, ...
                        panelZoneModel, backbone, addSplices, explicitMethod, g);

write_Gravity(INP, bldgData, AISC_v14p1, addEGF, modelSetUp)

write_modalAnalysis(INP,bldgData,max(DampModeI,DampModeJ),modelSetUp)
 
write_Damping(INP, AllEle, AllNodes, dampingType, backbone, fractureElement, ...
            addSplices, panelZoneModel)
        
write_DispRecorders(INP, AllNodes, isRHA)

write_BeamRecorders(INP, AllEle, fractureElement, backbone, isRHA)

write_ColumnRecorders(INP, AllEle, backbone, addSplices, isRHA)

write_PZrecorders(INP, AllNodes, panelZoneModel, isRHA)

fclose all;

end