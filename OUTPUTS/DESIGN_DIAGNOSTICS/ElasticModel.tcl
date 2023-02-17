####################################################################################################
####################################################################################################
#                                        35-story MRF Building
####################################################################################################
####################################################################################################

####### MODEL FEATURES #######;
# UNITS:                     kip, in
# Generation:                 
# Composite beams:           True
# Fracturing fiber sections: False
# Gravity system stiffness:  True
# Column splices included:   True
# Rigid diaphragm:           False
# Plastic hinge type:         
# Backbone type:             Elastic
# Cyclic degradation:        False
# Web connection type:       Bolted
# Panel zone model:          None

# BUILD MODEL (2D - 3 DOF/node)
wipe all
model basic -ndm 2 -ndf 3

####################################################################################################
#                                      SOURCING HELPER FUNCTIONS                                   #
####################################################################################################

source ConstructPanel_Cross.tcl;
source fracSectionWelded.tcl;
source fracSectionSplice.tcl;
source elasticBeamColumnSplice.tcl;
source hingeBeamColumn.tcl;
source matHysteretic.tcl;
source Spring_Pinching.tcl;
source modalAnalysis.tcl;

####################################################################################################
#                                              INPUT                                               #
####################################################################################################

# GENERAL CONSTANTS
set g 386.100;
set outdir Output
file mkdir $outdir; # create data directoryset pi [expr 2.0*asin(1.0)];
set addBasicRecorders 1
set addDetailedRecorders 1

# FRAME CENTERLINE DIMENSIONS
set num_stories 35;
set NBay  6;

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

# GRAVITY FRAME MODEL
set gap 0.08; # Gap to consider binding in gravity frame beam connections

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
set pzModelTag 0;

# BACKBONE FACTORS FOR COMPOSITE BEAM
set Composite 1; # Consider composite action
set Comp_I       1.400; # stiffness factor for MR frame beams
set Comp_I_GC    1.400; # stiffness factor for EGF beams
set trib        3.000;
set tslab       3.000;
# COLUMN SPLICES
set spliceLoc        48.000;

####################################################################################################
#                                          PRE-CALCULATIONS                                        #
####################################################################################################

# FRAME GRID LINES
set Floor1 0.0;
set Floor2  156.00;
set Floor3  336.00;
set Floor4  516.00;
set Floor5  672.00;
set Floor6  828.00;
set Floor7  984.00;
set Floor8  1140.00;
set Floor9  1296.00;
set Floor10  1452.00;
set Floor11  1608.00;
set Floor12  1764.00;
set Floor13  1920.00;
set Floor14  2076.00;
set Floor15  2232.00;
set Floor16  2388.00;
set Floor17  2544.00;
set Floor18  2700.00;
set Floor19  2856.00;
set Floor20  3012.00;
set Floor21  3168.00;
set Floor22  3324.00;
set Floor23  3480.00;
set Floor24  3636.00;
set Floor25  3792.00;
set Floor26  3948.00;
set Floor27  4104.00;
set Floor28  4260.00;
set Floor29  4416.00;
set Floor30  4572.00;
set Floor31  4728.00;
set Floor32  4932.00;
set Floor33  5088.00;
set Floor34  5244.00;
set Floor35  5400.00;
set Floor36  5556.00;

set Axis1 0.0;
set Axis2 560.24;
set Axis3 920.47;
set Axis4 1280.71;
set Axis5 1640.95;
set Axis6 2001.18;
set Axis7 2561.42;
set Axis8 3121.65;
set Axis9 3681.89;

set HBuilding 5556.00;
set WFrame 2561.42;

####################################################################################################
#                                                  NODES                                           #
####################################################################################################

# COMMAND SYNTAX 
# node $NodeID  $X-Coordinate  $Y-Coordinate;

# SUPPORT NODES
node 10100   $Axis1  $Floor1;
node 10200   $Axis2  $Floor1;
node 10400   $Axis4  $Floor1;
node 10500   $Axis5  $Floor1;
node 10600   $Axis6  $Floor1;
node 10700   $Axis7  $Floor1;

# EGF COLUMN GRID NODES
node 10800   $Axis8  $Floor1; node 10900   $Axis9  $Floor1; 
node 20800   $Axis8  $Floor2; node 20900   $Axis9  $Floor2; 
node 30800   $Axis8  $Floor3; node 30900   $Axis9  $Floor3; 
node 40800   $Axis8  $Floor4; node 40900   $Axis9  $Floor4; 
node 50800   $Axis8  $Floor5; node 50900   $Axis9  $Floor5; 
node 60800   $Axis8  $Floor6; node 60900   $Axis9  $Floor6; 
node 70800   $Axis8  $Floor7; node 70900   $Axis9  $Floor7; 
node 80800   $Axis8  $Floor8; node 80900   $Axis9  $Floor8; 
node 90800   $Axis8  $Floor9; node 90900   $Axis9  $Floor9; 
node 100800   $Axis8  $Floor10; node 100900   $Axis9  $Floor10; 
node 110800   $Axis8  $Floor11; node 110900   $Axis9  $Floor11; 
node 120800   $Axis8  $Floor12; node 120900   $Axis9  $Floor12; 
node 130800   $Axis8  $Floor13; node 130900   $Axis9  $Floor13; 
node 140800   $Axis8  $Floor14; node 140900   $Axis9  $Floor14; 
node 150800   $Axis8  $Floor15; node 150900   $Axis9  $Floor15; 
node 160800   $Axis8  $Floor16; node 160900   $Axis9  $Floor16; 
node 170800   $Axis8  $Floor17; node 170900   $Axis9  $Floor17; 
node 180800   $Axis8  $Floor18; node 180900   $Axis9  $Floor18; 
node 190800   $Axis8  $Floor19; node 190900   $Axis9  $Floor19; 
node 200800   $Axis8  $Floor20; node 200900   $Axis9  $Floor20; 
node 210800   $Axis8  $Floor21; node 210900   $Axis9  $Floor21; 
node 220800   $Axis8  $Floor22; node 220900   $Axis9  $Floor22; 
node 230800   $Axis8  $Floor23; node 230900   $Axis9  $Floor23; 
node 240800   $Axis8  $Floor24; node 240900   $Axis9  $Floor24; 
node 250800   $Axis8  $Floor25; node 250900   $Axis9  $Floor25; 
node 260800   $Axis8  $Floor26; node 260900   $Axis9  $Floor26; 
node 270800   $Axis8  $Floor27; node 270900   $Axis9  $Floor27; 
node 280800   $Axis8  $Floor28; node 280900   $Axis9  $Floor28; 
node 290800   $Axis8  $Floor29; node 290900   $Axis9  $Floor29; 
node 300800   $Axis8  $Floor30; node 300900   $Axis9  $Floor30; 
node 310800   $Axis8  $Floor31; node 310900   $Axis9  $Floor31; 
node 320800   $Axis8  $Floor32; node 320900   $Axis9  $Floor32; 
node 330800   $Axis8  $Floor33; node 330900   $Axis9  $Floor33; 
node 340800   $Axis8  $Floor34; node 340900   $Axis9  $Floor34; 
node 350800   $Axis8  $Floor35; node 350900   $Axis9  $Floor35; 
node 360800   $Axis8  $Floor36; node 360900   $Axis9  $Floor36; 

# EGF BEAM NODES
node 20804  $Axis8  $Floor2; node 20902  $Axis9  $Floor2; 
node 30804  $Axis8  $Floor3; node 30902  $Axis9  $Floor3; 
node 40804  $Axis8  $Floor4; node 40902  $Axis9  $Floor4; 
node 50804  $Axis8  $Floor5; node 50902  $Axis9  $Floor5; 
node 60804  $Axis8  $Floor6; node 60902  $Axis9  $Floor6; 
node 70804  $Axis8  $Floor7; node 70902  $Axis9  $Floor7; 
node 80804  $Axis8  $Floor8; node 80902  $Axis9  $Floor8; 
node 90804  $Axis8  $Floor9; node 90902  $Axis9  $Floor9; 
node 100804  $Axis8  $Floor10; node 100902  $Axis9  $Floor10; 
node 110804  $Axis8  $Floor11; node 110902  $Axis9  $Floor11; 
node 120804  $Axis8  $Floor12; node 120902  $Axis9  $Floor12; 
node 130804  $Axis8  $Floor13; node 130902  $Axis9  $Floor13; 
node 140804  $Axis8  $Floor14; node 140902  $Axis9  $Floor14; 
node 150804  $Axis8  $Floor15; node 150902  $Axis9  $Floor15; 
node 160804  $Axis8  $Floor16; node 160902  $Axis9  $Floor16; 
node 170804  $Axis8  $Floor17; node 170902  $Axis9  $Floor17; 
node 180804  $Axis8  $Floor18; node 180902  $Axis9  $Floor18; 
node 190804  $Axis8  $Floor19; node 190902  $Axis9  $Floor19; 
node 200804  $Axis8  $Floor20; node 200902  $Axis9  $Floor20; 
node 210804  $Axis8  $Floor21; node 210902  $Axis9  $Floor21; 
node 220804  $Axis8  $Floor22; node 220902  $Axis9  $Floor22; 
node 230804  $Axis8  $Floor23; node 230902  $Axis9  $Floor23; 
node 240804  $Axis8  $Floor24; node 240902  $Axis9  $Floor24; 
node 250804  $Axis8  $Floor25; node 250902  $Axis9  $Floor25; 
node 260804  $Axis8  $Floor26; node 260902  $Axis9  $Floor26; 
node 270804  $Axis8  $Floor27; node 270902  $Axis9  $Floor27; 
node 280804  $Axis8  $Floor28; node 280902  $Axis9  $Floor28; 
node 290804  $Axis8  $Floor29; node 290902  $Axis9  $Floor29; 
node 300804  $Axis8  $Floor30; node 300902  $Axis9  $Floor30; 
node 310804  $Axis8  $Floor31; node 310902  $Axis9  $Floor31; 
node 320804  $Axis8  $Floor32; node 320902  $Axis9  $Floor32; 
node 330804  $Axis8  $Floor33; node 330902  $Axis9  $Floor33; 
node 340804  $Axis8  $Floor34; node 340902  $Axis9  $Floor34; 
node 350804  $Axis8  $Floor35; node 350902  $Axis9  $Floor35; 
node 360804  $Axis8  $Floor36; node 360902  $Axis9  $Floor36; 

###################################################################################################
#                                  PANEL ZONE NODES & ELEMENTS                                    #
###################################################################################################

# CROSS PANEL ZONE NODES AND ELASTIC ELEMENTS
# Command Syntax; 
# ConstructPanel_Cross Axis Floor X_Axis Y_Floor E A_Panel I_Panel d_Col d_Beam transfTag 

# Panel zones floor2
ConstructPanel_Cross      1 2 $Axis1 $Floor2 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      2 2 $Axis2 $Floor2 $Es $A_Stiff $I_Stiff 35.80 42.10 $trans_selected;
ConstructPanel_Cross      3 2 $Axis3 $Floor2 $Es $A_Stiff $I_Stiff 35.80 42.10 $trans_selected;
ConstructPanel_Cross      4 2 $Axis4 $Floor2 $Es $A_Stiff $I_Stiff 35.80 42.10 $trans_selected;
ConstructPanel_Cross      6 2 $Axis6 $Floor2 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      7 2 $Axis7 $Floor2 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;

# Panel zones floor3
ConstructPanel_Cross      1 3 $Axis1 $Floor3 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      2 3 $Axis2 $Floor3 $Es $A_Stiff $I_Stiff 35.80 42.10 $trans_selected;
ConstructPanel_Cross      3 3 $Axis3 $Floor3 $Es $A_Stiff $I_Stiff 35.80 42.10 $trans_selected;
ConstructPanel_Cross      4 3 $Axis4 $Floor3 $Es $A_Stiff $I_Stiff 35.80 42.10 $trans_selected;
ConstructPanel_Cross      6 3 $Axis6 $Floor3 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      7 3 $Axis7 $Floor3 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;

# Panel zones floor4
ConstructPanel_Cross      1 4 $Axis1 $Floor4 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      2 4 $Axis2 $Floor4 $Es $A_Stiff $I_Stiff 35.80 42.10 $trans_selected;
ConstructPanel_Cross      3 4 $Axis3 $Floor4 $Es $A_Stiff $I_Stiff 35.80 42.10 $trans_selected;
ConstructPanel_Cross      4 4 $Axis4 $Floor4 $Es $A_Stiff $I_Stiff 35.80 42.10 $trans_selected;
ConstructPanel_Cross      5 4 $Axis5 $Floor4 $Es $A_Stiff $I_Stiff 35.80 42.10 $trans_selected;
ConstructPanel_Cross      6 4 $Axis6 $Floor4 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      7 4 $Axis7 $Floor4 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;

# Panel zones floor5
ConstructPanel_Cross      1 5 $Axis1 $Floor5 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      2 5 $Axis2 $Floor5 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      3 5 $Axis3 $Floor5 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      4 5 $Axis4 $Floor5 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      5 5 $Axis5 $Floor5 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      6 5 $Axis6 $Floor5 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      7 5 $Axis7 $Floor5 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;

# Panel zones floor6
ConstructPanel_Cross      1 6 $Axis1 $Floor6 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      2 6 $Axis2 $Floor6 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      3 6 $Axis3 $Floor6 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      4 6 $Axis4 $Floor6 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      5 6 $Axis5 $Floor6 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      6 6 $Axis6 $Floor6 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      7 6 $Axis7 $Floor6 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;

# Panel zones floor7
ConstructPanel_Cross      1 7 $Axis1 $Floor7 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      2 7 $Axis2 $Floor7 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      3 7 $Axis3 $Floor7 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      4 7 $Axis4 $Floor7 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      5 7 $Axis5 $Floor7 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      6 7 $Axis6 $Floor7 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      7 7 $Axis7 $Floor7 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;

# Panel zones floor8
ConstructPanel_Cross      3 8 $Axis3 $Floor8 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      4 8 $Axis4 $Floor8 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      5 8 $Axis5 $Floor8 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      6 8 $Axis6 $Floor8 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      7 8 $Axis7 $Floor8 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;

# Panel zones floor9
ConstructPanel_Cross      3 9 $Axis3 $Floor9 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      4 9 $Axis4 $Floor9 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      5 9 $Axis5 $Floor9 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      6 9 $Axis6 $Floor9 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      7 9 $Axis7 $Floor9 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;

# Panel zones floor10
ConstructPanel_Cross      3 10 $Axis3 $Floor10 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      4 10 $Axis4 $Floor10 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      5 10 $Axis5 $Floor10 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      6 10 $Axis6 $Floor10 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;
ConstructPanel_Cross      7 10 $Axis7 $Floor10 $Es $A_Stiff $I_Stiff 24.00 42.10 $trans_selected;

# Panel zones floor11
ConstructPanel_Cross      3 11 $Axis3 $Floor11 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      4 11 $Axis4 $Floor11 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      5 11 $Axis5 $Floor11 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      6 11 $Axis6 $Floor11 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      7 11 $Axis7 $Floor11 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;

# Panel zones floor12
ConstructPanel_Cross      3 12 $Axis3 $Floor12 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      4 12 $Axis4 $Floor12 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      5 12 $Axis5 $Floor12 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      6 12 $Axis6 $Floor12 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      7 12 $Axis7 $Floor12 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;

# Panel zones floor13
ConstructPanel_Cross      3 13 $Axis3 $Floor13 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      4 13 $Axis4 $Floor13 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      5 13 $Axis5 $Floor13 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      6 13 $Axis6 $Floor13 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      7 13 $Axis7 $Floor13 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;

# Panel zones floor14
ConstructPanel_Cross      3 14 $Axis3 $Floor14 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      4 14 $Axis4 $Floor14 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      5 14 $Axis5 $Floor14 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      6 14 $Axis6 $Floor14 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      7 14 $Axis7 $Floor14 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;

# Panel zones floor15
ConstructPanel_Cross      4 15 $Axis4 $Floor15 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      5 15 $Axis5 $Floor15 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      6 15 $Axis6 $Floor15 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      7 15 $Axis7 $Floor15 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;

# Panel zones floor16
ConstructPanel_Cross      4 16 $Axis4 $Floor16 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      5 16 $Axis5 $Floor16 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      6 16 $Axis6 $Floor16 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      7 16 $Axis7 $Floor16 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;

# Panel zones floor17
ConstructPanel_Cross      4 17 $Axis4 $Floor17 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      5 17 $Axis5 $Floor17 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      6 17 $Axis6 $Floor17 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      7 17 $Axis7 $Floor17 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;

# Panel zones floor18
ConstructPanel_Cross      4 18 $Axis4 $Floor18 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      5 18 $Axis5 $Floor18 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      6 18 $Axis6 $Floor18 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;
ConstructPanel_Cross      7 18 $Axis7 $Floor18 $Es $A_Stiff $I_Stiff 24.00 35.80 $trans_selected;

# Panel zones floor19
ConstructPanel_Cross      4 19 $Axis4 $Floor19 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      5 19 $Axis5 $Floor19 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      6 19 $Axis6 $Floor19 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      7 19 $Axis7 $Floor19 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;

# Panel zones floor20
ConstructPanel_Cross      4 20 $Axis4 $Floor20 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      5 20 $Axis5 $Floor20 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      6 20 $Axis6 $Floor20 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      7 20 $Axis7 $Floor20 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;

# Panel zones floor21
ConstructPanel_Cross      4 21 $Axis4 $Floor21 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      5 21 $Axis5 $Floor21 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      6 21 $Axis6 $Floor21 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      7 21 $Axis7 $Floor21 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;

# Panel zones floor22
ConstructPanel_Cross      4 22 $Axis4 $Floor22 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      5 22 $Axis5 $Floor22 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      6 22 $Axis6 $Floor22 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      7 22 $Axis7 $Floor22 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;

# Panel zones floor23
ConstructPanel_Cross      4 23 $Axis4 $Floor23 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      5 23 $Axis5 $Floor23 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      6 23 $Axis6 $Floor23 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      7 23 $Axis7 $Floor23 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;

# Panel zones floor24
ConstructPanel_Cross      4 24 $Axis4 $Floor24 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      5 24 $Axis5 $Floor24 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      6 24 $Axis6 $Floor24 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      7 24 $Axis7 $Floor24 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;

# Panel zones floor25
ConstructPanel_Cross      4 25 $Axis4 $Floor25 $Es $A_Stiff $I_Stiff 26.00 42.10 $trans_selected;
ConstructPanel_Cross      5 25 $Axis5 $Floor25 $Es $A_Stiff $I_Stiff 26.00 42.10 $trans_selected;
ConstructPanel_Cross      6 25 $Axis6 $Floor25 $Es $A_Stiff $I_Stiff 26.00 42.10 $trans_selected;
ConstructPanel_Cross      7 25 $Axis7 $Floor25 $Es $A_Stiff $I_Stiff 26.00 42.10 $trans_selected;

# Panel zones floor26
ConstructPanel_Cross      4 26 $Axis4 $Floor26 $Es $A_Stiff $I_Stiff 26.00 42.10 $trans_selected;
ConstructPanel_Cross      7 26 $Axis7 $Floor26 $Es $A_Stiff $I_Stiff 26.00 42.10 $trans_selected;

# Panel zones floor27
ConstructPanel_Cross      4 27 $Axis4 $Floor27 $Es $A_Stiff $I_Stiff 26.00 42.10 $trans_selected;
ConstructPanel_Cross      7 27 $Axis7 $Floor27 $Es $A_Stiff $I_Stiff 26.00 42.10 $trans_selected;

# Panel zones floor28
ConstructPanel_Cross      4 28 $Axis4 $Floor28 $Es $A_Stiff $I_Stiff 26.00 42.10 $trans_selected;
ConstructPanel_Cross      5 28 $Axis5 $Floor28 $Es $A_Stiff $I_Stiff 26.00 42.10 $trans_selected;
ConstructPanel_Cross      6 28 $Axis6 $Floor28 $Es $A_Stiff $I_Stiff 26.00 42.10 $trans_selected;
ConstructPanel_Cross      7 28 $Axis7 $Floor28 $Es $A_Stiff $I_Stiff 26.00 42.10 $trans_selected;

# Panel zones floor29
ConstructPanel_Cross      4 29 $Axis4 $Floor29 $Es $A_Stiff $I_Stiff 26.00 42.10 $trans_selected;
ConstructPanel_Cross      5 29 $Axis5 $Floor29 $Es $A_Stiff $I_Stiff 26.00 42.10 $trans_selected;
ConstructPanel_Cross      6 29 $Axis6 $Floor29 $Es $A_Stiff $I_Stiff 26.00 42.10 $trans_selected;
ConstructPanel_Cross      7 29 $Axis7 $Floor29 $Es $A_Stiff $I_Stiff 26.00 42.10 $trans_selected;

# Panel zones floor30
ConstructPanel_Cross      6 30 $Axis6 $Floor30 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      7 30 $Axis7 $Floor30 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;

# Panel zones floor31
ConstructPanel_Cross      6 31 $Axis6 $Floor31 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      7 31 $Axis7 $Floor31 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;

# Panel zones floor32
ConstructPanel_Cross      6 32 $Axis6 $Floor32 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      7 32 $Axis7 $Floor32 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;

# Panel zones floor33
ConstructPanel_Cross      6 33 $Axis6 $Floor33 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;
ConstructPanel_Cross      7 33 $Axis7 $Floor33 $Es $A_Stiff $I_Stiff 26.00 35.80 $trans_selected;

# Panel zones floor34
ConstructPanel_Cross      6 34 $Axis6 $Floor34 $Es $A_Stiff $I_Stiff 24.00 35.40 $trans_selected;
ConstructPanel_Cross      7 34 $Axis7 $Floor34 $Es $A_Stiff $I_Stiff 24.00 35.40 $trans_selected;

# Panel zones floor35
ConstructPanel_Cross      6 35 $Axis6 $Floor35 $Es $A_Stiff $I_Stiff 24.00 35.40 $trans_selected;
ConstructPanel_Cross      7 35 $Axis7 $Floor35 $Es $A_Stiff $I_Stiff 24.00 35.40 $trans_selected;

# Panel zones floor36
ConstructPanel_Cross      6 36 $Axis6 $Floor36 $Es $A_Stiff $I_Stiff 24.00 35.40 $trans_selected;
ConstructPanel_Cross      7 36 $Axis7 $Floor36 $Es $A_Stiff $I_Stiff 24.00 35.40 $trans_selected;



####################################################################################################
#                                             BEAM ELEMENTS                                        #
####################################################################################################

# COMMAND SYNTAX 
# element elasticBeamColumn   ElementID node_i node_j ...

# Beams at floor 2 bay 1
set Ieff  [expr 32561.463 * $Comp_I]
set A   106.705
element elasticBeamColumn   1020100 4020104 4020202 $A $Es $Ieff $trans_selected

# Beams at floor 2 bay 2
set Ieff  [expr 29719.183 * $Comp_I]
set A   106.705
element elasticBeamColumn   1020200 4020204 4020302 $A $Es $Ieff $trans_selected

# Beams at floor 2 bay 3
set Ieff  [expr 29719.183 * $Comp_I]
set A   106.705
element elasticBeamColumn   1020300 4020304 4020402 $A $Es $Ieff $trans_selected

# Beams at floor 2 bay 6
set Ieff  [expr 32602.272 * $Comp_I]
set A   106.705
element elasticBeamColumn   1020600 4020604 4020702 $A $Es $Ieff $trans_selected

# Beams at floor 3 bay 1
set Ieff  [expr 32561.463 * $Comp_I]
set A   106.705
element elasticBeamColumn   1030100 4030104 4030202 $A $Es $Ieff $trans_selected

# Beams at floor 3 bay 2
set Ieff  [expr 29719.183 * $Comp_I]
set A   106.705
element elasticBeamColumn   1030200 4030204 4030302 $A $Es $Ieff $trans_selected

# Beams at floor 3 bay 3
set Ieff  [expr 29719.183 * $Comp_I]
set A   106.705
element elasticBeamColumn   1030300 4030304 4030402 $A $Es $Ieff $trans_selected

# Beams at floor 3 bay 6
set Ieff  [expr 32602.272 * $Comp_I]
set A   106.705
element elasticBeamColumn   1030600 4030604 4030702 $A $Es $Ieff $trans_selected

# Beams at floor 4 bay 1
set Ieff  [expr 32561.463 * $Comp_I]
set A   106.705
element elasticBeamColumn   1040100 4040104 4040202 $A $Es $Ieff $trans_selected

# Beams at floor 4 bay 2
set Ieff  [expr 29719.183 * $Comp_I]
set A   106.705
element elasticBeamColumn   1040200 4040204 4040302 $A $Es $Ieff $trans_selected

# Beams at floor 4 bay 3
set Ieff  [expr 29719.183 * $Comp_I]
set A   106.705
element elasticBeamColumn   1040300 4040304 4040402 $A $Es $Ieff $trans_selected

# Beams at floor 4 bay 4
set Ieff  [expr 29719.183 * $Comp_I]
set A   106.705
element elasticBeamColumn   1040400 4040404 4040502 $A $Es $Ieff $trans_selected

# Beams at floor 4 bay 5
set Ieff  [expr 29866.678 * $Comp_I]
set A   106.705
element elasticBeamColumn   1040500 4040504 4040602 $A $Es $Ieff $trans_selected

# Beams at floor 4 bay 6
set Ieff  [expr 32602.272 * $Comp_I]
set A   106.705
element elasticBeamColumn   1040600 4040604 4040702 $A $Es $Ieff $trans_selected

# Beams at floor 5 bay 1
set Ieff  [expr 32602.272 * $Comp_I]
set A   106.705
element elasticBeamColumn   1050100 4050104 4050202 $A $Es $Ieff $trans_selected

# Beams at floor 5 bay 2
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1050200 4050204 4050302 $A $Es $Ieff $trans_selected

# Beams at floor 5 bay 3
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1050300 4050304 4050402 $A $Es $Ieff $trans_selected

# Beams at floor 5 bay 4
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1050400 4050404 4050502 $A $Es $Ieff $trans_selected

# Beams at floor 5 bay 5
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1050500 4050504 4050602 $A $Es $Ieff $trans_selected

# Beams at floor 5 bay 6
set Ieff  [expr 32602.272 * $Comp_I]
set A   106.705
element elasticBeamColumn   1050600 4050604 4050702 $A $Es $Ieff $trans_selected

# Beams at floor 6 bay 1
set Ieff  [expr 32602.272 * $Comp_I]
set A   106.705
element elasticBeamColumn   1060100 4060104 4060202 $A $Es $Ieff $trans_selected

# Beams at floor 6 bay 2
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1060200 4060204 4060302 $A $Es $Ieff $trans_selected

# Beams at floor 6 bay 3
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1060300 4060304 4060402 $A $Es $Ieff $trans_selected

# Beams at floor 6 bay 4
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1060400 4060404 4060502 $A $Es $Ieff $trans_selected

# Beams at floor 6 bay 5
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1060500 4060504 4060602 $A $Es $Ieff $trans_selected

# Beams at floor 6 bay 6
set Ieff  [expr 32602.272 * $Comp_I]
set A   106.705
element elasticBeamColumn   1060600 4060604 4060702 $A $Es $Ieff $trans_selected

# Beams at floor 7 bay 1
set Ieff  [expr 32602.272 * $Comp_I]
set A   106.705
element elasticBeamColumn   1070100 4070104 4070202 $A $Es $Ieff $trans_selected

# Beams at floor 7 bay 2
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1070200 4070204 4070302 $A $Es $Ieff $trans_selected

# Beams at floor 7 bay 3
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1070300 4070304 4070402 $A $Es $Ieff $trans_selected

# Beams at floor 7 bay 4
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1070400 4070404 4070502 $A $Es $Ieff $trans_selected

# Beams at floor 7 bay 5
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1070500 4070504 4070602 $A $Es $Ieff $trans_selected

# Beams at floor 7 bay 6
set Ieff  [expr 32602.272 * $Comp_I]
set A   106.705
element elasticBeamColumn   1070600 4070604 4070702 $A $Es $Ieff $trans_selected

# Beams at floor 8 bay 3
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1080300 4080304 4080402 $A $Es $Ieff $trans_selected

# Beams at floor 8 bay 4
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1080400 4080404 4080502 $A $Es $Ieff $trans_selected

# Beams at floor 8 bay 5
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1080500 4080504 4080602 $A $Es $Ieff $trans_selected

# Beams at floor 8 bay 6
set Ieff  [expr 32602.272 * $Comp_I]
set A   106.705
element elasticBeamColumn   1080600 4080604 4080702 $A $Es $Ieff $trans_selected

# Beams at floor 9 bay 3
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1090300 4090304 4090402 $A $Es $Ieff $trans_selected

# Beams at floor 9 bay 4
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1090400 4090404 4090502 $A $Es $Ieff $trans_selected

# Beams at floor 9 bay 5
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1090500 4090504 4090602 $A $Es $Ieff $trans_selected

# Beams at floor 9 bay 6
set Ieff  [expr 32602.272 * $Comp_I]
set A   106.705
element elasticBeamColumn   1090600 4090604 4090702 $A $Es $Ieff $trans_selected

# Beams at floor 10 bay 3
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1100300 4100304 4100402 $A $Es $Ieff $trans_selected

# Beams at floor 10 bay 4
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1100400 4100404 4100502 $A $Es $Ieff $trans_selected

# Beams at floor 10 bay 5
set Ieff  [expr 30007.834 * $Comp_I]
set A   106.705
element elasticBeamColumn   1100500 4100504 4100602 $A $Es $Ieff $trans_selected

# Beams at floor 10 bay 6
set Ieff  [expr 32602.272 * $Comp_I]
set A   106.705
element elasticBeamColumn   1100600 4100604 4100702 $A $Es $Ieff $trans_selected

# Beams at floor 11 bay 3
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1110300 4110304 4110402 $A $Es $Ieff $trans_selected

# Beams at floor 11 bay 4
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1110400 4110404 4110502 $A $Es $Ieff $trans_selected

# Beams at floor 11 bay 5
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1110500 4110504 4110602 $A $Es $Ieff $trans_selected

# Beams at floor 11 bay 6
set Ieff  [expr 17334.093 * $Comp_I]
set A   73.728
element elasticBeamColumn   1110600 4110604 4110702 $A $Es $Ieff $trans_selected

# Beams at floor 12 bay 3
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1120300 4120304 4120402 $A $Es $Ieff $trans_selected

# Beams at floor 12 bay 4
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1120400 4120404 4120502 $A $Es $Ieff $trans_selected

# Beams at floor 12 bay 5
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1120500 4120504 4120602 $A $Es $Ieff $trans_selected

# Beams at floor 12 bay 6
set Ieff  [expr 17334.093 * $Comp_I]
set A   73.728
element elasticBeamColumn   1120600 4120604 4120702 $A $Es $Ieff $trans_selected

# Beams at floor 13 bay 3
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1130300 4130304 4130402 $A $Es $Ieff $trans_selected

# Beams at floor 13 bay 4
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1130400 4130404 4130502 $A $Es $Ieff $trans_selected

# Beams at floor 13 bay 5
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1130500 4130504 4130602 $A $Es $Ieff $trans_selected

# Beams at floor 13 bay 6
set Ieff  [expr 17334.093 * $Comp_I]
set A   73.728
element elasticBeamColumn   1130600 4130604 4130702 $A $Es $Ieff $trans_selected

# Beams at floor 14 bay 3
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1140300 4140304 4140402 $A $Es $Ieff $trans_selected

# Beams at floor 14 bay 4
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1140400 4140404 4140502 $A $Es $Ieff $trans_selected

# Beams at floor 14 bay 5
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1140500 4140504 4140602 $A $Es $Ieff $trans_selected

# Beams at floor 14 bay 6
set Ieff  [expr 17334.093 * $Comp_I]
set A   73.728
element elasticBeamColumn   1140600 4140604 4140702 $A $Es $Ieff $trans_selected

# Beams at floor 15 bay 4
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1150400 4150404 4150502 $A $Es $Ieff $trans_selected

# Beams at floor 15 bay 5
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1150500 4150504 4150602 $A $Es $Ieff $trans_selected

# Beams at floor 15 bay 6
set Ieff  [expr 17334.093 * $Comp_I]
set A   73.728
element elasticBeamColumn   1150600 4150604 4150702 $A $Es $Ieff $trans_selected

# Beams at floor 16 bay 4
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1160400 4160404 4160502 $A $Es $Ieff $trans_selected

# Beams at floor 16 bay 5
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1160500 4160504 4160602 $A $Es $Ieff $trans_selected

# Beams at floor 16 bay 6
set Ieff  [expr 17334.093 * $Comp_I]
set A   73.728
element elasticBeamColumn   1160600 4160604 4160702 $A $Es $Ieff $trans_selected

# Beams at floor 17 bay 4
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1170400 4170404 4170502 $A $Es $Ieff $trans_selected

# Beams at floor 17 bay 5
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1170500 4170504 4170602 $A $Es $Ieff $trans_selected

# Beams at floor 17 bay 6
set Ieff  [expr 17334.093 * $Comp_I]
set A   73.728
element elasticBeamColumn   1170600 4170604 4170702 $A $Es $Ieff $trans_selected

# Beams at floor 18 bay 4
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1180400 4180404 4180502 $A $Es $Ieff $trans_selected

# Beams at floor 18 bay 5
set Ieff  [expr 16057.561 * $Comp_I]
set A   73.728
element elasticBeamColumn   1180500 4180504 4180602 $A $Es $Ieff $trans_selected

# Beams at floor 18 bay 6
set Ieff  [expr 17334.093 * $Comp_I]
set A   73.728
element elasticBeamColumn   1180600 4180604 4180702 $A $Es $Ieff $trans_selected

# Beams at floor 19 bay 4
set Ieff  [expr 16034.205 * $Comp_I]
set A   73.728
element elasticBeamColumn   1190400 4190404 4190502 $A $Es $Ieff $trans_selected

# Beams at floor 19 bay 5
set Ieff  [expr 16034.205 * $Comp_I]
set A   73.728
element elasticBeamColumn   1190500 4190504 4190602 $A $Es $Ieff $trans_selected

# Beams at floor 19 bay 6
set Ieff  [expr 17327.399 * $Comp_I]
set A   73.728
element elasticBeamColumn   1190600 4190604 4190702 $A $Es $Ieff $trans_selected

# Beams at floor 20 bay 4
set Ieff  [expr 16034.205 * $Comp_I]
set A   73.728
element elasticBeamColumn   1200400 4200404 4200502 $A $Es $Ieff $trans_selected

# Beams at floor 20 bay 5
set Ieff  [expr 16034.205 * $Comp_I]
set A   73.728
element elasticBeamColumn   1200500 4200504 4200602 $A $Es $Ieff $trans_selected

# Beams at floor 20 bay 6
set Ieff  [expr 17327.399 * $Comp_I]
set A   73.728
element elasticBeamColumn   1200600 4200604 4200702 $A $Es $Ieff $trans_selected

# Beams at floor 21 bay 4
set Ieff  [expr 16034.205 * $Comp_I]
set A   73.728
element elasticBeamColumn   1210400 4210404 4210502 $A $Es $Ieff $trans_selected

# Beams at floor 21 bay 5
set Ieff  [expr 16034.205 * $Comp_I]
set A   73.728
element elasticBeamColumn   1210500 4210504 4210602 $A $Es $Ieff $trans_selected

# Beams at floor 21 bay 6
set Ieff  [expr 17327.399 * $Comp_I]
set A   73.728
element elasticBeamColumn   1210600 4210604 4210702 $A $Es $Ieff $trans_selected

# Beams at floor 22 bay 4
set Ieff  [expr 16034.205 * $Comp_I]
set A   73.728
element elasticBeamColumn   1220400 4220404 4220502 $A $Es $Ieff $trans_selected

# Beams at floor 22 bay 5
set Ieff  [expr 16034.205 * $Comp_I]
set A   73.728
element elasticBeamColumn   1220500 4220504 4220602 $A $Es $Ieff $trans_selected

# Beams at floor 22 bay 6
set Ieff  [expr 17327.399 * $Comp_I]
set A   73.728
element elasticBeamColumn   1220600 4220604 4220702 $A $Es $Ieff $trans_selected

# Beams at floor 23 bay 4
set Ieff  [expr 16034.205 * $Comp_I]
set A   73.728
element elasticBeamColumn   1230400 4230404 4230502 $A $Es $Ieff $trans_selected

# Beams at floor 23 bay 5
set Ieff  [expr 16034.205 * $Comp_I]
set A   73.728
element elasticBeamColumn   1230500 4230504 4230602 $A $Es $Ieff $trans_selected

# Beams at floor 23 bay 6
set Ieff  [expr 17327.399 * $Comp_I]
set A   73.728
element elasticBeamColumn   1230600 4230604 4230702 $A $Es $Ieff $trans_selected

# Beams at floor 24 bay 4
set Ieff  [expr 16034.205 * $Comp_I]
set A   73.728
element elasticBeamColumn   1240400 4240404 4240502 $A $Es $Ieff $trans_selected

# Beams at floor 24 bay 5
set Ieff  [expr 16034.205 * $Comp_I]
set A   73.728
element elasticBeamColumn   1240500 4240504 4240602 $A $Es $Ieff $trans_selected

# Beams at floor 24 bay 6
set Ieff  [expr 17327.399 * $Comp_I]
set A   73.728
element elasticBeamColumn   1240600 4240604 4240702 $A $Es $Ieff $trans_selected

# Beams at floor 25 bay 4
set Ieff  [expr 29960.673 * $Comp_I]
set A   106.705
element elasticBeamColumn   1250400 4250404 4250502 $A $Es $Ieff $trans_selected

# Beams at floor 25 bay 5
set Ieff  [expr 29960.673 * $Comp_I]
set A   106.705
element elasticBeamColumn   1250500 4250504 4250602 $A $Es $Ieff $trans_selected

# Beams at floor 25 bay 6
set Ieff  [expr 32588.579 * $Comp_I]
set A   106.705
element elasticBeamColumn   1250600 4250604 4250702 $A $Es $Ieff $trans_selected

# Beams at floor 26 bays 4 to 6
set Ieff  [expr 34166.591 * $Comp_I]
set A   106.705
element elasticBeamColumn   1260400 4260404 4260702 $A $Es $Ieff $trans_selected

# Beams at floor 27 bays 4 to 6
set Ieff  [expr 34166.591 * $Comp_I]
set A   106.705
element elasticBeamColumn   1270400 4270404 4270702 $A $Es $Ieff $trans_selected

# Beams at floor 28 bay 4
set Ieff  [expr 29960.673 * $Comp_I]
set A   106.705
element elasticBeamColumn   1280400 4280404 4280502 $A $Es $Ieff $trans_selected

# Beams at floor 28 bay 5
set Ieff  [expr 29960.673 * $Comp_I]
set A   106.705
element elasticBeamColumn   1280500 4280504 4280602 $A $Es $Ieff $trans_selected

# Beams at floor 28 bay 6
set Ieff  [expr 32588.579 * $Comp_I]
set A   106.705
element elasticBeamColumn   1280600 4280604 4280702 $A $Es $Ieff $trans_selected

# Beams at floor 29 bay 4
set Ieff  [expr 29960.673 * $Comp_I]
set A   106.705
element elasticBeamColumn   1290400 4290404 4290502 $A $Es $Ieff $trans_selected

# Beams at floor 29 bay 5
set Ieff  [expr 29960.673 * $Comp_I]
set A   106.705
element elasticBeamColumn   1290500 4290504 4290602 $A $Es $Ieff $trans_selected

# Beams at floor 29 bay 6
set Ieff  [expr 32588.579 * $Comp_I]
set A   106.705
element elasticBeamColumn   1290600 4290604 4290702 $A $Es $Ieff $trans_selected

# Beams at floor 30 bay 6
set Ieff  [expr 17327.399 * $Comp_I]
set A   73.728
element elasticBeamColumn   1300600 4300604 4300702 $A $Es $Ieff $trans_selected

# Beams at floor 31 bay 6
set Ieff  [expr 17327.399 * $Comp_I]
set A   73.728
element elasticBeamColumn   1310600 4310604 4310702 $A $Es $Ieff $trans_selected

# Beams at floor 32 bay 6
set Ieff  [expr 17327.399 * $Comp_I]
set A   73.728
element elasticBeamColumn   1320600 4320604 4320702 $A $Es $Ieff $trans_selected

# Beams at floor 33 bay 6
set Ieff  [expr 17327.399 * $Comp_I]
set A   73.728
element elasticBeamColumn   1330600 4330604 4330702 $A $Es $Ieff $trans_selected

# Beams at floor 34 bay 6
set Ieff  [expr 6622.453 * $Comp_I]
set A   36.101
element elasticBeamColumn   1340600 4340604 4340702 $A $Es $Ieff $trans_selected

# Beams at floor 35 bay 6
set Ieff  [expr 6622.453 * $Comp_I]
set A   36.101
element elasticBeamColumn   1350600 4350604 4350702 $A $Es $Ieff $trans_selected

# Beams at floor 36 bay 6
set Ieff  [expr 6622.453 * $Comp_I]
set A   36.101
element elasticBeamColumn   1360600 4360604 4360702 $A $Es $Ieff $trans_selected

####################################################################################################
#                                            COLUMNS ELEMENTS                                      #
####################################################################################################

# COMMAND SYNTAX 
# element elasticBeamColumn   ElementID node_i node_j ...

# Columns at story 1 axis 1
set A   192.478
set Ieff   12721.154
element elasticBeamColumn   2010100 10100 4020101 $A $Es $Ieff $trans_selected

# Columns at story 2 axis 1
set A   192.478
set Ieff   12782.262
element elasticBeamColumn   2020100 4020103 4030101 $A $Es $Ieff $trans_selected

# Columns at story 3 axis 1
set ttab 4.020
set dtab 11.172
elasticBeamColumnSplice 2030100 4030103 4040101 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 4 axis 1
set A   144.500
set Ieff   9179.193
element elasticBeamColumn   2040100 4040103 4050101 $A $Es $Ieff $trans_selected

# Columns at story 5 axis 1
set A   144.500
set Ieff   9179.193
element elasticBeamColumn   2050100 4050103 4060101 $A $Es $Ieff $trans_selected

# Columns at story 6 axis 1
set ttab 1.500
set dtab 11.900
elasticBeamColumnSplice 2060100 4060103 4070101 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 1 axis 2
set A   311.791
set Ieff   39898.626
element elasticBeamColumn   2010200 10200 4020201 $A $Es $Ieff $trans_selected

# Columns at story 2 axis 2
set A   311.791
set Ieff   40167.799
element elasticBeamColumn   2020200 4020203 4030201 $A $Es $Ieff $trans_selected

# Columns at story 3 axis 2
set ttab 6.030
set dtab 19.432
elasticBeamColumnSplice 2030200 4030203 4040201 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 4 axis 2
set A   144.500
set Ieff   9179.193
element elasticBeamColumn   2040200 4040203 4050201 $A $Es $Ieff $trans_selected

# Columns at story 5 axis 2
set A   144.500
set Ieff   9179.193
element elasticBeamColumn   2050200 4050203 4060201 $A $Es $Ieff $trans_selected

# Columns at story 6 axis 2
set ttab 1.500
set dtab 11.900
elasticBeamColumnSplice 2060200 4060203 4070201 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 2 axis 3
set A   311.791
set Ieff   40167.799
element elasticBeamColumn   2020300 4020303 4030301 $A $Es $Ieff $trans_selected

# Columns at story 3 axis 3
set ttab 6.030
set dtab 19.432
elasticBeamColumnSplice 2030300 4030303 4040301 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 4 axis 3
set A   192.478
set Ieff   12166.312
element elasticBeamColumn   2040300 4040303 4050301 $A $Es $Ieff $trans_selected

# Columns at story 5 axis 3
set A   192.478
set Ieff   12166.312
element elasticBeamColumn   2050300 4050303 4060301 $A $Es $Ieff $trans_selected

# Columns at story 6 axis 3
set ttab 4.020
set dtab 11.172
elasticBeamColumnSplice 2060300 4060303 4070301 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 7 axis 3
set A   192.478
set Ieff   12166.312
element elasticBeamColumn   2070300 4070303 4080301 $A $Es $Ieff $trans_selected

# Columns at story 8 axis 3
set A   192.478
set Ieff   12166.312
element elasticBeamColumn   2080300 4080303 4090301 $A $Es $Ieff $trans_selected

# Columns at story 9 axis 3
set ttab 4.020
set dtab 11.172
elasticBeamColumnSplice 2090300 4090303 4100301 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 10 axis 3
set A   144.500
set Ieff   9331.107
element elasticBeamColumn   2100300 4100303 4110301 $A $Es $Ieff $trans_selected

# Columns at story 11 axis 3
set A   144.500
set Ieff   9475.762
element elasticBeamColumn   2110300 4110303 4120301 $A $Es $Ieff $trans_selected

# Columns at story 12 axis 3
set ttab 1.500
set dtab 11.900
elasticBeamColumnSplice 2120300 4120303 4130301 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 13 axis 3
set A   144.500
set Ieff   9475.762
element elasticBeamColumn   2130300 4130303 4140301 $A $Es $Ieff $trans_selected

# Columns at story 1 axis 4
set A   311.791
set Ieff   39898.626
element elasticBeamColumn   2010400 10400 4020401 $A $Es $Ieff $trans_selected

# Columns at story 2 axis 4
set A   311.791
set Ieff   40167.799
element elasticBeamColumn   2020400 4020403 4030401 $A $Es $Ieff $trans_selected

# Columns at story 3 axis 4
set ttab 6.030
set dtab 19.432
elasticBeamColumnSplice 2030400 4030403 4040401 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 4 axis 4
set A   192.478
set Ieff   12166.312
element elasticBeamColumn   2040400 4040403 4050401 $A $Es $Ieff $trans_selected

# Columns at story 5 axis 4
set A   192.478
set Ieff   12166.312
element elasticBeamColumn   2050400 4050403 4060401 $A $Es $Ieff $trans_selected

# Columns at story 6 axis 4
set ttab 4.020
set dtab 11.172
elasticBeamColumnSplice 2060400 4060403 4070401 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 7 axis 4
set A   192.478
set Ieff   12166.312
element elasticBeamColumn   2070400 4070403 4080401 $A $Es $Ieff $trans_selected

# Columns at story 8 axis 4
set A   192.478
set Ieff   12166.312
element elasticBeamColumn   2080400 4080403 4090401 $A $Es $Ieff $trans_selected

# Columns at story 9 axis 4
set ttab 4.020
set dtab 11.172
elasticBeamColumnSplice 2090400 4090403 4100401 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 10 axis 4
set A   144.500
set Ieff   2793.954
element elasticBeamColumn   2100400 4100403 4110401 $A $Es $Ieff $trans_selected

# Columns at story 11 axis 4
set A   144.500
set Ieff   2797.823
element elasticBeamColumn   2110400 4110403 4120401 $A $Es $Ieff $trans_selected

# Columns at story 12 axis 4
set ttab 1.500
set dtab 11.900
elasticBeamColumnSplice 2120400 4120403 4130401 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 13 axis 4
set A   144.500
set Ieff   9475.762
element elasticBeamColumn   2130400 4130403 4140401 $A $Es $Ieff $trans_selected

# Columns at story 14 axis 4
set A   144.500
set Ieff   9475.762
element elasticBeamColumn   2140400 4140403 4150401 $A $Es $Ieff $trans_selected

# Columns at story 15 axis 4
set ttab 1.500
set dtab 11.900
elasticBeamColumnSplice 2150400 4150403 4160401 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 16 axis 4
set A   144.500
set Ieff   9475.762
element elasticBeamColumn   2160400 4160403 4170401 $A $Es $Ieff $trans_selected

# Columns at story 17 axis 4
set A   144.500
set Ieff   9475.762
element elasticBeamColumn   2170400 4170403 4180401 $A $Es $Ieff $trans_selected

# Columns at story 18 axis 4
set ttab 0.980
set dtab 14.672
elasticBeamColumnSplice 2180400 4180403 4190401 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 19 axis 4
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2190400 4190403 4200401 $A $Es $Ieff $trans_selected

# Columns at story 20 axis 4
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2200400 4200403 4210401 $A $Es $Ieff $trans_selected

# Columns at story 21 axis 4
set ttab 0.980
set dtab 14.672
elasticBeamColumnSplice 2210400 4210403 4220401 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 22 axis 4
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2220400 4220403 4230401 $A $Es $Ieff $trans_selected

# Columns at story 23 axis 4
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2230400 4230403 4240401 $A $Es $Ieff $trans_selected

# Columns at story 24 axis 4
set ttab 0.980
set dtab 14.672
elasticBeamColumnSplice 2240400 4240403 4250401 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 25 axis 4
set A   116.099
set Ieff   8420.428
element elasticBeamColumn   2250400 4250403 4260401 $A $Es $Ieff $trans_selected

# Columns at story 26 axis 4
set A   116.099
set Ieff   8420.428
element elasticBeamColumn   2260400 4260403 4270401 $A $Es $Ieff $trans_selected

# Columns at story 27 axis 4
set ttab 0.980
set dtab 14.672
elasticBeamColumnSplice 2270400 4270403 4280401 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 28 axis 4
set A   116.099
set Ieff   8420.428
element elasticBeamColumn   2280400 4280403 4290401 $A $Es $Ieff $trans_selected

# Columns at story 1 to 3 Axis 5
set A   311.791
set Ieff   46749.848
element elasticBeamColumn   2010500 10500 4040501 $A $Es $Ieff $trans_selected

# Columns at story 4 axis 5
set A   192.478
set Ieff   12166.312
element elasticBeamColumn   2040500 4040503 4050501 $A $Es $Ieff $trans_selected

# Columns at story 5 axis 5
set A   192.478
set Ieff   12166.312
element elasticBeamColumn   2050500 4050503 4060501 $A $Es $Ieff $trans_selected

# Columns at story 6 axis 5
set ttab 4.020
set dtab 11.172
elasticBeamColumnSplice 2060500 4060503 4070501 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 7 axis 5
set A   192.478
set Ieff   12166.312
element elasticBeamColumn   2070500 4070503 4080501 $A $Es $Ieff $trans_selected

# Columns at story 8 axis 5
set A   192.478
set Ieff   12166.312
element elasticBeamColumn   2080500 4080503 4090501 $A $Es $Ieff $trans_selected

# Columns at story 9 axis 5
set ttab 4.020
set dtab 11.172
elasticBeamColumnSplice 2090500 4090503 4100501 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 10 axis 5
set A   144.500
set Ieff   2793.954
element elasticBeamColumn   2100500 4100503 4110501 $A $Es $Ieff $trans_selected

# Columns at story 11 axis 5
set A   144.500
set Ieff   2797.823
element elasticBeamColumn   2110500 4110503 4120501 $A $Es $Ieff $trans_selected

# Columns at story 12 axis 5
set ttab 1.500
set dtab 11.900
elasticBeamColumnSplice 2120500 4120503 4130501 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 13 axis 5
set A   144.500
set Ieff   9475.762
element elasticBeamColumn   2130500 4130503 4140501 $A $Es $Ieff $trans_selected

# Columns at story 14 axis 5
set A   144.500
set Ieff   9475.762
element elasticBeamColumn   2140500 4140503 4150501 $A $Es $Ieff $trans_selected

# Columns at story 15 axis 5
set ttab 1.500
set dtab 11.900
elasticBeamColumnSplice 2150500 4150503 4160501 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 16 axis 5
set A   144.500
set Ieff   9475.762
element elasticBeamColumn   2160500 4160503 4170501 $A $Es $Ieff $trans_selected

# Columns at story 17 axis 5
set A   144.500
set Ieff   9475.762
element elasticBeamColumn   2170500 4170503 4180501 $A $Es $Ieff $trans_selected

# Columns at story 18 axis 5
set ttab 0.980
set dtab 14.672
elasticBeamColumnSplice 2180500 4180503 4190501 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 19 axis 5
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2190500 4190503 4200501 $A $Es $Ieff $trans_selected

# Columns at story 20 axis 5
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2200500 4200503 4210501 $A $Es $Ieff $trans_selected

# Columns at story 21 axis 5
set ttab 0.980
set dtab 14.672
elasticBeamColumnSplice 2210500 4210503 4220501 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 22 axis 5
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2220500 4220503 4230501 $A $Es $Ieff $trans_selected

# Columns at story 23 axis 5
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2230500 4230503 4240501 $A $Es $Ieff $trans_selected

# Columns at story 24 axis 5
set ttab 0.980
set dtab 14.672
elasticBeamColumnSplice 2240500 4240503 4250501 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 28 axis 5
set A   116.099
set Ieff   8420.428
element elasticBeamColumn   2280500 4280503 4290501 $A $Es $Ieff $trans_selected

# Columns at story 1 axis 6
set A   192.478
set Ieff   12721.154
element elasticBeamColumn   2010600 10600 4020601 $A $Es $Ieff $trans_selected

# Columns at story 2 axis 6
set A   192.478
set Ieff   12782.262
element elasticBeamColumn   2020600 4020603 4030601 $A $Es $Ieff $trans_selected

# Columns at story 3 axis 6
set ttab 4.020
set dtab 11.172
elasticBeamColumnSplice 2030600 4030603 4040601 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 4 axis 6
set A   144.500
set Ieff   9179.193
element elasticBeamColumn   2040600 4040603 4050601 $A $Es $Ieff $trans_selected

# Columns at story 5 axis 6
set A   144.500
set Ieff   9179.193
element elasticBeamColumn   2050600 4050603 4060601 $A $Es $Ieff $trans_selected

# Columns at story 6 axis 6
set ttab 1.500
set dtab 11.900
elasticBeamColumnSplice 2060600 4060603 4070601 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 7 axis 6
set A   192.478
set Ieff   12166.312
element elasticBeamColumn   2070600 4070603 4080601 $A $Es $Ieff $trans_selected

# Columns at story 8 axis 6
set A   192.478
set Ieff   12166.312
element elasticBeamColumn   2080600 4080603 4090601 $A $Es $Ieff $trans_selected

# Columns at story 9 axis 6
set ttab 4.020
set dtab 11.172
elasticBeamColumnSplice 2090600 4090603 4100601 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 10 axis 6
set A   144.500
set Ieff   9331.107
element elasticBeamColumn   2100600 4100603 4110601 $A $Es $Ieff $trans_selected

# Columns at story 11 axis 6
set A   144.500
set Ieff   9475.762
element elasticBeamColumn   2110600 4110603 4120601 $A $Es $Ieff $trans_selected

# Columns at story 12 axis 6
set ttab 1.500
set dtab 11.900
elasticBeamColumnSplice 2120600 4120603 4130601 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 13 axis 6
set A   144.500
set Ieff   9475.762
element elasticBeamColumn   2130600 4130603 4140601 $A $Es $Ieff $trans_selected

# Columns at story 14 axis 6
set A   144.500
set Ieff   9475.762
element elasticBeamColumn   2140600 4140603 4150601 $A $Es $Ieff $trans_selected

# Columns at story 15 axis 6
set ttab 1.500
set dtab 11.900
elasticBeamColumnSplice 2150600 4150603 4160601 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 16 axis 6
set A   144.500
set Ieff   9475.762
element elasticBeamColumn   2160600 4160603 4170601 $A $Es $Ieff $trans_selected

# Columns at story 17 axis 6
set A   144.500
set Ieff   9475.762
element elasticBeamColumn   2170600 4170603 4180601 $A $Es $Ieff $trans_selected

# Columns at story 18 axis 6
set ttab 0.980
set dtab 14.672
elasticBeamColumnSplice 2180600 4180603 4190601 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 19 axis 6
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2190600 4190603 4200601 $A $Es $Ieff $trans_selected

# Columns at story 20 axis 6
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2200600 4200603 4210601 $A $Es $Ieff $trans_selected

# Columns at story 21 axis 6
set ttab 0.980
set dtab 14.672
elasticBeamColumnSplice 2210600 4210603 4220601 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 22 axis 6
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2220600 4220603 4230601 $A $Es $Ieff $trans_selected

# Columns at story 23 axis 6
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2230600 4230603 4240601 $A $Es $Ieff $trans_selected

# Columns at story 24 axis 6
set ttab 0.980
set dtab 14.672
elasticBeamColumnSplice 2240600 4240603 4250601 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 28 axis 6
set A   116.099
set Ieff   8420.428
element elasticBeamColumn   2280600 4280603 4290601 $A $Es $Ieff $trans_selected

# Columns at story 29 axis 6
set A   116.099
set Ieff   8601.935
element elasticBeamColumn   2290600 4290603 4300601 $A $Es $Ieff $trans_selected

# Columns at story 30 axis 6
set ttab 0.980
set dtab 14.672
elasticBeamColumnSplice 2300600 4300603 4310601 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 31 axis 6
set A   116.099
set Ieff   10728.855
element elasticBeamColumn   2310600 4310603 4320601 $A $Es $Ieff $trans_selected

# Columns at story 32 axis 6
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2320600 4320603 4330601 $A $Es $Ieff $trans_selected

# Columns at story 33 axis 6
set ttab 0.980
set dtab 14.700
elasticBeamColumnSplice 2330600 4330603 4340601 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 34 axis 6
set A   83.580
set Ieff   6250.042
element elasticBeamColumn   2340600 4340603 4350601 $A $Es $Ieff $trans_selected

# Columns at story 35 axis 6
set A   83.580
set Ieff   6250.042
element elasticBeamColumn   2350600 4350603 4360601 $A $Es $Ieff $trans_selected

# Columns at story 1 axis 7
set A   192.478
set Ieff   12721.154
element elasticBeamColumn   2010700 10700 4020701 $A $Es $Ieff $trans_selected

# Columns at story 2 axis 7
set A   192.478
set Ieff   12782.262
element elasticBeamColumn   2020700 4020703 4030701 $A $Es $Ieff $trans_selected

# Columns at story 3 axis 7
set ttab 4.020
set dtab 11.172
elasticBeamColumnSplice 2030700 4030703 4040701 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 4 axis 7
set A   144.500
set Ieff   9179.193
element elasticBeamColumn   2040700 4040703 4050701 $A $Es $Ieff $trans_selected

# Columns at story 5 axis 7
set A   144.500
set Ieff   9179.193
element elasticBeamColumn   2050700 4050703 4060701 $A $Es $Ieff $trans_selected

# Columns at story 6 axis 7
set ttab 1.500
set dtab 11.900
elasticBeamColumnSplice 2060700 4060703 4070701 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 7 axis 7
set A   144.500
set Ieff   9179.193
element elasticBeamColumn   2070700 4070703 4080701 $A $Es $Ieff $trans_selected

# Columns at story 8 axis 7
set A   144.500
set Ieff   9179.193
element elasticBeamColumn   2080700 4080703 4090701 $A $Es $Ieff $trans_selected

# Columns at story 9 axis 7
set ttab 1.500
set dtab 11.900
elasticBeamColumnSplice 2090700 4090703 4100701 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 10 axis 7
set A   134.790
set Ieff   9062.335
element elasticBeamColumn   2100700 4100703 4110701 $A $Es $Ieff $trans_selected

# Columns at story 11 axis 7
set A   134.790
set Ieff   9198.716
element elasticBeamColumn   2110700 4110703 4120701 $A $Es $Ieff $trans_selected

# Columns at story 12 axis 7
set ttab 1.500
set dtab 12.614
elasticBeamColumnSplice 2120700 4120703 4130701 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 13 axis 7
set A   134.790
set Ieff   9198.716
element elasticBeamColumn   2130700 4130703 4140701 $A $Es $Ieff $trans_selected

# Columns at story 14 axis 7
set A   134.790
set Ieff   9198.716
element elasticBeamColumn   2140700 4140703 4150701 $A $Es $Ieff $trans_selected

# Columns at story 15 axis 7
set ttab 1.500
set dtab 12.614
elasticBeamColumnSplice 2150700 4150703 4160701 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 16 axis 7
set A   134.790
set Ieff   9198.716
element elasticBeamColumn   2160700 4160703 4170701 $A $Es $Ieff $trans_selected

# Columns at story 17 axis 7
set A   134.790
set Ieff   9198.716
element elasticBeamColumn   2170700 4170703 4180701 $A $Es $Ieff $trans_selected

# Columns at story 18 axis 7
set ttab 0.980
set dtab 14.672
elasticBeamColumnSplice 2180700 4180703 4190701 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 19 axis 7
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2190700 4190703 4200701 $A $Es $Ieff $trans_selected

# Columns at story 20 axis 7
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2200700 4200703 4210701 $A $Es $Ieff $trans_selected

# Columns at story 21 axis 7
set ttab 0.980
set dtab 14.672
elasticBeamColumnSplice 2210700 4210703 4220701 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 22 axis 7
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2220700 4220703 4230701 $A $Es $Ieff $trans_selected

# Columns at story 23 axis 7
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2230700 4230703 4240701 $A $Es $Ieff $trans_selected

# Columns at story 24 axis 7
set ttab 0.980
set dtab 14.672
elasticBeamColumnSplice 2240700 4240703 4250701 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 25 axis 7
set A   116.099
set Ieff   8420.428
element elasticBeamColumn   2250700 4250703 4260701 $A $Es $Ieff $trans_selected

# Columns at story 26 axis 7
set A   116.099
set Ieff   8420.428
element elasticBeamColumn   2260700 4260703 4270701 $A $Es $Ieff $trans_selected

# Columns at story 27 axis 7
set ttab 0.980
set dtab 14.672
elasticBeamColumnSplice 2270700 4270703 4280701 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 28 axis 7
set A   116.099
set Ieff   8420.428
element elasticBeamColumn   2280700 4280703 4290701 $A $Es $Ieff $trans_selected

# Columns at story 29 axis 7
set A   116.099
set Ieff   8601.935
element elasticBeamColumn   2290700 4290703 4300701 $A $Es $Ieff $trans_selected

# Columns at story 30 axis 7
set ttab 0.980
set dtab 14.672
elasticBeamColumnSplice 2300700 4300703 4310701 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 31 axis 7
set A   116.099
set Ieff   10728.855
element elasticBeamColumn   2310700 4310703 4320701 $A $Es $Ieff $trans_selected

# Columns at story 32 axis 7
set A   116.099
set Ieff   8776.439
element elasticBeamColumn   2320700 4320703 4330701 $A $Es $Ieff $trans_selected

# Columns at story 33 axis 7
set ttab 0.980
set dtab 14.700
elasticBeamColumnSplice 2330700 4330703 4340701 "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;

# Columns at story 34 axis 7
set A   83.580
set Ieff   6250.042
element elasticBeamColumn   2340700 4340703 4350701 $A $Es $Ieff $trans_selected

# Columns at story 35 axis 7
set A   83.580
set Ieff   6250.042
element elasticBeamColumn   2350700 4350703 4360701 $A $Es $Ieff $trans_selected

####################################################################################################
#                                              FLOOR LINKS                                         #
####################################################################################################

# Command Syntax 
# element truss $ElementID $iNode $jNode $Area $matID
element truss 1036 4360704 360800 $A_Stiff $rigMatTag;
element truss 1035 4350704 350800 $A_Stiff $rigMatTag;
element truss 1034 4340704 340800 $A_Stiff $rigMatTag;
element truss 1033 4330704 330800 $A_Stiff $rigMatTag;
element truss 1032 4320704 320800 $A_Stiff $rigMatTag;
element truss 1031 4310704 310800 $A_Stiff $rigMatTag;
element truss 1030 4300704 300800 $A_Stiff $rigMatTag;
element truss 1029 4290704 290800 $A_Stiff $rigMatTag;
element truss 1028 4280704 280800 $A_Stiff $rigMatTag;
element truss 1027 4270704 270800 $A_Stiff $rigMatTag;
element truss 1026 4260704 260800 $A_Stiff $rigMatTag;
element truss 1025 4250704 250800 $A_Stiff $rigMatTag;
element truss 1024 4240704 240800 $A_Stiff $rigMatTag;
element truss 1023 4230704 230800 $A_Stiff $rigMatTag;
element truss 1022 4220704 220800 $A_Stiff $rigMatTag;
element truss 1021 4210704 210800 $A_Stiff $rigMatTag;
element truss 1020 4200704 200800 $A_Stiff $rigMatTag;
element truss 1019 4190704 190800 $A_Stiff $rigMatTag;
element truss 1018 4180704 180800 $A_Stiff $rigMatTag;
element truss 1017 4170704 170800 $A_Stiff $rigMatTag;
element truss 1016 4160704 160800 $A_Stiff $rigMatTag;
element truss 1015 4150704 150800 $A_Stiff $rigMatTag;
element truss 1014 4140704 140800 $A_Stiff $rigMatTag;
element truss 1013 4130704 130800 $A_Stiff $rigMatTag;
element truss 1012 4120704 120800 $A_Stiff $rigMatTag;
element truss 1011 4110704 110800 $A_Stiff $rigMatTag;
element truss 1010 4100704 100800 $A_Stiff $rigMatTag;
element truss 1009 4090704 90800 $A_Stiff $rigMatTag;
element truss 1008 4080704 80800 $A_Stiff $rigMatTag;
element truss 1007 4070704 70800 $A_Stiff $rigMatTag;
element truss 1006 4060704 60800 $A_Stiff $rigMatTag;
element truss 1005 4050704 50800 $A_Stiff $rigMatTag;
element truss 1004 4040704 40800 $A_Stiff $rigMatTag;
element truss 1003 4030704 30800 $A_Stiff $rigMatTag;
element truss 1002 4020704 20800 $A_Stiff $rigMatTag;

####################################################################################################
#                                          EGF COLUMNS AND BEAMS                                   #
####################################################################################################

# GRAVITY COLUMNS
set A   26.500
set Ieff   904.925
element elasticBeamColumn   601800 10800 20800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   601900 10900 20900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   926.644
element elasticBeamColumn   602800 20800 30800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   602900 20900 30900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   926.644
element elasticBeamColumn   603800 30800 40800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   603900 30900 40900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   604800 40800 50800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   604900 40900 50900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   605800 50800 60800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   605900 50900 60900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   606800 60800 70800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   606900 60900 70900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   607800 70800 80800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   607900 70900 80900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   608800 80800 90800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   608900 80900 90900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   609800 90800 100800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   609900 90900 100900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   610800 100800 110800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   610900 100900 110900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   611800 110800 120800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   611900 110900 120900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   612800 120800 130800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   612900 120900 130900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   613800 130800 140800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   613900 130900 140900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   614800 140800 150800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   614900 140900 150900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   615800 150800 160800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   615900 150900 160900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   616800 160800 170800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   616900 160900 170900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   617800 170800 180800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   617900 170900 180900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   618800 180800 190800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   618900 180900 190900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   619800 190800 200800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   619900 190900 200900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   620800 200800 210800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   620900 200900 210900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   621800 210800 220800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   621900 210900 220900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   622800 220800 230800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   622900 220900 230900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   623800 230800 240800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   623900 230900 240900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   624800 240800 250800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   624900 240900 250900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   625800 250800 260800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   625900 250900 260900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   626800 260800 270800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   626900 260900 270900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   627800 270800 280800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   627900 270900 280900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   628800 280800 290800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   628900 280900 290900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   629800 290800 300800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   629900 290900 300900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   630800 300800 310800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   630900 300900 310900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   941.749
element elasticBeamColumn   631800 310800 320800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   631900 310900 320900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   632800 320800 330800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   632900 320900 330900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   633800 330800 340800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   633900 330900 340900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   634800 340800 350800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   634900 340900 350900 $A $Es $Ieff $trans_selected
set A   26.500
set Ieff   904.925
element elasticBeamColumn   635800 350800 360800 $A $Es $Ieff $trans_selected
element elasticBeamColumn   635900 350900 360900 $A $Es $Ieff $trans_selected

# GRAVITY BEAMS
element elasticBeamColumn  502700   20804   20902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  503700   30804   30902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  504700   40804   40902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  505700   50804   50902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  506700   60804   60902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  507700   70804   70902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  508700   80804   80902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  509700   90804   90902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  510700  100804  100902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  511700  110804  110902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  512700  120804  120902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  513700  130804  130902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  514700  140804  140902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  515700  150804  150902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  516700  160804  160902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  517700  170804  170902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  518700  180804  180902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  519700  190804  190902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  520700  200804  200902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  521700  210804  210902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  522700  220804  220902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  523700  230804  230902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  524700  240804  240902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  525700  250804  250902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  526700  260804  260902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  527700  270804  270902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  528700  280804  280902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  529700  290804  290902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  530700  300804  300902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  531700  310804  310902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  532700  320804  320902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  533700  330804  330902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  534700  340804  340902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  535700  350804  350902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;
element elasticBeamColumn  536700  360804  360902 145.8000 $Es [expr $Comp_I_GC * 12150.0000] $trans_selected;

# GRAVITY BEAMS SPRINGS
equalDOF   20800   20804 1 2 3;equalDOF   20900   20902 1 2 3;
equalDOF   30800   30804 1 2 3;equalDOF   30900   30902 1 2 3;
equalDOF   40800   40804 1 2 3;equalDOF   40900   40902 1 2 3;
equalDOF   50800   50804 1 2 3;equalDOF   50900   50902 1 2 3;
equalDOF   60800   60804 1 2 3;equalDOF   60900   60902 1 2 3;
equalDOF   70800   70804 1 2 3;equalDOF   70900   70902 1 2 3;
equalDOF   80800   80804 1 2 3;equalDOF   80900   80902 1 2 3;
equalDOF   90800   90804 1 2 3;equalDOF   90900   90902 1 2 3;
equalDOF  100800  100804 1 2 3;equalDOF  100900  100902 1 2 3;
equalDOF  110800  110804 1 2 3;equalDOF  110900  110902 1 2 3;
equalDOF  120800  120804 1 2 3;equalDOF  120900  120902 1 2 3;
equalDOF  130800  130804 1 2 3;equalDOF  130900  130902 1 2 3;
equalDOF  140800  140804 1 2 3;equalDOF  140900  140902 1 2 3;
equalDOF  150800  150804 1 2 3;equalDOF  150900  150902 1 2 3;
equalDOF  160800  160804 1 2 3;equalDOF  160900  160902 1 2 3;
equalDOF  170800  170804 1 2 3;equalDOF  170900  170902 1 2 3;
equalDOF  180800  180804 1 2 3;equalDOF  180900  180902 1 2 3;
equalDOF  190800  190804 1 2 3;equalDOF  190900  190902 1 2 3;
equalDOF  200800  200804 1 2 3;equalDOF  200900  200902 1 2 3;
equalDOF  210800  210804 1 2 3;equalDOF  210900  210902 1 2 3;
equalDOF  220800  220804 1 2 3;equalDOF  220900  220902 1 2 3;
equalDOF  230800  230804 1 2 3;equalDOF  230900  230902 1 2 3;
equalDOF  240800  240804 1 2 3;equalDOF  240900  240902 1 2 3;
equalDOF  250800  250804 1 2 3;equalDOF  250900  250902 1 2 3;
equalDOF  260800  260804 1 2 3;equalDOF  260900  260902 1 2 3;
equalDOF  270800  270804 1 2 3;equalDOF  270900  270902 1 2 3;
equalDOF  280800  280804 1 2 3;equalDOF  280900  280902 1 2 3;
equalDOF  290800  290804 1 2 3;equalDOF  290900  290902 1 2 3;
equalDOF  300800  300804 1 2 3;equalDOF  300900  300902 1 2 3;
equalDOF  310800  310804 1 2 3;equalDOF  310900  310902 1 2 3;
equalDOF  320800  320804 1 2 3;equalDOF  320900  320902 1 2 3;
equalDOF  330800  330804 1 2 3;equalDOF  330900  330902 1 2 3;
equalDOF  340800  340804 1 2 3;equalDOF  340900  340902 1 2 3;
equalDOF  350800  350804 1 2 3;equalDOF  350900  350902 1 2 3;
equalDOF  360800  360804 1 2 3;equalDOF  360900  360902 1 2 3;

###################################################################################################
#                                       BOUNDARY CONDITIONS                                       #
###################################################################################################

# FRAME BASE SUPPORTS
fix 10100 1 1 1;
fix 10200 1 1 1;
fix 10400 1 1 1;
fix 10500 1 1 1;
fix 10600 1 1 1;
fix 10700 1 1 1;

# EGF SUPPORTS
fix 10800 1 1 0; fix 10900 1 1 0; 

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
mass 4020103 0.4148  0.0041 108.4972;
mass 4020203 0.4965  0.0050 129.8591;
mass 4020303 1.5635  0.0156 169.0751;
mass 4020403 0.3695  0.0037 39.9556;
mass 4020603 0.3695  0.0037 39.9556;
mass 4020703 0.3695  0.0037 96.6372;
# Panel zones floor3
mass 4030103 0.1270  0.0013 33.2218;
mass 4030203 0.2087  0.0021 54.5838;
mass 4030303 0.1633  0.0016 17.6646;
mass 4030403 0.0817  0.0008 8.8323;
mass 4030603 0.0817  0.0008 8.8323;
mass 4030703 0.0817  0.0008 21.3619;
# Panel zones floor4
mass 4040103 0.1270  0.0013 33.2218;
mass 4040203 0.2087  0.0021 54.5838;
mass 4040303 0.1633  0.0016 17.6646;
mass 4040403 0.1633  0.0016 17.6646;
mass 4040503 0.1633  0.0016 17.6646;
mass 4040603 0.1633  0.0016 17.6646;
mass 4040703 0.0817  0.0008 21.3619;
# Panel zones floor5
mass 4050103 0.1270  0.0013 33.2218;
mass 4050203 0.2087  0.0021 54.5838;
mass 4050303 0.1633  0.0016 17.6646;
mass 4050403 0.1633  0.0016 17.6646;
mass 4050503 0.1633  0.0016 17.6646;
mass 4050603 0.1633  0.0016 17.6646;
mass 4050703 0.0817  0.0008 21.3619;
# Panel zones floor6
mass 4060103 0.1270  0.0013 33.2218;
mass 4060203 0.2087  0.0021 54.5838;
mass 4060303 0.1633  0.0016 17.6646;
mass 4060403 0.1633  0.0016 17.6646;
mass 4060503 0.1633  0.0016 17.6646;
mass 4060603 0.1633  0.0016 17.6646;
mass 4060703 0.0817  0.0008 21.3619;
# Panel zones floor7
mass 4070103 0.3020  0.0030 78.9974;
mass 4070203 0.3837  0.0038 100.3593;
mass 4070303 0.0933  0.0009 10.0940;
mass 4070403 0.0933  0.0009 10.0940;
mass 4070503 0.0933  0.0009 10.0940;
mass 4070603 0.0933  0.0009 10.0940;
mass 4070703 0.0117  0.0001 3.0517;
# Panel zones floor8
mass 4080303 0.0817  0.0008 8.8323;
mass 4080403 0.1633  0.0016 17.6646;
mass 4080503 0.1633  0.0016 17.6646;
mass 4080603 0.1633  0.0016 17.6646;
mass 4080703 0.0817  0.0008 21.3619;
# Panel zones floor9
mass 4090303 0.0817  0.0008 8.8323;
mass 4090403 0.1633  0.0016 17.6646;
mass 4090503 0.1633  0.0016 17.6646;
mass 4090603 0.1633  0.0016 17.6646;
mass 4090703 0.0817  0.0008 21.3619;
# Panel zones floor10
mass 4100303 0.0817  0.0008 8.8323;
mass 4100403 0.0817  0.0008 8.8323;
mass 4100503 0.0817  0.0008 8.8323;
mass 4100603 0.1633  0.0016 17.6646;
mass 4100703 0.0817  0.0008 21.3619;
# Panel zones floor11
mass 4110303 0.0817  0.0008 8.8323;
mass 4110403 0.0817  0.0008 8.8323;
mass 4110503 0.0817  0.0008 8.8323;
mass 4110603 0.1633  0.0016 17.6646;
mass 4110703 0.0817  0.0008 21.3619;
# Panel zones floor12
mass 4120303 0.0817  0.0008 8.8323;
mass 4120403 0.1633  0.0016 17.6646;
mass 4120503 0.1633  0.0016 17.6646;
mass 4120603 0.1633  0.0016 17.6646;
mass 4120703 0.0817  0.0008 21.3619;
# Panel zones floor13
mass 4130303 0.0817  0.0008 8.8323;
mass 4130403 0.1633  0.0016 17.6646;
mass 4130503 0.1633  0.0016 17.6646;
mass 4130603 0.1633  0.0016 17.6646;
mass 4130703 0.0817  0.0008 21.3619;
# Panel zones floor14
mass 4140303 0.3267  0.0033 35.3291;
mass 4140403 0.1021  0.0010 11.0404;
mass 4140503 0.1021  0.0010 11.0404;
mass 4140603 0.1021  0.0010 11.0404;
mass 4140703 0.0204  0.0002 5.3405;
# Panel zones floor15
mass 4150403 0.0817  0.0008 8.8323;
mass 4150503 0.1633  0.0016 17.6646;
mass 4150603 0.1633  0.0016 17.6646;
mass 4150703 0.0817  0.0008 21.3619;
# Panel zones floor16
mass 4160403 0.0817  0.0008 8.8323;
mass 4160503 0.1633  0.0016 17.6646;
mass 4160603 0.1633  0.0016 17.6646;
mass 4160703 0.0817  0.0008 21.3619;
# Panel zones floor17
mass 4170403 0.0817  0.0008 8.8323;
mass 4170503 0.1633  0.0016 17.6646;
mass 4170603 0.1633  0.0016 17.6646;
mass 4170703 0.0817  0.0008 21.3619;
# Panel zones floor18
mass 4180403 0.0817  0.0008 8.8323;
mass 4180503 0.1633  0.0016 17.6646;
mass 4180603 0.1633  0.0016 17.6646;
mass 4180703 0.0817  0.0008 21.3619;
# Panel zones floor19
mass 4190403 0.0817  0.0008 8.8323;
mass 4190503 0.1633  0.0016 17.6646;
mass 4190603 0.1633  0.0016 17.6646;
mass 4190703 0.0817  0.0008 21.3619;
# Panel zones floor20
mass 4200403 0.0817  0.0008 8.8323;
mass 4200503 0.1633  0.0016 17.6646;
mass 4200603 0.1633  0.0016 17.6646;
mass 4200703 0.0817  0.0008 21.3619;
# Panel zones floor21
mass 4210403 0.0817  0.0008 8.8323;
mass 4210503 0.1633  0.0016 17.6646;
mass 4210603 0.1633  0.0016 17.6646;
mass 4210703 0.0817  0.0008 21.3619;
# Panel zones floor22
mass 4220403 0.0817  0.0008 8.8323;
mass 4220503 0.1633  0.0016 17.6646;
mass 4220603 0.1633  0.0016 17.6646;
mass 4220703 0.0817  0.0008 21.3619;
# Panel zones floor23
mass 4230403 0.0817  0.0008 8.8323;
mass 4230503 0.1633  0.0016 17.6646;
mass 4230603 0.1633  0.0016 17.6646;
mass 4230703 0.0817  0.0008 21.3619;
# Panel zones floor24
mass 4240403 0.0817  0.0008 8.8323;
mass 4240503 0.1633  0.0016 17.6646;
mass 4240603 0.1633  0.0016 17.6646;
mass 4240703 0.0817  0.0008 21.3619;
# Panel zones floor25
mass 4250403 0.2246  0.0022 24.2888;
mass 4250503 0.9597  0.0096 103.7793;
mass 4250603 1.5314  0.0153 165.6053;
mass 4250703 0.2246  0.0022 58.7453;
# Panel zones floor26
mass 4260403 0.1633  0.0016 17.6646;
mass 4260703 0.1633  0.0016 42.7238;
# Panel zones floor27
mass 4270403 0.1633  0.0016 17.6646;
mass 4270703 0.1633  0.0016 42.7238;
# Panel zones floor28
mass 4280403 0.6942  0.0069 75.0744;
mass 4280503 0.1633  0.0016 17.6646;
mass 4280603 0.7351  0.0074 79.4906;
mass 4280703 0.6942  0.0069 181.5763;
# Panel zones floor29
mass 4290403 0.0817  0.0008 8.8323;
mass 4290503 0.1633  0.0016 17.6646;
mass 4290603 0.1633  0.0016 17.6646;
mass 4290703 0.0817  0.0008 21.3619;
# Panel zones floor30
mass 4300603 0.0817  0.0008 8.8323;
mass 4300703 0.0817  0.0008 21.3619;
# Panel zones floor31
mass 4310603 0.0817  0.0008 8.8323;
mass 4310703 0.0817  0.0008 21.3619;
# Panel zones floor32
mass 4320603 0.0817  0.0008 8.8323;
mass 4320703 0.0817  0.0008 21.3619;
# Panel zones floor33
mass 4330603 0.0817  0.0008 8.8323;
mass 4330703 0.0817  0.0008 21.3619;
# Panel zones floor34
mass 4340603 0.0817  0.0008 8.8323;
mass 4340703 0.0817  0.0008 21.3619;
# Panel zones floor35
mass 4350603 0.0817  0.0008 8.8323;
mass 4350703 0.0817  0.0008 21.3619;
# Panel zones floor36
mass 4360603 0.0817  0.0008 8.8323;
mass 4360703 0.0817  0.0008 21.3619;

# MASS ON THE GRAVITY SYSTEM

mass 10800 0.4464  0.4464 21.3619;	mass 10900 0.4464  0.4464 21.3619;
mass 20800 0.4464  0.4464 21.3619;	mass 20900 0.4464  0.4464 21.3619;
mass 30800 0.6425  0.6425 21.3619;	mass 30900 0.6425  0.6425 21.3619;
mass 40800 0.6425  0.6425 21.3619;	mass 40900 0.6425  0.6425 21.3619;
mass 50800 0.6425  0.6425 21.3619;	mass 50900 0.6425  0.6425 21.3619;
mass 60800 0.6425  0.6425 21.3619;	mass 60900 0.6425  0.6425 21.3619;
mass 70800 0.3920  0.3920 21.3619;	mass 70900 0.3920  0.3920 21.3619;
mass 80800 0.3920  0.3920 21.3619;	mass 80900 0.3920  0.3920 21.3619;
mass 90800 0.2940  0.2940 21.3619;	mass 90900 0.2940  0.2940 21.3619;
mass 100800 0.2940  0.2940 21.3619;	mass 100900 0.2940  0.2940 21.3619;
mass 110800 0.3920  0.3920 21.3619;	mass 110900 0.3920  0.3920 21.3619;
mass 120800 0.3920  0.3920 21.3619;	mass 120900 0.3920  0.3920 21.3619;
mass 130800 0.3920  0.3920 21.3619;	mass 130900 0.3920  0.3920 21.3619;
mass 140800 0.2940  0.2940 21.3619;	mass 140900 0.2940  0.2940 21.3619;
mass 150800 0.2940  0.2940 21.3619;	mass 150900 0.2940  0.2940 21.3619;
mass 160800 0.2940  0.2940 21.3619;	mass 160900 0.2940  0.2940 21.3619;
mass 170800 0.2940  0.2940 21.3619;	mass 170900 0.2940  0.2940 21.3619;
mass 180800 0.2940  0.2940 21.3619;	mass 180900 0.2940  0.2940 21.3619;
mass 190800 0.2940  0.2940 21.3619;	mass 190900 0.2940  0.2940 21.3619;
mass 200800 0.2940  0.2940 21.3619;	mass 200900 0.2940  0.2940 21.3619;
mass 210800 0.2940  0.2940 21.3619;	mass 210900 0.2940  0.2940 21.3619;
mass 220800 0.2940  0.2940 21.3619;	mass 220900 0.2940  0.2940 21.3619;
mass 230800 0.2940  0.2940 21.3619;	mass 230900 0.2940  0.2940 21.3619;
mass 240800 0.2940  0.2940 21.3619;	mass 240900 0.2940  0.2940 21.3619;
mass 250800 0.2940  0.2940 21.3619;	mass 250900 0.2940  0.2940 21.3619;
mass 260800 0.2940  0.2940 21.3619;	mass 260900 0.2940  0.2940 21.3619;
mass 270800 0.2940  0.2940 21.3619;	mass 270900 0.2940  0.2940 21.3619;
mass 280800 0.2940  0.2940 21.3619;	mass 280900 0.2940  0.2940 21.3619;
mass 290800 0.0980  0.0980 21.3619;	mass 290900 0.0980  0.0980 21.3619;
mass 300800 0.0980  0.0980 21.3619;	mass 300900 0.0980  0.0980 21.3619;
mass 310800 0.0980  0.0980 21.3619;	mass 310900 0.0980  0.0980 21.3619;
mass 320800 0.0980  0.0980 21.3619;	mass 320900 0.0980  0.0980 21.3619;
mass 330800 0.0980  0.0980 21.3619;	mass 330900 0.0980  0.0980 21.3619;
mass 340800 0.0980  0.0980 21.3619;	mass 340900 0.0980  0.0980 21.3619;
mass 350800 0.0980  0.0980 21.3619;	mass 350900 0.0980  0.0980 21.3619;

###################################################################################################
#                                            GRAVITY LOAD                                         #
###################################################################################################

pattern Plain 101 Linear {

	# MR Frame: Distributed beam element loads
	# Floor 2
	eleLoad -ele 1020100 -type -beamUniform   -0.09247; # Beam at floor 2 bay 1
	eleLoad -ele 1020200 -type -beamUniform   -0.09720; # Beam at floor 2 bay 2
	eleLoad -ele 1020300 -type -beamUniform   -0.09720; # Beam at floor 2 bay 3
	eleLoad -ele 1020600 -type -beamUniform   -0.05881; # Beam at floor 2 bay 6
	# Floor 3
	eleLoad -ele 1030100 -type -beamUniform   -0.09247; # Beam at floor 3 bay 1
	eleLoad -ele 1030200 -type -beamUniform   -0.09720; # Beam at floor 3 bay 2
	eleLoad -ele 1030300 -type -beamUniform   -0.09720; # Beam at floor 3 bay 3
	eleLoad -ele 1030600 -type -beamUniform   -0.05881; # Beam at floor 3 bay 6
	# Floor 4
	eleLoad -ele 1040100 -type -beamUniform   -0.09247; # Beam at floor 4 bay 1
	eleLoad -ele 1040200 -type -beamUniform   -0.09720; # Beam at floor 4 bay 2
	eleLoad -ele 1040300 -type -beamUniform   -0.09720; # Beam at floor 4 bay 3
	eleLoad -ele 1040400 -type -beamUniform   -0.09720; # Beam at floor 4 bay 4
	eleLoad -ele 1040500 -type -beamUniform   -0.09546; # Beam at floor 4 bay 5
	eleLoad -ele 1040600 -type -beamUniform   -0.05881; # Beam at floor 4 bay 6
	# Floor 5
	eleLoad -ele 1050100 -type -beamUniform   -0.09145; # Beam at floor 5 bay 1
	eleLoad -ele 1050200 -type -beamUniform   -0.09379; # Beam at floor 5 bay 2
	eleLoad -ele 1050300 -type -beamUniform   -0.09379; # Beam at floor 5 bay 3
	eleLoad -ele 1050400 -type -beamUniform   -0.09379; # Beam at floor 5 bay 4
	eleLoad -ele 1050500 -type -beamUniform   -0.09379; # Beam at floor 5 bay 5
	eleLoad -ele 1050600 -type -beamUniform   -0.05881; # Beam at floor 5 bay 6
	# Floor 6
	eleLoad -ele 1060100 -type -beamUniform   -0.09145; # Beam at floor 6 bay 1
	eleLoad -ele 1060200 -type -beamUniform   -0.09379; # Beam at floor 6 bay 2
	eleLoad -ele 1060300 -type -beamUniform   -0.09379; # Beam at floor 6 bay 3
	eleLoad -ele 1060400 -type -beamUniform   -0.09379; # Beam at floor 6 bay 4
	eleLoad -ele 1060500 -type -beamUniform   -0.09379; # Beam at floor 6 bay 5
	eleLoad -ele 1060600 -type -beamUniform   -0.05881; # Beam at floor 6 bay 6
	# Floor 7
	eleLoad -ele 1070100 -type -beamUniform   -0.09145; # Beam at floor 7 bay 1
	eleLoad -ele 1070200 -type -beamUniform   -0.09379; # Beam at floor 7 bay 2
	eleLoad -ele 1070300 -type -beamUniform   -0.09379; # Beam at floor 7 bay 3
	eleLoad -ele 1070400 -type -beamUniform   -0.09379; # Beam at floor 7 bay 4
	eleLoad -ele 1070500 -type -beamUniform   -0.09379; # Beam at floor 7 bay 5
	eleLoad -ele 1070600 -type -beamUniform   -0.05881; # Beam at floor 7 bay 6
	# Floor 8
	eleLoad -ele 1080300 -type -beamUniform   -0.09379; # Beam at floor 8 bay 3
	eleLoad -ele 1080400 -type -beamUniform   -0.09379; # Beam at floor 8 bay 4
	eleLoad -ele 1080500 -type -beamUniform   -0.09379; # Beam at floor 8 bay 5
	eleLoad -ele 1080600 -type -beamUniform   -0.05881; # Beam at floor 8 bay 6
	# Floor 9
	eleLoad -ele 1090300 -type -beamUniform   -0.09379; # Beam at floor 9 bay 3
	eleLoad -ele 1090400 -type -beamUniform   -0.09379; # Beam at floor 9 bay 4
	eleLoad -ele 1090500 -type -beamUniform   -0.09379; # Beam at floor 9 bay 5
	eleLoad -ele 1090600 -type -beamUniform   -0.05881; # Beam at floor 9 bay 6
	# Floor 10
	eleLoad -ele 1100300 -type -beamUniform   -0.09379; # Beam at floor 10 bay 3
	eleLoad -ele 1100400 -type -beamUniform   -0.09379; # Beam at floor 10 bay 4
	eleLoad -ele 1100500 -type -beamUniform   -0.09379; # Beam at floor 10 bay 5
	eleLoad -ele 1100600 -type -beamUniform   -0.05881; # Beam at floor 10 bay 6
	# Floor 11
	eleLoad -ele 1110300 -type -beamUniform   -0.09379; # Beam at floor 11 bay 3
	eleLoad -ele 1110400 -type -beamUniform   -0.09379; # Beam at floor 11 bay 4
	eleLoad -ele 1110500 -type -beamUniform   -0.09379; # Beam at floor 11 bay 5
	eleLoad -ele 1110600 -type -beamUniform   -0.05881; # Beam at floor 11 bay 6
	# Floor 12
	eleLoad -ele 1120300 -type -beamUniform   -0.09379; # Beam at floor 12 bay 3
	eleLoad -ele 1120400 -type -beamUniform   -0.09379; # Beam at floor 12 bay 4
	eleLoad -ele 1120500 -type -beamUniform   -0.09379; # Beam at floor 12 bay 5
	eleLoad -ele 1120600 -type -beamUniform   -0.05881; # Beam at floor 12 bay 6
	# Floor 13
	eleLoad -ele 1130300 -type -beamUniform   -0.09379; # Beam at floor 13 bay 3
	eleLoad -ele 1130400 -type -beamUniform   -0.09379; # Beam at floor 13 bay 4
	eleLoad -ele 1130500 -type -beamUniform   -0.09379; # Beam at floor 13 bay 5
	eleLoad -ele 1130600 -type -beamUniform   -0.05881; # Beam at floor 13 bay 6
	# Floor 14
	eleLoad -ele 1140300 -type -beamUniform   -0.09379; # Beam at floor 14 bay 3
	eleLoad -ele 1140400 -type -beamUniform   -0.09379; # Beam at floor 14 bay 4
	eleLoad -ele 1140500 -type -beamUniform   -0.09379; # Beam at floor 14 bay 5
	eleLoad -ele 1140600 -type -beamUniform   -0.05881; # Beam at floor 14 bay 6
	# Floor 15
	eleLoad -ele 1150400 -type -beamUniform   -0.09379; # Beam at floor 15 bay 4
	eleLoad -ele 1150500 -type -beamUniform   -0.09379; # Beam at floor 15 bay 5
	eleLoad -ele 1150600 -type -beamUniform   -0.05881; # Beam at floor 15 bay 6
	# Floor 16
	eleLoad -ele 1160400 -type -beamUniform   -0.09379; # Beam at floor 16 bay 4
	eleLoad -ele 1160500 -type -beamUniform   -0.09379; # Beam at floor 16 bay 5
	eleLoad -ele 1160600 -type -beamUniform   -0.05881; # Beam at floor 16 bay 6
	# Floor 17
	eleLoad -ele 1170400 -type -beamUniform   -0.09379; # Beam at floor 17 bay 4
	eleLoad -ele 1170500 -type -beamUniform   -0.09379; # Beam at floor 17 bay 5
	eleLoad -ele 1170600 -type -beamUniform   -0.05881; # Beam at floor 17 bay 6
	# Floor 18
	eleLoad -ele 1180400 -type -beamUniform   -0.09379; # Beam at floor 18 bay 4
	eleLoad -ele 1180500 -type -beamUniform   -0.09379; # Beam at floor 18 bay 5
	eleLoad -ele 1180600 -type -beamUniform   -0.05881; # Beam at floor 18 bay 6
	# Floor 19
	eleLoad -ele 1190400 -type -beamUniform   -0.09435; # Beam at floor 19 bay 4
	eleLoad -ele 1190500 -type -beamUniform   -0.09435; # Beam at floor 19 bay 5
	eleLoad -ele 1190600 -type -beamUniform   -0.05903; # Beam at floor 19 bay 6
	# Floor 20
	eleLoad -ele 1200400 -type -beamUniform   -0.09435; # Beam at floor 20 bay 4
	eleLoad -ele 1200500 -type -beamUniform   -0.09435; # Beam at floor 20 bay 5
	eleLoad -ele 1200600 -type -beamUniform   -0.05903; # Beam at floor 20 bay 6
	# Floor 21
	eleLoad -ele 1210400 -type -beamUniform   -0.09435; # Beam at floor 21 bay 4
	eleLoad -ele 1210500 -type -beamUniform   -0.09435; # Beam at floor 21 bay 5
	eleLoad -ele 1210600 -type -beamUniform   -0.05903; # Beam at floor 21 bay 6
	# Floor 22
	eleLoad -ele 1220400 -type -beamUniform   -0.09435; # Beam at floor 22 bay 4
	eleLoad -ele 1220500 -type -beamUniform   -0.09435; # Beam at floor 22 bay 5
	eleLoad -ele 1220600 -type -beamUniform   -0.05903; # Beam at floor 22 bay 6
	# Floor 23
	eleLoad -ele 1230400 -type -beamUniform   -0.09435; # Beam at floor 23 bay 4
	eleLoad -ele 1230500 -type -beamUniform   -0.09435; # Beam at floor 23 bay 5
	eleLoad -ele 1230600 -type -beamUniform   -0.05903; # Beam at floor 23 bay 6
	# Floor 24
	eleLoad -ele 1240400 -type -beamUniform   -0.09435; # Beam at floor 24 bay 4
	eleLoad -ele 1240500 -type -beamUniform   -0.09435; # Beam at floor 24 bay 5
	eleLoad -ele 1240600 -type -beamUniform   -0.05903; # Beam at floor 24 bay 6
	# Floor 25
	eleLoad -ele 1250400 -type -beamUniform   -0.09435; # Beam at floor 25 bay 4
	eleLoad -ele 1250500 -type -beamUniform   -0.09435; # Beam at floor 25 bay 5
	eleLoad -ele 1250600 -type -beamUniform   -0.05903; # Beam at floor 25 bay 6
	# Floor 26
	eleLoad -ele 1260400 -type -beamUniform   -0.07540; # Beams at floor 26 bays 4 to 6
	# Floor 27
	eleLoad -ele 1270400 -type -beamUniform   -0.07540; # Beams at floor 27 bays 4 to 6
	# Floor 28
	eleLoad -ele 1280400 -type -beamUniform   -0.09435; # Beam at floor 28 bay 4
	eleLoad -ele 1280500 -type -beamUniform   -0.09435; # Beam at floor 28 bay 5
	eleLoad -ele 1280600 -type -beamUniform   -0.05903; # Beam at floor 28 bay 6
	# Floor 29
	eleLoad -ele 1290400 -type -beamUniform   -0.09435; # Beam at floor 29 bay 4
	eleLoad -ele 1290500 -type -beamUniform   -0.09435; # Beam at floor 29 bay 5
	eleLoad -ele 1290600 -type -beamUniform   -0.05903; # Beam at floor 29 bay 6
	# Floor 30
	eleLoad -ele 1300600 -type -beamUniform   -0.05903; # Beam at floor 30 bay 6
	# Floor 31
	eleLoad -ele 1310600 -type -beamUniform   -0.05903; # Beam at floor 31 bay 6
	# Floor 32
	eleLoad -ele 1320600 -type -beamUniform   -0.05903; # Beam at floor 32 bay 6
	# Floor 33
	eleLoad -ele 1330600 -type -beamUniform   -0.05903; # Beam at floor 33 bay 6
	# Floor 34
	eleLoad -ele 1340600 -type -beamUniform   -0.05881; # Beam at floor 34 bay 6
	# Floor 35
	eleLoad -ele 1350600 -type -beamUniform   -0.05881; # Beam at floor 35 bay 6
	# Floor 36
	eleLoad -ele 1360600 -type -beamUniform   -0.05881; # Beam at floor 36 bay 6

	#  MR Frame: Point loads on columns
	# Floor2
	load 4020103 0.0 -24.5207 0.0;
	load 4020203 0.0 -40.2877 0.0;
	load 4020303 0.0 -31.5340 0.0;
	load 4020403 0.0 -15.7670 0.0;
	load 4020603 0.0 -15.7670 0.0;
	load 4020703 0.0 -15.7670 0.0;
	# Floor3
	load 4030103 0.0 -24.5207 0.0;
	load 4030203 0.0 -40.2877 0.0;
	load 4030303 0.0 -31.5340 0.0;
	load 4030403 0.0 -15.7670 0.0;
	load 4030603 0.0 -15.7670 0.0;
	load 4030703 0.0 -15.7670 0.0;
	# Floor4
	load 4040103 0.0 -24.5207 0.0;
	load 4040203 0.0 -40.2877 0.0;
	load 4040303 0.0 -31.5340 0.0;
	load 4040403 0.0 -31.5340 0.0;
	load 4040503 0.0 -31.5340 0.0;
	load 4040603 0.0 -31.5340 0.0;
	load 4040703 0.0 -15.7670 0.0;
	# Floor5
	load 4050103 0.0 -24.5207 0.0;
	load 4050203 0.0 -40.2877 0.0;
	load 4050303 0.0 -31.5340 0.0;
	load 4050403 0.0 -31.5340 0.0;
	load 4050503 0.0 -31.5340 0.0;
	load 4050603 0.0 -31.5340 0.0;
	load 4050703 0.0 -15.7670 0.0;
	# Floor6
	load 4060103 0.0 -24.5207 0.0;
	load 4060203 0.0 -40.2877 0.0;
	load 4060303 0.0 -31.5340 0.0;
	load 4060403 0.0 -31.5340 0.0;
	load 4060503 0.0 -31.5340 0.0;
	load 4060603 0.0 -31.5340 0.0;
	load 4060703 0.0 -15.7670 0.0;
	# Floor7
	load 4070103 0.0 -24.5207 0.0;
	load 4070203 0.0 -40.2877 0.0;
	load 4070303 0.0 -31.5340 0.0;
	load 4070403 0.0 -31.5340 0.0;
	load 4070503 0.0 -31.5340 0.0;
	load 4070603 0.0 -31.5340 0.0;
	load 4070703 0.0 -15.7670 0.0;
	# Floor8
	load 4080303 0.0 -15.7670 0.0;
	load 4080403 0.0 -31.5340 0.0;
	load 4080503 0.0 -31.5340 0.0;
	load 4080603 0.0 -31.5340 0.0;
	load 4080703 0.0 -15.7670 0.0;
	# Floor9
	load 4090303 0.0 -15.7670 0.0;
	load 4090403 0.0 -31.5340 0.0;
	load 4090503 0.0 -31.5340 0.0;
	load 4090603 0.0 -31.5340 0.0;
	load 4090703 0.0 -15.7670 0.0;
	# Floor10
	load 4100303 0.0 -15.7670 0.0;
	load 4100603 0.0 -31.5340 0.0;
	load 4100703 0.0 -15.7670 0.0;
	# Floor11
	load 4110303 0.0 -15.7670 0.0;
	load 4110603 0.0 -31.5340 0.0;
	load 4110703 0.0 -15.7670 0.0;
	# Floor12
	load 4120303 0.0 -15.7670 0.0;
	load 4120403 0.0 -31.5340 0.0;
	load 4120503 0.0 -31.5340 0.0;
	load 4120603 0.0 -31.5340 0.0;
	load 4120703 0.0 -15.7670 0.0;
	# Floor13
	load 4130303 0.0 -15.7670 0.0;
	load 4130403 0.0 -31.5340 0.0;
	load 4130503 0.0 -31.5340 0.0;
	load 4130603 0.0 -31.5340 0.0;
	load 4130703 0.0 -15.7670 0.0;
	# Floor14
	load 4140303 0.0 -15.7670 0.0;
	load 4140403 0.0 -31.5340 0.0;
	load 4140503 0.0 -31.5340 0.0;
	load 4140603 0.0 -31.5340 0.0;
	load 4140703 0.0 -15.7670 0.0;
	# Floor15
	load 4150403 0.0 -15.7670 0.0;
	load 4150503 0.0 -31.5340 0.0;
	load 4150603 0.0 -31.5340 0.0;
	load 4150703 0.0 -15.7670 0.0;
	# Floor16
	load 4160403 0.0 -15.7670 0.0;
	load 4160503 0.0 -31.5340 0.0;
	load 4160603 0.0 -31.5340 0.0;
	load 4160703 0.0 -15.7670 0.0;
	# Floor17
	load 4170403 0.0 -15.7670 0.0;
	load 4170503 0.0 -31.5340 0.0;
	load 4170603 0.0 -31.5340 0.0;
	load 4170703 0.0 -15.7670 0.0;
	# Floor18
	load 4180403 0.0 -15.7670 0.0;
	load 4180503 0.0 -31.5340 0.0;
	load 4180603 0.0 -31.5340 0.0;
	load 4180703 0.0 -15.7670 0.0;
	# Floor19
	load 4190403 0.0 -15.7670 0.0;
	load 4190503 0.0 -31.5340 0.0;
	load 4190603 0.0 -31.5340 0.0;
	load 4190703 0.0 -15.7670 0.0;
	# Floor20
	load 4200403 0.0 -15.7670 0.0;
	load 4200503 0.0 -31.5340 0.0;
	load 4200603 0.0 -31.5340 0.0;
	load 4200703 0.0 -15.7670 0.0;
	# Floor21
	load 4210403 0.0 -15.7670 0.0;
	load 4210503 0.0 -31.5340 0.0;
	load 4210603 0.0 -31.5340 0.0;
	load 4210703 0.0 -15.7670 0.0;
	# Floor22
	load 4220403 0.0 -15.7670 0.0;
	load 4220503 0.0 -31.5340 0.0;
	load 4220603 0.0 -31.5340 0.0;
	load 4220703 0.0 -15.7670 0.0;
	# Floor23
	load 4230403 0.0 -15.7670 0.0;
	load 4230503 0.0 -31.5340 0.0;
	load 4230603 0.0 -31.5340 0.0;
	load 4230703 0.0 -15.7670 0.0;
	# Floor24
	load 4240403 0.0 -15.7670 0.0;
	load 4240503 0.0 -31.5340 0.0;
	load 4240603 0.0 -31.5340 0.0;
	load 4240703 0.0 -15.7670 0.0;
	# Floor25
	load 4250403 0.0 -15.7670 0.0;
	load 4250503 0.0 -31.5340 0.0;
	load 4250603 0.0 -31.5340 0.0;
	load 4250703 0.0 -15.7670 0.0;
	# Floor26
	load 4260403 0.0 -15.7670 0.0;
	load 4260703 0.0 -15.7670 0.0;
	# Floor27
	load 4270403 0.0 -15.7670 0.0;
	load 4270703 0.0 -15.7670 0.0;
	# Floor28
	load 4280403 0.0 -15.7670 0.0;
	load 4280503 0.0 -31.5340 0.0;
	load 4280603 0.0 -31.5340 0.0;
	load 4280703 0.0 -15.7670 0.0;
	# Floor29
	load 4290403 0.0 -15.7670 0.0;
	load 4290503 0.0 -31.5340 0.0;
	load 4290603 0.0 -31.5340 0.0;
	load 4290703 0.0 -15.7670 0.0;
	# Floor30
	load 4300603 0.0 -15.7670 0.0;
	load 4300703 0.0 -15.7670 0.0;
	# Floor31
	load 4310603 0.0 -15.7670 0.0;
	load 4310703 0.0 -15.7670 0.0;
	# Floor32
	load 4320603 0.0 -15.7670 0.0;
	load 4320703 0.0 -15.7670 0.0;
	# Floor33
	load 4330603 0.0 -15.7670 0.0;
	load 4330703 0.0 -15.7670 0.0;
	# Floor34
	load 4340603 0.0 -15.7670 0.0;
	load 4340703 0.0 -15.7670 0.0;
	# Floor35
	load 4350603 0.0 -15.7670 0.0;
	load 4350703 0.0 -15.7670 0.0;
	# Floor36
	load 4360603 0.0 -15.7670 0.0;
	load 4360703 0.0 -15.7670 0.0;

	#  Gravity Frame: Point loads on columns
	load 20800 0.0 -172.3720 0.0;
	load 20900 0.0 -172.3720 0.0;
	load 30800 0.0 -172.3720 0.0;
	load 30900 0.0 -172.3720 0.0;
	load 40800 0.0 -248.0535 0.0;
	load 40900 0.0 -248.0535 0.0;
	load 50800 0.0 -248.0535 0.0;
	load 50900 0.0 -248.0535 0.0;
	load 60800 0.0 -248.0535 0.0;
	load 60900 0.0 -248.0535 0.0;
	load 70800 0.0 -248.0535 0.0;
	load 70900 0.0 -248.0535 0.0;
	load 80800 0.0 -151.3631 0.0;
	load 80900 0.0 -151.3631 0.0;
	load 90800 0.0 -151.3631 0.0;
	load 90900 0.0 -151.3631 0.0;
	load 100800 0.0 -113.5223 0.0;
	load 100900 0.0 -113.5223 0.0;
	load 110800 0.0 -113.5223 0.0;
	load 110900 0.0 -113.5223 0.0;
	load 120800 0.0 -151.3631 0.0;
	load 120900 0.0 -151.3631 0.0;
	load 130800 0.0 -151.3631 0.0;
	load 130900 0.0 -151.3631 0.0;
	load 140800 0.0 -151.3631 0.0;
	load 140900 0.0 -151.3631 0.0;
	load 150800 0.0 -113.5223 0.0;
	load 150900 0.0 -113.5223 0.0;
	load 160800 0.0 -113.5223 0.0;
	load 160900 0.0 -113.5223 0.0;
	load 170800 0.0 -113.5223 0.0;
	load 170900 0.0 -113.5223 0.0;
	load 180800 0.0 -113.5223 0.0;
	load 180900 0.0 -113.5223 0.0;
	load 190800 0.0 -113.5223 0.0;
	load 190900 0.0 -113.5223 0.0;
	load 200800 0.0 -113.5223 0.0;
	load 200900 0.0 -113.5223 0.0;
	load 210800 0.0 -113.5223 0.0;
	load 210900 0.0 -113.5223 0.0;
	load 220800 0.0 -113.5223 0.0;
	load 220900 0.0 -113.5223 0.0;
	load 230800 0.0 -113.5223 0.0;
	load 230900 0.0 -113.5223 0.0;
	load 240800 0.0 -113.5223 0.0;
	load 240900 0.0 -113.5223 0.0;
	load 250800 0.0 -113.5223 0.0;
	load 250900 0.0 -113.5223 0.0;
	load 260800 0.0 -113.5223 0.0;
	load 260900 0.0 -113.5223 0.0;
	load 270800 0.0 -113.5223 0.0;
	load 270900 0.0 -113.5223 0.0;
	load 280800 0.0 -113.5223 0.0;
	load 280900 0.0 -113.5223 0.0;
	load 290800 0.0 -113.5223 0.0;
	load 290900 0.0 -113.5223 0.0;
	load 300800 0.0 -37.8408 0.0;
	load 300900 0.0 -37.8408 0.0;
	load 310800 0.0 -37.8408 0.0;
	load 310900 0.0 -37.8408 0.0;
	load 320800 0.0 -37.8408 0.0;
	load 320900 0.0 -37.8408 0.0;
	load 330800 0.0 -37.8408 0.0;
	load 330900 0.0 -37.8408 0.0;
	load 340800 0.0 -37.8408 0.0;
	load 340900 0.0 -37.8408 0.0;
	load 350800 0.0 -37.8408 0.0;
	load 350900 0.0 -37.8408 0.0;
	load 360800 0.0 -37.8408 0.0;
	load 360900 0.0 -37.8408 0.0;

}

# ----- RECORDERS ----- #

recorder Node -file $outdir/Gravity.out -node 10100 10200 10400 10500 10600 10700 10800 10900 -dof 1 2 3 reaction 

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
	10700
	4020703
	4030703
	4040703
	4050703
	4060703
	4070703
	4080703
	4090703
	4100703
	4110703
	4120703
	4130703
	4140703
	4150703
	4160703
	4170703
	4180703
	4190703
	4200703
	4210703
	4220703
	4230703
	4240703
	4250703
	4260703
	4270703
	4280703
	4290703
	4300703
	4310703
	4320703
	4330703
	4340703
	4350703
	4360703
};

set hVector {
	156
	180
	180
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	156
	204
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
set filename_eigen "$outdir/modal_results.txt"
set omegas [modal $num_modes $filename_eigen]
set filename_modes "$outdir/mode_shapes.txt"
print_modes $num_modes $ctrl_nodes2 $dof $filename_modes

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
set a1_mod $a1;


# Beam elastic elements
region 1 -ele 1020100 1020200 1020300 1020600 1030100 1030200 1030300 1030600 1040100 1040200 1040300 1040400 1040500 1040600 1050100 1050200 1050300 1050400 1050500 1050600 1060100 1060200 1060300 1060400 1060500 1060600 1070100 1070200 1070300 1070400 1070500 1070600 1080300 1080400 1080500 1080600 1090300 1090400 1090500 1090600 1100300 1100400 1100500 1100600 1110300 1110400 1110500 1110600 1120300 1120400 1120500 1120600 1130300 1130400 1130500 1130600 1140300 1140400 1140500 1140600 1150400 1150500 1150600 1160400 1160500 1160600 1170400 1170500 1170600 1180400 1180500 1180600 1190400 1190500 1190600 1200400 1200500 1200600 1210400 1210500 1210600 1220400 1220500 1220600 1230400 1230500 1230600 1240400 1240500 1240600 1250400 1250500 1250600 1260400 1270400 1280400 1280500 1280600 1290400 1290500 1290600 1300600 1310600 1320600 1330600 1340600 1350600 1360600 502700 503700 504700 505700 506700 507700 508700 509700 510700 511700 512700 513700 514700 515700 516700 517700 518700 519700 520700 521700 522700 523700 524700 525700 526700 527700 528700 529700 530700 531700 532700 533700 534700 535700 536700 -rayleigh 0.0 0.0 $a1_mod 0.0;

# Column elastic elements
region 2 -ele 2010100 2020100 2030100 2040100 2050100 2060100 2010200 2020200 2030200 2040200 2050200 2060200 2020300 2030300 2040300 2050300 2060300 2070300 2080300 2090300 2100300 2110300 2120300 2130300 2010400 2020400 2030400 2040400 2050400 2060400 2070400 2080400 2090400 2100400 2110400 2120400 2130400 2140400 2150400 2160400 2170400 2180400 2190400 2200400 2210400 2220400 2230400 2240400 2250400 2260400 2270400 2280400 2010500 2040500 2050500 2060500 2070500 2080500 2090500 2100500 2110500 2120500 2130500 2140500 2150500 2160500 2170500 2180500 2190500 2200500 2210500 2220500 2230500 2240500 2280500 2010600 2020600 2030600 2040600 2050600 2060600 2070600 2080600 2090600 2100600 2110600 2120600 2130600 2140600 2150600 2160600 2170600 2180600 2190600 2200600 2210600 2220600 2230600 2240600 2280600 2290600 2300600 2310600 2320600 2330600 2340600 2350600 2010700 2020700 2030700 2040700 2050700 2060700 2070700 2080700 2090700 2100700 2110700 2120700 2130700 2140700 2150700 2160700 2170700 2180700 2190700 2200700 2210700 2220700 2230700 2240700 2250700 2260700 2270700 2280700 2290700 2300700 2310700 2320700 2330700 2340700 2350700 601800 601900 602800 602900 603800 603900 604800 604900 605800 605900 606800 606900 607800 607900 608800 608900 609800 609900 610800 610900 611800 611900 612800 612900 613800 613900 614800 614900 615800 615900 616800 616900 617800 617900 618800 618900 619800 619900 620800 620900 621800 621900 622800 622900 623800 623900 624800 624900 625800 625900 626800 626900 627800 627900 628800 628900 629800 629900 630800 630900 631800 631900 632800 632900 633800 633900 634800 634900 635800 635900 2030102 2060102 2030202 2060202 2030302 2060302 2090302 2120302 2030402 2060402 2090402 2120402 2150402 2180402 2210402 2240402 2270402 2060502 2090502 2120502 2150502 2180502 2210502 2240502 2030602 2060602 2090602 2120602 2150602 2180602 2210602 2240602 2300602 2330602 2030702 2060702 2090702 2120702 2150702 2180702 2210702 2240702 2270702 2300702 2330702 -rayleigh 0.0 0.0 $a1_mod 0.0;

# Hinge elements [beam springs, column springs]

# Nodes with mass
region 4 -nodes 4020103 4020203 4020303 4020403 4020603 4020703 4030103 4030203 4030303 4030403 4030603 4030703 4040103 4040203 4040303 4040403 4040503 4040603 4040703 4050103 4050203 4050303 4050403 4050503 4050603 4050703 4060103 4060203 4060303 4060403 4060503 4060603 4060703 4070103 4070203 4070303 4070403 4070503 4070603 4070703 4080303 4080403 4080503 4080603 4080703 4090303 4090403 4090503 4090603 4090703 4100303 4100403 4100503 4100603 4100703 4110303 4110403 4110503 4110603 4110703 4120303 4120403 4120503 4120603 4120703 4130303 4130403 4130503 4130603 4130703 4140303 4140403 4140503 4140603 4140703 4150403 4150503 4150603 4150703 4160403 4160503 4160603 4160703 4170403 4170503 4170603 4170703 4180403 4180503 4180603 4180703 4190403 4190503 4190603 4190703 4200403 4200503 4200603 4200703 4210403 4210503 4210603 4210703 4220403 4220503 4220603 4220703 4230403 4230503 4230603 4230703 4240403 4240503 4240603 4240703 4250403 4250503 4250603 4250703 4260403 4260703 4270403 4270703 4280403 4280503 4280603 4280703 4290403 4290503 4290603 4290703 4300603 4300703 4310603 4310703 4320603 4320703 4330603 4330703 4340603 4340703 4350603 4350703 4360603 4360703 -rayleigh $a0 0.0 0.0 0.0;

###################################################################################################
#                                     DETAILED RECORDERS                                          #
###################################################################################################

if {$addBasicRecorders == 1} {

	# Recorders for lateral displacement on each panel zone
	recorder Node -file $outdir/all_disp.out -closeOnWrite -precision 16 -time -nodes 4020103 4020203 4020303 4020403 4020603 4020703 4030103 4030203 4030303 4030403 4030603 4030703 4040103 4040203 4040303 4040403 4040503 4040603 4040703 4050103 4050203 4050303 4050403 4050503 4050603 4050703 4060103 4060203 4060303 4060403 4060503 4060603 4060703 4070103 4070203 4070303 4070403 4070503 4070603 4070703 4080303 4080403 4080503 4080603 4080703 4090303 4090403 4090503 4090603 4090703 4100303 4100403 4100503 4100603 4100703 4110303 4110403 4110503 4110603 4110703 4120303 4120403 4120503 4120603 4120703 4130303 4130403 4130503 4130603 4130703 4140303 4140403 4140503 4140603 4140703 4150403 4150503 4150603 4150703 4160403 4160503 4160603 4160703 4170403 4170503 4170603 4170703 4180403 4180503 4180603 4180703 4190403 4190503 4190603 4190703 4200403 4200503 4200603 4200703 4210403 4210503 4210603 4210703 4220403 4220503 4220603 4220703 4230403 4230503 4230603 4230703 4240403 4240503 4240603 4240703 4250403 4250503 4250603 4250703 4260403 4260703 4270403 4270703 4280403 4280503 4280603 4280703 4290403 4290503 4290603 4290703 4300603 4300703 4310603 4310703 4320603 4320703 4330603 4330703 4340603 4340703 4350603 4350703 4360603 4360703 -dof 1 disp;

}

if {$addDetailedRecorders == 1} {

	# Recorders for beam internal forces
	recorder Element -file $outdir/beam_forces.out -closeOnWrite -precision 16 -ele 1020100 1020200 1020300 1020600 1030100 1030200 1030300 1030600 1040100 1040200 1040300 1040400 1040500 1040600 1050100 1050200 1050300 1050400 1050500 1050600 1060100 1060200 1060300 1060400 1060500 1060600 1070100 1070200 1070300 1070400 1070500 1070600 1080300 1080400 1080500 1080600 1090300 1090400 1090500 1090600 1100300 1100400 1100500 1100600 1110300 1110400 1110500 1110600 1120300 1120400 1120500 1120600 1130300 1130400 1130500 1130600 1140300 1140400 1140500 1140600 1150400 1150500 1150600 1160400 1160500 1160600 1170400 1170500 1170600 1180400 1180500 1180600 1190400 1190500 1190600 1200400 1200500 1200600 1210400 1210500 1210600 1220400 1220500 1220600 1230400 1230500 1230600 1240400 1240500 1240600 1250400 1250500 1250600 1260400 1270400 1280400 1280500 1280600 1290400 1290500 1290600 1300600 1310600 1320600 1330600 1340600 1350600 1360600 globalForce;

}

if {$addDetailedRecorders == 1} {

	# Recorders for column internal forces
	recorder Element -file $outdir/column_forces.out -closeOnWrite -precision 8 -ele 2010100 2020100 2030100 2040100 2050100 2060100 2010200 2020200 2030200 2040200 2050200 2060200 2020300 2030300 2040300 2050300 2060300 2070300 2080300 2090300 2100300 2110300 2120300 2130300 2010400 2020400 2030400 2040400 2050400 2060400 2070400 2080400 2090400 2100400 2110400 2120400 2130400 2140400 2150400 2160400 2170400 2180400 2190400 2200400 2210400 2220400 2230400 2240400 2250400 2260400 2270400 2280400 2010500 2040500 2050500 2060500 2070500 2080500 2090500 2100500 2110500 2120500 2130500 2140500 2150500 2160500 2170500 2180500 2190500 2200500 2210500 2220500 2230500 2240500 2280500 2010600 2020600 2030600 2040600 2050600 2060600 2070600 2080600 2090600 2100600 2110600 2120600 2130600 2140600 2150600 2160600 2170600 2180600 2190600 2200600 2210600 2220600 2230600 2240600 2280600 2290600 2300600 2310600 2320600 2330600 2340600 2350600 2010700 2020700 2030700 2040700 2050700 2060700 2070700 2080700 2090700 2100700 2110700 2120700 2130700 2140700 2150700 2160700 2170700 2180700 2190700 2200700 2210700 2220700 2230700 2240700 2250700 2260700 2270700 2280700 2290700 2300700 2310700 2320700 2330700 2340700 2350700 globalForce;

}

if {$addBasicRecorders == 1} {

	# Recorders column splices
	recorder Element -file $outdir/ss_splice.out -closeOnWrite -precision 8 -ele 2030105 2060105 2030205 2060205 2030305 2060305 2090305 2120305 2030405 2060405 2090405 2120405 2150405 2180405 2210405 2240405 2270405 2060505 2090505 2120505 2150505 2180505 2210505 2240505 2030605 2060605 2090605 2120605 2150605 2180605 2210605 2240605 2300605 2330605 2030705 2060705 2090705 2120705 2150705 2180705 2210705 2240705 2270705 2300705 2330705 section fiber 0 stressStrain;

	recorder Element -file $outdir/def_splice.out -closeOnWrite -precision 8 -ele 2030105 2060105 2030205 2060205 2030305 2060305 2090305 2120305 2030405 2060405 2090405 2120405 2150405 2180405 2210405 2240405 2270405 2060505 2090505 2120505 2150505 2180505 2210505 2240505 2030605 2060605 2090605 2120605 2150605 2180605 2210605 2240605 2300605 2330605 2030705 2060705 2090705 2120705 2150705 2180705 2210705 2240705 2270705 2300705 2330705  deformation;

	recorder Element -file $outdir/force_splice.out -closeOnWrite -precision 8 -ele 2030105 2060105 2030205 2060205 2030305 2060305 2090305 2120305 2030405 2060405 2090405 2120405 2150405 2180405 2210405 2240405 2270405 2060505 2090505 2120505 2150505 2180505 2210505 2240505 2030605 2060605 2090605 2120605 2150605 2180605 2210605 2240605 2300605 2330605 2030705 2060705 2090705 2120705 2150705 2180705 2210705 2240705 2270705 2300705 2330705  localForce;

}

