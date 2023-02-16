####################################################################################################
####################################################################################################
#                                        8-story MRF Building
####################################################################################################
####################################################################################################

####### MODEL FEATURES #######;
# UNITS:                     kip, in
# Generation:                 
# Composite beams:           False
# Fracturing fiber sections: False
# Gravity system stiffness:  False
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
set pzModelTag 0;

# BACKBONE FACTORS FOR COMPOSITE BEAM
set Composite 0; # Ignore composite action
set Comp_I       1.000; # stiffness factor for MR frame beams
set Comp_I_GC    1.000; # stiffness factor for EGF beams
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

# CROSS PANEL ZONE NODES AND ELASTIC ELEMENTS
# Command Syntax; 
# ConstructPanel_Cross Axis Floor X_Axis Y_Floor E A_Panel I_Panel d_Col d_Beam transfTag 

# Panel zones floor2
ConstructPanel_Cross      1 2 $Axis1 $Floor2 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;
ConstructPanel_Cross      2 2 $Axis2 $Floor2 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;
ConstructPanel_Cross      3 2 $Axis3 $Floor2 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;
ConstructPanel_Cross      4 2 $Axis4 $Floor2 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;
ConstructPanel_Cross      5 2 $Axis5 $Floor2 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;

# Panel zones floor3
ConstructPanel_Cross      1 3 $Axis1 $Floor3 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;
ConstructPanel_Cross      2 3 $Axis2 $Floor3 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;
ConstructPanel_Cross      3 3 $Axis3 $Floor3 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;
ConstructPanel_Cross      4 3 $Axis4 $Floor3 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;
ConstructPanel_Cross      5 3 $Axis5 $Floor3 $Es $A_Stiff $I_Stiff 15.70 27.30 $trans_selected;

# Panel zones floor4
ConstructPanel_Cross      1 4 $Axis1 $Floor4 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;
ConstructPanel_Cross      2 4 $Axis2 $Floor4 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;
ConstructPanel_Cross      3 4 $Axis3 $Floor4 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;
ConstructPanel_Cross      4 4 $Axis4 $Floor4 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;
ConstructPanel_Cross      5 4 $Axis5 $Floor4 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;

# Panel zones floor5
ConstructPanel_Cross      1 5 $Axis1 $Floor5 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;
ConstructPanel_Cross      2 5 $Axis2 $Floor5 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;
ConstructPanel_Cross      3 5 $Axis3 $Floor5 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;
ConstructPanel_Cross      4 5 $Axis4 $Floor5 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;
ConstructPanel_Cross      5 5 $Axis5 $Floor5 $Es $A_Stiff $I_Stiff 15.50 27.10 $trans_selected;

# Panel zones floor6
ConstructPanel_Cross      1 6 $Axis1 $Floor6 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;
ConstructPanel_Cross      2 6 $Axis2 $Floor6 $Es $A_Stiff $I_Stiff 15.20 26.90 $trans_selected;
ConstructPanel_Cross      3 6 $Axis3 $Floor6 $Es $A_Stiff $I_Stiff 15.20 26.90 $trans_selected;
ConstructPanel_Cross      4 6 $Axis4 $Floor6 $Es $A_Stiff $I_Stiff 15.20 26.90 $trans_selected;
ConstructPanel_Cross      5 6 $Axis5 $Floor6 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;

# Panel zones floor7
ConstructPanel_Cross      1 7 $Axis1 $Floor7 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;
ConstructPanel_Cross      2 7 $Axis2 $Floor7 $Es $A_Stiff $I_Stiff 15.20 26.90 $trans_selected;
ConstructPanel_Cross      3 7 $Axis3 $Floor7 $Es $A_Stiff $I_Stiff 15.20 26.90 $trans_selected;
ConstructPanel_Cross      4 7 $Axis4 $Floor7 $Es $A_Stiff $I_Stiff 15.20 26.90 $trans_selected;
ConstructPanel_Cross      5 7 $Axis5 $Floor7 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;

# Panel zones floor8
ConstructPanel_Cross      1 8 $Axis1 $Floor8 $Es $A_Stiff $I_Stiff 14.70 26.90 $trans_selected;
ConstructPanel_Cross      2 8 $Axis2 $Floor8 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;
ConstructPanel_Cross      3 8 $Axis3 $Floor8 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;
ConstructPanel_Cross      4 8 $Axis4 $Floor8 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;
ConstructPanel_Cross      5 8 $Axis5 $Floor8 $Es $A_Stiff $I_Stiff 14.70 26.90 $trans_selected;

# Panel zones floor9
ConstructPanel_Cross      1 9 $Axis1 $Floor9 $Es $A_Stiff $I_Stiff 14.70 26.90 $trans_selected;
ConstructPanel_Cross      2 9 $Axis2 $Floor9 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;
ConstructPanel_Cross      3 9 $Axis3 $Floor9 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;
ConstructPanel_Cross      4 9 $Axis4 $Floor9 $Es $A_Stiff $I_Stiff 15.00 26.90 $trans_selected;
ConstructPanel_Cross      5 9 $Axis5 $Floor9 $Es $A_Stiff $I_Stiff 14.70 26.90 $trans_selected;



####################################################################################################
#                                             BEAM ELEMENTS                                        #
####################################################################################################

# COMMAND SYNTAX 
# element elasticBeamColumn   ElementID node_i node_j ...

# Beams at floor 2 bay 1
set Ieff  [expr 3884.700 * $Comp_I]
set A   33.600
element elasticBeamColumn   1020100 4020104 4020202 $A $Es $Ieff $trans_selected

# Beams at floor 2 bay 2
set Ieff  [expr 3884.700 * $Comp_I]
set A   33.600
element elasticBeamColumn   1020200 4020204 4020302 $A $Es $Ieff $trans_selected

# Beams at floor 2 bay 3
set Ieff  [expr 3884.700 * $Comp_I]
set A   33.600
element elasticBeamColumn   1020300 4020304 4020402 $A $Es $Ieff $trans_selected

# Beams at floor 2 bay 4
set Ieff  [expr 3884.700 * $Comp_I]
set A   33.600
element elasticBeamColumn   1020400 4020404 4020502 $A $Es $Ieff $trans_selected

# Beams at floor 3 bay 1
set Ieff  [expr 3884.700 * $Comp_I]
set A   33.600
element elasticBeamColumn   1030100 4030104 4030202 $A $Es $Ieff $trans_selected

# Beams at floor 3 bay 2
set Ieff  [expr 3884.700 * $Comp_I]
set A   33.600
element elasticBeamColumn   1030200 4030204 4030302 $A $Es $Ieff $trans_selected

# Beams at floor 3 bay 3
set Ieff  [expr 3884.700 * $Comp_I]
set A   33.600
element elasticBeamColumn   1030300 4030304 4030402 $A $Es $Ieff $trans_selected

# Beams at floor 3 bay 4
set Ieff  [expr 3884.700 * $Comp_I]
set A   33.600
element elasticBeamColumn   1030400 4030404 4030502 $A $Es $Ieff $trans_selected

# Beams at floor 4 bay 1
set Ieff  [expr 3445.698 * $Comp_I]
set A   30.000
element elasticBeamColumn   1040100 4040104 4040202 $A $Es $Ieff $trans_selected

# Beams at floor 4 bay 2
set Ieff  [expr 3445.698 * $Comp_I]
set A   30.000
element elasticBeamColumn   1040200 4040204 4040302 $A $Es $Ieff $trans_selected

# Beams at floor 4 bay 3
set Ieff  [expr 3445.698 * $Comp_I]
set A   30.000
element elasticBeamColumn   1040300 4040304 4040402 $A $Es $Ieff $trans_selected

# Beams at floor 4 bay 4
set Ieff  [expr 3445.698 * $Comp_I]
set A   30.000
element elasticBeamColumn   1040400 4040404 4040502 $A $Es $Ieff $trans_selected

# Beams at floor 5 bay 1
set Ieff  [expr 3445.698 * $Comp_I]
set A   30.000
element elasticBeamColumn   1050100 4050104 4050202 $A $Es $Ieff $trans_selected

# Beams at floor 5 bay 2
set Ieff  [expr 3445.698 * $Comp_I]
set A   30.000
element elasticBeamColumn   1050200 4050204 4050302 $A $Es $Ieff $trans_selected

# Beams at floor 5 bay 3
set Ieff  [expr 3445.698 * $Comp_I]
set A   30.000
element elasticBeamColumn   1050300 4050304 4050402 $A $Es $Ieff $trans_selected

# Beams at floor 5 bay 4
set Ieff  [expr 3445.698 * $Comp_I]
set A   30.000
element elasticBeamColumn   1050400 4050404 4050502 $A $Es $Ieff $trans_selected

# Beams at floor 6 bay 1
set Ieff  [expr 3119.678 * $Comp_I]
set A   27.600
element elasticBeamColumn   1060100 4060104 4060202 $A $Es $Ieff $trans_selected

# Beams at floor 6 bay 2
set Ieff  [expr 3119.578 * $Comp_I]
set A   27.600
element elasticBeamColumn   1060200 4060204 4060302 $A $Es $Ieff $trans_selected

# Beams at floor 6 bay 3
set Ieff  [expr 3119.578 * $Comp_I]
set A   27.600
element elasticBeamColumn   1060300 4060304 4060402 $A $Es $Ieff $trans_selected

# Beams at floor 6 bay 4
set Ieff  [expr 3119.678 * $Comp_I]
set A   27.600
element elasticBeamColumn   1060400 4060404 4060502 $A $Es $Ieff $trans_selected

# Beams at floor 7 bay 1
set Ieff  [expr 3119.678 * $Comp_I]
set A   27.600
element elasticBeamColumn   1070100 4070104 4070202 $A $Es $Ieff $trans_selected

# Beams at floor 7 bay 2
set Ieff  [expr 3119.578 * $Comp_I]
set A   27.600
element elasticBeamColumn   1070200 4070204 4070302 $A $Es $Ieff $trans_selected

# Beams at floor 7 bay 3
set Ieff  [expr 3119.578 * $Comp_I]
set A   27.600
element elasticBeamColumn   1070300 4070304 4070402 $A $Es $Ieff $trans_selected

# Beams at floor 7 bay 4
set Ieff  [expr 3119.678 * $Comp_I]
set A   27.600
element elasticBeamColumn   1070400 4070404 4070502 $A $Es $Ieff $trans_selected

# Beams at floor 8 bay 1
set Ieff  [expr 3119.927 * $Comp_I]
set A   27.600
element elasticBeamColumn   1080100 4080104 4080202 $A $Es $Ieff $trans_selected

# Beams at floor 8 bay 2
set Ieff  [expr 3119.777 * $Comp_I]
set A   27.600
element elasticBeamColumn   1080200 4080204 4080302 $A $Es $Ieff $trans_selected

# Beams at floor 8 bay 3
set Ieff  [expr 3119.777 * $Comp_I]
set A   27.600
element elasticBeamColumn   1080300 4080304 4080402 $A $Es $Ieff $trans_selected

# Beams at floor 8 bay 4
set Ieff  [expr 3119.927 * $Comp_I]
set A   27.600
element elasticBeamColumn   1080400 4080404 4080502 $A $Es $Ieff $trans_selected

# Beams at floor 9 bay 1
set Ieff  [expr 3119.927 * $Comp_I]
set A   27.600
element elasticBeamColumn   1090100 4090104 4090202 $A $Es $Ieff $trans_selected

# Beams at floor 9 bay 2
set Ieff  [expr 3119.777 * $Comp_I]
set A   27.600
element elasticBeamColumn   1090200 4090204 4090302 $A $Es $Ieff $trans_selected

# Beams at floor 9 bay 3
set Ieff  [expr 3119.777 * $Comp_I]
set A   27.600
element elasticBeamColumn   1090300 4090304 4090402 $A $Es $Ieff $trans_selected

# Beams at floor 9 bay 4
set Ieff  [expr 3119.927 * $Comp_I]
set A   27.600
element elasticBeamColumn   1090400 4090404 4090502 $A $Es $Ieff $trans_selected

####################################################################################################
#                                            COLUMNS ELEMENTS                                      #
####################################################################################################

# COMMAND SYNTAX 
# element elasticBeamColumn   ElementID node_i node_j ...

# Columns at story 1 axis 1
set A   62.000
set Ieff   2347.550
element elasticBeamColumn   2010100 10100 4020101 $A $Es $Ieff $trans_selected

# Columns at story 2 axis 1
set A   62.000
set Ieff   2287.531
element elasticBeamColumn   2020100 4020103 4030101 $A $Es $Ieff $trans_selected

# Columns at story 3 axis 1
set ttab 0.890
set dtab 8.834
elasticBeamColumnSplice 2030100 4030103 4040101 "Vertical" $trans_selected $Es $rigMatTag 56.800 2062.565 $spliceLoc;

# Columns at story 4 axis 1
set A   56.800
set Ieff   2063.015
element elasticBeamColumn   2040100 4040103 4050101 $A $Es $Ieff $trans_selected

# Columns at story 5 axis 1
set A   46.700
set Ieff   1638.798
element elasticBeamColumn   2050100 4050103 4060101 $A $Es $Ieff $trans_selected

# Columns at story 6 axis 1
set ttab 0.745
set dtab 8.834
elasticBeamColumnSplice 2060100 4060103 4070101 "Vertical" $trans_selected $Es $rigMatTag 46.700 1639.147 $spliceLoc;

# Columns at story 7 axis 1
set A   38.800
set Ieff   1329.235
element elasticBeamColumn   2070100 4070103 4080101 $A $Es $Ieff $trans_selected

# Columns at story 8 axis 1
set A   38.800
set Ieff   1329.235
element elasticBeamColumn   2080100 4080103 4090101 $A $Es $Ieff $trans_selected

# Columns at story 1 axis 2
set A   62.000
set Ieff   2347.550
element elasticBeamColumn   2010200 10200 4020201 $A $Es $Ieff $trans_selected

# Columns at story 2 axis 2
set A   62.000
set Ieff   2287.531
element elasticBeamColumn   2020200 4020203 4030201 $A $Es $Ieff $trans_selected

# Columns at story 3 axis 2
set ttab 0.890
set dtab 8.834
elasticBeamColumnSplice 2030200 4030203 4040201 "Vertical" $trans_selected $Es $rigMatTag 56.800 2062.565 $spliceLoc;

# Columns at story 4 axis 2
set A   56.800
set Ieff   2063.015
element elasticBeamColumn   2040200 4040203 4050201 $A $Es $Ieff $trans_selected

# Columns at story 5 axis 2
set A   51.800
set Ieff   1846.396
element elasticBeamColumn   2050200 4050203 4060201 $A $Es $Ieff $trans_selected

# Columns at story 6 axis 2
set ttab 0.830
set dtab 8.806
elasticBeamColumnSplice 2060200 4060203 4070201 "Vertical" $trans_selected $Es $rigMatTag 51.800 1846.788 $spliceLoc;

# Columns at story 7 axis 2
set A   46.700
set Ieff   1639.147
element elasticBeamColumn   2070200 4070203 4080201 $A $Es $Ieff $trans_selected

# Columns at story 8 axis 2
set A   46.700
set Ieff   1639.147
element elasticBeamColumn   2080200 4080203 4090201 $A $Es $Ieff $trans_selected

# Columns at story 1 axis 3
set A   62.000
set Ieff   2347.550
element elasticBeamColumn   2010300 10300 4020301 $A $Es $Ieff $trans_selected

# Columns at story 2 axis 3
set A   62.000
set Ieff   2287.531
element elasticBeamColumn   2020300 4020303 4030301 $A $Es $Ieff $trans_selected

# Columns at story 3 axis 3
set ttab 0.890
set dtab 8.834
elasticBeamColumnSplice 2030300 4030303 4040301 "Vertical" $trans_selected $Es $rigMatTag 56.800 2062.565 $spliceLoc;

# Columns at story 4 axis 3
set A   56.800
set Ieff   2063.015
element elasticBeamColumn   2040300 4040303 4050301 $A $Es $Ieff $trans_selected

# Columns at story 5 axis 3
set A   51.800
set Ieff   1846.396
element elasticBeamColumn   2050300 4050303 4060301 $A $Es $Ieff $trans_selected

# Columns at story 6 axis 3
set ttab 0.830
set dtab 8.806
elasticBeamColumnSplice 2060300 4060303 4070301 "Vertical" $trans_selected $Es $rigMatTag 51.800 1846.788 $spliceLoc;

# Columns at story 7 axis 3
set A   46.700
set Ieff   1639.147
element elasticBeamColumn   2070300 4070303 4080301 $A $Es $Ieff $trans_selected

# Columns at story 8 axis 3
set A   46.700
set Ieff   1639.147
element elasticBeamColumn   2080300 4080303 4090301 $A $Es $Ieff $trans_selected

# Columns at story 1 axis 4
set A   62.000
set Ieff   2347.550
element elasticBeamColumn   2010400 10400 4020401 $A $Es $Ieff $trans_selected

# Columns at story 2 axis 4
set A   62.000
set Ieff   2287.531
element elasticBeamColumn   2020400 4020403 4030401 $A $Es $Ieff $trans_selected

# Columns at story 3 axis 4
set ttab 0.890
set dtab 8.834
elasticBeamColumnSplice 2030400 4030403 4040401 "Vertical" $trans_selected $Es $rigMatTag 56.800 2062.565 $spliceLoc;

# Columns at story 4 axis 4
set A   56.800
set Ieff   2063.015
element elasticBeamColumn   2040400 4040403 4050401 $A $Es $Ieff $trans_selected

# Columns at story 5 axis 4
set A   51.800
set Ieff   1846.396
element elasticBeamColumn   2050400 4050403 4060401 $A $Es $Ieff $trans_selected

# Columns at story 6 axis 4
set ttab 0.830
set dtab 8.806
elasticBeamColumnSplice 2060400 4060403 4070401 "Vertical" $trans_selected $Es $rigMatTag 51.800 1846.788 $spliceLoc;

# Columns at story 7 axis 4
set A   46.700
set Ieff   1639.147
element elasticBeamColumn   2070400 4070403 4080401 $A $Es $Ieff $trans_selected

# Columns at story 8 axis 4
set A   46.700
set Ieff   1639.147
element elasticBeamColumn   2080400 4080403 4090401 $A $Es $Ieff $trans_selected

# Columns at story 1 axis 5
set A   62.000
set Ieff   2347.550
element elasticBeamColumn   2010500 10500 4020501 $A $Es $Ieff $trans_selected

# Columns at story 2 axis 5
set A   62.000
set Ieff   2287.531
element elasticBeamColumn   2020500 4020503 4030501 $A $Es $Ieff $trans_selected

# Columns at story 3 axis 5
set ttab 0.890
set dtab 8.834
elasticBeamColumnSplice 2030500 4030503 4040501 "Vertical" $trans_selected $Es $rigMatTag 56.800 2062.565 $spliceLoc;

# Columns at story 4 axis 5
set A   56.800
set Ieff   2063.015
element elasticBeamColumn   2040500 4040503 4050501 $A $Es $Ieff $trans_selected

# Columns at story 5 axis 5
set A   46.700
set Ieff   1638.798
element elasticBeamColumn   2050500 4050503 4060501 $A $Es $Ieff $trans_selected

# Columns at story 6 axis 5
set ttab 0.745
set dtab 8.834
elasticBeamColumnSplice 2060500 4060503 4070501 "Vertical" $trans_selected $Es $rigMatTag 46.700 1639.147 $spliceLoc;

# Columns at story 7 axis 5
set A   38.800
set Ieff   1329.235
element elasticBeamColumn   2070500 4070503 4080501 $A $Es $Ieff $trans_selected

# Columns at story 8 axis 5
set A   38.800
set Ieff   1329.235
element elasticBeamColumn   2080500 4080503 4090501 $A $Es $Ieff $trans_selected

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

# ----- RECORDERS ----- #

recorder Node -file $outdir/Gravity.out -node 10100 10200 10300 10400 10500 10602 -dof 1 2 3 reaction 

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
region 1 -ele 1020100 1020200 1020300 1020400 1030100 1030200 1030300 1030400 1040100 1040200 1040300 1040400 1050100 1050200 1050300 1050400 1060100 1060200 1060300 1060400 1070100 1070200 1070300 1070400 1080100 1080200 1080300 1080400 1090100 1090200 1090300 1090400 -rayleigh 0.0 0.0 $a1_mod 0.0;

# Column elastic elements
region 2 -ele 2010100 2020100 2030100 2040100 2050100 2060100 2070100 2080100 2010200 2020200 2030200 2040200 2050200 2060200 2070200 2080200 2010300 2020300 2030300 2040300 2050300 2060300 2070300 2080300 2010400 2020400 2030400 2040400 2050400 2060400 2070400 2080400 2010500 2020500 2030500 2040500 2050500 2060500 2070500 2080500 2030102 2060102 2030202 2060202 2030302 2060302 2030402 2060402 2030502 2060502 -rayleigh 0.0 0.0 $a1_mod 0.0;

# Hinge elements [beam springs, column springs]

# Nodes with mass
region 4 -nodes 4020103 4020203 4020303 4020403 4020503 4030103 4030203 4030303 4030403 4030503 4040103 4040203 4040303 4040403 4040503 4050103 4050203 4050303 4050403 4050503 4060103 4060203 4060303 4060403 4060503 4070103 4070203 4070303 4070403 4070503 4080103 4080203 4080303 4080403 4080503 4090103 4090203 4090303 4090403 4090503 -rayleigh $a0 0.0 0.0 0.0;

###################################################################################################
#                                     DETAILED RECORDERS                                          #
###################################################################################################

if {$addBasicRecorders == 1} {

	# Recorders for lateral displacement on each panel zone
	recorder Node -file $outdir/all_disp.out -closeOnWrite -precision 16 -time -nodes 4020103 4020203 4020303 4020403 4020503 4030103 4030203 4030303 4030403 4030503 4040103 4040203 4040303 4040403 4040503 4050103 4050203 4050303 4050403 4050503 4060103 4060203 4060303 4060403 4060503 4070103 4070203 4070303 4070403 4070503 4080103 4080203 4080303 4080403 4080503 4090103 4090203 4090303 4090403 4090503 -dof 1 disp;

}

if {$addDetailedRecorders == 1} {

	# Recorders for beam internal forces
	recorder Element -file $outdir/beam_forces.out -closeOnWrite -precision 16 -ele 1020100 1020200 1020300 1020400 1030100 1030200 1030300 1030400 1040100 1040200 1040300 1040400 1050100 1050200 1050300 1050400 1060100 1060200 1060300 1060400 1070100 1070200 1070300 1070400 1080100 1080200 1080300 1080400 1090100 1090200 1090300 1090400 globalForce;

}

if {$addDetailedRecorders == 1} {

	# Recorders for column internal forces
	recorder Element -file $outdir/column_forces.out -closeOnWrite -precision 8 -ele 2010100 2020100 2030100 2040100 2050100 2060100 2070100 2080100 2010200 2020200 2030200 2040200 2050200 2060200 2070200 2080200 2010300 2020300 2030300 2040300 2050300 2060300 2070300 2080300 2010400 2020400 2030400 2040400 2050400 2060400 2070400 2080400 2010500 2020500 2030500 2040500 2050500 2060500 2070500 2080500 globalForce;

}

if {$addBasicRecorders == 1} {

	# Recorders column splices
	recorder Element -file $outdir/ss_splice.out -closeOnWrite -precision 8 -ele 2030105 2060105 2030205 2060205 2030305 2060305 2030405 2060405 2030505 2060505 section fiber 0 stressStrain;

	recorder Element -file $outdir/def_splice.out -closeOnWrite -precision 8 -ele 2030105 2060105 2030205 2060205 2030305 2060305 2030405 2060405 2030505 2060505  deformation;

	recorder Element -file $outdir/force_splice.out -closeOnWrite -precision 8 -ele 2030105 2060105 2030205 2060205 2030305 2060305 2030405 2060405 2030505 2060505  localForce;

}

