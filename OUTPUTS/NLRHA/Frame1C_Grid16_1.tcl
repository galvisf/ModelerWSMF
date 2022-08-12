####################################################################################################
####################################################################################################
#                                        3-story MRF Building
####################################################################################################
####################################################################################################

####### MODEL FEATURES #######;
# UNITS:                     kip, in
# Generation:                Pre_Northridge
# Composite beams:           True
# Fracturing fiber sections: True
# Gravity system stiffness:  False
# Column splices included:   False
# Rigid diaphragm:           False
# Plastic hinge type:        non_RBS
# Backbone type:             ASCE41
# Cyclic degradation:        False
# Web connection type:       Bolted
# Panel zone model:          Elkady2021

# BUILD MODEL (2D - 3 DOF/node)
wipe all
model basic -ndm 2 -ndf 3

####################################################################################################
#                                      SOURCING HELPER FUNCTIONS                                   #
####################################################################################################

source ConstructPanel_Rectangle.tcl;
source PanelZoneSpring.tcl;
source fracSectionBolted.tcl;
source hingeBeamColumnFracture.tcl;
source sigCrNIST2017.tcl;
source fracSectionWelded.tcl;
source hingeBeamColumn.tcl;
source matHysteretic.tcl;
source matIMKBilin.tcl;
source matBilin02.tcl;
source modalAnalysis.tcl;

####################################################################################################
#                                              INPUT                                               #
####################################################################################################

# GENERAL CONSTANTS
set g 386.100;
set pi [expr 2.0*asin(1.0)];
set n 10.0; # stiffness multiplier for CPH elements
set addBasicRecorders 1
set addDetailedRecorders 1

# FRAME CENTERLINE DIMENSIONS
set num_stories  3;
set NBay  1;

# MATERIAL PROPERTIES
set Es  29000.000; 
set mu  0.300; 
set FyBeam  44.000;
set FyCol  44.000;

# RIGID MATERIAL FOR ZERO LENGTH ELEMENT STIFF DOF
set rigMatTag 99
uniaxialMaterial Elastic  $rigMatTag [expr 50*50*29000];  #Rigid Material [using axial stiffness of a 500in2 steel element] 

# RAYLEIGH DAMPING PARAMETERS
set  DampModeI 1;
set  DampModeJ 3;
set  zeta 0.020;

# GEOMETRIC TRANSFORMATIONS IDs
geomTransf Linear 		 1;
geomTransf PDelta 		 2;
geomTransf Corotational 3;
set trans_Linear 	1;
set trans_PDelta 	2;
set trans_Corot  	3;
set trans_selected  2;

# STIFF ELEMENTS FOR PANEL ZONE MODEL PROPERTY
set A_Stiff [expr 50*50]; # [using 500in2 section as a reference]
set I_Stiff [expr 50*pow(50,3)]; # [using second moment of area of a large rectangle as a reference]

# PANEL ZONE MODELING
set SH_PZ 0.015;
set pzModelTag 4;

# BACKBONE FACTORS FOR COMPOSITE BEAM
set Composite 1; # Consider composite action
set Comp_I       1.400; # stiffness factor for MR frame beams
set Comp_I_GC    1.400; # stiffness factor for EGF beams
set trib        3.000;
set tslab       3.000;
set bslab       36.000;
set AslabSteel  15.000;
# compBackboneFactors {MpP/Mp MpN/Mp Mc/MpP Mc/MpN Mr/MpP Mr/MpN D_P D_N theta_p_P_comp theta_p_N_comp theta_pc_P_comp theta_pc_P_comp};
set compBackboneFactors {1.350 1.250 1.300 1.050 0.300 0.200 1.150 1.000 1.800 0.950 1.350 0.950};
# slabFiberMaterials {fc epsc0 epsU fy degrad};
set slabFiberMaterials {-3.000 -0.002 -0.010 60.000 -0.100};

# DEGRADATION IN PLASTIC HINGEs
set degradation 0;
set c 0.000; # Exponent for degradation in plastic hinges

# MATERIAL PROPERTIES FOR FRACURING FIBER-SECTIONS
set alpha 7.6; # Calibration constant to compute KIC (Stillmaker et al. 2017)
set T_service_F 70; # Temperature at service [F]
set FyWeld 70; # Yielding strength for sigCr calculations (Use 70ksi to be consistent with Galvis et al. 2021 calibrations)
# fracSecMaterials {FyFiber EsFiber betaC_B betaC_T sigMin FuBolt FyTab FuTab};
set fracSecMaterials {150.000 29000.000 0.500 0.800 17.600 68.000 47.000 70.000};

# FRACTURE INDEX LIMIT FOR FRACTURE PER FLANGE AND CONNECTION
# Left-Bottom                       Left-Top                            Right-Bottom                       Right-Top
set FI_limB_bay1_floor2_i 1.000;	set FI_limT_bay1_floor2_i 1.000;	set FI_limB_bay1_floor2_j 1.000;	set FI_limT_bay1_floor2_j 1.000;	
set FI_limB_bay1_floor3_i 1.000;	set FI_limT_bay1_floor3_i 1.000;	set FI_limB_bay1_floor3_j 1.000;	set FI_limT_bay1_floor3_j 1.000;	
set FI_limB_bay1_floor4_i 1.000;	set FI_limT_bay1_floor4_i 1.000;	set FI_limB_bay1_floor4_j 1.000;	set FI_limT_bay1_floor4_j 1.000;	

# CVN PER FLANGE AND CONNECTION
# Left connection               Right connection
set cvn_bay1_floor2_i 12.000;	set cvn_bay1_floor2_j 12.000;	
set cvn_bay1_floor3_i 12.000;	set cvn_bay1_floor3_j 12.000;	
set cvn_bay1_floor4_i 12.000;	set cvn_bay1_floor4_j 12.000;	

# a0 PER FLANGE AND CONNECTION
# Left connection           Right connection
set a0_bay1_floor2_i 0.168;	set a0_bay1_floor2_j 0.168;	
set a0_bay1_floor3_i 0.157;	set a0_bay1_floor3_j 0.157;	
set a0_bay1_floor4_i 0.068;	set a0_bay1_floor4_j 0.068;	

####################################################################################################
#                                          PRE-CALCULATIONS                                        #
####################################################################################################

# FRAME GRID LINES
set Floor1 0.0;
set Floor2  224.04;
set Floor3  446.04;
set Floor4  773.04;

set Axis1 0.0;
set Axis2 360.00;

set HBuilding 773.04;
set WFrame 360.00;

# SIGMA CRITICAL PER FLANGE AND CONNECTION
set sigCrB_bay1_floor2_i [sigCrNIST2017 "bottom" $cvn_bay1_floor2_i $a0_bay1_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor2_i [sigCrNIST2017 "top" $cvn_bay1_floor2_i $a0_bay1_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor2_j [sigCrNIST2017 "bottom" $cvn_bay1_floor2_j $a0_bay1_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor2_j [sigCrNIST2017 "top" $cvn_bay1_floor2_j $a0_bay1_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor3_i [sigCrNIST2017 "bottom" $cvn_bay1_floor3_i $a0_bay1_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor3_i [sigCrNIST2017 "top" $cvn_bay1_floor3_i $a0_bay1_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor3_j [sigCrNIST2017 "bottom" $cvn_bay1_floor3_j $a0_bay1_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor3_j [sigCrNIST2017 "top" $cvn_bay1_floor3_j $a0_bay1_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor4_i [sigCrNIST2017 "bottom" $cvn_bay1_floor4_i $a0_bay1_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor4_i [sigCrNIST2017 "top" $cvn_bay1_floor4_i $a0_bay1_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor4_j [sigCrNIST2017 "bottom" $cvn_bay1_floor4_j $a0_bay1_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor4_j [sigCrNIST2017 "top" $cvn_bay1_floor4_j $a0_bay1_floor4_j $alpha $T_service_F $Es $FyWeld];

####################################################################################################
#                                                  NODES                                           #
####################################################################################################

# COMMAND SYNTAX 
# node $NodeID  $X-Coordinate  $Y-Coordinate;

# SUPPORT NODES
node 10100   $Axis1  $Floor1;
node 10200   $Axis2  $Floor1;


#LEANING COLUMN NODES
#column lower node label: story_i*10000+(axisNum+1)*100 + 2;
#column upper node label: story_i*10000+(axisNum+1)*100 + 4;
node 10302  720.000    0.000;
node 10304  720.000  224.040;
node 20302  720.000  224.040;
node 20304  720.000  446.040;
node 30302  720.000  446.040;
node 30304  720.000  773.040;

#Pin the nodes for leaning column, floor 2
equalDOF 20302 10304 1 2;

#Pin the nodes for leaning column, floor 3
equalDOF 30302 20304 1 2;
###################################################################################################
#                                  PANEL ZONE NODES & ELEMENTS                                    #
###################################################################################################

# PANEL ZONE NODES AND ELASTIC ELEMENTS
# Command Syntax; 
# ConstructPanel_Rectangle Axis Floor X_Axis Y_Floor E A_Panel I_Panel d_Col d_Beam transfTag 

# Panel zones floor2
ConstructPanel_Rectangle  1 2 $Axis1 $Floor2 $Es $A_Stiff $I_Stiff 18.30 37.30 $trans_selected;
ConstructPanel_Rectangle  2 2 $Axis2 $Floor2 $Es $A_Stiff $I_Stiff 18.30 37.30 $trans_selected;

# Panel zones floor3
ConstructPanel_Rectangle  1 3 $Axis1 $Floor3 $Es $A_Stiff $I_Stiff 18.30 37.10 $trans_selected;
ConstructPanel_Rectangle  2 3 $Axis2 $Floor3 $Es $A_Stiff $I_Stiff 18.30 37.10 $trans_selected;

# Panel zones floor4
ConstructPanel_Rectangle  1 4 $Axis1 $Floor4 $Es $A_Stiff $I_Stiff 18.30 23.90 $trans_selected;
ConstructPanel_Rectangle  2 4 $Axis2 $Floor4 $Es $A_Stiff $I_Stiff 18.30 23.90 $trans_selected;


####################################################################################################
#                                          PANEL ZONE SPRINGS                                      #
####################################################################################################

# COMMAND SYNTAX 
# PanelZoneSpring    eleID NodeI NodeJ Es mu Fy dc bc tcf tcw tdp db Ic Acol alpha Pr trib ts pzModelTag isExterior Composite
# Panel zones floor2
PanelZoneSpring 9020100 4020109 4020110 $Es $mu $FyCol 18.30 16.60  2.85  1.77  2.75 37.30 6000.00 117.000 $SH_PZ 255.475 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9020200 4020209 4020210 $Es $mu $FyCol 18.30 16.60  2.85  1.77  2.75 37.30 6000.00 117.000 $SH_PZ 255.475 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor3
PanelZoneSpring 9030100 4030109 4030110 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.75 37.10 6000.00 117.000 $SH_PZ 165.275 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9030200 4030209 4030210 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.75 37.10 6000.00 117.000 $SH_PZ 165.275 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor4
PanelZoneSpring 9040100 4040109 4040110 $Es $mu $FyCol 18.30 16.60  2.85  1.77  0.00 23.90 6000.00 117.000 $SH_PZ 56.375 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9040200 4040209 4040210 $Es $mu $FyCol 18.30 16.60  2.85  1.77  0.00 23.90 6000.00 117.000 $SH_PZ 56.375 $trib $tslab $pzModelTag 1 $Composite;


####################################################################################################
#                                             BEAM ELEMENTS                                        #
####################################################################################################

# COMMAND SYNTAX 
# secInfo  Zp, Mc/Mp, Mr/Mp, theta_p, theta_pc, theta_u, lambda
# (Welded web) fracSecGeometry  d, bf, tf, ttab, tabLength, dtab
# (Bolted web) fracSecGeometry  d, bf, tf, ttab, tabLength, str, boltDiameter, Lc
# hingeBeamColumnFracture  ElementID node_i node_j eleDir, ... A, Ieff, ... webConnection
# hingeBeamColumn  ElementID node_i node_j eleDir, ... A, Ieff

# Beams at floor 2 bay 1
set secInfo_i {1280.0000   1.1177   0.2000   0.0142   0.0013   0.0220   0.0000};
set secInfo_j {1280.0000   1.1177   0.2000   0.0142   0.0013   0.0220   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp

# Beams at floor 3 bay 1
set secInfo_i {936.0000   1.1178   0.2000   0.0180   0.0016   0.0277   0.0000};
set secInfo_j {936.0000   1.1178   0.2000   0.0180   0.0016   0.0277   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp

# Beams at floor 4 bay 1
