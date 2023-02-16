####################################################################################################
####################################################################################################
#                                        4-story MRF Building
####################################################################################################
####################################################################################################

####### MODEL FEATURES #######;
# UNITS:                     kip, in
# Generation:                Pre_Northridge
# Composite beams:           True
# Fracturing fiber sections: False
# Gravity system stiffness:  False
# Column splices included:   False
# Rigid diaphragm:           False
# Plastic hinge type:        PN
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
set addDetailedRecorders 0

# FRAME CENTERLINE DIMENSIONS
set num_stories  4;
set NBay  4;

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
set bslab       120.000;
set AslabSteel  5.000;
# compBackboneFactors {MpP/Mp MpN/Mp Mc/MpP Mc/MpN Mr/MpP Mr/MpN D_P D_N theta_p_P_comp theta_p_N_comp theta_pc_P_comp theta_pc_P_comp};
set compBackboneFactors {1.350 1.250 1.300 1.050 0.300 0.200 1.150 1.000 1.800 0.950 1.350 0.950};
# slabFiberMaterials {fc epsc0 epsU fy degrad};
set slabFiberMaterials {-3.000 -0.002 -0.010 60.000 -0.100};

# DEGRADATION IN PLASTIC HINGEs
set degradation 0;
set c 0.000; # Exponent for degradation in plastic hinges

####################################################################################################
#                                          PRE-CALCULATIONS                                        #
####################################################################################################

# FRAME GRID LINES
set Floor1 0.0;
set Floor2  156.00;
set Floor3  312.00;
set Floor4  468.00;
set Floor5  624.00;

set Axis1 0.0;
set Axis2 300.00;
set Axis3 600.00;
set Axis4 900.00;
set Axis5 1200.00;

set HBuilding 624.00;
set WFrame 1200.00;

####################################################################################################
#                                                  NODES                                           #
####################################################################################################

# COMMAND SYNTAX 
# node $NodeID  $X-Coordinate  $Y-Coordinate;

# SUPPORT NODES
node 10100   $Axis1  $Floor1;
node 10200   $Axis2  $Floor1;
node 10300   $Axis3  $Floor1;
node 10400   $Axis4  $Floor1;
node 10500   $Axis5  $Floor1;


#LEANING COLUMN NODES
#column lower node label: story_i*10000+(axisNum+1)*100 + 2;
#column upper node label: story_i*10000+(axisNum+1)*100 + 4;
node 10602 1500.000    0.000;
node 10604 1500.000  156.000;
node 20602 1500.000  156.000;
node 20604 1500.000  312.000;
node 30602 1500.000  312.000;
node 30604 1500.000  468.000;
node 40602 1500.000  468.000;
node 40604 1500.000  624.000;

#Pin the nodes for leaning column, floor 2
equalDOF 20602 10604 1 2;

#Pin the nodes for leaning column, floor 3
equalDOF 30602 20604 1 2;

#Pin the nodes for leaning column, floor 4
equalDOF 40602 30604 1 2;
###################################################################################################
#                                  PANEL ZONE NODES & ELEMENTS                                    #
###################################################################################################

# PANEL ZONE NODES AND ELASTIC ELEMENTS
# Command Syntax; 
# ConstructPanel_Rectangle Axis Floor X_Axis Y_Floor E A_Panel I_Panel d_Col d_Beam transfTag 

# Panel zones floor2
ConstructPanel_Rectangle  1 2 $Axis1 $Floor2 $Es $A_Stiff $I_Stiff 14.80 24.10 $trans_selected;
ConstructPanel_Rectangle  2 2 $Axis2 $Floor2 $Es $A_Stiff $I_Stiff 14.80 24.10 $trans_selected;
ConstructPanel_Rectangle  3 2 $Axis3 $Floor2 $Es $A_Stiff $I_Stiff 14.80 24.10 $trans_selected;
ConstructPanel_Rectangle  4 2 $Axis4 $Floor2 $Es $A_Stiff $I_Stiff 14.80 24.10 $trans_selected;
ConstructPanel_Rectangle  5 2 $Axis5 $Floor2 $Es $A_Stiff $I_Stiff 14.80 24.10 $trans_selected;

# Panel zones floor3
ConstructPanel_Rectangle  1 3 $Axis1 $Floor3 $Es $A_Stiff $I_Stiff 14.80 24.10 $trans_selected;
ConstructPanel_Rectangle  2 3 $Axis2 $Floor3 $Es $A_Stiff $I_Stiff 14.80 24.10 $trans_selected;
ConstructPanel_Rectangle  3 3 $Axis3 $Floor3 $Es $A_Stiff $I_Stiff 14.80 24.10 $trans_selected;
ConstructPanel_Rectangle  4 3 $Axis4 $Floor3 $Es $A_Stiff $I_Stiff 14.80 24.10 $trans_selected;
ConstructPanel_Rectangle  5 3 $Axis5 $Floor3 $Es $A_Stiff $I_Stiff 14.80 24.10 $trans_selected;

# Panel zones floor4
ConstructPanel_Rectangle  1 4 $Axis1 $Floor4 $Es $A_Stiff $I_Stiff 14.70 23.70 $trans_selected;
ConstructPanel_Rectangle  2 4 $Axis2 $Floor4 $Es $A_Stiff $I_Stiff 14.70 23.70 $trans_selected;
ConstructPanel_Rectangle  3 4 $Axis3 $Floor4 $Es $A_Stiff $I_Stiff 14.70 23.70 $trans_selected;
ConstructPanel_Rectangle  4 4 $Axis4 $Floor4 $Es $A_Stiff $I_Stiff 14.70 23.70 $trans_selected;
ConstructPanel_Rectangle  5 4 $Axis5 $Floor4 $Es $A_Stiff $I_Stiff 14.70 23.70 $trans_selected;

# Panel zones floor5
ConstructPanel_Rectangle  1 5 $Axis1 $Floor5 $Es $A_Stiff $I_Stiff 14.70 23.70 $trans_selected;
ConstructPanel_Rectangle  2 5 $Axis2 $Floor5 $Es $A_Stiff $I_Stiff 14.70 23.70 $trans_selected;
ConstructPanel_Rectangle  3 5 $Axis3 $Floor5 $Es $A_Stiff $I_Stiff 14.70 23.70 $trans_selected;
ConstructPanel_Rectangle  4 5 $Axis4 $Floor5 $Es $A_Stiff $I_Stiff 14.70 23.70 $trans_selected;
ConstructPanel_Rectangle  5 5 $Axis5 $Floor5 $Es $A_Stiff $I_Stiff 14.70 23.70 $trans_selected;


####################################################################################################
#                                          PANEL ZONE SPRINGS                                      #
####################################################################################################

# COMMAND SYNTAX 
# PanelZoneSpring    eleID NodeI NodeJ Es mu Fy dc bc tcf tcw tdp db Ic Acol alpha Pr trib ts pzModelTag isExterior Composite
# Panel zones floor2
PanelZoneSpring 9020100 4020109 4020110 $Es $mu $FyCol 14.80 15.50  1.09  0.68  1.00 24.10 1710.00 42.700 $SH_PZ 68.438 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9020200 4020209 4020210 $Es $mu $FyCol 14.80 15.50  1.09  0.68  1.75 24.10 1710.00 42.700 $SH_PZ 136.875 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9020300 4020309 4020310 $Es $mu $FyCol 14.80 15.50  1.09  0.68  1.75 24.10 1710.00 42.700 $SH_PZ 136.875 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9020400 4020409 4020410 $Es $mu $FyCol 14.80 15.50  1.09  0.68  1.75 24.10 1710.00 42.700 $SH_PZ 136.875 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9020500 4020509 4020510 $Es $mu $FyCol 14.80 15.50  1.09  0.68  1.00 24.10 1710.00 42.700 $SH_PZ 68.438 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor3
PanelZoneSpring 9030100 4030109 4030110 $Es $mu $FyCol 14.80 15.50  1.09  0.68  0.00 24.10 1710.00 42.700 $SH_PZ 51.328 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9030200 4030209 4030210 $Es $mu $FyCol 14.80 15.50  1.09  0.68  1.50 24.10 1710.00 42.700 $SH_PZ 102.656 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9030300 4030309 4030310 $Es $mu $FyCol 14.80 15.50  1.09  0.68  1.50 24.10 1710.00 42.700 $SH_PZ 102.656 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9030400 4030409 4030410 $Es $mu $FyCol 14.80 15.50  1.09  0.68  1.50 24.10 1710.00 42.700 $SH_PZ 102.656 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9030500 4030509 4030510 $Es $mu $FyCol 14.80 15.50  1.09  0.68  0.00 24.10 1710.00 42.700 $SH_PZ 51.328 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor4
PanelZoneSpring 9040100 4040109 4040110 $Es $mu $FyCol 14.70 14.70  1.03  0.65  0.00 23.70 1530.00 38.800 $SH_PZ 34.219 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9040200 4040209 4040210 $Es $mu $FyCol 14.70 14.70  1.03  0.65  1.25 23.70 1530.00 38.800 $SH_PZ 68.438 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9040300 4040309 4040310 $Es $mu $FyCol 14.70 14.70  1.03  0.65  1.25 23.70 1530.00 38.800 $SH_PZ 68.438 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9040400 4040409 4040410 $Es $mu $FyCol 14.70 14.70  1.03  0.65  1.25 23.70 1530.00 38.800 $SH_PZ 68.438 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9040500 4040509 4040510 $Es $mu $FyCol 14.70 14.70  1.03  0.65  0.00 23.70 1530.00 38.800 $SH_PZ 34.219 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor5
PanelZoneSpring 9050100 4050109 4050110 $Es $mu $FyCol 14.70 14.70  1.03  0.65  0.75 23.70 1530.00 38.800 $SH_PZ 17.109 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9050200 4050209 4050210 $Es $mu $FyCol 14.70 14.70  1.03  0.65  1.25 23.70 1530.00 38.800 $SH_PZ 34.219 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9050300 4050309 4050310 $Es $mu $FyCol 14.70 14.70  1.03  0.65  1.25 23.70 1530.00 38.800 $SH_PZ 34.219 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9050400 4050409 4050410 $Es $mu $FyCol 14.70 14.70  1.03  0.65  1.25 23.70 1530.00 38.800 $SH_PZ 34.219 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9050500 4050509 4050510 $Es $mu $FyCol 14.70 14.70  1.03  0.65  0.75 23.70 1530.00 38.800 $SH_PZ 17.109 $trib $tslab $pzModelTag 1 $Composite;


####################################################################################################
#                                             BEAM ELEMENTS                                        #
####################################################################################################

# COMMAND SYNTAX 
# secInfo  Zp, Mc/Mp, Mr/Mp, theta_p, theta_pc, theta_u, lambda
# hingeBeamColumn  ElementID node_i node_j eleDir, ... A, Ieff

# Beams at floor 2 bay 1
set secInfo_i {224.0000   1.0830   0.2000   0.0126   0.0009   0.0183   0.0000};
set secInfo_j {224.0000   1.0830   0.2000   0.0157   0.0012   0.0228   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1020100 4020104 4020202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 24.700 [expr 2270.983*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 2 bay 2
set secInfo_i {224.0000   1.0830   0.2000   0.0157   0.0012   0.0228   0.0000};
set secInfo_j {224.0000   1.0830   0.2000   0.0157   0.0012   0.0228   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1020200 4020204 4020302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 24.700 [expr 2270.983*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 2 bay 3
set secInfo_i {224.0000   1.0830   0.2000   0.0157   0.0012   0.0228   0.0000};
set secInfo_j {224.0000   1.0830   0.2000   0.0157   0.0012   0.0228   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1020300 4020304 4020402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 24.700 [expr 2270.983*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 2 bay 4
set secInfo_i {224.0000   1.0830   0.2000   0.0157   0.0012   0.0228   0.0000};
set secInfo_j {224.0000   1.0830   0.2000   0.0126   0.0009   0.0183   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1020400 4020404 4020502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 24.700 [expr 2270.983*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 3 bay 1
set secInfo_i {224.0000   1.0830   0.2000   0.0126   0.0009   0.0183   0.0000};
set secInfo_j {224.0000   1.0830   0.2000   0.0157   0.0012   0.0228   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1030100 4030104 4030202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 24.700 [expr 2270.983*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 3 bay 2
set secInfo_i {224.0000   1.0830   0.2000   0.0157   0.0012   0.0228   0.0000};
set secInfo_j {224.0000   1.0830   0.2000   0.0157   0.0012   0.0228   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1030200 4030204 4030302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 24.700 [expr 2270.983*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 3 bay 3
set secInfo_i {224.0000   1.0830   0.2000   0.0157   0.0012   0.0228   0.0000};
set secInfo_j {224.0000   1.0830   0.2000   0.0157   0.0012   0.0228   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1030300 4030304 4030402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 24.700 [expr 2270.983*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 3 bay 4
set secInfo_i {224.0000   1.0830   0.2000   0.0157   0.0012   0.0228   0.0000};
set secInfo_j {224.0000   1.0830   0.2000   0.0126   0.0009   0.0183   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1030400 4030404 4030502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 24.700 [expr 2270.983*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 4 bay 1
set secInfo_i {153.0000   1.0828   0.2000   0.0162   0.0011   0.0230   0.0000};
set secInfo_j {153.0000   1.0828   0.2000   0.0129   0.0009   0.0184   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1040100 4040104 4040202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 18.200 [expr 1508.316*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 4 bay 2
set secInfo_i {153.0000   1.0828   0.2000   0.0129   0.0009   0.0184   0.0000};
set secInfo_j {153.0000   1.0828   0.2000   0.0129   0.0009   0.0184   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1040200 4040204 4040302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 18.200 [expr 1508.316*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 4 bay 3
set secInfo_i {153.0000   1.0828   0.2000   0.0129   0.0009   0.0184   0.0000};
set secInfo_j {153.0000   1.0828   0.2000   0.0129   0.0009   0.0184   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1040300 4040304 4040402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 18.200 [expr 1508.316*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 4 bay 4
set secInfo_i {153.0000   1.0828   0.2000   0.0129   0.0009   0.0184   0.0000};
set secInfo_j {153.0000   1.0828   0.2000   0.0162   0.0011   0.0230   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1040400 4040404 4040502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 18.200 [expr 1508.316*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 5 bay 1
set secInfo_i {153.0000   1.0828   0.2000   0.0129   0.0009   0.0184   0.0000};
set secInfo_j {153.0000   1.0828   0.2000   0.0129   0.0009   0.0184   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1050100 4050104 4050202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 18.200 [expr 1508.316*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 5 bay 2
set secInfo_i {153.0000   1.0828   0.2000   0.0129   0.0009   0.0184   0.0000};
set secInfo_j {153.0000   1.0828   0.2000   0.0129   0.0009   0.0184   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1050200 4050204 4050302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 18.200 [expr 1508.316*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 5 bay 3
set secInfo_i {153.0000   1.0828   0.2000   0.0129   0.0009   0.0184   0.0000};
set secInfo_j {153.0000   1.0828   0.2000   0.0129   0.0009   0.0184   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1050300 4050304 4050402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 18.200 [expr 1508.316*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 5 bay 4
set secInfo_i {153.0000   1.0828   0.2000   0.0129   0.0009   0.0184   0.0000};
set secInfo_j {153.0000   1.0828   0.2000   0.0129   0.0009   0.0184   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1050400 4050404 4050502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 18.200 [expr 1508.316*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

####################################################################################################
#                                            COLUMNS ELEMENTS                                      #
####################################################################################################

# COMMAND SYNTAX 
# secInfo  Zp, Mc/Mp, Mr/Mp, theta_p, theta_pc, theta_u, lambda
# spliceSecGeometry  min(d_i, d_j), min(bf_i, bf_j), min(tf_i, tf_j), min(tw_i, tw_j)
# (splice)    hingeBeamColumnSplice  ElementID node_i node_j eleDir, ... A, Ieff, ... 
# (no splice) hingeBeamColumn        ElementID node_i node_j eleDir, ... A, Ieff

# Columns at story 1 axis 1
set secInfo_i {250.5292   1.1988   0.8672   0.0397   0.0420   0.0957   0.0000};
set secInfo_j {250.5292   1.1988   0.8672   0.0397   0.0420   0.0957   0.0000};
hingeBeamColumn 2010100 10100 4020101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 42.700 1521.412 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 1
set secInfo_i {252.8969   1.2194   0.8754   0.0414   0.0442   0.1004   0.0000};
set secInfo_j {252.8969   1.2194   0.8754   0.0414   0.0442   0.1004   0.0000};
hingeBeamColumn 2020100 4020103 4030101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 42.700 1489.034 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 3 axis 1
set secInfo_i {229.3098   1.2091   0.8820   0.0398   0.0425   0.0965   0.0000};
set secInfo_j {229.3098   1.2091   0.8820   0.0398   0.0425   0.0965   0.0000};
hingeBeamColumn 2030100 4030103 4040101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 38.800 1341.808 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 1
set secInfo_i {231.6549   1.2118   0.8910   0.0408   0.0436   0.0989   0.0000};
set secInfo_j {231.6549   1.2118   0.8910   0.0408   0.0436   0.0989   0.0000};
hingeBeamColumn 2040100 4040103 4050101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 38.800 1342.321 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 2
set secInfo_i {241.0584   1.1884   0.8344   0.0362   0.0382   0.0871   0.0000};
set secInfo_j {241.0584   1.1884   0.8344   0.0362   0.0382   0.0871   0.0000};
hingeBeamColumn 2010200 10200 4020201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 42.700 1521.412 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 2
set secInfo_i {245.7938   1.2109   0.8508   0.0387   0.0412   0.0936   0.0000};
set secInfo_j {245.7938   1.2109   0.8508   0.0387   0.0412   0.0936   0.0000};
hingeBeamColumn 2020200 4020203 4030201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 42.700 1489.034 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 3 axis 2
set secInfo_i {224.6195   1.2031   0.8639   0.0379   0.0404   0.0917   0.0000};
set secInfo_j {224.6195   1.2031   0.8639   0.0379   0.0404   0.0917   0.0000};
hingeBeamColumn 2030200 4030203 4040201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 38.800 1341.808 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 2
set secInfo_i {229.3098   1.2088   0.8820   0.0398   0.0425   0.0965   0.0000};
set secInfo_j {229.3098   1.2088   0.8820   0.0398   0.0425   0.0965   0.0000};
hingeBeamColumn 2040200 4040203 4050201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 38.800 1342.321 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 3
set secInfo_i {241.0584   1.1884   0.8344   0.0362   0.0382   0.0871   0.0000};
set secInfo_j {241.0584   1.1884   0.8344   0.0362   0.0382   0.0871   0.0000};
hingeBeamColumn 2010300 10300 4020301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 42.700 1521.412 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 3
set secInfo_i {245.7938   1.2109   0.8508   0.0387   0.0412   0.0936   0.0000};
set secInfo_j {245.7938   1.2109   0.8508   0.0387   0.0412   0.0936   0.0000};
hingeBeamColumn 2020300 4020303 4030301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 42.700 1489.034 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 3 axis 3
set secInfo_i {224.6195   1.2031   0.8639   0.0379   0.0404   0.0917   0.0000};
set secInfo_j {224.6195   1.2031   0.8639   0.0379   0.0404   0.0917   0.0000};
hingeBeamColumn 2030300 4030303 4040301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 38.800 1341.808 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 3
set secInfo_i {229.3098   1.2088   0.8820   0.0398   0.0425   0.0965   0.0000};
set secInfo_j {229.3098   1.2088   0.8820   0.0398   0.0425   0.0965   0.0000};
hingeBeamColumn 2040300 4040303 4050301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 38.800 1342.321 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 4
set secInfo_i {241.0584   1.1884   0.8344   0.0362   0.0382   0.0871   0.0000};
set secInfo_j {241.0584   1.1884   0.8344   0.0362   0.0382   0.0871   0.0000};
hingeBeamColumn 2010400 10400 4020401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 42.700 1521.412 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 4
set secInfo_i {245.7938   1.2109   0.8508   0.0387   0.0412   0.0936   0.0000};
set secInfo_j {245.7938   1.2109   0.8508   0.0387   0.0412   0.0936   0.0000};
hingeBeamColumn 2020400 4020403 4030401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 42.700 1489.034 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 3 axis 4
set secInfo_i {224.6195   1.2031   0.8639   0.0379   0.0404   0.0917   0.0000};
set secInfo_j {224.6195   1.2031   0.8639   0.0379   0.0404   0.0917   0.0000};
hingeBeamColumn 2030400 4030403 4040401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 38.800 1341.808 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 4
set secInfo_i {229.3098   1.2088   0.8820   0.0398   0.0425   0.0965   0.0000};
set secInfo_j {229.3098   1.2088   0.8820   0.0398   0.0425   0.0965   0.0000};
hingeBeamColumn 2040400 4040403 4050401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 38.800 1342.321 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 5
set secInfo_i {250.5292   1.1988   0.8672   0.0397   0.0420   0.0957   0.0000};
set secInfo_j {250.5292   1.1988   0.8672   0.0397   0.0420   0.0957   0.0000};
hingeBeamColumn 2010500 10500 4020501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 42.700 1521.412 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 5
set secInfo_i {252.8969   1.2194   0.8754   0.0414   0.0442   0.1004   0.0000};
set secInfo_j {252.8969   1.2194   0.8754   0.0414   0.0442   0.1004   0.0000};
hingeBeamColumn 2020500 4020503 4030501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 42.700 1489.034 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 3 axis 5
set secInfo_i {229.3098   1.2091   0.8820   0.0398   0.0425   0.0965   0.0000};
set secInfo_j {229.3098   1.2091   0.8820   0.0398   0.0425   0.0965   0.0000};
hingeBeamColumn 2030500 4030503 4040501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 38.800 1341.808 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 5
set secInfo_i {231.6549   1.2118   0.8910   0.0408   0.0436   0.0989   0.0000};
set secInfo_j {231.6549   1.2118   0.8910   0.0408   0.0436   0.0989   0.0000};
hingeBeamColumn 2040500 4040503 4050501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 38.800 1342.321 $degradation $c $secInfo_i $secInfo_j 0 0;

####################################################################################################
#                                              FLOOR LINKS                                         #
####################################################################################################

# Command Syntax 
# element truss $ElementID $iNode $jNode $Area $matID
element truss 1005 4050504 40604 $A_Stiff $rigMatTag;
element truss 1004 4040504 30604 $A_Stiff $rigMatTag;
element truss 1003 4030504 20604 $A_Stiff $rigMatTag;
element truss 1002 4020504 10604 $A_Stiff $rigMatTag;

####################################################################################################
#                                          EGF COLUMNS AND BEAMS                                   #
####################################################################################################

# LEANING COLUMN
element elasticBeamColumn 2010600 10602 10604 $A_Stiff $Es $I_Stiff $trans_selected;
element elasticBeamColumn 2020600 20602 20604 $A_Stiff $Es $I_Stiff $trans_selected;
element elasticBeamColumn 2030600 30602 30604 $A_Stiff $Es $I_Stiff $trans_selected;
element elasticBeamColumn 2040600 40602 40604 $A_Stiff $Es $I_Stiff $trans_selected;
###################################################################################################
#                                       BOUNDARY CONDITIONS                                       #
###################################################################################################

# FRAME BASE SUPPORTS
fix 10100 1 1 1;
fix 10200 1 1 1;
fix 10300 1 1 1;
fix 10400 1 1 1;
fix 10500 1 1 1;

# LEANING COLUMN SUPPORT
fix 10602 1 1 0;
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
mass 4020103 0.0443  0.0004 3.3235;
mass 4020203 0.0886  0.0009 6.6470;
mass 4020303 0.0886  0.0009 6.6470;
mass 4020403 0.0886  0.0009 6.6470;
mass 4020503 0.0443  0.0004 3.3235;
# Panel zones floor3
mass 4030103 0.0443  0.0004 3.3235;
mass 4030203 0.0886  0.0009 6.6470;
mass 4030303 0.0886  0.0009 6.6470;
mass 4030403 0.0886  0.0009 6.6470;
mass 4030503 0.0443  0.0004 3.3235;
# Panel zones floor4
mass 4040103 0.0443  0.0004 3.3235;
mass 4040203 0.0886  0.0009 6.6470;
mass 4040303 0.0886  0.0009 6.6470;
mass 4040403 0.0886  0.0009 6.6470;
mass 4040503 0.0443  0.0004 3.3235;
# Panel zones floor5
mass 4050103 0.0443  0.0004 3.3235;
mass 4050203 0.0886  0.0009 6.6470;
mass 4050303 0.0886  0.0009 6.6470;
mass 4050403 0.0886  0.0009 6.6470;
mass 4050503 0.0443  0.0004 3.3235;

# MASS ON THE GRAVITY SYSTEM

mass 10604 1.0635  0.0106 79.7640;
mass 20604 1.0635  0.0106 79.7640;
mass 30604 1.0635  0.0106 79.7640;
mass 40604 1.0635  0.0106 79.7640;

###################################################################################################
#                                            GRAVITY LOAD                                         #
###################################################################################################

pattern Plain 101 Linear {

	# MR Frame: Distributed beam element loads
	# Floor 2
	# Floor 3
	# Floor 4
	# Floor 5

	#  MR Frame: Point loads on columns
	# Floor2
	load 4020103 0.0 -17.1094 0.0;
	load 4020203 0.0 -34.2188 0.0;
	load 4020303 0.0 -34.2188 0.0;
	load 4020403 0.0 -34.2188 0.0;
	load 4020503 0.0 -17.1094 0.0;
	# Floor3
	load 4030103 0.0 -17.1094 0.0;
	load 4030203 0.0 -34.2188 0.0;
	load 4030303 0.0 -34.2188 0.0;
	load 4030403 0.0 -34.2188 0.0;
	load 4030503 0.0 -17.1094 0.0;
	# Floor4
	load 4040103 0.0 -17.1094 0.0;
	load 4040203 0.0 -34.2188 0.0;
	load 4040303 0.0 -34.2188 0.0;
	load 4040403 0.0 -34.2188 0.0;
	load 4040503 0.0 -17.1094 0.0;
	# Floor5
	load 4050103 0.0 -17.1094 0.0;
	load 4050203 0.0 -34.2188 0.0;
	load 4050303 0.0 -34.2188 0.0;
	load 4050403 0.0 -34.2188 0.0;
	load 4050503 0.0 -17.1094 0.0;

	#  Gravity Frame: Point loads on columns
	load 10604 0.0 -410.6250 0.0;
	load 20604 0.0 -410.6250 0.0;
	load 30604 0.0 -410.6250 0.0;
	load 40604 0.0 -410.6250 0.0;

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
	10500
	4020503
	4030503
	4040503
	4050503
};

set hVector {
	156
	156
	156
	156
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
region 1 -ele 1020100 1020200 1020300 1020400 1030100 1030200 1030300 1030400 1040100 1040200 1040300 1040400 1050100 1050200 1050300 1050400 -rayleigh 0.0 0.0 $a1_mod 0.0;

# Column elastic elements
region 2 -ele 2010100 2020100 2030100 2040100 2010200 2020200 2030200 2040200 2010300 2020300 2030300 2040300 2010400 2020400 2030400 2040400 2010500 2020500 2030500 2040500 -rayleigh 0.0 0.0 $a1_mod 0.0;

# Hinge elements [beam springs, column springs]
region 3 -ele 1020101 1020102 1020201 1020202 1020301 1020302 1020401 1020402 1030101 1030102 1030201 1030202 1030301 1030302 1030401 1030402 1040101 1040102 1040201 1040202 1040301 1040302 1040401 1040402 1050101 1050102 1050201 1050202 1050301 1050302 1050401 1050402 2010101 2010102 2020101 2020102 2030101 2030102 2040101 2040102 2010201 2010202 2020201 2020202 2030201 2030202 2040201 2040202 2010301 2010302 2020301 2020302 2030301 2030302 2040301 2040302 2010401 2010402 2020401 2020402 2030401 2030402 2040401 2040402 2010501 2010502 2020501 2020502 2030501 2030502 2040501 2040502 -rayleigh 0.0 0.0 [expr $a1_mod/$n] 0.0;

# Nodes with mass
region 4 -nodes 4020103 4020203 4020303 4020403 4020503 4030103 4030203 4030303 4030403 4030503 4040103 4040203 4040303 4040403 4040503 4050103 4050203 4050303 4050403 4050503 -rayleigh $a0 0.0 0.0 0.0;

###################################################################################################
#                                     DETAILED RECORDERS                                          #
###################################################################################################

if {$addBasicRecorders == 1} {

	# Recorders for lateral displacement on each panel zone
	recorder Node -file $outdir/all_disp.out -dT 0.01 -time -nodes 4020103 4020203 4020303 4020403 4020503 4030103 4030203 4030303 4030403 4030503 4040103 4040203 4040303 4040403 4040503 4050103 4050203 4050303 4050403 4050503 -dof 1 disp;

}

if {$addBasicRecorders == 1} {

	# Recorders beam hinge element

	# Left
	recorder Element -file $outdir/hinge_left.out -dT 0.01 -ele 1020101 1020201 1020301 1020401 1030101 1030201 1030301 1030401 1040101 1040201 1040301 1040401 1050101 1050201 1050301 1050401 deformation;

	# Right
	recorder Element -file $outdir/hinge_right.out -dT 0.01 -ele 1020102 1020202 1020302 1020402 1030102 1030202 1030302 1030402 1040102 1040202 1040302 1040402 1050102 1050202 1050302 1050402 deformation;
}

if {$addDetailedRecorders == 1} {

	recorder Element -file $outdir/hinge_right_force.out -dT 0.01 -ele 1020102 1020202 1020302 1020402 1030102 1030202 1030302 1030402 1040102 1040202 1040302 1040402 1050102 1050202 1050302 1050402 force;

	recorder Element -file $outdir/hinge_left_force.out -dT 0.01 -ele 1020101 1020201 1020301 1020401 1030101 1030201 1030301 1030401 1040101 1040201 1040301 1040401 1050101 1050201 1050301 1050401 force;
}

if {$addDetailedRecorders == 1} {

	# Recorders for beam internal forces
	recorder Element -file $outdir/beam_forces.out -dT 0.01 -ele 1020100 1020200 1020300 1020400 1030100 1030200 1030300 1030400 1040100 1040200 1040300 1040400 1050100 1050200 1050300 1050400 globalForce;

}

if {$addDetailedRecorders == 1} {

	# Recorders for column internal forces
	recorder Element -file $outdir/column_forces.out -dT 0.01 -ele 2010100 2020100 2030100 2040100 2010200 2020200 2030200 2040200 2010300 2020300 2030300 2040300 2010400 2020400 2030400 2040400 2010500 2020500 2030500 2040500 globalForce;

}

if {$addBasicRecorders == 1} {

	# Recorders column hinges
	# Bottom
	recorder Element -file $outdir/hinge_bot.out -dT 0.01 -ele 2010101 2020101 2030101 2040101 2010201 2020201 2030201 2040201 2010301 2020301 2030301 2040301 2010401 2020401 2030401 2040401 2010501 2020501 2030501 2040501 deformation;
	# Top
	recorder Element -file $outdir/hinge_top.out -dT 0.01 -ele 2010102 2020102 2030102 2040102 2010202 2020202 2030202 2040202 2010302 2020302 2030302 2040302 2010402 2020402 2030402 2040402 2010502 2020502 2030502 2040502 deformation;
}

if {$addDetailedRecorders == 1} {

	# Bottom
	recorder Element -file $outdir/hinge_bot_force.out -dT 0.01 -ele 2010101 2020101 2030101 2040101 2010201 2020201 2030201 2040201 2010301 2020301 2030301 2040301 2010401 2020401 2030401 2040401 2010501 2020501 2030501 2040501 force;
	# Top
	recorder Element -file $outdir/hinge_top_force.out -dT 0.01 -ele 2010102 2020102 2030102 2040102 2010202 2020202 2030202 2040202 2010302 2020302 2030302 2040302 2010402 2020402 2030402 2040402 2010502 2020502 2030502 2040502 force;
}

if {$addBasicRecorders == 1} {

	# Recorders panel zone elements
	recorder Element -file $outdir/pz_rot.out -dT 0.01 -ele 9010100 9010200 9010300 9010400 9010500 9020100 9020200 9020300 9020400 9020500 9030100 9030200 9030300 9030400 9030500 9040100 9040200 9040300 9040400 9040500 9050100 9050200 9050300 9050400 9050500 deformation;
}

if {$addDetailedRecorders == 1} {

	recorder Element -file $outdir/pz_M.out -dT 0.01 -ele 9010100 9010200 9010300 9010400 9010500 9020100 9020200 9020300 9020400 9020500 9030100 9030200 9030300 9030400 9030500 9040100 9040200 9040300 9040400 9040500 9050100 9050200 9050300 9050400 9050500 force;
}

