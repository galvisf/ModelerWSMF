####################################################################################################
####################################################################################################
#                                        3-story MRF Building
####################################################################################################
####################################################################################################

####### MODEL FEATURES #######;
# UNITS:                     kip, in
# Generation:                 
# Composite beams:           True
# Fracturing fiber sections: False
# Gravity system stiffness:  False
# Column splices included:   False
# Rigid diaphragm:           False
# Plastic hinge type:         
# Backbone type:             Elastic
# Cyclic degradation:        False
# Web connection type:       Bolted
# Panel zone model:          Elastic

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
set pzModelTag 5;

# BACKBONE FACTORS FOR COMPOSITE BEAM
set Composite 1; # Consider composite action
set Comp_I       1.400; # stiffness factor for MR frame beams
set Comp_I_GC    1.400; # stiffness factor for EGF beams
set trib        3.000;
set tslab       3.000;
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
# element elasticBeamColumn   ElementID node_i node_j ...

# Beams at floor 2 bay 1
set Ieff  [expr 19515.550 * $Comp_I]
set A   89.000
element elasticBeamColumn   1020100 4020104 4020202 $A $Es $Ieff $trans_selected

# Beams at floor 3 bay 1
set Ieff  [expr 14129.237 * $Comp_I]
set A   68.000
element elasticBeamColumn   1030100 4030104 4030202 $A $Es $Ieff $trans_selected

# Beams at floor 4 bay 1
set Ieff  [expr 2048.462 * $Comp_I]
set A   22.400
element elasticBeamColumn   1040100 4040104 4040202 $A $Es $Ieff $trans_selected

####################################################################################################
#                                            COLUMNS ELEMENTS                                      #
####################################################################################################

# COMMAND SYNTAX 
# element elasticBeamColumn   ElementID node_i node_j ...

# Columns at story 1 axis 1
set A   117.000
set Ieff   5615.347
element elasticBeamColumn   2010100 10100 4020101 $A $Es $Ieff $trans_selected

# Columns at story 2 axis 1
set A   117.000
set Ieff   5531.917
element elasticBeamColumn   2020100 4020103 4030101 $A $Es $Ieff $trans_selected

# Columns at story 3 axis 1
set A   117.000
set Ieff   5809.055
element elasticBeamColumn   2030100 4030103 4040101 $A $Es $Ieff $trans_selected

# Columns at story 1 axis 2
set A   117.000
set Ieff   5615.347
element elasticBeamColumn   2010200 10200 4020201 $A $Es $Ieff $trans_selected

# Columns at story 2 axis 2
set A   117.000
set Ieff   5531.917
element elasticBeamColumn   2020200 4020203 4030201 $A $Es $Ieff $trans_selected

# Columns at story 3 axis 2
set A   117.000
set Ieff   5809.055
element elasticBeamColumn   2030200 4030203 4040201 $A $Es $Ieff $trans_selected

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

# ----- RECORDERS ----- #

recorder Node -file $outdir/Gravity.out -node 10100 10200 10302 -dof 1 2 3 reaction 

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
region 1 -ele 1020100 1030100 1040100 -rayleigh 0.0 0.0 $a1_mod 0.0;

# Column elastic elements
region 2 -ele 2010100 2020100 2030100 2010200 2020200 2030200 -rayleigh 0.0 0.0 $a1_mod 0.0;

# Hinge elements [beam springs, column springs]

# Nodes with mass
region 4 -nodes 4020103 4020203 4030103 4030203 4040103 4040203 -rayleigh $a0 0.0 0.0 0.0;

###################################################################################################
#                                     DETAILED RECORDERS                                          #
###################################################################################################

if {$addBasicRecorders == 1} {

	# Recorders for lateral displacement on each panel zone
	recorder Node -file $outdir/all_disp.out -closeOnWrite -precision 16 -time -nodes 4020103 4020203 4030103 4030203 4040103 4040203 -dof 1 disp;

}

if {$addDetailedRecorders == 1} {

	# Recorders for beam internal forces
	recorder Element -file $outdir/beam_forces.out -closeOnWrite -precision 16 -ele 1020100 1030100 1040100 globalForce;

}

if {$addDetailedRecorders == 1} {

	# Recorders for column internal forces
	recorder Element -file $outdir/column_forces.out -closeOnWrite -precision 8 -ele 2010100 2020100 2030100 2010200 2020200 2030200 globalForce;

}

if {$addBasicRecorders == 1} {

	# Recorders panel zone elements
	recorder Element -file $outdir/pz_rot.out -closeOnWrite -precision 16 -ele 9010100 9010200 9020100 9020200 9030100 9030200 9040100 9040200 deformation;
}

if {$addDetailedRecorders == 1} {

	recorder Element -file $outdir/pz_M.out -closeOnWrite -precision 16 -ele 9010100 9010200 9020100 9020200 9030100 9030200 9040100 9040200 force;
}

