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
proc forceBeamColumnFracture { eleTag node1 node2 eleDir transfTag Es Fy rigMatTag webConnection fracSecGeometry fracSecMaterials sigCrB_i sigCrT_i sigCrB_j sigCrT_j FI_limB_i FI_limT_i FI_limB_j FI_limT_j Composite trib tslab bslab AslabSteel slabFiberMaterials elemConvTol} {

	## Get section tags ##
	set hingeSecTag_i [expr $eleTag + 1]
	set hingeSecTag_j [expr $eleTag + 2]

	## Create intermediate nodes for fracture springs ##
	set n1Coord [nodeCoord $node1];
	set x1 [lindex $n1Coord 0];
	set y1 [lindex $n1Coord 1];
	set nodeInt1 [expr $node1+10];
	node $nodeInt1 $x1 $y1;
	
	set n2Coord [nodeCoord $node2];
	set x2 [lindex $n2Coord 0];
	set y2 [lindex $n2Coord 1];	
	set nodeInt2 [expr $node1+20];
	node $nodeInt2 $x2 $y2;
	
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
		set dtab [lindex $fracSecGeometry 6]
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
	set fpcu 0.0
	set epsU [lindex $slabFiberMaterials 2];#-0.01
	set fy [lindex $slabFiberMaterials 3];#60
	set gap 0
	set degrad [lindex $slabFiberMaterials 4];#-0.10
	
	## Define fracture section materials ##
	set nfdw 10;
	set nftw 1;
	set nfbf 1;
	set nftf 1;
	
	set topFMatTag_i [expr $hingeSecTag_i + 10]
	set botFMatTag_i [expr $hingeSecTag_i + 20]
	set topFMatTag_j [expr $hingeSecTag_i + 15]
	set botFMatTag_j [expr $hingeSecTag_i + 25]
	set webMatTag_i [expr $hingeSecTag_i + 30]
	set webMatTag_j [expr $hingeSecTag_i + 35]
	
	uniaxialMaterial SteelFractureDI $botFMatTag_i $FyFiber $EsFiber 0.02 18 0.85 0.15 0.08 1.00 0.08 1.00 $sigCrB_i $betaC_B $sigMin $FI_limB_i;
	uniaxialMaterial SteelFractureDI $topFMatTag_i $FyFiber $EsFiber 0.02 18 0.85 0.15 0.08 1.00 0.08 1.00 $sigCrT_i $betaC_T $sigMin $FI_limT_i;
	uniaxialMaterial SteelFractureDI $botFMatTag_j $FyFiber $EsFiber 0.02 18 0.85 0.15 0.08 1.00 0.08 1.00 $sigCrB_j $betaC_B $sigMin $FI_limB_j;
	uniaxialMaterial SteelFractureDI $topFMatTag_j $FyFiber $EsFiber 0.02 18 0.85 0.15 0.08 1.00 0.08 1.00 $sigCrT_j $betaC_T $sigMin $FI_limT_j;
	
	# ---------------- Concrete slab material ---------------------	
	set slabMatCompTag [expr $hingeSecTag_i + 60]
	set slabMatTenTag [expr $hingeSecTag_i + 70]
	uniaxialMaterial Concrete01  $slabMatCompTag $fc $epsc0 $fpcu $epsU
	uniaxialMaterial ElasticPPGap $slabMatTenTag $EsFiber $fy $gap $degrad damage
	
	# ---------------- Create sections ---------------------	
	set fracSecTag_i [expr $hingeSecTag_i + 10]
	set fracSecTag_j [expr $hingeSecTag_i + 20]
	
	# Fracture section (Beam-Column connection)
	if {$webConnection == "Bolted"} {	
		# Bolted web connection		
		set du_div 2; #Fraction of nominal displacement capacity of web fiber material
		fracSectionBolted $fracSecTag_i $eleDir $topFMatTag_i $botFMatTag_i $webMatTag_i $d $bf $tf $ttab $boltLocation $boltDiameter $FuBolt $FyTab $FuTab $Lc $tabLength $du_div $Composite $slabMatCompTag $slabMatTenTag $trib $tslab $bslab $AslabSteel;
		fracSectionBolted $fracSecTag_j $eleDir $topFMatTag_j $botFMatTag_j $webMatTag_j $d $bf $tf $ttab $boltLocation $boltDiameter $FuBolt $FyTab $FuTab $Lc $tabLength $du_div $Composite $slabMatCompTag $slabMatTenTag $trib $tslab $bslab $AslabSteel;
		
	} else {
		# Fully welded web connection		
		fracSectionWelded $fracSecTag_i $eleDir $topFMatTag_i $botFMatTag_i $webMatTag_i $d $bf $tf $ttab $dtab $FyTab $FuTab $EsFiber $Composite $slabMatCompTag $slabMatTenTag $trib $tslab $AslabSteel;
		fracSectionWelded $fracSecTag_j $eleDir $topFMatTag_j $botFMatTag_j $webMatTag_j $d $bf $tf $ttab $dtab $FyTab $FuTab $EsFiber $Composite $slabMatCompTag $slabMatTenTag $trib $tslab $AslabSteel;
		
	}
	
	# set rigMatTag [expr $hingeSecTag_i + 40]
	set fracSecTag2_i [expr $hingeSecTag_i + 30]
	set fracSecTag2_j [expr $hingeSecTag_i + 40]
	# uniaxialMaterial Elastic $rigMatTag 1e9;
	section Aggregator $fracSecTag2_i $rigMatTag Vy -section $fracSecTag_i
	section Aggregator $fracSecTag2_j $rigMatTag Vy -section $fracSecTag_j		
	
	## Define materials force-based element##
	set intMatTag [expr $eleTag+2];
	set hingeMatTag [expr $eleTag+4];
	set shearMatTag [expr $eleTag+5];
	set beta 1.2; # strain-hardening factor for Mp calculations (NIST, 2017 and ASCE41)
	uniaxialMaterial Elastic $intMatTag $Es;
	set Gs [expr $Es/(2*(1+0.3))]
	set Av [expr 2*$d*$tw]
	uniaxialMaterial Elastic $shearMatTag [expr $Gs*$Av];
	
	# uniaxialMaterial Steel02 $hingeMatTag [expr $beta*$Fy] $Es 0.01 18 0.85 0.15 0.08 1.00 0.08 1.00;
	uniaxialMaterial Steel4 $hingeMatTag [expr $beta*$Fy] $Es -kin 0.01 18 0.85 0.15 -iso 0.001 0.2 1e-6 20 0.1 -ult [expr 1.3*$beta*$Fy] 5;
	
	## Define sections for force-based element ##
	set intSecTag [expr $eleTag+2];
	set hingeSecTag [expr $eleTag+4];	
	set intSecTagShear [expr $eleTag+6];
	set hingeSecTagShear [expr $eleTag+7];
	set hingeWebMatTag [expr $eleTag+6]
	
	# Internal section
	set nfdw 10;
	set nftw 1;
	set nfbf 1;
	set nftf 1;
	Wsection $intSecTag $intMatTag $d $bf $tf $tw $nfdw $nftw $nfbf $nftf
	section Aggregator $intSecTagShear $shearMatTag Vy -section $intSecTag
	
	# Hinge section
	if $Composite {
		WsectionSlab $hingeSecTag $hingeMatTag $d $bf $tf $tw $nfdw $nftw $nfbf $nftf $trib $tslab $bslab		
	} else {
		Wsection $hingeSecTag $hingeMatTag $d $bf $tf $tw $nfdw $nftw $nfbf $nftf
	}
	section Aggregator $hingeSecTagShear $shearMatTag Vy -section $hingeSecTag
	
	# Inelastic force-based element
	set hingeLgth [expr 0.2*$eleLength/2]	
	set integration "HingeRadau $hingeSecTagShear $hingeLgth $hingeSecTagShear $hingeLgth $intSecTagShear";	
	element forceBeamColumn   $eleTag $nodeInt1 $nodeInt2 $transfTag $integration -iter 50 $elemConvTol;
	
	# Fracture element
	set fracEleTag_i [expr $eleTag+5];
	set fracEleTag_j [expr $eleTag+6];
	if {$eleDir == "Horizontal"} {
		element zeroLengthSection $fracEleTag_i $node1 $nodeInt1 $fracSecTag2_i -orient 1 0 0 0 1 0 -doRayleigh 1; # local x is global X and local y is global Y
		element zeroLengthSection $fracEleTag_j $nodeInt2 $node2 $fracSecTag2_j -orient 1 0 0 0 1 0 -doRayleigh 1; # local x is global X and local y is global Y			
	} else {
		element zeroLengthSection $fracEleTag_i $node1 $nodeInt1 $fracSecTag2_i -orient 0 1 0 -1 0 0 -doRayleigh 1; # local x is global Y and local y is global -X		
		element zeroLengthSection $fracEleTag_j $nodeInt2 $node2 $fracSecTag2_j -orient 0 1 0 -1 0 0 -doRayleigh 1; # local x is global Y and local y is global -X		
	}
}
