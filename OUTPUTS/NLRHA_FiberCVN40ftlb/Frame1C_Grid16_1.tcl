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
set FyBeam  47.300;
set FyCol  47.300;

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
set fracSecMaterials {150.000 29000.000 0.500 0.800 18.920 68.000 47.000 70.000};

# FRACTURE INDEX LIMIT FOR FRACTURE PER FLANGE AND CONNECTION
# Left-Bottom                       Left-Top                            Right-Bottom                       Right-Top
set FI_limB_bay1_floor2_i 1.190;	set FI_limT_bay1_floor2_i 0.986;	set FI_limB_bay1_floor2_j 1.187;	set FI_limT_bay1_floor2_j 0.956;	
set FI_limB_bay1_floor3_i 0.971;	set FI_limT_bay1_floor3_i 1.388;	set FI_limB_bay1_floor3_j 1.402;	set FI_limT_bay1_floor3_j 1.366;	
set FI_limB_bay1_floor4_i 1.175;	set FI_limT_bay1_floor4_i 0.767;	set FI_limB_bay1_floor4_j 1.188;	set FI_limT_bay1_floor4_j 1.431;	

# CVN PER FLANGE AND CONNECTION
# Left connection               Right connection
set cvn_bay1_floor2_i 40.000;	set cvn_bay1_floor2_j 40.000;	
set cvn_bay1_floor3_i 40.000;	set cvn_bay1_floor3_j 40.000;	
set cvn_bay1_floor4_i 40.000;	set cvn_bay1_floor4_j 40.000;	

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
set secInfo_i {1280.0000   1.1095   0.2000   0.0142   0.0058   0.0220   0.0000};
set secInfo_j {1280.0000   1.1095   0.2000   0.0142   0.0058   0.0220   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 37.3000  16.7000   1.6800   0.9450   0.5000   5.0000 { -16.5  -13.5  -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  13.5  16.5  }     1.12        2 1.0};
set kBL 1.315
set kTL 1.159
set kBR 1.315
set kTR 1.159
hingeBeamColumnFracture 1020100 4020104 4020202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 89.000 [expr 19515.550*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay1_floor2_i] [expr $kTL*$sigCrT_bay1_floor2_i] [expr $kBR*$sigCrB_bay1_floor2_j] [expr $kTR*$sigCrT_bay1_floor2_j] $FI_limB_bay1_floor2_i $FI_limT_bay1_floor2_i $FI_limB_bay1_floor2_j $FI_limT_bay1_floor2_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 3 bay 1
set secInfo_i {936.0000   1.1096   0.2000   0.0180   0.0073   0.0277   0.0000};
set secInfo_j {936.0000   1.1096   0.2000   0.0180   0.0073   0.0277   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 37.1000  12.1000   1.5700   0.8700   0.5000   5.0000 { -12  -9  -6  -3  0  3  6  9  12  }     1.12        2 1.0};
set kBL 1.334
set kTL 1.188
set kBR 1.334
set kTR 1.188
hingeBeamColumnFracture 1030100 4030104 4030202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 68.000 [expr 14129.237*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay1_floor3_i] [expr $kTL*$sigCrT_bay1_floor3_i] [expr $kBR*$sigCrB_bay1_floor3_j] [expr $kTR*$sigCrT_bay1_floor3_j] $FI_limB_bay1_floor3_i $FI_limT_bay1_floor3_i $FI_limB_bay1_floor3_j $FI_limT_bay1_floor3_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 4 bay 1
set secInfo_i {163.0825   1.1555   0.2000   0.0307   0.0105   0.0446   0.0000};
set secInfo_j {163.0825   1.1555   0.2000   0.0307   0.0105   0.0446   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.9000   8.9900   0.6800   0.4400   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.604
set kTL 1.614
set kBR 1.604
set kTR 1.614
hingeBeamColumnFracture 1040100 4040104 4040202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 22.400 [expr 2048.462*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay1_floor4_i] [expr $kTL*$sigCrT_bay1_floor4_i] [expr $kBR*$sigCrB_bay1_floor4_j] [expr $kTR*$sigCrT_bay1_floor4_j] $FI_limB_bay1_floor4_i $FI_limT_bay1_floor4_i $FI_limB_bay1_floor4_j $FI_limT_bay1_floor4_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

####################################################################################################
#                                            COLUMNS ELEMENTS                                      #
####################################################################################################

# COMMAND SYNTAX 
# secInfo  Zp, Mc/Mp, Mr/Mp, theta_p, theta_pc, theta_u, lambda
# spliceSecGeometry  min(d_i, d_j), min(bf_i, bf_j), min(tf_i, tf_j), min(tw_i, tw_j)
# (splice)    hingeBeamColumnSplice  ElementID node_i node_j eleDir, ... A, Ieff, ... 
# (no splice) hingeBeamColumn        ElementID node_i node_j eleDir, ... A, Ieff

# Columns at story 1 axis 1
set secInfo_i {764.0228   1.2733   0.8585   0.0692   0.0607   0.1501   0.0000};
set secInfo_j {764.0228   1.2733   0.8585   0.0692   0.0607   0.1501   0.0000};
hingeBeamColumn 2010100 10100 4020101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5617.449 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 1
set secInfo_i {777.0783   1.3222   0.8731   0.0758   0.0677   0.1660   0.0000};
set secInfo_j {777.0783   1.3222   0.8731   0.0758   0.0677   0.1660   0.0000};
hingeBeamColumn 2020100 4020103 4030101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5533.957 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 3 axis 1
set secInfo_i {792.8403   1.1677   0.8908   0.0615   0.0515   0.1301   0.0000};
set secInfo_j {792.8403   1.1677   0.8908   0.0615   0.0515   0.1301   0.0000};
hingeBeamColumn 2030100 4030103 4040101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5811.305 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 2
set secInfo_i {764.0228   1.2733   0.8585   0.0692   0.0607   0.1501   0.0000};
set secInfo_j {764.0228   1.2733   0.8585   0.0692   0.0607   0.1501   0.0000};
hingeBeamColumn 2010200 10200 4020201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5617.449 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 2
set secInfo_i {777.0783   1.3222   0.8731   0.0758   0.0677   0.1660   0.0000};
set secInfo_j {777.0783   1.3222   0.8731   0.0758   0.0677   0.1660   0.0000};
hingeBeamColumn 2020200 4020203 4030201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5533.957 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 3 axis 2
set secInfo_i {792.8403   1.1677   0.8908   0.0615   0.0515   0.1301   0.0000};
set secInfo_j {792.8403   1.1677   0.8908   0.0615   0.0515   0.1301   0.0000};
hingeBeamColumn 2030200 4030203 4040201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5811.305 $degradation $c $secInfo_i $secInfo_j 0 0;

####################################################################################################
#                                              FLOOR LINKS                                         #
####################################################################################################

# Command Syntax 
# element truss $ElementID $iNode $jNode $Area $matID
element truss 1004 4040204 30304 $A_Stiff $rigMatTag;
element truss 1003 4030204 20304 $A_Stiff $rigMatTag;
element truss 1002 4020204 10304 $A_Stiff $rigMatTag;

####################################################################################################
#                                          EGF COLUMNS AND BEAMS                                   #
####################################################################################################

# LEANING COLUMN
element elasticBeamColumn 2010300 10302 10304 $A_Stiff $Es $I_Stiff $trans_selected;
element elasticBeamColumn 2020300 20302 20304 $A_Stiff $Es $I_Stiff $trans_selected;
element elasticBeamColumn 2030300 30302 30304 $A_Stiff $Es $I_Stiff $trans_selected;
###################################################################################################
#                                       BOUNDARY CONDITIONS                                       #
###################################################################################################

# FRAME BASE SUPPORTS
fix 10100 1 1 0;
fix 10200 1 1 0;

# LEANING COLUMN SUPPORT
fix 10302 1 1 0;

# ADDITIONAL SPRINGS
node 10205 360.000 [expr 224.040+37.3/2]
fix 10205 1 1 1
set springMatTag 98
uniaxialMaterial Elastic $springMatTag 35;
element zeroLength 1 10205 4020203 -mat $springMatTag -dir 1

###################################################################################################
###################################################################################################
                                         puts "

"                                               
                                      puts "Model Built"                                           
###################################################################################################
###################################################################################################

###################################################################################################
#                                              NODAL MASS                                         #
###################################################################################################

# MASS ON THE MOMENT FRAME

# Panel zones floor2
mass 4020103 0.2336  0.0023 25.2308;
mass 4020203 0.2336  0.0023 25.2308;
# Panel zones floor3
mass 4030103 0.2821  0.0028 30.4615;
mass 4030203 0.2821  0.0028 30.4615;
# Panel zones floor4
mass 4040103 0.1460  0.0015 15.7692;
mass 4040203 0.1460  0.0015 15.7692;

# MASS ON THE GRAVITY SYSTEM

mass 10304 2.3818  0.0238 257.2308;
mass 20304 3.5799  0.0358 386.6294;
mass 30304 0.4850  0.0048 52.3776;

###################################################################################################
#                                            GRAVITY LOAD                                         #
###################################################################################################

pattern Plain 101 Linear {

	# MR Frame: Distributed beam element loads
	# Floor 2
	eleLoad -ele 1020100 -type -beamUniform   -0.19315; # Beam at floor 2 bay 1
	# Floor 3
	eleLoad -ele 1030100 -type -beamUniform   -0.17867; # Beam at floor 3 bay 1
	# Floor 4

	#  MR Frame: Point loads on columns
	# Floor2
	load 4020103 0.0 -57.2000 0.0;
	load 4020203 0.0 -57.2000 0.0;
	# Floor3
	load 4030103 0.0 -78.3750 0.0;
	load 4030203 0.0 -78.3750 0.0;
	# Floor4
	load 4040103 0.0 -56.3750 0.0;
	load 4040203 0.0 -56.3750 0.0;

	#  Gravity Frame: Point loads on columns
	load 10304 0.0 -919.6000 0.0;
	load 20304 0.0 -1382.2000 0.0;
	load 30304 0.0 -187.2500 0.0;

}

# ----- Gravity analyses commands ----- #
constraints Transformation;
numberer RCM;
system BandGeneral;
test RelativeEnergyIncr 1.0e-05 20;
algorithm Newton;
integrator LoadControl 0.10;
analysis Static;
if {[analyze 10]} {puts "Application of gravity load failed"};
loadConst -time 0.0;
remove recorders;

###################################################################################################
###################################################################################################
                                        puts "Gravity Done"                                        
###################################################################################################
###################################################################################################

###################################################################################################
#                                            CONTROL NODES                                        #
###################################################################################################

set ctrl_nodes {
	10200
	4020203
	4030203
	4040203
};

set hVector {
	2.240400e+02
	222
	327
};

###################################################################################################
#                                        EIGEN VALUE ANALYSIS                                     #
###################################################################################################

set num_modes 3
set dof 1
set ctrl_nodes2 $ctrl_nodes
set filename_eigen ""
set omegas [modal $num_modes $filename_eigen]

###################################################################################################
###################################################################################################
                                   puts "Eigen Analysis Done"                                      
###################################################################################################
###################################################################################################

###################################################################################################
#                                               DAMPING                                           #
###################################################################################################

# Calculate Rayleigh Damping constnats
set wI [lindex $omegas $DampModeI-1]
set wJ [lindex $omegas $DampModeJ-1]
set a0 [expr $zeta*2.0*$wI*$wJ/($wI+$wJ)];
set a1 [expr $zeta*2.0/($wI+$wJ)];
set a1_mod [expr $a1*(1.0+$n)/$n];


# Beam elastic elements
region 1 -ele 1020100 1030100 1040100 -rayleigh 0.0 0.0 $a1_mod 0.0;

# Column elastic elements
region 2 -ele 2010100 2020100 2030100 2010200 2020200 2030200 -rayleigh 0.0 0.0 $a1_mod 0.0;

# Hinge elements [beam springs, column springs]
region 3 -ele 1020102 1020104 1030102 1030104 1040102 1040104 2010101 2010102 2020101 2020102 2030101 2030102 2010201 2010202 2020201 2020202 2030201 2030202 -rayleigh 0.0 0.0 [expr $a1_mod/$n] 0.0;

# Nodes with mass
region 4 -nodes 4020103 4020203 4030103 4030203 4040103 4040203 -rayleigh $a0 0.0 0.0 0.0;

###################################################################################################
#                                     DETAILED RECORDERS                                          #
###################################################################################################

if {$addBasicRecorders == 1} {

	# Recorders for lateral displacement on each panel zone
	recorder Node -file $outdir/all_disp.out -dT 0.01 -time -nodes 4020103 4020203 4030103 4030203 4040103 4040203 -dof 1 disp;

}

if {$addBasicRecorders == 1} {

	# Recorders for beam fracture boolean
	# Left-bottom flange
	recorder Element -file $outdir/frac_LB.out -dT 0.01 -ele 1020105 1030105 1040105 section fiber 7 failure;

	# Left-top flange
	recorder Element -file $outdir/frac_LT.out -dT 0.01 -ele 1020105 1030105 1040105 section fiber 2 failure;

	# Right-bottom flange
	recorder Element -file $outdir/frac_RB.out -dT 0.01 -ele 1020106 1030106 1040106 section fiber 7 failure;

	# Right-top flange
	recorder Element -file $outdir/frac_RT.out -dT 0.01 -ele 1020106 1030106 1040106 section fiber 2 failure;

	# Recorders for beam fracture index
	# Left-bottom flange
	recorder Element -file $outdir/FI_LB.out -dT 0.01 -ele 1020105 1030105 1040105 section fiber 7 damage;

	# Left-top flange
	recorder Element -file $outdir/FI_LT.out -dT 0.01 -ele 1020105 1030105 1040105 section fiber 2 damage;

	# Right-bottom flange
	recorder Element -file $outdir/FI_RB.out -dT 0.01 -ele 1020106 1030106 1040106 section fiber 7 damage;

	# Right-top flange
	recorder Element -file $outdir/FI_RT.out -dT 0.01 -ele 1020106 1030106 1040106 section fiber 2 damage;

}

if {$addDetailedRecorders == 1} {

	# Recorders for beam fracture index
	# Left-bottom flange
	recorder Element -file $outdir/ss_LB.out -dT 0.01 -ele 1020105 1030105 1040105 section fiber 7 stressStrain;

	# Left-top flange
	recorder Element -file $outdir/ss_LT.out -dT 0.01 -ele 1020105 1030105 1040105 section fiber 2 stressStrain;

	# Right-bottom flange
	recorder Element -file $outdir/ss_RB.out -dT 0.01 -ele 1020106 1030106 1040106 section fiber 7 stressStrain;

	# Right-top flange
	recorder Element -file $outdir/ss_RT.out -dT 0.01 -ele 1020106 1030106 1040106 section fiber 2 stressStrain;

	# Recorders for slab fiber stressStrain

	# Left-Concrete
	recorder Element -file $outdir/slabComp_L.out -dT 0.01 -ele 1020105 1030105 1040105 section fiber 10 stressStrain;

	# Left-Steel
	recorder Element -file $outdir/slabTen_L.out -dT 0.01 -ele 1020105 1030105 1040105 section fiber 11 stressStrain;

	# Right-Concrete
	recorder Element -file $outdir/slabComp_R.out -dT 0.01 -ele 1020106 1030106 1040106 section fiber 10 stressStrain;

	# Right-Steel
	recorder Element -file $outdir/slabTen_R.out -dT 0.01 -ele 1020106 1030106 1040106 section fiber 11 stressStrain;

	# Recorders for web fibers

	# Left-web1
	recorder Element -file $outdir/webfiber_L1.out -dT 0.01 -ele 1020105 1030105 1040105 section fiber 12 stressStrain;

	# Left-web2
	recorder Element -file $outdir/webfiber_L2.out -dT 0.01 -ele 1020105 1030105 1040105 section fiber 13 stressStrain;

	# Left-web3
	recorder Element -file $outdir/webfiber_L3.out -dT 0.01 -ele 1020105 1030105 1040105 section fiber 14 stressStrain;


	# Left-web4
	recorder Element -file $outdir/webfiber_L4.out -dT 0.01 -ele 1020105 1030105 1040105 section fiber 15 stressStrain;


	# Right-web1
	recorder Element -file $outdir/webfiber_R1.out -dT 0.01 -ele 1020106 1030106 1040106 section fiber 12 stressStrain;

	# Right-web2
	recorder Element -file $outdir/webfiber_R2.out -dT 0.01 -ele 1020106 1030106 1040106 section fiber 13 stressStrain;

	# Right-web3
	recorder Element -file $outdir/webfiber_R3.out -dT 0.01 -ele 1020106 1030106 1040106 section fiber 14 stressStrain;


	# Right-web4
	recorder Element -file $outdir/webfiber_R4.out -dT 0.01 -ele 1020106 1030106 1040106 section fiber 15 stressStrain;

	# Recorders beam fiber-section element

	# Left
	recorder Element -file $outdir/def_left.out -dT 0.01 -ele 1020105 1030105 1040105 section deformation;

	# Right
	recorder Element -file $outdir/def_right.out -dT 0.01 -ele 1020106 1030106 1040106 section deformation;

}

if {$addBasicRecorders == 1} {

	# Recorders beam hinge element

	# Left
	recorder Element -file $outdir/hinge_left.out -dT 0.01 -ele 1020102 1030102 1040102 deformation;

	# Right
	recorder Element -file $outdir/hinge_right.out -dT 0.01 -ele 1020104 1030104 1040104 deformation;
}

if {$addDetailedRecorders == 1} {

	recorder Element -file $outdir/hinge_right_force.out -dT 0.01 -ele 1020104 1030104 1040104 force;

	recorder Element -file $outdir/hinge_left_force.out -dT 0.01 -ele 1020102 1030102 1040102 force;
}

if {$addDetailedRecorders == 1} {

	# Recorders for beam internal forces
	recorder Element -file $outdir/beam_forces.out -dT 0.01 -ele 1020100 1030100 1040100 globalForce;

}

if {$addDetailedRecorders == 1} {

	# Recorders for column internal forces
	recorder Element -file $outdir/column_forces.out -dT 0.01 -ele 2010100 2020100 2030100 2010200 2020200 2030200 globalForce;

}

if {$addBasicRecorders == 1} {

	# Recorders column hinges
	# Bottom
	recorder Element -file $outdir/hinge_bot.out -dT 0.01 -ele 2010101 2020101 2030101 2010201 2020201 2030201 deformation;
	# Top
	recorder Element -file $outdir/hinge_top.out -dT 0.01 -ele 2010102 2020102 2030102 2010202 2020202 2030202 deformation;
}

if {$addDetailedRecorders == 1} {

	# Bottom
	recorder Element -file $outdir/hinge_bot_force.out -dT 0.01 -ele 2010101 2020101 2030101 2010201 2020201 2030201 force;
	# Top
	recorder Element -file $outdir/hinge_top_force.out -dT 0.01 -ele 2010102 2020102 2030102 2010202 2020202 2030202 force;
}

if {$addBasicRecorders == 1} {

	# Recorders panel zone elements
	recorder Element -file $outdir/pz_rot.out -dT 0.01 -ele 9010100 9010200 9020100 9020200 9030100 9030200 9040100 9040200 deformation;
}

if {$addDetailedRecorders == 1} {

	recorder Element -file $outdir/pz_M.out -dT 0.01 -ele 9010100 9010200 9020100 9020200 9030100 9030200 9040100 9040200 force;
}

