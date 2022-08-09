%% This function writes the general assumptions for materials in the model
%
% Original from: Prof. Ahmed Elkady
% Adapted by: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
%
function write_BasicInput (INP, bldgData,AISC_v14p1,Es,mu_poisson,FyBeam,FyCol,...
                           TransformationX, backbone, SH_PZ, panelZoneModel, ...
                           CompositeX, Comp_I, Comp_I_GC,...
                           DampModeI, DampModeJ, zeta, ...
                           addEGF, addSplices, g, outdir, addBasicRecorders, addDetailedRecorders, ...
                           modelSetUp, compBackboneFactors, n, ...
                           fractureElement, slabFiberMaterials, fracSecMaterials, ...
                           FI_lim_type, cvn_a0_type, flangeProp, degradation, c)
            
%% Read relevant variables
storyNum  = bldgData.storyNum;
bayNum    = bldgData.bayNum;
floorNum  = bldgData.floorNum;
trib       = bldgData.trib;
tslab      = bldgData.tslab;
bslab      = bldgData.bslab;
AslabSteel = bldgData.AslabSteel;
beamSize   = bldgData.beamSize;
spliceLoc  = bldgData.spliceLoc; % length in [ft] at input file

if fractureElement
    fracSecMaterials.sigMin = fracSecMaterials.sigMin*FyBeam;
    
    switch cvn_a0_type
        case 'Constant'
            cvn = flangeProp.cvn; % Fracture thougness of all beam flanges in the building
            a0_tf = flangeProp.a0_tf;
        otherwise
            cvn      = flangeProp.cvn; % median
            betaCVN  = flangeProp.betaCVN; % dispersion
            a0_tf    = flangeProp.a0_tf; % median
            beta_a0  = flangeProp.beta_a0; % dispersion
            a0_limit = flangeProp.a0_limit; % upper bound
    end
    
    if strcmp(FI_lim_type, 'Constant')
        FI_lim = flangeProp.FI_lim;
    else
        FI = flangeProp.FI;
        betaFI_bot = flangeProp.betaFI_bot;
        betaFI_top = flangeProp.betaFI_top;
    end
end

%%
fprintf(INP,'####################################################################################################\n');
fprintf(INP,'#                                              INPUT                                               #\n');
fprintf(INP,'####################################################################################################\n');
fprintf(INP,'\n');

fprintf(INP,'# GENERAL CONSTANTS\n');
fprintf(INP,'set g %.3f;\n', g);
if strcmp(modelSetUp, 'Generic')
    fprintf(INP,'set outdir %s\n', outdir);
    fprintf(INP,'file mkdir $outdir; # create data directory');
end
fprintf(INP,'set pi [expr 2.0*asin(1.0)];\n');
if ~strcmp(backbone, 'Elastic')   
    fprintf(INP,'set n %.1f; # stiffness multiplier for CPH elements\n', n);
end
fprintf(INP,'set addBasicRecorders %d\n', addBasicRecorders);
fprintf(INP,'set addDetailedRecorders %d', addDetailedRecorders);
fprintf(INP,'\n\n');

fprintf(INP,'# FRAME CENTERLINE DIMENSIONS\n');
fprintf(INP,'set num_stories %2.0f;\n', storyNum);
fprintf(INP,'set NBay %2.0f;\n', bayNum);
fprintf(INP,'\n');

fprintf(INP,'# MATERIAL PROPERTIES\n');
fprintf(INP,'set Es  %.3f; \n',Es);
fprintf(INP,'set mu  %.3f; \n',mu_poisson);
fprintf(INP,'set FyBeam  %.3f;\n',FyBeam);
fprintf(INP,'set FyCol  %.3f;\n',FyCol);
fprintf(INP,'\n');

fprintf(INP,'# RIGID MATERIAL FOR ZERO LENGTH ELEMENT STIFF DOF\n');
fprintf(INP,'set rigMatTag 99\n');
fprintf(INP,'uniaxialMaterial Elastic  $rigMatTag [expr 50*50*29000];  #Rigid Material [using axial stiffness of a 500in2 steel element] \n');
fprintf(INP,'\n');

fprintf(INP,'# RAYLEIGH DAMPING PARAMETERS\n');
fprintf(INP,'set  DampModeI %d;\n',DampModeI);
fprintf(INP,'set  DampModeJ %d;\n',DampModeJ);
fprintf(INP,'set  zeta %.3f;\n',zeta);
fprintf(INP,'\n');

if addEGF
    fprintf(INP,'# GRAVITY FRAME MODEL\n');
    fprintf(INP,'set gap 0.08; # Gap to consider binding in gravity frame beam connections\n');
    fprintf(INP,'\n');
end

fprintf(INP,'# GEOMETRIC TRANSFORMATIONS IDs\n');
fprintf(INP,'geomTransf Linear 		 1;\n');
fprintf(INP,'geomTransf PDelta 		 2;\n');
fprintf(INP,'geomTransf Corotational 3;\n');
fprintf(INP,'set trans_Linear 	1;\n');
fprintf(INP,'set trans_PDelta 	2;\n');
fprintf(INP,'set trans_Corot  	3;\n');
fprintf(INP,'set trans_selected  %d;\n', TransformationX);
fprintf(INP,'\n');

fprintf(INP,'# STIFF ELEMENTS FOR PANEL ZONE MODEL PROPERTY\n');
fprintf(INP,'set A_Stiff [expr 50*50]; # [using 500in2 section as a reference]\n');
fprintf(INP,'set I_Stiff [expr 50*pow(50,3)]; # [using second moment of area of a large rectangle as a reference]\n');
fprintf(INP,'\n');

fprintf(INP,'# PANEL ZONE MODELING\n');
fprintf(INP,'set SH_PZ %5.3f;\n', SH_PZ);
switch panelZoneModel
    case 'Gupta1999'
        pzModelTag = 1;
    case 'NIST2017'
        pzModelTag = 2;
    case 'Kim2015'
        pzModelTag = 3;
    case 'Elkady2021'
        pzModelTag = 4;
    case 'Elastic'
        pzModelTag = 5;
    otherwise
        pzModelTag = 0;
end
fprintf(INP,'set pzModelTag %d;\n', pzModelTag);
fprintf(INP,'\n');

fprintf(INP,'# BACKBONE FACTORS FOR COMPOSITE BEAM\n');
if CompositeX == 1
    fprintf(INP,'set Composite 1; # Consider composite action\n');
    fprintf(INP,'set Comp_I       %.3f; # stiffness factor for MR frame beams\n', Comp_I);
    fprintf(INP,'set Comp_I_GC    %.3f; # stiffness factor for EGF beams\n', Comp_I_GC);
else
    fprintf(INP,'set Composite 0; # Ignore composite action\n');
    fprintf(INP,'set Comp_I       %.3f; # stiffness factor for MR frame beams\n', 1.0);
    fprintf(INP,'set Comp_I_GC    %.3f; # stiffness factor for EGF beams\n', 1.0);    
end
fprintf(INP,'set trib        %.3f;\n', trib);
fprintf(INP,'set tslab       %.3f;\n', tslab);
    
if ~strcmp(backbone, 'Elastic')        
    fprintf(INP,'set bslab       %.3f;\n', bslab);
    fprintf(INP,'set AslabSteel  %.3f;\n', AslabSteel);
    fprintf(INP, '# compBackboneFactors {MpP/Mp MpN/Mp Mc/MpP Mc/MpN Mr/MpP Mr/MpN D_P D_N theta_p_P_comp theta_p_N_comp theta_pc_P_comp theta_pc_P_comp};\n');
    fprintf(INP,'set compBackboneFactors {%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f};\n',...
        struct2array(compBackboneFactors));
    fprintf(INP, '# slabFiberMaterials {fc epsc0 epsU fy degrad};\n');
    slabMaterial = struct2array(slabFiberMaterials);
    fprintf(INP,'set slabFiberMaterials {%.3f %.3f %.3f %.3f %.3f};\n',...
        slabMaterial(1:end-2));
    fprintf(INP,'\n');

    fprintf(INP,'# DEGRADATION IN PLASTIC HINGEs\n');
    if degradation    
        fprintf(INP,'set degradation %d;\n', 1.0);
        fprintf(INP,'set c %.3f; # Exponent for degradation in plastic hinges\n', c);    
    else
        fprintf(INP,'set degradation %d;\n', 0.0);
        fprintf(INP,'set c %.3f; # Exponent for degradation in plastic hinges\n', 0.0);  
    end
    fprintf(INP,'\n');
end

if addSplices
    fprintf(INP,'# COLUMN SPLICES\n');
    fprintf(INP,'set spliceLoc        %.3f;\n', spliceLoc*12); % length [in] from bottom end of the column
    fprintf(INP,'\n');
end

if fractureElement
    fprintf(INP,'# MATERIAL PROPERTIES FOR FRACURING FIBER-SECTIONS\n');
    fprintf(INP, 'set alpha 7.6; # Calibration constant to compute KIC (Stillmaker et al. 2017)\n');
    fprintf(INP, 'set T_service_F 70; # Temperature at service [F]\n');
    fprintf(INP, 'set FyWeld 70; # Yielding strength for sigCr calculations (Use 70ksi to be consistent with Galvis et al. 2021 calibrations)\n');
    fprintf(INP, '# fracSecMaterials {FyFiber EsFiber betaC_B betaC_T sigMin FuBolt FyTab FuTab};\n');
    fprintf(INP,'set fracSecMaterials {%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f};\n',...
        struct2array(fracSecMaterials));
    fprintf(INP,'\n');

    fprintf(INP,'# FRACTURE INDEX LIMIT FOR FRACTURE PER FLANGE AND CONNECTION\n');
    fprintf(INP,'# Left-Bottom                       Left-Top                            Right-Bottom                       Right-Top\n');       
    for Floor = 2:floorNum
        Story = Floor - 1;
        for Bay = 1:bayNum
            if ~isempty(beamSize{Story,Bay})
                if strcmp(FI_lim_type, 'Constant')
                    FI_lim_BL = FI_lim;
                    FI_lim_TL = FI_lim;
                    FI_lim_BR = FI_lim;
                    FI_lim_TR = FI_lim;
                else
                    FI_lim_BL = lognrnd(log(FI),betaFI_bot,1);
                    FI_lim_TL = lognrnd(log(FI),betaFI_top,1);
                    FI_lim_BR = lognrnd(log(FI),betaFI_bot,1);
                    FI_lim_TR = lognrnd(log(FI),betaFI_top,1);
                end
                % Write FI limit for bottom flange left 
                fprintf(INP,'set FI_limB_bay%d_floor%d_i %.3f;\t', Bay, Floor, FI_lim_BL);
                % Write FI limit for top flange left 
                fprintf(INP,'set FI_limT_bay%d_floor%d_i %.3f;\t', Bay, Floor, FI_lim_TL);
                % Write FI limit for bottom flange right 
                fprintf(INP,'set FI_limB_bay%d_floor%d_j %.3f;\t', Bay, Floor, FI_lim_BR);
                % Write FI limit for top flange right 
                fprintf(INP,'set FI_limT_bay%d_floor%d_j %.3f;\t', Bay, Floor, FI_lim_TR);
                fprintf(INP,'\n');
            end            
        end
    end
    fprintf(INP,'\n');

    fprintf(INP,'# CVN PER FLANGE AND CONNECTION\n');
    fprintf(INP,'# Left connection               Right connection\n');
    
    % Sample connection CVN if uniform for the bldg
    if strcmp(cvn_a0_type, 'Constant')
        cvn_i = cvn;
        cvn_j = cvn;
    elseif strcmp(cvn_a0_type, 'Uniform')
        cvn_bldg = lognrnd(log(cvn),betaCVN,1);
        cvn_i = cvn_bldg;
        cvn_j = cvn_bldg;
    end
    
    for Floor = 2:floorNum
        Story = Floor - 1;
        % Sample connection CVN if byFloor (using lognormal)
        if strcmp(cvn_a0_type, 'byFloor')
            cvn_floor = lognrnd(log(cvn),betaCVN,1);
            cvn_i = cvn_floor;
            cvn_j = cvn_floor;
        end
        for Bay = 1:bayNum            
            if ~isempty(beamSize{Story,Bay})
                % Sample connection CVN if byConnection (using lognormal)
                if strcmp(cvn_a0_type, 'byConnection')
                    cvn_beam = lognrnd(log(cvn),betaCVN,1);
                    cvn_i = cvn_beam;
                    cvn_j = cvn_beam;
                end
                % Write cvn left connection
                fprintf(INP,'set cvn_bay%d_floor%d_i %.3f;\t', Bay, Floor, cvn_i);
                % Write cvn rigth connection
                fprintf(INP,'set cvn_bay%d_floor%d_j %.3f;\t', Bay, Floor, cvn_j);
                fprintf(INP,'\n');
            end            
        end
    end
    fprintf(INP,'\n');
    
    fprintf(INP,'# a0 PER FLANGE AND CONNECTION\n');
    fprintf(INP,'# Left connection           Right connection\n');
    % Sample connection a0 if uniform for the bldg
    if strcmp(cvn_a0_type, 'Constant')
        a0_tf_i = a0_tf;
        a0_tf_j = a0_tf;
    elseif strcmp(cvn_a0_type, 'Uniform')
        pd = makedist('Lognormal','mu',log(a0_tf),'sigma',beta_a0);
        t = truncate(pd,0,a0_limit);
        a0_tf_bldg = random(t);
        a0_tf_i = a0_tf_bldg;
        a0_tf_j = a0_tf_bldg;
    end
    
    for Floor = 2:floorNum
        Story = Floor - 1;
        % Sample connection a0 if byFloor (using truncated lognormal)
        if strcmp(cvn_a0_type, 'byFloor')
            pd = makedist('Lognormal','mu',log(a0_tf),'sigma',beta_a0);
            t = truncate(pd,0,a0_limit);
            a0_tf_floor = random(t);
            a0_tf_i = a0_tf_floor;
            a0_tf_j = a0_tf_floor;
        end
        for Bay = 1:bayNum
            if ~isempty(beamSize{Story,Bay})
                % Sample connection a0 if byConnection (using truncated lognormal)
                if strcmp(cvn_a0_type, 'byConnection')
                    pd = makedist('Lognormal','mu',log(a0_tf),'sigma',beta_a0);
                    t = truncate(pd,0,a0_limit);
                    a0_tf_floor = random(t);
                    a0_tf_i = a0_tf_floor;
                    a0_tf_j = a0_tf_floor;
                end
                beamProps = getSteelSectionProps(beamSize{Floor-1, Bay}, AISC_v14p1);
                tf = beamProps.tf;
                % Write a0 left connection
                fprintf(INP,'set a0_bay%d_floor%d_i %.3f;\t', Bay, Floor, a0_tf_i*tf);
                % Write a0 rigth connection
                fprintf(INP,'set a0_bay%d_floor%d_j %.3f;\t', Bay, Floor, a0_tf_j*tf);
                fprintf(INP,'\n');
            end            
        end
    end
    fprintf(INP,'\n');    
    
end

end