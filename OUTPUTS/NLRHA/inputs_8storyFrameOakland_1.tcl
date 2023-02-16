####################################################################################################
####################################################################################################
#                                        8-story MRF Building
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
set num_stories  8;
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
set Floor6  780.00;
set Floor7  936.00;
set Floor8  1092.00;
set Floor9  1248.00;

set Axis1 0.0;
set Axis2 300.00;
set Axis3 600.00;
set Axis4 900.00;
set Axis5 1200.00;

set HBuilding 1248.00;
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
node 50602 1500.000  624.000;
node 50604 1500.000  780.000;
node 60602 1500.000  780.000;
node 60604 1500.000  936.000;
node 70602 1500.000  936.000;
node 70604 1500.000 1092.000;
node 80602 1500.000 1092.000;
node 80604 1500.000 1248.000;

#Pin the nodes for leaning column, floor 2
equalDOF 20602 10604 1 2;

#Pin the nodes for leaning column, floor 3
equalDOF 30602 20604 1 2;

#Pin the nodes for leaning column, floor 4
equalDOF 40602 30604 1 2;

#Pin the nodes for leaning column, floor 5
equalDOF 50602 40604 1 2;

#Pin the nodes for leaning column, floor 6
equalDOF 60602 50604 1 2;

#Pin the nodes for leaning column, floor 7
equalDOF 70602 60604 1 2;

#Pin the nodes for leaning column, floor 8
equalDOF 80602 70604 1 2;
###################################################################################################
#                                  PANEL ZONE NODES & ELEMENTS                                    #
###################################################################################################

# PANEL ZONE NODES AND ELASTIC ELEMENTS
# Command Syntax; 
# ConstructPanel_Rectangle Axis Floor X_Axis Y_Floor E A_Panel I_Panel d_Col d_Beam transfTag 

# Panel zones floor2
ConstructPanel_Rectangle  1 2 $Axis1 $Floor2 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;
ConstructPanel_Rectangle  2 2 $Axis2 $Floor2 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;
ConstructPanel_Rectangle  3 2 $Axis3 $Floor2 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;
ConstructPanel_Rectangle  4 2 $Axis4 $Floor2 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;
ConstructPanel_Rectangle  5 2 $Axis5 $Floor2 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;

# Panel zones floor3
ConstructPanel_Rectangle  1 3 $Axis1 $Floor3 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;
ConstructPanel_Rectangle  2 3 $Axis2 $Floor3 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;
ConstructPanel_Rectangle  3 3 $Axis3 $Floor3 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;
ConstructPanel_Rectangle  4 3 $Axis4 $Floor3 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;
ConstructPanel_Rectangle  5 3 $Axis5 $Floor3 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;

# Panel zones floor4
ConstructPanel_Rectangle  1 4 $Axis1 $Floor4 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;
ConstructPanel_Rectangle  2 4 $Axis2 $Floor4 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;
ConstructPanel_Rectangle  3 4 $Axis3 $Floor4 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;
ConstructPanel_Rectangle  4 4 $Axis4 $Floor4 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;
ConstructPanel_Rectangle  5 4 $Axis5 $Floor4 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;

# Panel zones floor5
ConstructPanel_Rectangle  1 5 $Axis1 $Floor5 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;
ConstructPanel_Rectangle  2 5 $Axis2 $Floor5 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;
ConstructPanel_Rectangle  3 5 $Axis3 $Floor5 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;
ConstructPanel_Rectangle  4 5 $Axis4 $Floor5 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;
ConstructPanel_Rectangle  5 5 $Axis5 $Floor5 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;

# Panel zones floor6
ConstructPanel_Rectangle  1 6 $Axis1 $Floor6 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;
ConstructPanel_Rectangle  2 6 $Axis2 $Floor6 $Es $A_Stiff $I_Stiff 15.20 26.90 $trans_selected;
ConstructPanel_Rectangle  3 6 $Axis3 $Floor6 $Es $A_Stiff $I_Stiff 15.20 26.90 $trans_selected;
ConstructPanel_Rectangle  4 6 $Axis4 $Floor6 $Es $A_Stiff $I_Stiff 15.20 26.90 $trans_selected;
ConstructPanel_Rectangle  5 6 $Axis5 $Floor6 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;

# Panel zones floor7
ConstructPanel_Rectangle  1 7 $Axis1 $Floor7 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;
ConstructPanel_Rectangle  2 7 $Axis2 $Floor7 $Es $A_Stiff $I_Stiff 15.20 26.90 $trans_selected;
ConstructPanel_Rectangle  3 7 $Axis3 $Floor7 $Es $A_Stiff $I_Stiff 15.20 26.90 $trans_selected;
ConstructPanel_Rectangle  4 7 $Axis4 $Floor7 $Es $A_Stiff $I_Stiff 15.20 26.90 $trans_selected;
ConstructPanel_Rectangle  5 7 $Axis5 $Floor7 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;

# Panel zones floor8
ConstructPanel_Rectangle  1 8 $Axis1 $Floor8 $Es $A_Stiff $I_Stiff 14.70 26.90 $trans_selected;
ConstructPanel_Rectangle  2 8 $Axis2 $Floor8 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;
ConstructPanel_Rectangle  3 8 $Axis3 $Floor8 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;
ConstructPanel_Rectangle  4 8 $Axis4 $Floor8 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;
ConstructPanel_Rectangle  5 8 $Axis5 $Floor8 $Es $A_Stiff $I_Stiff 14.70 26.90 $trans_selected;

# Panel zones floor9
ConstructPanel_Rectangle  1 9 $Axis1 $Floor9 $Es $A_Stiff $I_Stiff 14.70 26.90 $trans_selected;
ConstructPanel_Rectangle  2 9 $Axis2 $Floor9 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;
ConstructPanel_Rectangle  3 9 $Axis3 $Floor9 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;
ConstructPanel_Rectangle  4 9 $Axis4 $Floor9 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;
ConstructPanel_Rectangle  5 9 $Axis5 $Floor9 $Es $A_Stiff $I_Stiff 14.70 26.90 $trans_selected;


####################################################################################################
#                                          PANEL ZONE SPRINGS                                      #
####################################################################################################

# COMMAND SYNTAX 
# PanelZoneSpring    eleID NodeI NodeJ Es mu Fy dc bc tcf tcw tdp db Ic Acol alpha Pr trib ts pzModelTag isExterior Composite
# Panel zones floor2
PanelZoneSpring 9020100 4020109 4020110 $Es $mu $FyCol 15.70 15.80  1.56  0.98  1.25 27.30 2660.00 62.000 $SH_PZ 136.875 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9020200 4020209 4020210 $Es $mu $FyCol 15.70 15.80  1.56  0.98  2.25 27.30 2660.00 62.000 $SH_PZ 273.750 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9020300 4020309 4020310 $Es $mu $FyCol 15.70 15.80  1.56  0.98  2.25 27.30 2660.00 62.000 $SH_PZ 273.750 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9020400 4020409 4020410 $Es $mu $FyCol 15.70 15.80  1.56  0.98  2.25 27.30 2660.00 62.000 $SH_PZ 273.750 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9020500 4020509 4020510 $Es $mu $FyCol 15.70 15.80  1.56  0.98  1.25 27.30 2660.00 62.000 $SH_PZ 136.875 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor3
PanelZoneSpring 9030100 4030109 4030110 $Es $mu $FyCol 15.70 15.80  1.56  0.98  0.00 27.30 2660.00 62.000 $SH_PZ 119.766 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9030200 4030209 4030210 $Es $mu $FyCol 15.70 15.80  1.56  0.98  2.00 27.30 2660.00 62.000 $SH_PZ 239.531 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9030300 4030309 4030310 $Es $mu $FyCol 15.70 15.80  1.56  0.98  2.00 27.30 2660.00 62.000 $SH_PZ 239.531 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9030400 4030409 4030410 $Es $mu $FyCol 15.70 15.80  1.56  0.98  2.00 27.30 2660.00 62.000 $SH_PZ 239.531 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9030500 4030509 4030510 $Es $mu $FyCol 15.70 15.80  1.56  0.98  0.00 27.30 2660.00 62.000 $SH_PZ 119.766 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor4
PanelZoneSpring 9040100 4040109 4040110 $Es $mu $FyCol 15.50 15.70  1.44  0.89  0.00 27.10 2400.00 56.800 $SH_PZ 102.656 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9040200 4040209 4040210 $Es $mu $FyCol 15.50 15.70  1.44  0.89  1.75 27.10 2400.00 56.800 $SH_PZ 205.312 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9040300 4040309 4040310 $Es $mu $FyCol 15.50 15.70  1.44  0.89  1.75 27.10 2400.00 56.800 $SH_PZ 205.312 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9040400 4040409 4040410 $Es $mu $FyCol 15.50 15.70  1.44  0.89  1.75 27.10 2400.00 56.800 $SH_PZ 205.312 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9040500 4040509 4040510 $Es $mu $FyCol 15.50 15.70  1.44  0.89  0.00 27.10 2400.00 56.800 $SH_PZ 102.656 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor5
PanelZoneSpring 9050100 4050109 4050110 $Es $mu $FyCol 15.50 15.70  1.44  0.89  0.00 27.10 2400.00 56.800 $SH_PZ 85.547 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9050200 4050209 4050210 $Es $mu $FyCol 15.50 15.70  1.44  0.89  1.75 27.10 2400.00 56.800 $SH_PZ 171.094 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9050300 4050309 4050310 $Es $mu $FyCol 15.50 15.70  1.44  0.89  1.75 27.10 2400.00 56.800 $SH_PZ 171.094 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9050400 4050409 4050410 $Es $mu $FyCol 15.50 15.70  1.44  0.89  1.75 27.10 2400.00 56.800 $SH_PZ 171.094 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9050500 4050509 4050510 $Es $mu $FyCol 15.50 15.70  1.44  0.89  0.00 27.10 2400.00 56.800 $SH_PZ 85.547 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor6
PanelZoneSpring 9060100 4060109 4060110 $Es $mu $FyCol 15.00 15.60  1.19  0.74  0.75 26.90 1900.00 46.700 $SH_PZ 68.438 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9060200 4060209 4060210 $Es $mu $FyCol 15.20 15.70  1.31  0.83  1.75 26.90 2140.00 51.800 $SH_PZ 136.875 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9060300 4060309 4060310 $Es $mu $FyCol 15.20 15.70  1.31  0.83  1.75 26.90 2140.00 51.800 $SH_PZ 136.875 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9060400 4060409 4060410 $Es $mu $FyCol 15.20 15.70  1.31  0.83  1.75 26.90 2140.00 51.800 $SH_PZ 136.875 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9060500 4060509 4060510 $Es $mu $FyCol 15.00 15.60  1.19  0.74  0.75 26.90 1900.00 46.700 $SH_PZ 68.438 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor7
PanelZoneSpring 9070100 4070109 4070110 $Es $mu $FyCol 15.00 15.60  1.19  0.74  1.00 26.90 1900.00 46.700 $SH_PZ 51.328 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9070200 4070209 4070210 $Es $mu $FyCol 15.20 15.70  1.31  0.83  1.75 26.90 2140.00 51.800 $SH_PZ 102.656 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9070300 4070309 4070310 $Es $mu $FyCol 15.20 15.70  1.31  0.83  1.75 26.90 2140.00 51.800 $SH_PZ 102.656 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9070400 4070409 4070410 $Es $mu $FyCol 15.20 15.70  1.31  0.83  1.75 26.90 2140.00 51.800 $SH_PZ 102.656 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9070500 4070509 4070510 $Es $mu $FyCol 15.00 15.60  1.19  0.74  1.00 26.90 1900.00 46.700 $SH_PZ 51.328 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor8
PanelZoneSpring 9080100 4080109 4080110 $Es $mu $FyCol 14.70 14.70  1.03  0.65  1.00 26.90 1530.00 38.800 $SH_PZ 34.219 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9080200 4080209 4080210 $Es $mu $FyCol 15.00 15.60  1.19  0.74  1.75 26.90 1900.00 46.700 $SH_PZ 68.438 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9080300 4080309 4080310 $Es $mu $FyCol 15.00 15.60  1.19  0.74  1.75 26.90 1900.00 46.700 $SH_PZ 68.438 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9080400 4080409 4080410 $Es $mu $FyCol 15.00 15.60  1.19  0.74  1.75 26.90 1900.00 46.700 $SH_PZ 68.438 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9080500 4080509 4080510 $Es $mu $FyCol 14.70 14.70  1.03  0.65  1.00 26.90 1530.00 38.800 $SH_PZ 34.219 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor9
PanelZoneSpring 9090100 4090109 4090110 $Es $mu $FyCol 14.70 14.70  1.03  0.65  1.00 26.90 1530.00 38.800 $SH_PZ 17.109 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9090200 4090209 4090210 $Es $mu $FyCol 15.00 15.60  1.19  0.74  1.50 26.90 1900.00 46.700 $SH_PZ 34.219 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9090300 4090309 4090310 $Es $mu $FyCol 15.00 15.60  1.19  0.74  1.50 26.90 1900.00 46.700 $SH_PZ 34.219 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9090400 4090409 4090410 $Es $mu $FyCol 15.00 15.60  1.19  0.74  1.50 26.90 1900.00 46.700 $SH_PZ 34.219 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9090500 4090509 4090510 $Es $mu $FyCol 14.70 14.70  1.03  0.65  1.00 26.90 1530.00 38.800 $SH_PZ 17.109 $trib $tslab $pzModelTag 1 $Composite;


####################################################################################################
#                                             BEAM ELEMENTS                                        #
####################################################################################################

# COMMAND SYNTAX 
# secInfo  Zp, Mc/Mp, Mr/Mp, theta_p, theta_pc, theta_u, lambda
# hingeBeamColumn  ElementID node_i node_j eleDir, ... A, Ieff

# Beams at floor 2 bay 1
set secInfo_i {343.0000   1.0733   0.2000   0.0099   0.0012   0.0170   0.0000};
set secInfo_j {343.0000   1.0733   0.2000   0.0124   0.0015   0.0213   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1020100 4020104 4020202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 33.600 [expr 3884.700*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 2 bay 2
set secInfo_i {343.0000   1.0733   0.2000   0.0124   0.0015   0.0213   0.0000};
set secInfo_j {343.0000   1.0733   0.2000   0.0124   0.0015   0.0213   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1020200 4020204 4020302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 33.600 [expr 3884.700*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 2 bay 3
set secInfo_i {343.0000   1.0733   0.2000   0.0124   0.0015   0.0213   0.0000};
set secInfo_j {343.0000   1.0733   0.2000   0.0124   0.0015   0.0213   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1020300 4020304 4020402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 33.600 [expr 3884.700*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 2 bay 4
set secInfo_i {343.0000   1.0733   0.2000   0.0124   0.0015   0.0213   0.0000};
set secInfo_j {343.0000   1.0733   0.2000   0.0099   0.0012   0.0170   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1020400 4020404 4020502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 33.600 [expr 3884.700*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 3 bay 1
set secInfo_i {343.0000   1.0733   0.2000   0.0099   0.0012   0.0170   0.0000};
set secInfo_j {343.0000   1.0733   0.2000   0.0124   0.0015   0.0213   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1030100 4030104 4030202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 33.600 [expr 3884.700*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 3 bay 2
set secInfo_i {343.0000   1.0733   0.2000   0.0124   0.0015   0.0213   0.0000};
set secInfo_j {343.0000   1.0733   0.2000   0.0124   0.0015   0.0213   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1030200 4030204 4030302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 33.600 [expr 3884.700*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 3 bay 3
set secInfo_i {343.0000   1.0733   0.2000   0.0124   0.0015   0.0213   0.0000};
set secInfo_j {343.0000   1.0733   0.2000   0.0124   0.0015   0.0213   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1030300 4030304 4030402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 33.600 [expr 3884.700*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 3 bay 4
set secInfo_i {343.0000   1.0733   0.2000   0.0124   0.0015   0.0213   0.0000};
set secInfo_j {343.0000   1.0733   0.2000   0.0099   0.0012   0.0170   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1030400 4030404 4030502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 33.600 [expr 3884.700*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 4 bay 1
set secInfo_i {305.0000   1.0743   0.2000   0.0101   0.0012   0.0171   0.0000};
set secInfo_j {305.0000   1.0743   0.2000   0.0126   0.0015   0.0214   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1040100 4040104 4040202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 30.000 [expr 3445.698*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 4 bay 2
set secInfo_i {305.0000   1.0743   0.2000   0.0126   0.0015   0.0214   0.0000};
set secInfo_j {305.0000   1.0743   0.2000   0.0126   0.0015   0.0214   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1040200 4040204 4040302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 30.000 [expr 3445.698*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 4 bay 3
set secInfo_i {305.0000   1.0743   0.2000   0.0126   0.0015   0.0214   0.0000};
set secInfo_j {305.0000   1.0743   0.2000   0.0126   0.0015   0.0214   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1040300 4040304 4040402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 30.000 [expr 3445.698*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 4 bay 4
set secInfo_i {305.0000   1.0743   0.2000   0.0126   0.0015   0.0214   0.0000};
set secInfo_j {305.0000   1.0743   0.2000   0.0101   0.0012   0.0171   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1040400 4040404 4040502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 30.000 [expr 3445.698*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 5 bay 1
set secInfo_i {305.0000   1.0743   0.2000   0.0101   0.0012   0.0171   0.0000};
set secInfo_j {305.0000   1.0743   0.2000   0.0126   0.0015   0.0214   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1050100 4050104 4050202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 30.000 [expr 3445.698*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 5 bay 2
set secInfo_i {305.0000   1.0743   0.2000   0.0126   0.0015   0.0214   0.0000};
set secInfo_j {305.0000   1.0743   0.2000   0.0126   0.0015   0.0214   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1050200 4050204 4050302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 30.000 [expr 3445.698*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 5 bay 3
set secInfo_i {305.0000   1.0743   0.2000   0.0126   0.0015   0.0214   0.0000};
set secInfo_j {305.0000   1.0743   0.2000   0.0126   0.0015   0.0214   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1050300 4050304 4050402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 30.000 [expr 3445.698*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 5 bay 4
set secInfo_i {305.0000   1.0743   0.2000   0.0126   0.0015   0.0214   0.0000};
set secInfo_j {305.0000   1.0743   0.2000   0.0101   0.0012   0.0171   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1050400 4050404 4050502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 30.000 [expr 3445.698*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 6 bay 1
set secInfo_i {278.0000   1.0749   0.2000   0.0103   0.0012   0.0172   0.0000};
set secInfo_j {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1060100 4060104 4060202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 27.600 [expr 3119.678*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 6 bay 2
set secInfo_i {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set secInfo_j {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1060200 4060204 4060302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 27.600 [expr 3119.578*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 6 bay 3
set secInfo_i {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set secInfo_j {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1060300 4060304 4060402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 27.600 [expr 3119.578*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 6 bay 4
set secInfo_i {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set secInfo_j {278.0000   1.0749   0.2000   0.0103   0.0012   0.0172   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1060400 4060404 4060502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 27.600 [expr 3119.678*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 7 bay 1
set secInfo_i {278.0000   1.0749   0.2000   0.0103   0.0012   0.0172   0.0000};
set secInfo_j {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1070100 4070104 4070202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 27.600 [expr 3119.678*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 7 bay 2
set secInfo_i {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set secInfo_j {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1070200 4070204 4070302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 27.600 [expr 3119.578*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 7 bay 3
set secInfo_i {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set secInfo_j {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1070300 4070304 4070402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 27.600 [expr 3119.578*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 7 bay 4
set secInfo_i {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set secInfo_j {278.0000   1.0749   0.2000   0.0103   0.0012   0.0172   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1070400 4070404 4070502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 27.600 [expr 3119.678*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 8 bay 1
set secInfo_i {278.0000   1.0748   0.2000   0.0103   0.0012   0.0172   0.0000};
set secInfo_j {278.0000   1.0748   0.2000   0.0128   0.0014   0.0215   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1080100 4080104 4080202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 27.600 [expr 3119.927*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 8 bay 2
set secInfo_i {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set secInfo_j {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1080200 4080204 4080302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 27.600 [expr 3119.777*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 8 bay 3
set secInfo_i {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set secInfo_j {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1080300 4080304 4080402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 27.600 [expr 3119.777*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 8 bay 4
set secInfo_i {278.0000   1.0748   0.2000   0.0128   0.0014   0.0215   0.0000};
set secInfo_j {278.0000   1.0748   0.2000   0.0103   0.0012   0.0172   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1080400 4080404 4080502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 27.600 [expr 3119.927*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 9 bay 1
set secInfo_i {278.0000   1.0748   0.2000   0.0103   0.0012   0.0172   0.0000};
set secInfo_j {278.0000   1.0748   0.2000   0.0128   0.0014   0.0215   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1090100 4090104 4090202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 27.600 [expr 3119.927*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 9 bay 2
set secInfo_i {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set secInfo_j {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1090200 4090204 4090302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 27.600 [expr 3119.777*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 9 bay 3
set secInfo_i {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set secInfo_j {278.0000   1.0749   0.2000   0.0128   0.0014   0.0215   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1090300 4090304 4090402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 27.600 [expr 3119.777*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 9 bay 4
set secInfo_i {278.0000   1.0748   0.2000   0.0128   0.0014   0.0215   0.0000};
set secInfo_j {278.0000   1.0748   0.2000   0.0103   0.0012   0.0172   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
hingeBeamColumn 1090400 4090404 4090502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 27.600 [expr 3119.927*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

####################################################################################################
#                                            COLUMNS ELEMENTS                                      #
####################################################################################################

# COMMAND SYNTAX 
# secInfo  Zp, Mc/Mp, Mr/Mp, theta_p, theta_pc, theta_u, lambda
# spliceSecGeometry  min(d_i, d_j), min(bf_i, bf_j), min(tf_i, tf_j), min(tw_i, tw_j)
# (splice)    hingeBeamColumnSplice  ElementID node_i node_j eleDir, ... A, Ieff, ... 
# (no splice) hingeBeamColumn        ElementID node_i node_j eleDir, ... A, Ieff

# Columns at story 1 axis 1
set secInfo_i {370.4321   1.2763   0.8548   0.0524   0.0527   0.1226   0.0000};
set secInfo_j {370.4321   1.2763   0.8548   0.0524   0.0527   0.1226   0.0000};
hingeBeamColumn 2010100 10100 4020101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 62.000 2342.330 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 1
set secInfo_i {372.8781   1.3091   0.8605   0.0548   0.0557   0.1290   0.0000};
set secInfo_j {372.8781   1.3091   0.8605   0.0548   0.0557   0.1290   0.0000};
hingeBeamColumn 2020100 4020103 4030101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 62.000 2282.574 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 3 axis 1
set secInfo_i {340.4181   1.2841   0.8630   0.0509   0.0524   0.1207   0.0000};
set secInfo_j {340.4181   1.2841   0.8630   0.0509   0.0524   0.1207   0.0000};
hingeBeamColumn 2030100 4030103 4040101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 56.800 2064.411 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 1
set secInfo_i {342.8485   1.2866   0.8692   0.0517   0.0533   0.1228   0.0000};
set secInfo_j {342.8485   1.2866   0.8692   0.0517   0.0533   0.1228   0.0000};
hingeBeamColumn 2040100 4040103 4050101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 56.800 2064.862 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 5 axis 1
set secInfo_i {277.4411   1.2424   0.8700   0.0445   0.0470   0.1072   0.0000};
set secInfo_j {277.4411   1.2424   0.8700   0.0445   0.0470   0.1072   0.0000};
hingeBeamColumn 2050100 4050103 4060101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 46.700 1642.516 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 6 axis 1
set secInfo_i {279.8308   1.2451   0.8775   0.0454   0.0480   0.1094   0.0000};
set secInfo_j {279.8308   1.2451   0.8775   0.0454   0.0480   0.1094   0.0000};
hingeBeamColumn 2060100 4060103 4070101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 46.700 1642.867 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 7 axis 1
set secInfo_i {229.3098   1.2137   0.8820   0.0400   0.0428   0.0971   0.0000};
set secInfo_j {229.3098   1.2137   0.8820   0.0400   0.0428   0.0971   0.0000};
hingeBeamColumn 2070100 4070103 4080101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 38.800 1333.874 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 8 axis 1
set secInfo_i {231.6549   1.2168   0.8910   0.0410   0.0439   0.0995   0.0000};
set secInfo_j {231.6549   1.2168   0.8910   0.0410   0.0439   0.0995   0.0000};
hingeBeamColumn 2080100 4080103 4090101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 38.800 1333.874 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 2
set secInfo_i {350.8642   1.2567   0.8097   0.0461   0.0461   0.1075   0.0000};
set secInfo_j {350.8642   1.2567   0.8097   0.0461   0.0461   0.1075   0.0000};
hingeBeamColumn 2010200 10200 4020201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 62.000 2342.330 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 2
set secInfo_i {355.7562   1.2901   0.8210   0.0490   0.0496   0.1152   0.0000};
set secInfo_j {355.7562   1.2901   0.8210   0.0490   0.0496   0.1152   0.0000};
hingeBeamColumn 2020200 4020203 4030201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 62.000 2282.574 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 3 axis 2
set secInfo_i {325.8363   1.2676   0.8261   0.0459   0.0470   0.1086   0.0000};
set secInfo_j {325.8363   1.2676   0.8261   0.0459   0.0470   0.1086   0.0000};
hingeBeamColumn 2030200 4030203 4040201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 56.800 2064.411 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 2
set secInfo_i {330.6969   1.2729   0.8384   0.0475   0.0488   0.1125   0.0000};
set secInfo_j {330.6969   1.2729   0.8384   0.0475   0.0488   0.1125   0.0000};
hingeBeamColumn 2040200 4040203 4050201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 56.800 2064.862 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 5 axis 2
set secInfo_i {300.7827   1.2580   0.8460   0.0458   0.0475   0.1091   0.0000};
set secInfo_j {300.7827   1.2580   0.8460   0.0458   0.0475   0.1091   0.0000};
hingeBeamColumn 2050200 4050203 4060201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 51.800 1843.120 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 6 axis 2
set secInfo_i {305.5870   1.2634   0.8595   0.0475   0.0494   0.1133   0.0000};
set secInfo_j {305.5870   1.2634   0.8595   0.0475   0.0494   0.1133   0.0000};
hingeBeamColumn 2060200 4060203 4070201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 51.800 1843.510 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 7 axis 2
set secInfo_i {277.4411   1.2422   0.8700   0.0445   0.0470   0.1071   0.0000};
set secInfo_j {277.4411   1.2422   0.8700   0.0445   0.0470   0.1071   0.0000};
hingeBeamColumn 2070200 4070203 4080201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 46.700 1642.867 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 8 axis 2
set secInfo_i {282.2206   1.2479   0.8850   0.0464   0.0490   0.1117   0.0000};
set secInfo_j {282.2206   1.2479   0.8850   0.0464   0.0490   0.1117   0.0000};
hingeBeamColumn 2080200 4080203 4090201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 46.700 1642.867 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 3
set secInfo_i {350.8642   1.2567   0.8097   0.0461   0.0461   0.1075   0.0000};
set secInfo_j {350.8642   1.2567   0.8097   0.0461   0.0461   0.1075   0.0000};
hingeBeamColumn 2010300 10300 4020301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 62.000 2342.330 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 3
set secInfo_i {355.7562   1.2901   0.8210   0.0490   0.0496   0.1152   0.0000};
set secInfo_j {355.7562   1.2901   0.8210   0.0490   0.0496   0.1152   0.0000};
hingeBeamColumn 2020300 4020303 4030301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 62.000 2282.574 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 3 axis 3
set secInfo_i {325.8363   1.2676   0.8261   0.0459   0.0470   0.1086   0.0000};
set secInfo_j {325.8363   1.2676   0.8261   0.0459   0.0470   0.1086   0.0000};
hingeBeamColumn 2030300 4030303 4040301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 56.800 2064.411 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 3
set secInfo_i {330.6969   1.2729   0.8384   0.0475   0.0488   0.1125   0.0000};
set secInfo_j {330.6969   1.2729   0.8384   0.0475   0.0488   0.1125   0.0000};
hingeBeamColumn 2040300 4040303 4050301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 56.800 2064.862 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 5 axis 3
set secInfo_i {300.7827   1.2580   0.8460   0.0458   0.0475   0.1091   0.0000};
set secInfo_j {300.7827   1.2580   0.8460   0.0458   0.0475   0.1091   0.0000};
hingeBeamColumn 2050300 4050303 4060301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 51.800 1843.120 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 6 axis 3
set secInfo_i {305.5870   1.2634   0.8595   0.0475   0.0494   0.1133   0.0000};
set secInfo_j {305.5870   1.2634   0.8595   0.0475   0.0494   0.1133   0.0000};
hingeBeamColumn 2060300 4060303 4070301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 51.800 1843.510 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 7 axis 3
set secInfo_i {277.4411   1.2422   0.8700   0.0445   0.0470   0.1071   0.0000};
set secInfo_j {277.4411   1.2422   0.8700   0.0445   0.0470   0.1071   0.0000};
hingeBeamColumn 2070300 4070303 4080301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 46.700 1642.867 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 8 axis 3
set secInfo_i {282.2206   1.2479   0.8850   0.0464   0.0490   0.1117   0.0000};
set secInfo_j {282.2206   1.2479   0.8850   0.0464   0.0490   0.1117   0.0000};
hingeBeamColumn 2080300 4080303 4090301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 46.700 1642.867 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 4
set secInfo_i {350.8642   1.2567   0.8097   0.0461   0.0461   0.1075   0.0000};
set secInfo_j {350.8642   1.2567   0.8097   0.0461   0.0461   0.1075   0.0000};
hingeBeamColumn 2010400 10400 4020401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 62.000 2342.330 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 4
set secInfo_i {355.7562   1.2901   0.8210   0.0490   0.0496   0.1152   0.0000};
set secInfo_j {355.7562   1.2901   0.8210   0.0490   0.0496   0.1152   0.0000};
hingeBeamColumn 2020400 4020403 4030401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 62.000 2282.574 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 3 axis 4
set secInfo_i {325.8363   1.2676   0.8261   0.0459   0.0470   0.1086   0.0000};
set secInfo_j {325.8363   1.2676   0.8261   0.0459   0.0470   0.1086   0.0000};
hingeBeamColumn 2030400 4030403 4040401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 56.800 2064.411 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 4
set secInfo_i {330.6969   1.2729   0.8384   0.0475   0.0488   0.1125   0.0000};
set secInfo_j {330.6969   1.2729   0.8384   0.0475   0.0488   0.1125   0.0000};
hingeBeamColumn 2040400 4040403 4050401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 56.800 2064.862 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 5 axis 4
set secInfo_i {300.7827   1.2580   0.8460   0.0458   0.0475   0.1091   0.0000};
set secInfo_j {300.7827   1.2580   0.8460   0.0458   0.0475   0.1091   0.0000};
hingeBeamColumn 2050400 4050403 4060401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 51.800 1843.120 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 6 axis 4
set secInfo_i {305.5870   1.2634   0.8595   0.0475   0.0494   0.1133   0.0000};
set secInfo_j {305.5870   1.2634   0.8595   0.0475   0.0494   0.1133   0.0000};
hingeBeamColumn 2060400 4060403 4070401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 51.800 1843.510 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 7 axis 4
set secInfo_i {277.4411   1.2422   0.8700   0.0445   0.0470   0.1071   0.0000};
set secInfo_j {277.4411   1.2422   0.8700   0.0445   0.0470   0.1071   0.0000};
hingeBeamColumn 2070400 4070403 4080401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 46.700 1642.867 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 8 axis 4
set secInfo_i {282.2206   1.2479   0.8850   0.0464   0.0490   0.1117   0.0000};
set secInfo_j {282.2206   1.2479   0.8850   0.0464   0.0490   0.1117   0.0000};
hingeBeamColumn 2080400 4080403 4090401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 46.700 1642.867 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 5
set secInfo_i {370.4321   1.2763   0.8548   0.0524   0.0527   0.1226   0.0000};
set secInfo_j {370.4321   1.2763   0.8548   0.0524   0.0527   0.1226   0.0000};
hingeBeamColumn 2010500 10500 4020501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 62.000 2342.330 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 5
set secInfo_i {372.8781   1.3091   0.8605   0.0548   0.0557   0.1290   0.0000};
set secInfo_j {372.8781   1.3091   0.8605   0.0548   0.0557   0.1290   0.0000};
hingeBeamColumn 2020500 4020503 4030501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 62.000 2282.574 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 3 axis 5
set secInfo_i {340.4181   1.2841   0.8630   0.0509   0.0524   0.1207   0.0000};
set secInfo_j {340.4181   1.2841   0.8630   0.0509   0.0524   0.1207   0.0000};
hingeBeamColumn 2030500 4030503 4040501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 56.800 2064.411 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 5
set secInfo_i {342.8485   1.2866   0.8692   0.0517   0.0533   0.1228   0.0000};
set secInfo_j {342.8485   1.2866   0.8692   0.0517   0.0533   0.1228   0.0000};
hingeBeamColumn 2040500 4040503 4050501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 56.800 2064.862 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 5 axis 5
set secInfo_i {277.4411   1.2424   0.8700   0.0445   0.0470   0.1072   0.0000};
set secInfo_j {277.4411   1.2424   0.8700   0.0445   0.0470   0.1072   0.0000};
hingeBeamColumn 2050500 4050503 4060501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 46.700 1642.516 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 6 axis 5
set secInfo_i {279.8308   1.2451   0.8775   0.0454   0.0480   0.1094   0.0000};
set secInfo_j {279.8308   1.2451   0.8775   0.0454   0.0480   0.1094   0.0000};
hingeBeamColumn 2060500 4060503 4070501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 46.700 1642.867 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 7 axis 5
set secInfo_i {229.3098   1.2137   0.8820   0.0400   0.0428   0.0971   0.0000};
set secInfo_j {229.3098   1.2137   0.8820   0.0400   0.0428   0.0971   0.0000};
hingeBeamColumn 2070500 4070503 4080501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 38.800 1333.874 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 8 axis 5
set secInfo_i {231.6549   1.2168   0.8910   0.0410   0.0439   0.0995   0.0000};
set secInfo_j {231.6549   1.2168   0.8910   0.0410   0.0439   0.0995   0.0000};
hingeBeamColumn 2080500 4080503 4090501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 38.800 1333.874 $degradation $c $secInfo_i $secInfo_j 0 0;

####################################################################################################
#                                              FLOOR LINKS                                         #
####################################################################################################

# Command Syntax 
# element truss $ElementID $iNode $jNode $Area $matID
element truss 1009 4090504 80604 $A_Stiff $rigMatTag;
element truss 1008 4080504 70604 $A_Stiff $rigMatTag;
element truss 1007 4070504 60604 $A_Stiff $rigMatTag;
element truss 1006 4060504 50604 $A_Stiff $rigMatTag;
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
element elasticBeamColumn 2050600 50602 50604 $A_Stiff $Es $I_Stiff $trans_selected;
element elasticBeamColumn 2060600 60602 60604 $A_Stiff $Es $I_Stiff $trans_selected;
element elasticBeamColumn 2070600 70602 70604 $A_Stiff $Es $I_Stiff $trans_selected;
element elasticBeamColumn 2080600 80602 80604 $A_Stiff $Es $I_Stiff $trans_selected;
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
# Panel zones floor6
mass 4060103 0.0443  0.0004 3.3235;
mass 4060203 0.0886  0.0009 6.6470;
mass 4060303 0.0886  0.0009 6.6470;
mass 4060403 0.0886  0.0009 6.6470;
mass 4060503 0.0443  0.0004 3.3235;
# Panel zones floor7
mass 4070103 0.0443  0.0004 3.3235;
mass 4070203 0.0886  0.0009 6.6470;
mass 4070303 0.0886  0.0009 6.6470;
mass 4070403 0.0886  0.0009 6.6470;
mass 4070503 0.0443  0.0004 3.3235;
# Panel zones floor8
mass 4080103 0.0443  0.0004 3.3235;
mass 4080203 0.0886  0.0009 6.6470;
mass 4080303 0.0886  0.0009 6.6470;
mass 4080403 0.0886  0.0009 6.6470;
mass 4080503 0.0443  0.0004 3.3235;
# Panel zones floor9
mass 4090103 0.0443  0.0004 3.3235;
mass 4090203 0.0886  0.0009 6.6470;
mass 4090303 0.0886  0.0009 6.6470;
mass 4090403 0.0886  0.0009 6.6470;
mass 4090503 0.0443  0.0004 3.3235;

# MASS ON THE GRAVITY SYSTEM

mass 10604 1.0635  0.0106 79.7640;
mass 20604 1.0635  0.0106 79.7640;
mass 30604 1.0635  0.0106 79.7640;
mass 40604 1.0635  0.0106 79.7640;
mass 50604 1.0635  0.0106 79.7640;
mass 60604 1.0635  0.0106 79.7640;
mass 70604 1.0635  0.0106 79.7640;
mass 80604 1.0635  0.0106 79.7640;

###################################################################################################
#                                            GRAVITY LOAD                                         #
###################################################################################################

pattern Plain 101 Linear {

	# MR Frame: Distributed beam element loads
	# Floor 2
	# Floor 3
	# Floor 4
	# Floor 5
	# Floor 6
	# Floor 7
	# Floor 8
	# Floor 9

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
	# Floor6
	load 4060103 0.0 -17.1094 0.0;
	load 4060203 0.0 -34.2188 0.0;
	load 4060303 0.0 -34.2188 0.0;
	load 4060403 0.0 -34.2188 0.0;
	load 4060503 0.0 -17.1094 0.0;
	# Floor7
	load 4070103 0.0 -17.1094 0.0;
	load 4070203 0.0 -34.2188 0.0;
	load 4070303 0.0 -34.2188 0.0;
	load 4070403 0.0 -34.2188 0.0;
	load 4070503 0.0 -17.1094 0.0;
	# Floor8
	load 4080103 0.0 -17.1094 0.0;
	load 4080203 0.0 -34.2188 0.0;
	load 4080303 0.0 -34.2188 0.0;
	load 4080403 0.0 -34.2188 0.0;
	load 4080503 0.0 -17.1094 0.0;
	# Floor9
	load 4090103 0.0 -17.1094 0.0;
	load 4090203 0.0 -34.2188 0.0;
	load 4090303 0.0 -34.2188 0.0;
	load 4090403 0.0 -34.2188 0.0;
	load 4090503 0.0 -17.1094 0.0;

	#  Gravity Frame: Point loads on columns
	load 10604 0.0 -410.6250 0.0;
	load 20604 0.0 -410.6250 0.0;
	load 30604 0.0 -410.6250 0.0;
	load 40604 0.0 -410.6250 0.0;
	load 50604 0.0 -410.6250 0.0;
	load 60604 0.0 -410.6250 0.0;
	load 70604 0.0 -410.6250 0.0;
	load 80604 0.0 -410.6250 0.0;

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
	4060503
	4070503
	4080503
	4090503
};

set hVector {
	156
	156
	156
	156
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
region 1 -ele 1020100 1020200 1020300 1020400 1030100 1030200 1030300 1030400 1040100 1040200 1040300 1040400 1050100 1050200 1050300 1050400 1060100 1060200 1060300 1060400 1070100 1070200 1070300 1070400 1080100 1080200 1080300 1080400 1090100 1090200 1090300 1090400 -rayleigh 0.0 0.0 $a1_mod 0.0;

# Column elastic elements
region 2 -ele 2010100 2020100 2030100 2040100 2050100 2060100 2070100 2080100 2010200 2020200 2030200 2040200 2050200 2060200 2070200 2080200 2010300 2020300 2030300 2040300 2050300 2060300 2070300 2080300 2010400 2020400 2030400 2040400 2050400 2060400 2070400 2080400 2010500 2020500 2030500 2040500 2050500 2060500 2070500 2080500 -rayleigh 0.0 0.0 $a1_mod 0.0;

# Hinge elements [beam springs, column springs]
region 3 -ele 1020101 1020102 1020201 1020202 1020301 1020302 1020401 1020402 1030101 1030102 1030201 1030202 1030301 1030302 1030401 1030402 1040101 1040102 1040201 1040202 1040301 1040302 1040401 1040402 1050101 1050102 1050201 1050202 1050301 1050302 1050401 1050402 1060101 1060102 1060201 1060202 1060301 1060302 1060401 1060402 1070101 1070102 1070201 1070202 1070301 1070302 1070401 1070402 1080101 1080102 1080201 1080202 1080301 1080302 1080401 1080402 1090101 1090102 1090201 1090202 1090301 1090302 1090401 1090402 2010101 2010102 2020101 2020102 2030101 2030102 2040101 2040102 2050101 2050102 2060101 2060102 2070101 2070102 2080101 2080102 2010201 2010202 2020201 2020202 2030201 2030202 2040201 2040202 2050201 2050202 2060201 2060202 2070201 2070202 2080201 2080202 2010301 2010302 2020301 2020302 2030301 2030302 2040301 2040302 2050301 2050302 2060301 2060302 2070301 2070302 2080301 2080302 2010401 2010402 2020401 2020402 2030401 2030402 2040401 2040402 2050401 2050402 2060401 2060402 2070401 2070402 2080401 2080402 2010501 2010502 2020501 2020502 2030501 2030502 2040501 2040502 2050501 2050502 2060501 2060502 2070501 2070502 2080501 2080502 -rayleigh 0.0 0.0 [expr $a1_mod/$n] 0.0;

# Nodes with mass
region 4 -nodes 4020103 4020203 4020303 4020403 4020503 4030103 4030203 4030303 4030403 4030503 4040103 4040203 4040303 4040403 4040503 4050103 4050203 4050303 4050403 4050503 4060103 4060203 4060303 4060403 4060503 4070103 4070203 4070303 4070403 4070503 4080103 4080203 4080303 4080403 4080503 4090103 4090203 4090303 4090403 4090503 -rayleigh $a0 0.0 0.0 0.0;

###################################################################################################
#                                     DETAILED RECORDERS                                          #
###################################################################################################

if {$addBasicRecorders == 1} {

	# Recorders for lateral displacement on each panel zone
	recorder Node -file $outdir/all_disp.out -dT 0.01 -time -nodes 4020103 4020203 4020303 4020403 4020503 4030103 4030203 4030303 4030403 4030503 4040103 4040203 4040303 4040403 4040503 4050103 4050203 4050303 4050403 4050503 4060103 4060203 4060303 4060403 4060503 4070103 4070203 4070303 4070403 4070503 4080103 4080203 4080303 4080403 4080503 4090103 4090203 4090303 4090403 4090503 -dof 1 disp;

}

if {$addBasicRecorders == 1} {

	# Recorders beam hinge element

	# Left
	recorder Element -file $outdir/hinge_left.out -dT 0.01 -ele 1020101 1020201 1020301 1020401 1030101 1030201 1030301 1030401 1040101 1040201 1040301 1040401 1050101 1050201 1050301 1050401 1060101 1060201 1060301 1060401 1070101 1070201 1070301 1070401 1080101 1080201 1080301 1080401 1090101 1090201 1090301 1090401 deformation;

	# Right
	recorder Element -file $outdir/hinge_right.out -dT 0.01 -ele 1020102 1020202 1020302 1020402 1030102 1030202 1030302 1030402 1040102 1040202 1040302 1040402 1050102 1050202 1050302 1050402 1060102 1060202 1060302 1060402 1070102 1070202 1070302 1070402 1080102 1080202 1080302 1080402 1090102 1090202 1090302 1090402 deformation;
}

if {$addDetailedRecorders == 1} {

	recorder Element -file $outdir/hinge_right_force.out -dT 0.01 -ele 1020102 1020202 1020302 1020402 1030102 1030202 1030302 1030402 1040102 1040202 1040302 1040402 1050102 1050202 1050302 1050402 1060102 1060202 1060302 1060402 1070102 1070202 1070302 1070402 1080102 1080202 1080302 1080402 1090102 1090202 1090302 1090402 force;

	recorder Element -file $outdir/hinge_left_force.out -dT 0.01 -ele 1020101 1020201 1020301 1020401 1030101 1030201 1030301 1030401 1040101 1040201 1040301 1040401 1050101 1050201 1050301 1050401 1060101 1060201 1060301 1060401 1070101 1070201 1070301 1070401 1080101 1080201 1080301 1080401 1090101 1090201 1090301 1090401 force;
}

if {$addDetailedRecorders == 1} {

	# Recorders for beam internal forces
	recorder Element -file $outdir/beam_forces.out -dT 0.01 -ele 1020100 1020200 1020300 1020400 1030100 1030200 1030300 1030400 1040100 1040200 1040300 1040400 1050100 1050200 1050300 1050400 1060100 1060200 1060300 1060400 1070100 1070200 1070300 1070400 1080100 1080200 1080300 1080400 1090100 1090200 1090300 1090400 globalForce;

}

if {$addDetailedRecorders == 1} {

	# Recorders for column internal forces
	recorder Element -file $outdir/column_forces.out -dT 0.01 -ele 2010100 2020100 2030100 2040100 2050100 2060100 2070100 2080100 2010200 2020200 2030200 2040200 2050200 2060200 2070200 2080200 2010300 2020300 2030300 2040300 2050300 2060300 2070300 2080300 2010400 2020400 2030400 2040400 2050400 2060400 2070400 2080400 2010500 2020500 2030500 2040500 2050500 2060500 2070500 2080500 globalForce;

}

if {$addBasicRecorders == 1} {

	# Recorders column hinges
	# Bottom
	recorder Element -file $outdir/hinge_bot.out -dT 0.01 -ele 2010101 2020101 2030101 2040101 2050101 2060101 2070101 2080101 2010201 2020201 2030201 2040201 2050201 2060201 2070201 2080201 2010301 2020301 2030301 2040301 2050301 2060301 2070301 2080301 2010401 2020401 2030401 2040401 2050401 2060401 2070401 2080401 2010501 2020501 2030501 2040501 2050501 2060501 2070501 2080501 deformation;
	# Top
	recorder Element -file $outdir/hinge_top.out -dT 0.01 -ele 2010102 2020102 2030102 2040102 2050102 2060102 2070102 2080102 2010202 2020202 2030202 2040202 2050202 2060202 2070202 2080202 2010302 2020302 2030302 2040302 2050302 2060302 2070302 2080302 2010402 2020402 2030402 2040402 2050402 2060402 2070402 2080402 2010502 2020502 2030502 2040502 2050502 2060502 2070502 2080502 deformation;
}

if {$addDetailedRecorders == 1} {

	# Bottom
	recorder Element -file $outdir/hinge_bot_force.out -dT 0.01 -ele 2010101 2020101 2030101 2040101 2050101 2060101 2070101 2080101 2010201 2020201 2030201 2040201 2050201 2060201 2070201 2080201 2010301 2020301 2030301 2040301 2050301 2060301 2070301 2080301 2010401 2020401 2030401 2040401 2050401 2060401 2070401 2080401 2010501 2020501 2030501 2040501 2050501 2060501 2070501 2080501 force;
	# Top
	recorder Element -file $outdir/hinge_top_force.out -dT 0.01 -ele 2010102 2020102 2030102 2040102 2050102 2060102 2070102 2080102 2010202 2020202 2030202 2040202 2050202 2060202 2070202 2080202 2010302 2020302 2030302 2040302 2050302 2060302 2070302 2080302 2010402 2020402 2030402 2040402 2050402 2060402 2070402 2080402 2010502 2020502 2030502 2040502 2050502 2060502 2070502 2080502 force;
}

if {$addBasicRecorders == 1} {

	# Recorders panel zone elements
	recorder Element -file $outdir/pz_rot.out -dT 0.01 -ele 9010100 9010200 9010300 9010400 9010500 9020100 9020200 9020300 9020400 9020500 9030100 9030200 9030300 9030400 9030500 9040100 9040200 9040300 9040400 9040500 9050100 9050200 9050300 9050400 9050500 9060100 9060200 9060300 9060400 9060500 9070100 9070200 9070300 9070400 9070500 9080100 9080200 9080300 9080400 9080500 9090100 9090200 9090300 9090400 9090500 deformation;
}

if {$addDetailedRecorders == 1} {

	recorder Element -file $outdir/pz_M.out -dT 0.01 -ele 9010100 9010200 9010300 9010400 9010500 9020100 9020200 9020300 9020400 9020500 9030100 9030200 9030300 9030400 9030500 9040100 9040200 9040300 9040400 9040500 9050100 9050200 9050300 9050400 9050500 9060100 9060200 9060300 9060400 9060500 9070100 9070200 9070300 9070400 9070500 9080100 9080200 9080300 9080400 9080500 9090100 9090200 9090300 9090400 9090500 force;
}

