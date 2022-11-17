####################################################################################################
####################################################################################################
#                                        4-story MRF Building
####################################################################################################
####################################################################################################

####### MODEL FEATURES #######;
# UNITS:                     kip, in
# Generation:                Post_Northridge
# Composite beams:           False
# Fracturing fiber sections: False
# Gravity system stiffness:  False
# Column splices included:   False
# Rigid diaphragm:           False
# Plastic hinge type:        non_RBS
# Backbone type:             ASCE41
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
set outdir Output
file mkdir $outdir; # create data directoryset pi [expr 2.0*asin(1.0)];
set n 10.0; # stiffness multiplier for CPH elements
set addBasicRecorders 1
set addDetailedRecorders 1

# FRAME CENTERLINE DIMENSIONS
set num_stories  4;
set NBay  2;

# MATERIAL PROPERTIES
set Es  29000.000; 
set mu  0.300; 
set FyBeam  40.000;
set FyCol  40.000;

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
set trib        0.000;
set tslab       0.000;
set bslab       0.000;
set AslabSteel  0.000;
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
set Floor2  35.43;
set Floor3  70.87;
set Floor4  106.30;
set Floor5  141.73;

set Axis1 0.0;
set Axis2 49.21;
set Axis3 98.43;

set HBuilding 141.73;
set WFrame 98.43;

####################################################################################################
#                                                  NODES                                           #
####################################################################################################

# COMMAND SYNTAX 
# node $NodeID  $X-Coordinate  $Y-Coordinate;

# SUPPORT NODES
node 10100   $Axis1  $Floor1;
node 10200   $Axis2  $Floor1;
node 10300   $Axis3  $Floor1;


#LEANING COLUMN NODES
#column lower node label: story_i*10000+(axisNum+1)*100 + 2;
#column upper node label: story_i*10000+(axisNum+1)*100 + 4;
node 10402  147.638    0.000;
node 10404  147.638   35.433;
node 20402  147.638   35.433;
node 20404  147.638   70.866;
node 30402  147.638   70.866;
node 30404  147.638  106.299;
node 40402  147.638  106.299;
node 40404  147.638  141.732;

#Pin the nodes for leaning column, floor 2
equalDOF 20402 10404 1 2;

#Pin the nodes for leaning column, floor 3
equalDOF 30402 20404 1 2;

#Pin the nodes for leaning column, floor 4
equalDOF 40402 30404 1 2;
###################################################################################################
#                                  PANEL ZONE NODES & ELEMENTS                                    #
###################################################################################################

# CROSS PANEL ZONE NODES AND ELASTIC ELEMENTS
# Command Syntax; 
# ConstructPanel_Cross Axis Floor X_Axis Y_Floor E A_Panel I_Panel d_Col d_Beam transfTag 

# Panel zones floor2
ConstructPanel_Cross      1 2 $Axis1 $Floor2 $Es $A_Stiff $I_Stiff  3.75  3.15 $trans_selected;
ConstructPanel_Cross      2 2 $Axis2 $Floor2 $Es $A_Stiff $I_Stiff  3.75  3.15 $trans_selected;
ConstructPanel_Cross      3 2 $Axis3 $Floor2 $Es $A_Stiff $I_Stiff  3.75  3.15 $trans_selected;

# Panel zones floor3
ConstructPanel_Cross      1 3 $Axis1 $Floor3 $Es $A_Stiff $I_Stiff  3.75  3.15 $trans_selected;
ConstructPanel_Cross      2 3 $Axis2 $Floor3 $Es $A_Stiff $I_Stiff  3.75  3.15 $trans_selected;
ConstructPanel_Cross      3 3 $Axis3 $Floor3 $Es $A_Stiff $I_Stiff  3.75  3.15 $trans_selected;

# Panel zones floor4
ConstructPanel_Cross      1 4 $Axis1 $Floor4 $Es $A_Stiff $I_Stiff  3.75  3.15 $trans_selected;
ConstructPanel_Cross      2 4 $Axis2 $Floor4 $Es $A_Stiff $I_Stiff  3.75  3.15 $trans_selected;
ConstructPanel_Cross      3 4 $Axis3 $Floor4 $Es $A_Stiff $I_Stiff  3.75  3.15 $trans_selected;

# Panel zones floor5
ConstructPanel_Cross      1 5 $Axis1 $Floor5 $Es $A_Stiff $I_Stiff  3.75  3.15 $trans_selected;
ConstructPanel_Cross      2 5 $Axis2 $Floor5 $Es $A_Stiff $I_Stiff  3.75  3.15 $trans_selected;
ConstructPanel_Cross      3 5 $Axis3 $Floor5 $Es $A_Stiff $I_Stiff  3.75  3.15 $trans_selected;



####################################################################################################
#                                             BEAM ELEMENTS                                        #
####################################################################################################

# COMMAND SYNTAX 
# secInfo  Zp, Mc/Mp, Mr/Mp, theta_p, theta_pc, theta_u, lambda
# hingeBeamColumn  ElementID node_i node_j eleDir, ... A, Ieff

# Beams at floor 2 bay 1
set secInfo_i {  2.2622   1.2280   0.2000   0.0405   0.0027   0.0569   0.0000};
set secInfo_j {  2.2622   1.2280   0.2000   0.0405   0.0027   0.0569   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0500];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0500];# MpN/Mp
hingeBeamColumn 1020100 4020104 4020202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 2.174 [expr 2.842*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 2 bay 2
set secInfo_i {  2.2622   1.2280   0.2000   0.0405   0.0027   0.0569   0.0000};
set secInfo_j {  2.2622   1.2280   0.2000   0.0405   0.0027   0.0569   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0500];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0500];# MpN/Mp
hingeBeamColumn 1020200 4020204 4020302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 2.174 [expr 2.842*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 3 bay 1
set secInfo_i {  2.2622   1.2280   0.2000   0.0405   0.0027   0.0569   0.0000};
set secInfo_j {  2.2622   1.2280   0.2000   0.0405   0.0027   0.0569   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0500];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0500];# MpN/Mp
hingeBeamColumn 1030100 4030104 4030202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 2.174 [expr 2.842*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 3 bay 2
set secInfo_i {  2.2622   1.2280   0.2000   0.0405   0.0027   0.0569   0.0000};
set secInfo_j {  2.2622   1.2280   0.2000   0.0405   0.0027   0.0569   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0500];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0500];# MpN/Mp
hingeBeamColumn 1030200 4030204 4030302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 2.174 [expr 2.842*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 4 bay 1
set secInfo_i {  2.2622   1.2280   0.2000   0.0405   0.0027   0.0569   0.0000};
set secInfo_j {  2.2622   1.2280   0.2000   0.0405   0.0027   0.0569   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0500];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0500];# MpN/Mp
hingeBeamColumn 1040100 4040104 4040202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 2.174 [expr 2.842*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 4 bay 2
set secInfo_i {  2.2622   1.2280   0.2000   0.0405   0.0027   0.0569   0.0000};
set secInfo_j {  2.2622   1.2280   0.2000   0.0405   0.0027   0.0569   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0500];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0500];# MpN/Mp
hingeBeamColumn 1040200 4040204 4040302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 2.174 [expr 2.842*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 5 bay 1
set secInfo_i {  2.2622   1.2280   0.2000   0.0405   0.0027   0.0569   0.0000};
set secInfo_j {  2.2622   1.2280   0.2000   0.0405   0.0027   0.0569   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0500];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0500];# MpN/Mp
hingeBeamColumn 1050100 4050104 4050202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 2.174 [expr 2.842*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

# Beams at floor 5 bay 2
set secInfo_i {  2.2622   1.2280   0.2000   0.0405   0.0027   0.0569   0.0000};
set secInfo_j {  2.2622   1.2280   0.2000   0.0405   0.0027   0.0569   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0500];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0500];# MpN/Mp
hingeBeamColumn 1050200 4050204 4050302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 2.174 [expr 2.842*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;

####################################################################################################
#                                            COLUMNS ELEMENTS                                      #
####################################################################################################

# COMMAND SYNTAX 
# secInfo  Zp, Mc/Mp, Mr/Mp, theta_p, theta_pc, theta_u, lambda
# spliceSecGeometry  min(d_i, d_j), min(bf_i, bf_j), min(tf_i, tf_j), min(tw_i, tw_j)
# (splice)    hingeBeamColumnSplice  ElementID node_i node_j eleDir, ... A, Ieff, ... 
# (no splice) hingeBeamColumn        ElementID node_i node_j eleDir, ... A, Ieff

# Columns at story 1 axis 1
set secInfo_i {  2.7027   1.0972   0.4906   0.0166   0.0288   0.0550   0.0000};
set secInfo_j {  2.7027   1.0972   0.4906   0.0166   0.0288   0.0550   0.0000};
hingeBeamColumn 2010100 10100 4020101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 1.757 4.111 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 1
set secInfo_i {  2.7199   1.1054   0.4937   0.0175   0.0289   0.0560   0.0000};
set secInfo_j {  2.7199   1.1054   0.4937   0.0175   0.0289   0.0560   0.0000};
hingeBeamColumn 2020100 4020103 4030101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 1.757 4.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 3 axis 1
set secInfo_i {  2.7329   1.1055   0.4961   0.0176   0.0293   0.0566   0.0000};
set secInfo_j {  2.7329   1.1055   0.4961   0.0176   0.0293   0.0566   0.0000};
hingeBeamColumn 2030100 4030103 4040101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 1.757 4.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 1
set secInfo_i {  2.7459   1.1057   0.4984   0.0177   0.0296   0.0572   0.0000};
set secInfo_j {  2.7459   1.1057   0.4984   0.0177   0.0296   0.0572   0.0000};
hingeBeamColumn 2040100 4040103 4050101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 1.757 4.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 2
set secInfo_i {  2.6508   1.0965   0.4812   0.0161   0.0275   0.0528   0.0000};
set secInfo_j {  2.6508   1.0965   0.4812   0.0161   0.0275   0.0528   0.0000};
hingeBeamColumn 2010200 10200 4020201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 1.757 4.111 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 2
set secInfo_i {  2.6854   1.1049   0.4875   0.0172   0.0280   0.0545   0.0000};
set secInfo_j {  2.6854   1.1049   0.4875   0.0172   0.0280   0.0545   0.0000};
hingeBeamColumn 2020200 4020203 4030201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 1.757 4.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 3 axis 2
set secInfo_i {  2.7113   1.1052   0.4922   0.0174   0.0287   0.0557   0.0000};
set secInfo_j {  2.7113   1.1052   0.4922   0.0174   0.0287   0.0557   0.0000};
hingeBeamColumn 2030200 4030203 4040201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 1.757 4.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 2
set secInfo_i {  2.7372   1.1056   0.4969   0.0176   0.0294   0.0568   0.0000};
set secInfo_j {  2.7372   1.1056   0.4969   0.0176   0.0294   0.0568   0.0000};
hingeBeamColumn 2040200 4040203 4050201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 1.757 4.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 3
set secInfo_i {  2.7027   1.0972   0.4906   0.0166   0.0288   0.0550   0.0000};
set secInfo_j {  2.7027   1.0972   0.4906   0.0166   0.0288   0.0550   0.0000};
hingeBeamColumn 2010300 10300 4020301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 1.757 4.111 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 3
set secInfo_i {  2.7199   1.1054   0.4937   0.0175   0.0289   0.0560   0.0000};
set secInfo_j {  2.7199   1.1054   0.4937   0.0175   0.0289   0.0560   0.0000};
hingeBeamColumn 2020300 4020303 4030301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 1.757 4.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 3 axis 3
set secInfo_i {  2.7329   1.1055   0.4961   0.0176   0.0293   0.0566   0.0000};
set secInfo_j {  2.7329   1.1055   0.4961   0.0176   0.0293   0.0566   0.0000};
hingeBeamColumn 2030300 4030303 4040301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 1.757 4.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 3
set secInfo_i {  2.7459   1.1057   0.4984   0.0177   0.0296   0.0572   0.0000};
set secInfo_j {  2.7459   1.1057   0.4984   0.0177   0.0296   0.0572   0.0000};
hingeBeamColumn 2040300 4040303 4050301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 1.757 4.061 $degradation $c $secInfo_i $secInfo_j 0 0;

####################################################################################################
#                                            BRACE ELEMENTS                                        #
####################################################################################################

# INELASTIC MATERIAL FOR BRACES
set elMatTag 98
set A   0.22
set L	55
set fy [expr $A*$FyBeam]
set dy [expr $fy/($Es*$A/$L)]
set du [expr 0.10*$L]
uniaxialMaterial Hysteretic $braceMatTag $fy $dy [expr 1.1*$fy] $du 0.0 [expr 2*$du] [expr -0.05*$fy] [expr -$dy] 0.0 [expr 2*$du]

set A_dummy   1

# COMMAND SYNTAX 
# element truss $eleTag $iNode $jNode $A $matTag <-rho $rho> <-cMass $cFlag> <-doRayleigh $rFlag>

# Brace at story 1 bay 1

element truss   3010100 10100 202 $A_dummy $braceMatTag

# Brace at story 1 bay 2
element truss   3010200 10300 202 $A_dummy $braceMatTag

# Brace at story 2 bay 1
element truss   3020100 201 302 $A_dummy $braceMatTag

# Brace at story 2 bay 2
element truss   3020200 203 302 $A_dummy $braceMatTag

# Brace at story 3 bay 1
element truss   3030100 301 402 $A_dummy $braceMatTag

# Brace at story 3 bay 2
element truss   3030200 303 402 $A_dummy $braceMatTag

# Brace at story 4 bay 1
element truss   3040100 401 502 $A_dummy $braceMatTag

# Brace at story 4 bay 2
element truss   3040200 403 502 $A_dummy $braceMatTag

####################################################################################################
#                                              FLOOR LINKS                                         #
####################################################################################################

# Command Syntax 
# element truss $ElementID $iNode $jNode $Area $matID
element truss 1005 4050304 40404 $A_Stiff $rigMatTag;
element truss 1004 4040304 30404 $A_Stiff $rigMatTag;
element truss 1003 4030304 20404 $A_Stiff $rigMatTag;
element truss 1002 4020304 10404 $A_Stiff $rigMatTag;

####################################################################################################
#                                          EGF COLUMNS AND BEAMS                                   #
####################################################################################################

# LEANING COLUMN
element elasticBeamColumn 2010400 10402 10404 $A_Stiff $Es $I_Stiff $trans_selected;
element elasticBeamColumn 2020400 20402 20404 $A_Stiff $Es $I_Stiff $trans_selected;
element elasticBeamColumn 2030400 30402 30404 $A_Stiff $Es $I_Stiff $trans_selected;
element elasticBeamColumn 2040400 40402 40404 $A_Stiff $Es $I_Stiff $trans_selected;
###################################################################################################
#                                       BOUNDARY CONDITIONS                                       #
###################################################################################################

# FRAME BASE SUPPORTS
fix 10100 1 1 1;
fix 10200 1 1 1;
fix 10300 1 1 1;

# LEANING COLUMN SUPPORT
fix 10402 1 1 0;
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
mass 4020103 0.0011  0.0000 0.0023;
mass 4020203 0.0023  0.0000 0.0046;
mass 4020303 0.0011  0.0000 0.0023;
# Panel zones floor3
mass 4030103 0.0009  0.0000 0.0017;
mass 4030203 0.0017  0.0000 0.0035;
mass 4030303 0.0009  0.0000 0.0017;
# Panel zones floor4
mass 4040103 0.0009  0.0000 0.0017;
mass 4040203 0.0017  0.0000 0.0035;
mass 4040303 0.0009  0.0000 0.0017;
# Panel zones floor5
mass 4050103 0.0006  0.0000 0.0012;
mass 4050203 0.0011  0.0000 0.0023;
mass 4050303 0.0006  0.0000 0.0012;

# MASS ON THE GRAVITY SYSTEM

mass 10404 0.0046  0.0000 0.0092;
mass 20404 0.0034  0.0000 0.0069;
mass 30404 0.0034  0.0000 0.0069;
mass 40404 0.0023  0.0000 0.0046;

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
	load 4020103 0.0 -0.4409 0.0;
	load 4020203 0.0 -0.8818 0.0;
	load 4020303 0.0 -0.4409 0.0;
	# Floor3
	load 4030103 0.0 -0.3307 0.0;
	load 4030203 0.0 -0.6614 0.0;
	load 4030303 0.0 -0.3307 0.0;
	# Floor4
	load 4040103 0.0 -0.3307 0.0;
	load 4040203 0.0 -0.6614 0.0;
	load 4040303 0.0 -0.3307 0.0;
	# Floor5
	load 4050103 0.0 -0.2205 0.0;
	load 4050203 0.0 -0.4409 0.0;
	load 4050303 0.0 -0.2205 0.0;

	#  Gravity Frame: Point loads on columns
	load 10404 0.0 -1.7637 0.0;
	load 20404 0.0 -1.3228 0.0;
	load 30404 0.0 -1.3228 0.0;
	load 40404 0.0 -0.8818 0.0;

}

# ----- RECORDERS ----- #

recorder Node -file $outdir/Gravity.out -node 10100 10200 10300 10402 -dof 1 2 3 reaction 

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
	10300
	4020303
	4030303
	4040303
	4050303
};

set hVector {
	3.543307e+01
	3.543307e+01
	3.543307e+01
	3.543307e+01
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
set a1_mod [expr $a1*(1.0+$n)/$n];


# Beam elastic elements
region 1 -ele 1020100 1020200 1030100 1030200 1040100 1040200 1050100 1050200 -rayleigh 0.0 0.0 $a1_mod 0.0;

# Column elastic elements
region 2 -ele 2010100 2020100 2030100 2040100 2010200 2020200 2030200 2040200 2010300 2020300 2030300 2040300 -rayleigh 0.0 0.0 $a1_mod 0.0;

# Hinge elements [beam springs, column springs]
region 3 -ele 1020101 1020102 1020201 1020202 1030101 1030102 1030201 1030202 1040101 1040102 1040201 1040202 1050101 1050102 1050201 1050202 2010101 2010102 2020101 2020102 2030101 2030102 2040101 2040102 2010201 2010202 2020201 2020202 2030201 2030202 2040201 2040202 2010301 2010302 2020301 2020302 2030301 2030302 2040301 2040302 -rayleigh 0.0 0.0 [expr $a1_mod/$n] 0.0;

# Nodes with mass
region 4 -nodes 4020103 4020203 4020303 4030103 4030203 4030303 4040103 4040203 4040303 4050103 4050203 4050303 -rayleigh $a0 0.0 0.0 0.0;

###################################################################################################
#                                     DETAILED RECORDERS                                          #
###################################################################################################

if {$addBasicRecorders == 1} {

	# Recorders for lateral displacement on each panel zone
	recorder Node -file $outdir/all_disp.out -closeOnWrite -precision 16 -time -nodes 4020103 4020203 4020303 4030103 4030203 4030303 4040103 4040203 4040303 4050103 4050203 4050303 -dof 1 disp;

}

if {$addBasicRecorders == 1} {

	# Recorders beam hinge element

	# Left
	recorder Element -file $outdir/hinge_left.out -closeOnWrite -precision 16 -ele 1020101 1020201 1030101 1030201 1040101 1040201 1050101 1050201 deformation;

	# Right
	recorder Element -file $outdir/hinge_right.out -closeOnWrite -precision 16 -ele 1020102 1020202 1030102 1030202 1040102 1040202 1050102 1050202 deformation;
}

if {$addDetailedRecorders == 1} {

	recorder Element -file $outdir/hinge_right_force.out -closeOnWrite -precision 16 -ele 1020102 1020202 1030102 1030202 1040102 1040202 1050102 1050202 force;

	recorder Element -file $outdir/hinge_left_force.out -closeOnWrite -precision 16 -ele 1020101 1020201 1030101 1030201 1040101 1040201 1050101 1050201 force;
}

if {$addDetailedRecorders == 1} {

	# Recorders for beam internal forces
	recorder Element -file $outdir/beam_forces.out -closeOnWrite -precision 16 -ele 1020100 1020200 1030100 1030200 1040100 1040200 1050100 1050200 globalForce;

}

if {$addDetailedRecorders == 1} {

	# Recorders for column internal forces
	recorder Element -file $outdir/column_forces.out -closeOnWrite -precision 8 -ele 2010100 2020100 2030100 2040100 2010200 2020200 2030200 2040200 2010300 2020300 2030300 2040300 globalForce;

}

if {$addBasicRecorders == 1} {

	# Recorders column hinges
	# Bottom
	recorder Element -file $outdir/hinge_bot.out -closeOnWrite -precision 8 -ele 2010101 2020101 2030101 2040101 2010201 2020201 2030201 2040201 2010301 2020301 2030301 2040301 deformation;
	# Top
	recorder Element -file $outdir/hinge_top.out -closeOnWrite -precision 8 -ele 2010102 2020102 2030102 2040102 2010202 2020202 2030202 2040202 2010302 2020302 2030302 2040302 deformation;
}

if {$addDetailedRecorders == 1} {

	# Bottom
	recorder Element -file $outdir/hinge_bot_force.out -closeOnWrite -precision 8 -ele 2010101 2020101 2030101 2040101 2010201 2020201 2030201 2040201 2010301 2020301 2030301 2040301 force;
	# Top
	recorder Element -file $outdir/hinge_top_force.out -closeOnWrite -precision 8 -ele 2010102 2020102 2030102 2040102 2010202 2020202 2030202 2040202 2010302 2020302 2030302 2040302 force;
}

