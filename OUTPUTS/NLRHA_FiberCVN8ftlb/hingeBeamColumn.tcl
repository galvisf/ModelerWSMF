########################################################################################################
# hingeBeamColumn.tcl                                                                         
#
# SubRoutine to construct a beam or column element with plastic hinges at both ends
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
# c						Exponent defining the rate of cyclic deterioration [often assumed = 1]
# secInfo_i				list with initial side backbone parameters
#						{Zp_i Mc/Mp, Mr/Mp, thetaCap, thetaPC, thetaUlt, Lambda}
# secInfo_j				list with end side backbone parameters
#						{Zp_j Mc/Mp, Mr/Mp, thetaCap, thetaPC, thetaUlt, Lambda}
# Composite     		consider or not composite slab
# compBackboneFactors 	list with the factors that modify the backbone from bare to composite
#						{MpP/Mp MpN/Mp Mc/MpP Mc/MpN Mr/MpP Mr/MpN D_P D_N theta_p_P_comp 
#						theta_p_N_comp theta_pc_P_comp theta_pc_P_comp}
#
# Written by: Francisco Galvis, Stanford University
#
proc hingeBeamColumn { eleTag node_i node_j eleDir transfTag n Es Fy rigMatTag A Ieff degradation c secInfo_i secInfo_j Composite compBackboneFactors} {

	## Get section tags ##
	set hingeSecTag_i [expr $eleTag + 1]
	set hingeSecTag_j [expr $eleTag + 2]
	
	## Create intermediate nodes ##
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
	
	## Get element length ##
	if {$eleDir == "Horizontal"} {
		set eleLength [expr $x2 - $x1]
	} elseif {$eleDir == "Vertical"} {
		set eleLength [expr $y2 - $y1]
	} else {
		puts "ERROR: specify Horizontal or Vertical element direction"
	}
	
	## Read inputs ##		
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

	## Define stiffness constants ##
	set EIeff [expr $Es*$Ieff]	
	
	## Create hinge materials ##
	if {$degradation == 1} {
		# Model with cyclic degradation so uses monotonic backbone
		
		matBilin02 $hingeSecTag_i $EIeff $Mp_i $McMp_i $theta_p_i $theta_pc_i $theta_u_i $lambda_i $c $MrMp_i $n $eleLength	$Composite $compBackboneFactors
		matBilin02 $hingeSecTag_j $EIeff $Mp_j $McMp_j $theta_p_j $theta_pc_j $theta_u_j $lambda_j $c $MrMp_j $n $eleLength $Composite $compBackboneFactors
		
		# matIMKBilin $hingeSecTag_i $EIeff $eleLength $n $Mp_i $McMp_i $theta_p_i $theta_pc_i $theta_u_i $lambda_i $c $MrMp_i $Composite $compBackboneFactors
		# matIMKBilin $hingeSecTag_j $EIeff $eleLength $n $Mp_j $McMp_j $theta_p_j $theta_pc_j $theta_u_j $lambda_j $c $MrMp_j $Composite $compBackboneFactors		

	} else {
		# puts "Hysteretic hinge"
		# Model without cyclic degradation so uses first-cycle backbone
		matHysteretic $hingeSecTag_i $EIeff $eleLength $n $Mp_i $McMp_i $theta_p_i $theta_pc_i $MrMp_i  $Composite $compBackboneFactors 
		matHysteretic $hingeSecTag_j $EIeff $eleLength $n $Mp_j $McMp_j $theta_p_j $theta_pc_j $MrMp_j  $Composite $compBackboneFactors

	}
	
	## Create elements ##
	set hinge_i_EleTag [expr $eleTag+1];
	set hinge_j_EleTag [expr $eleTag+2];
	
	## Elastic element in the middle
	# Option 1: ModElastic
	set K44_2 [expr 6*(1+$n)/(2+3*$n)];
	set K11_2 [expr (1+2*$n)*$K44_2/(1+$n)];
	set K33_2 [expr (1+2*$n)*$K44_2/(1+$n)];
	set IeffElement [expr $Ieff * ($n+1) / $n]
	element ModElasticBeam2d $eleTag $nodeInt1 $nodeInt2 $A $Es $IeffElement $K11_2 $K33_2 $K44_2 $transfTag
	
	# Option 2 Typical elasticBeamColumn
	# set IeffElement [expr $Ieff * ($n+1) / $n]	
	# element elasticBeamColumn   $eleTag $nodeInt1 $nodeInt2 $A $Es $IeffElement $transfTag
	
	## End springs and elastic element in the middle
	# Option 1: Constraint (MORE EFFICIENT FOR IMPLICIT SOLUTION ALGORITHMS)
	equalDOF $node_i $nodeInt1 1 2
	equalDOF $node_j $nodeInt2 1 2
	element zeroLength $hinge_i_EleTag $node_i $nodeInt1 -mat $hingeSecTag_i -dir 6
	element zeroLength $hinge_j_EleTag $nodeInt2 $node_j -mat $hingeSecTag_j -dir 6
	
	# # Option 2: rigid material
	# element zeroLength $hinge_i_EleTag $node_i $nodeInt1 -mat $rigMatTag $rigMatTag $hingeSecTag_i -dir 1 2 6
	# element zeroLength $hinge_j_EleTag $nodeInt2 $node_j -mat $rigMatTag $rigMatTag $hingeSecTag_j -dir 1 2 6
	
}

