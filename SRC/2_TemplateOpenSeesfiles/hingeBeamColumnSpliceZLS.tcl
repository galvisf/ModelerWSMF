########################################################################################################
# hingeBeamColumnSplice.tcl                                                                         
#
# SubRoutine to construct a beam or column element with a splice in a given location
#                                                      
########################################################################################################
#
# Input Arguments:
#------------------
# eleTag 				Element ID
# node_i 				Initial node
# node_j 				End node
# eleDir				'Horizontal'
#						'Vertical'
# transfTag 			1 -> Linear 
#						2 -> PDelta
#						3 -> Corotational
# n						Stiffness multiplier for CPH elements (often =10)
# Es					Elastic modulus [ksi]
# Fy					Steel yielding stress [ksi]
# rigMatTag				tag of a pre-created elastic material with large E
# A						Cross-sectional area of the element [in^2]
# Ieff					Second moment of area of the section [in^4]
# degradation 			0 -> use hysteretic hinge (no cyclic degradation)#						
#						1 -> use IMK hinge to include cyclic degradation
# Zp_i					Plastic section modulus at initial side of the element
# Zp_j					Plastic section modulus at end side of the element
# c						Exponent defining the rate of cyclic deterioration [often assumed = 1]
# secInfo_i				list with initial side backbone parameters
#						{Zp_i, Mc/Mp, Mr/Mp, thetaCap, thetaPC, thetaUlt, Lambda}
# secInfo_j				list with end side backbone parameters
#						{Zp_j, Mc/Mp, Mr/Mp, thetaCap, thetaPC, thetaUlt, Lambda}
# spliceLoc				Splice location measured from node_i [in]
# spliceSecGeometry		list with the dimensions of the splice section
#						{d, bf, tf, tw}
# FySplice				Yielding strength of the splice steel [ksi]
# sigCr					Fracture stress of the splice welded flanges [ksi]
# ttab 					thickness of the shear tab [in]
# dtab					depth of the web welded to the column (assumed centered in the beam depth) [in]
# 
# Written by: Francisco Galvis, Stanford University
#
proc hingeBeamColumnSpliceZLS { eleTag node_i node_j eleDir transfTag n Es Fy rigMatTag A Ieff degradation c secInfo_i secInfo_j spliceLoc  spliceSecGeometry FySplice sigCr ttab dtab} {

	## Get section tags
	set hingeSecTag_i [expr $eleTag + 1]
	set hingeSecTag_j [expr $eleTag + 2]

	## Create intermediate nodes for hinges ##
	set n1Coord [nodeCoord $node_i];
	set x1 [lindex $n1Coord 0];
	set y1 [lindex $n1Coord 1];
	set nodeInt1 [expr $node_i+10];
	node $nodeInt1 $x1 $y1;
	
	set n2Coord [nodeCoord $node_j];
	set x2 [lindex $n2Coord 0];
	set y2 [lindex $n2Coord 1];	
	set nodeInt2 [expr $node_i+20];
	node $nodeInt2 $x2 $y2;
	
	## Create intermediate nodes for splices ##
	set nodeSpl1 [expr $node_i+30];
	set nodeSpl2 [expr $node_i+40];
	if {$eleDir == "Horizontal"} {
		set x3 [expr $x1 + $spliceLoc];
		set y3 $y1;
		node $nodeSpl1 [expr $x3 - 0] $y3;	
		node $nodeSpl2 [expr $x3 + 0] $y3;
	} else {
		set x3 $x1
		set y3 [expr $y1 + $spliceLoc];
		node $nodeSpl1 $x3 [expr $y3 - 0];	
		node $nodeSpl2 $x3 [expr $y3 + 0];
	}	
	
	## Get element length ##
	if {$eleDir == "Horizontal"} {
		set eleLength [expr $x2 - $x1]
	} elseif {$eleDir == "Vertical"} {
		set eleLength [expr $y2 - $y1]
	} else {
		puts "ERROR: specify Horizontal or Vertical element direction"
	}
	
	## Read inputs for splice element ##
	# Beam profile and tab geometry
	set d [lindex $spliceSecGeometry 0]
	set bf [lindex $spliceSecGeometry 1]
	set tf [lindex $spliceSecGeometry 2]
	set tw [lindex $spliceSecGeometry 3]
	
	## Read inputs for hinge ##
	# Flexural hinge next to node 1 for bare steel section
	set Zp_i [lindex $secInfo_i 0]
	set McMp_i [lindex $secInfo_i 1]
	set MrMp_i [lindex $secInfo_i 2]
	set theta_p_i [lindex $secInfo_i 3]
	set theta_pc_i [lindex $secInfo_i 4]
	set theta_u_i [lindex $secInfo_i 5]
	set lambda_i [lindex $secInfo_i 6]
	
	# Flexural hinge next to node 2 for bare steel section
	set Zp_j [lindex $secInfo_i 0]
	set McMp_j [lindex $secInfo_j 1]
	set MrMp_j [lindex $secInfo_j 2]
	set theta_p_j [lindex $secInfo_j 3]
	set theta_pc_j [lindex $secInfo_j 4]
	set theta_u_j [lindex $secInfo_j 5]
	set lambda_j [lindex $secInfo_j 6]
	
	## Compute beam plastic moment ###
	set Mp_i [expr $Fy*$Zp_i]
	set Mp_j [expr $Fy*$Zp_j]
	
	## Define stiffness constants
	set n 10
	set EIeff [expr $Es*$Ieff]
	set EA [expr $Es*$A]		
	
	## Create hinge materials ##
	if {$degradation == 1} {
		# Model with cyclic degradation so uses monotonic backbone
		
		matBilin02 $hingeSecTag_i $EIeff $Mp_i $McMp_i $theta_p_i $theta_pc_i $theta_u_i $lambda_i $c $MrMp_i $n $eleLength	0 0
		matBilin02 $hingeSecTag_j $EIeff $Mp_j $McMp_j $theta_p_j $theta_pc_j $theta_u_j $lambda_j $c $MrMp_j $n $eleLength 0 0
		
		# matIMKBilin $hingeSecTag_i $EIeff $eleLength $n $Mp_i $McMp_i $theta_p_i $theta_pc_i $theta_u_i $lambda_i $c $MrMp_i 0 0
		# matIMKBilin $hingeSecTag_j $EIeff $eleLength $n $Mp_j $McMp_j $theta_p_j $theta_pc_j $theta_u_j $lambda_j $c $MrMp_j 0 0		

	} else {
		# Model without cyclic degradation so uses first-cycle backbone
		matHysteretic $hingeSecTag_i $EIeff $eleLength $n $Mp_i $McMp_i $theta_p_i $theta_pc_i $MrMp_i  0 0 
		matHysteretic $hingeSecTag_j $EIeff $eleLength $n $Mp_j $McMp_j $theta_p_j $theta_pc_j $MrMp_j  0 0

	}
	
	## Create splice section ##
	set spliceSecTag [expr $hingeSecTag_i + 10]
	set webMatTag [expr $hingeSecTag_i+10]
	fracSectionSplice $spliceSecTag $eleDir $hingeSecTag_j $sigCr $webMatTag $d $bf $tf $ttab $dtab $FySplice $Es
	
	set rigSecTag [expr $hingeSecTag_i + 30]
	set spliceSecTag2 [expr $hingeSecTag_i + 20]
	uniaxialMaterial Elastic $rigSecTag 1e9;
	section Aggregator $spliceSecTag2 $rigSecTag Vy -section $spliceSecTag	
	
	## Create elements ##
	set eleTag2 [expr $eleTag+2];
	set hingeEleTag_i [expr $eleTag+3];
	set hingeEleTag_j [expr $eleTag+4];
	set spliceEleTag [expr $eleTag+5];
	
	# End springs
	# Option 1: Constraint (MORE EFFICIENT FOR IMPLICIT SOLUTION ALGORITHMS)
	equalDOF $node_i $nodeInt1 1 2
	equalDOF $node_j $nodeInt2 1 2
	element zeroLength $hingeEleTag_i $node_i $nodeInt1 -mat $hingeSecTag_i -dir 6
	element zeroLength $hingeEleTag_j $nodeInt2 $node_j -mat $hingeSecTag_j -dir 6
	# # Option 2: rigid material
	# element zeroLength $hingeEleTag_i $node_i $nodeInt1 -mat $rigMatTag $rigMatTag $hingeSecTag_i -dir 1 2 6
	# element zeroLength $hingeEleTag_j $nodeInt2 $node_j -mat $rigMatTag $rigMatTag $hingeSecTag_j -dir 1 2 6
	
	# Elastic elements between end springs
	# Option 1
	set IeffElement [expr $Ieff * ($n+1) / $n]
	element elasticBeamColumn   $eleTag $nodeInt1 $nodeSpl1 $A $Es $IeffElement $transfTag;
	element elasticBeamColumn   $eleTag2 $nodeSpl2 $nodeInt2 $A $Es $IeffElement $transfTag;

	# Splice element
	element zeroLengthSection $spliceEleTag $nodeSpl1 $nodeSpl2 $spliceSecTag2
	
}