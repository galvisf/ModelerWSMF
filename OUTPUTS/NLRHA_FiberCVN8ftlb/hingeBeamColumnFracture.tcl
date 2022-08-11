########################################################################################################
# hingeBeamColumnFracture.tcl                                                                         
#
# SubRoutine to construct a beam or column element with plastic hinges at both ends and a fiber-section
# spring in series to capture fracture of the flanges and damage to the shear tab
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
#						{Mc/Mp, Mr/Mp, thetaCap, thetaPC, thetaUlt, Lambda}
# secInfo_j				list with end side backbone parameters
#						{Mc/Mp, Mr/Mp, thetaCap, thetaPC, thetaUlt, Lambda}
# webConnection			'Bolted' -> web to column connected with bolted shear tab
#						'Welded' -> web to column connected with CJP weld
# fracSecGeometry		list of the relevant geometry of the beam for the fracturing fiber-section
#						if webConnection == 'Bolted' -> {d bf tf ttab tabLength boltLocation boltDiameter Lc}
#						if webConnection == 'Welded' -> {d bf tf ttab tabLength dtab}
# fracSecMaterials		list of the material parameters for the fiber section
#						{FyFiber EsFiber betaC_B betaC_T sigMin FuBolt FyTab FuTab}
# sigCrB_i 				sigma critical bottom flange at initial side of the element
# sigCrT_i				sigma critical top flange at initial side of the element
# sigCrB_j				sigma critical bottom flange at end side of the element
# sigCrT_j				sigma critical top flange at end side of the element
# FI_limB_i 			FI limit for fracture: bottom flange at initial side of the element 
# FI_limT_i				FI limit for fracture: top flange at initial side of the element 
# FI_limB_j				FI limit for fracture: bottom flange at end side of the element 
# FI_limT_j				FI limit for fracture: top flange at end side of the element 
# Composite     		consider or not composite slab
# compBackboneFactors 	list with the factors that modify the backbone from bare to composite
#						{MpP/Mp MpN/Mp Mc/MpP Mc/MpN Mr/MpP Mr/MpN D_P D_N theta_p_P_comp 
#						theta_p_N_comp theta_pc_P_comp theta_pc_P_comp}	
# trib					Steel deck rib depth [in]
# tslab					Concrete slab depth above the rib [in]
# bslab					Concrete slab effective width [in]
# AslabSteel			Area of the steel resisting tension in the slab [in^2]
# slabFiberMaterials	list with the material properties for the slab fibers (Concrete01 and ElasticPPGap)
#						{fc epsc0 epsU fy degrad}
#
# Written by: Francisco Galvis, Stanford University
#
proc hingeBeamColumnFracture { eleTag node1 node2 eleDir transfTag n Es Fy rigMatTag A Ieff degradation c secInfo_i secInfo_j webConnection fracSecGeometry fracSecMaterials sigCrB_i sigCrT_i sigCrB_j sigCrT_j FI_limB_i FI_limT_i FI_limB_j FI_limT_j Composite compBackboneFactors trib tslab bslab AslabSteel slabFiberMaterials} {

	## Get section tags ##
	set hingeSecTag_i [expr $eleTag + 1]
	set hingeSecTag_j [expr $eleTag + 2]

	## Create intermediate nodes for fracture and hinge elements ##
	set n1Coord [nodeCoord $node1];
	set x1 [lindex $n1Coord 0];
	set y1 [lindex $n1Coord 1];
	set nodeInt1 [expr $node1+10];
	set nodeInt2 [expr $node1+20];
	node $nodeInt1 $x1 $y1;
	node $nodeInt2 $x1 $y1;
	
	set n2Coord [nodeCoord $node2];
	set x2 [lindex $n2Coord 0];
	set y2 [lindex $n2Coord 1];	
	set nodeInt3 [expr $node1+30];
	set nodeInt4 [expr $node1+40];
	node $nodeInt3 $x2 $y2;
	node $nodeInt4 $x2 $y2;
	
	## Get element length ##
	if {$eleDir == "Horizontal"} {
		set eleLength [expr $x2 - $x1]
	} elseif {$eleDir == "Vertical"} {
		set eleLength [expr $y2 - $y1]
	} else {
		puts "ERROR: specify Horizontal or Vertical element direction"
	}
	
	## Read inputs for fracture elements ##
	# Beam profile and tab geometry
	set d [lindex $fracSecGeometry 0]
	set bf [lindex $fracSecGeometry 1]
	set tf [lindex $fracSecGeometry 2]
	set tw [lindex $fracSecGeometry 3]
	set ttab [lindex $fracSecGeometry 4]
	set tabLength [lindex $fracSecGeometry 5]
	if {$webConnection == "Bolted"} {
		set boltLocation [lindex $fracSecGeometry 6]
		set boltDiameter [lindex $fracSecGeometry 7]	
		set Lc [lindex $fracSecGeometry 8]
		set du_div [lindex $fracSecGeometry 9]
	} else {
		set dtab [lindex $fracSecGeometry 5]
	}
		
	# Fracture fibers material properties
	set FyFiber [lindex $fracSecMaterials 0]
	set EsFiber [lindex $fracSecMaterials 1]
	set betaC_B [lindex $fracSecMaterials 2]
	set betaC_T [lindex $fracSecMaterials 3]
	set sigMin [lindex $fracSecMaterials 4]
	
	# Bolt and tab material properties
	set FuBolt [lindex $fracSecMaterials 5]
	set FyTab [lindex $fracSecMaterials 6]
	set FuTab [lindex $fracSecMaterials 7]	
	
	## Read inputs for slab ##
	set fc [lindex $slabFiberMaterials 0];#-3.0
	set epsc0 [lindex $slabFiberMaterials 1];#-0.002
	set epsU [lindex $slabFiberMaterials 2];#-0.01
	set fy [lindex $slabFiberMaterials 3];#60
	set degrad [lindex $slabFiberMaterials 4];#-0.10
	
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

	## Define stiffness constants for element	
	set EIeff [expr $Es*$Ieff]	
	
	## Define fracture section materials ##
	set nfdw 10;
	set nftw 1;
	set nfbf 1;
	set nftf 1;
	
	set webMatTag_i [expr $hingeSecTag_i + 30]
	set webMatTag_j [expr $hingeSecTag_i + 35]

	# ---------------- Concrete slab material ---------------------	
	set slabMatTag [expr $hingeSecTag_i + 60]
	set FyP [expr $fy*$AslabSteel]
	set FrP [expr 0]
	set FyN [expr $fc*$bslab*($tslab+$trib/2)]
	set FrN [expr 0]
	set AslabFiber 1.0
	
	uniaxialMaterial Hysteretic $slabMatTag $FyP [expr $fy/$EsFiber] $FrP [expr 10.0*$fy/$EsFiber] $FyN $epsc0 $FrN $epsU 0.50 0.50 0.02 0.02
	
	# ---------------- Create sections ---------------------	
	set fracSecTag_i [expr $hingeSecTag_i + 10]
	set fracSecTag_j [expr $hingeSecTag_i + 20]
	
	# Fracture section (Beam-Column connection)
	if {$webConnection == "Bolted"} {	
		# Bolted web connection		
		#set du_div 2; #Fraction of nominal displacement capacity of web fiber material		 
		fracSectionBolted $fracSecTag_i $eleDir $FyFiber $EsFiber $sigCrB_i $sigCrT_i $FI_limB_i $FI_limT_i $betaC_B $betaC_T $sigMin $webMatTag_i $d $bf $tf $ttab $boltLocation $boltDiameter $FuBolt $FyTab $FuTab $Lc $tabLength $du_div $Composite $slabMatTag  $trib $tslab $AslabFiber;
		fracSectionBolted $fracSecTag_j $eleDir $FyFiber $EsFiber $sigCrB_j $sigCrT_j $FI_limB_j $FI_limT_j $betaC_B $betaC_T $sigMin $webMatTag_j $d $bf $tf $ttab $boltLocation $boltDiameter $FuBolt $FyTab $FuTab $Lc $tabLength $du_div $Composite $slabMatTag  $trib $tslab $AslabFiber;
		
	} else {
		# Fully welded web connection		
		fracSectionWelded $fracSecTag_i $eleDir $FyFiber $EsFiber $sigCrB_i $sigCrT_i $FI_limB_i $FI_limT_i $betaC_B $betaC_T $sigMin $webMatTag_i $d $bf $tf $ttab $dtab $FyTab $FuTab $EsFiber $Composite $slabMatTag $trib $tslab $AslabFiber;
		fracSectionWelded $fracSecTag_j $eleDir $FyFiber $EsFiber $sigCrB_j $sigCrT_j $FI_limB_j $FI_limT_j $betaC_B $betaC_T $sigMin $webMatTag_j $d $bf $tf $ttab $dtab $FyTab $FuTab $EsFiber $Composite $slabMatTag $trib $tslab $AslabFiber;
		
	}
	
	# set rigMatTag [expr $hingeSecTag_i + 40]
	set fracSecTag2_i [expr $hingeSecTag_i + 30]
	set fracSecTag2_j [expr $hingeSecTag_i + 40]
	# uniaxialMaterial Elastic $rigMatTag 1e9;
	section Aggregator $fracSecTag2_i $rigMatTag Vy -section $fracSecTag_i
	section Aggregator $fracSecTag2_j $rigMatTag Vy -section $fracSecTag_j		
	
	## Create hinge materials ##
	if {$degradation == 1} {
		# Model with cyclic degradation so uses monotonic backbone

		matBilin02 $hingeSecTag_i $EIeff $Mp_i $McMp_i $theta_p_i $theta_pc_i $theta_u_i $lambda_i $c $MrMp_i $n $eleLength	$Composite $compBackboneFactors
		matBilin02 $hingeSecTag_j $EIeff $Mp_j $McMp_j $theta_p_j $theta_pc_j $theta_u_j $lambda_j $c $MrMp_j $n $eleLength $Composite $compBackboneFactors
		
		# matIMKBilin $hingeSecTag_i $EIeff $eleLength $n $Mp_i $McMp_i $theta_p_i $theta_pc_i $theta_u_i $lambda_i $c $MrMp_i $Composite $compBackboneFactors
		# matIMKBilin $hingeSecTag_j $EIeff $eleLength $n $Mp_j $McMp_j $theta_p_j $theta_pc_j $theta_u_j $lambda_j $c $MrMp_j $Composite $compBackboneFactors		

	} else {
		# Model without cyclic degradation so uses first-cycle backbone
		matHysteretic $hingeSecTag_i $EIeff $eleLength $n $Mp_i $McMp_i $theta_p_i $theta_pc_i $MrMp_i  $Composite $compBackboneFactors 
		matHysteretic $hingeSecTag_j $EIeff $eleLength $n $Mp_j $McMp_j $theta_p_j $theta_pc_j $MrMp_j  $Composite $compBackboneFactors

	}
	
	## Create elements ##
	set hingeEleTag_i [expr $eleTag+2];
	set hingeEleTag_j [expr $eleTag+4];
	set fracEleTag_i [expr $eleTag+5];
	set fracEleTag_j [expr $eleTag+6];
	
	# Elastic elements between end springs
	# set IeffElement [expr $Ieff * ($n+1) / $n]
	# element elasticBeamColumn   $eleTag $nodeInt2 $nodeInt3 $A $Es $IeffElement $transfTag;

	set K44_2 [expr 6*(1+$n)/(2+3*$n)];
	set K11_2 [expr (1+2*$n)*$K44_2/(1+$n)];
	set K33_2 [expr (1+2*$n)*$K44_2/(1+$n)];
	set IeffElement [expr $Ieff * ($n+1) / $n]
	element ModElasticBeam2d $eleTag $nodeInt2 $nodeInt3 $A $Es $IeffElement $K11_2 $K33_2 $K44_2 $transfTag

	# Fracture element
	if {$eleDir == "Horizontal"} {
		# Option 1: Constraint (MORE EFFICIENT FOR IMPLICIT SOLUTION ALGORITHMS)
		equalDOF $nodeInt1 $nodeInt2 1 2
		equalDOF $nodeInt3 $nodeInt4 1 2
		element zeroLength $hingeEleTag_i $nodeInt1 $nodeInt2 -mat $hingeSecTag_i -dir 6 -orient 1 0 0 0 1 0 -doRayleigh 1 
		element zeroLength $hingeEleTag_j $nodeInt3 $nodeInt4 -mat $hingeSecTag_j -dir 6 -orient 1 0 0 0 1 0 -doRayleigh 1
		
		# # Option 2: rigid material
		# element zeroLength $hingeEleTag_i $nodeInt1 $nodeInt2 -mat $rigMatTag $rigMatTag $hingeSecTag_i -dir 1 2 6 -orient 1 0 0 0 1 0 -doRayleigh 1
		# element zeroLength $hingeEleTag_j $nodeInt3 $nodeInt4 -mat $rigMatTag $rigMatTag $hingeSecTag_j -dir 1 2 6 -orient 1 0 0 0 1 0 -doRayleigh 1	
		
		element zeroLengthSection $fracEleTag_i $node1 $nodeInt1 $fracSecTag2_i -orient 1 0 0 0 1 0; # local x is global X and local y is global Y
		element zeroLengthSection $fracEleTag_j $nodeInt4 $node2 $fracSecTag2_j -orient 1 0 0 0 1 0; # local x is global X and local y is global Y			
	} else {
		# Option 1: Constraint (MORE EFFICIENT FOR IMPLICIT SOLUTION ALGORITHMS)
		equalDOF $nodeInt1 $nodeInt2 1 2
		equalDOF $nodeInt3 $nodeInt4 1 2
		element zeroLength $hingeEleTag_i $nodeInt1 $nodeInt2 -mat $hingeSecTag_i -dir 6 -orient 0 1 0 -1 0 0 -doRayleigh 1
		element zeroLength $hingeEleTag_j $nodeInt3 $nodeInt4 -mat $hingeSecTag_j -dir 6 -orient 0 1 0 -1 0 0 -doRayleigh 1	
		
		# # Option 2: rigid material
		# element zeroLength $hingeEleTag_i $nodeInt1 $nodeInt2 -mat $rigMatTag $rigMatTag $hingeSecTag_i -dir 1 2 6 -orient 0 1 0 -1 0 0 -doRayleigh 1
		# element zeroLength $hingeEleTag_j $nodeInt3 $nodeInt4 -mat $rigMatTag $rigMatTag $hingeSecTag_j -dir 1 2 6 -orient 0 1 0 -1 0 0 -doRayleigh 1		
		
		element zeroLengthSection $fracEleTag_i $node1 $nodeInt1 $fracSecTag2_i -orient 0 1 0 -1 0 0; # local x is global Y and local y is global -X		
		element zeroLengthSection $fracEleTag_j $nodeInt4 $node2 $fracSecTag2_j -orient 0 1 0 -1 0 0; # local x is global Y and local y is global -X		
	}
}
