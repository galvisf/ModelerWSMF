########################################################################################################
# fracSectionBolted.tcl                                                                         
#
# SubRoutine to construct a fiber section of a welded-flange-bolted-web steel flange section
# for bare or composite section (top slab and tension steel)
#                                                      
########################################################################################################
#
# Input Arguments:
#------------------
# secTag			Section ID
# eleDir			'Horizontal'
#					'Vertical'
# topFMatTag		Material ID for the top flange steel
# botFMatTag		Material ID for the bottom flange steel
# webMatTag			Material ID for the web fibers
# d					Beam Depth [in]
# bf				Beam Flange Width [in]
# tf 				Beam Flange ThicknEsFibers [in]
# ttab 				thicknEsFibers of the shear tab [in]
# boltLocation		list with the bolt locations measured vertically from the center of the section
# boltDiameter		bolt diameter [in]
# FuvBolt			Ultimate SHEAR STREsFiberS of the bolt steel [ksi]
# FuTab				Ultimate AXIAL STREsFiberS of the tab steel [ksi]
# FyTab				Yielding AXIAL STREsFiberS of the tab steel [ksi]
# Lc				Clear distance from the edge of the bolt holEsFiber and the edge of the shar tab [in]
# tabLength			Width of the shear tab in the direction of the beam axis [in]
# du_div			Fraction of nominal displacement capacity of web fiber material
# Composite     	Consider or not composite slab
# slabMatTag	 	Material ID for the slab fiber
# trib				Steel deck rib depth [in]
# tslab				Concrete slab depth above the rib [in]
# AslabFiber		Area of slab fiber [1 in^2]
#
# Written by: Francisco Galvis, Stanford University
#
proc fracSectionBolted {secTag eleDir FyFiber EsFiber sigCrB sigCrT FI_limB FI_limT betaC_B betaC_T sigMin webMatTag d bf tf ttab boltLocation boltDiameter FuvBolt FyTab FuTab Lc tabLength du_div Composite slabMatTag trib tslab AslabFiber} {
	
	##################################################
	###              Pre-calculations              ###
	##################################################
	
	set widthDivNum 1; # Vertical direction to discretize the effective width per bolt
	set Nbolts [llength $boltLocation]; # Number of bolts 
	set sbolt [expr [lindex $boltLocation 1] - [lindex $boltLocation 0]]; # Vertical separation of bolts

	##################################################
	###  Compute Bolt-Web-Tab spring propertiEsFiber    ###
	##################################################
    # Based on recomendation from 2012 NIST          #
	# Technical Note 1749 (Section 3 - Reduced model)#
	##################################################	
	set Abolt [expr 3.1416 * pow($boltDiameter,2)/4];
	set dbg [expr $sbolt*($Nbolts - 1)];

	set Ktab [expr 28000*($dbg - 5.6)];
	if {$Ktab < 0} {
		# CasEsFiber with 2 bolts just for erection purposEsFiber and no welding
		set Ktab 1e6;
	}
	
	set summYsquare 0;
	for {set i 0} {$i < [llength $boltLocation]} {incr i} {
		set yCenter [lindex $boltLocation $i];
		set summYsquare [expr $summYsquare + pow($yCenter,2)];
	}

	set k [expr $Ktab/$summYsquare]; # Bolt spring stiffnEsFibers
	set du [expr 0.085*$dbg - 0.0018*pow($dbg,2)]; # Displacement at ultimate load

	# Bearing at bolt hole limit state
	set temp1 [expr 3*$boltDiameter*$ttab*$FuTab];
	set temp2 [expr 1.5*$Lc*$ttab*$FuTab];
	set tu1 [expr min($temp1,$temp2)];
	set cu1 [expr 3*$boltDiameter*$ttab*$FuTab];

	# Bolt shear limit state
	set tu2 [expr $Abolt*$FuvBolt];
	set cu2 [expr $Abolt*$FuvBolt];

	# Choose controlling limit state in tension
	if {$tu1 < $tu2} {
		# Bearing at bolt hole governs
		set tu $tu1;
		
		set temp1 [expr 3*$boltDiameter*$ttab*$FyTab];
		set temp2 [expr 1.5*$Lc*$ttab*$FyTab];
		set ty [expr min($temp1,$temp2)];
		set dyP [expr $ty/$k];
		
		set dfP [expr max($Lc, 1.15*$du)];
		
	} else {
		# Bolt shear governs
		set tu $tu2;
		set ty [expr 0.75*$tu];
		set dyP [expr $ty/$k];
		
		set dfP [expr 1.15*$du];
	}
	set du [expr $du/$du_div]
	set dfP [expr $dfP/$du_div]
	set kpP [expr ($tu - $ty)/($du - $dyP)];

	# Choose controling limit state in comprEsFibersion
	if {$cu1 < $cu2} {
		# Bearing at bolt hole governs
		set cu $cu1;
		set cy [expr 3*$boltDiameter*$ttab*$FyTab];
		set dyN [expr $cy/$k];
		
		set dfN 100;
		
	} else {
		# Bolt shear governs
		set cu $cu2;
		set cy [expr 0.75*$cu];
		set dyN [expr $cy/$k];	
		set dfN [expr 1.15*$du];
	}
	set kpN [expr abs($cu - $cy)/($du - $dyN)];

	##################################################
	###        Create Bolt-Web-Tab material        ###
	##################################################
	set AbearingBolt [expr $sbolt*$ttab];

	set E [expr $k*$tabLength/$AbearingBolt];
	set FyP [expr $ty/$AbearingBolt];
	set FyN [expr -$cy/$AbearingBolt];
	set th_pP [expr ($du - $dyP)/$tabLength];
	set th_pN [expr ($du - $dyN)/$tabLength];
	set th_pcP [expr ($dfP - $du)/$tabLength];
	set th_pcN [expr ($dfN - $du)/$tabLength];;
	set REsFiberP 0.2;
	set REsFiberN 0.2;

	uniaxialMaterial Hysteretic $webMatTag $FyP [expr $FyP/$E] [expr $tu/$AbearingBolt] [expr ($th_pP + $FyP/$E)] \
	[expr $REsFiberP*$tu/$AbearingBolt] [expr ($th_pcP + $th_pP + $FyP/$E)] $FyN [expr $FyN/$E] [expr -1*$cu/$AbearingBolt] [expr (-1*$th_pN + $FyN/$E)] \
	[expr -$REsFiberN*$cu/$AbearingBolt] [expr (-1*($th_pcN + $th_pN) + $FyN/$E)] 1.00 1.00 0.00 0.00
		
	##################################################
	###          Create flange materials           ###
	##################################################
	
	set botFMatTag_1 [expr $secTag]
	set botFMatTag_2 [expr $secTag + 1]
	set botFMatTag_3 [expr $secTag + 2]
	set botFMatTag_4 [expr $secTag + 3]
	set botFMatTag_5 [expr $secTag + 4]
	uniaxialMaterial SteelFractureDI $botFMatTag_1 $FyFiber $FyFiber $EsFiber 0.02 18 0.85 0.15 0.08 1.00 0.08 1.00 $sigCrB $betaC_B $sigMin [expr 1.0*$FI_limB];
	uniaxialMaterial SteelFractureDI $botFMatTag_2 $FyFiber $FyFiber $EsFiber 0.02 18 0.85 0.15 0.08 1.00 0.08 1.00 $sigCrB $betaC_B $sigMin [expr 1.0*$FI_limB];
	uniaxialMaterial SteelFractureDI $botFMatTag_3 $FyFiber $FyFiber $EsFiber 0.02 18 0.85 0.15 0.08 1.00 0.08 1.00 $sigCrB $betaC_B $sigMin [expr 1.0*$FI_limB];
	uniaxialMaterial SteelFractureDI $botFMatTag_4 $FyFiber $FyFiber $EsFiber 0.02 18 0.85 0.15 0.08 1.00 0.08 1.00 $sigCrB $betaC_B $sigMin [expr 1.0*$FI_limB];
	uniaxialMaterial SteelFractureDI $botFMatTag_5 $FyFiber $FyFiber $EsFiber 0.02 18 0.85 0.15 0.08 1.00 0.08 1.00 $sigCrB $betaC_B $sigMin [expr 1.0*$FI_limB];	
	
	set topFMatTag_1 [expr $secTag + 5]
	set topFMatTag_2 [expr $secTag + 6]
	set topFMatTag_3 [expr $secTag + 7]
	set topFMatTag_4 [expr $secTag + 8]
	set topFMatTag_5 [expr $secTag + 9]
	uniaxialMaterial SteelFractureDI $topFMatTag_1 $FyFiber $FyFiber $EsFiber 0.02 18 0.85 0.15 0.08 1.00 0.08 1.00 $sigCrT $betaC_T $sigMin [expr 1.0*$FI_limT];
	uniaxialMaterial SteelFractureDI $topFMatTag_2 $FyFiber $FyFiber $EsFiber 0.02 18 0.85 0.15 0.08 1.00 0.08 1.00 $sigCrT $betaC_T $sigMin [expr 1.0*$FI_limT];
	uniaxialMaterial SteelFractureDI $topFMatTag_3 $FyFiber $FyFiber $EsFiber 0.02 18 0.85 0.15 0.08 1.00 0.08 1.00 $sigCrT $betaC_T $sigMin [expr 1.0*$FI_limT];
	uniaxialMaterial SteelFractureDI $topFMatTag_4 $FyFiber $FyFiber $EsFiber 0.02 18 0.85 0.15 0.08 1.00 0.08 1.00 $sigCrT $betaC_T $sigMin [expr 1.0*$FI_limT];
	uniaxialMaterial SteelFractureDI $topFMatTag_5 $FyFiber $FyFiber $EsFiber 0.02 18 0.85 0.15 0.08 1.00 0.08 1.00 $sigCrT $betaC_T $sigMin [expr 1.0*$FI_limT];	
	
	##################################################
	###            Create fiber-section            ###
	##################################################
	
	# fiber area and location (flangEsFiber)
	if {$eleDir == "Vertical"} {
		set ybot [expr ($d-$tf)/2];	 # bottom flange on a vertical tEsFibert has the bottom flange to the left (positive local y)		
	} else {
		set ybot [expr -($d-$tf)/2]; # bottom flange on a horizontal beam has the bottom flange below (negative local y)		
	}
	set ytop [expr -$ybot];
	set z 0.0;
	set AFlange [expr $bf*$tf];
	
	if {$Composite} {
		# fiber area and location (slab)
		set yslab [expr $ytop + $trib + $tslab/2]
	}
	
	# define fiber section
	section Fiber $secTag {	
		
		# top and bottom flangEsFiber # changed here
		fiber $ytop $z [expr $AFlange/5] $topFMatTag_1; 
		fiber $ybot $z [expr $AFlange/5] $botFMatTag_1; 
		
		fiber $ytop $z [expr $AFlange/5] $topFMatTag_2; 
		fiber $ybot $z [expr $AFlange/5] $botFMatTag_2; 
		
		fiber $ytop $z [expr $AFlange/5] $topFMatTag_3; 
		fiber $ybot $z [expr $AFlange/5] $botFMatTag_3; 
		
		fiber $ytop $z [expr $AFlange/5] $topFMatTag_4; 
		fiber $ybot $z [expr $AFlange/5] $botFMatTag_4; 
		
		fiber $ytop $z [expr $AFlange/5] $topFMatTag_5; 
		fiber $ybot $z [expr $AFlange/5] $botFMatTag_5; 

		# web springs
		for {set i 0} {$i < [llength $boltLocation]} {incr i} {
			set yCenter [lindex $boltLocation $i];
			set numSubdivY $widthDivNum;								   # Vertical direction per bolt
			set numSubdivZ 1; 											   # TicknEsFibers direction per bolt
			set yI [expr $yCenter-$sbolt/2];
			set zI [expr -$ttab/2];
			set yJ [expr $yCenter+$sbolt/2];
			set zJ [expr $ttab/2];
			patch rect $webMatTag $numSubdivY $numSubdivZ $yI $zI $yJ $zJ; # Fibers of the steel tab;
			
			# set AboltFiber [expr $sbolt*$ttab]
			# fiber $yCenter $z $AboltFiber $webMatTag;
			
		}
		
		# Slab
		if {$Composite} {
			if {$eleDir == "Horizontal"} {
				fiber $yslab $z $AslabFiber $slabMatTag;
			}
		}		
	}
}
