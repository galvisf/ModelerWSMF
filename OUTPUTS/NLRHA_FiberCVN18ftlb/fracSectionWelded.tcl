########################################################################################################
# fracSectionWelded.tcl                                                                         
#
# SubRoutine to construct a fiber section of a welded-flange-welded-web steel flange section
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
# tf 				Beam Flange Thickness [in]
# ttab 				thickness of the shear tab [in]
# dtab				depth of the web welded to the column (assumed centered in the beam depth) [in]
# FyTab				Yielding AXIAL STRESS of the tab steel [ksi]
# FuTab				Ultimate AXIAL STRESS of the tab steel [ksi]
# Es	         	Young's modulus [ksi]
# Composite     	Consider or not composite slab
# slabMatTag	 	Material ID for the slab fiber
# trib				Steel deck rib depth [in]
# tslab				Concrete slab depth above the rib [in]
# AslabFiber		Area of slab fiber [1 in^2]
#
# Written by: Francisco Galvis, Stanford University
#
proc fracSectionWelded {secTag eleDir FyFiber EsFiber sigCrB sigCrT FI_limB FI_limT betaC_B betaC_T sigMin webMatTag d bf tf ttab dtab FyTab FuTab Es Composite slabMatTag trib tslab AslabFiber} {

	##################################################
	###              Pre-calculations              ###
	##################################################
	set widthDivNum 1; # Vertical direction to discretize the effective width per bolt
	set sfiber 3; # Vertical separation of fibers
	set Nfibers [expr  floor($dtab/$sfiber - 1)]; # Number of fibers
	set dy [expr $FyTab/$Es]
	#puts "Nfibers=$Nfibers"
	#puts "dy=$dy"
	#puts "FyTab=$FyTab"
	#puts "FuTab=$FuTab"
	#puts "ttab=$ttab"
	#puts "bf=$bf"
	#puts "tf=$tf"
	
	##################################################
	###          Create welded-web material        ###
	##################################################
	if {$FyTab == $FuTab} {
		# sudden fracture
		uniaxialMaterial Hysteretic $webMatTag $FyTab $dy [expr 0.2*$FyTab] [expr 2*$dy] [expr -1*$FyTab] [expr -1*$dy] [expr -0.2*$FyTab] [expr -2*$dy] 1.00 1.00 0.00 0.00
	} else {
		# yields
		uniaxialMaterial Hysteretic $webMatTag $FyTab $dy [expr $FuTab] 0.10 [expr 0.2*$FyTab] 0.20 [expr -1*$FyTab] [expr -1*$dy] [expr $FuTab] -0.10 [expr -0.2*$FyTab] -0.2 1.00 1.00 0.00 0.00	
	}
	
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
	
	# fiber area and location (flanges)
	if {$eleDir == "Vertical"} {
		set ybot [expr ($d-$tf)/2];	 # bottom flange on a vertical test has the bottom flange to the left (positive local y)		
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
		for {set i 0} {$i < $Nfibers} {incr i} {
			set yCenter [expr -1*$sfiber*$Nfibers/2 + $i*$sfiber];   # Center of the fiber
			set numSubdivY $widthDivNum;		        		   # Vertical direction per bolt
			set numSubdivZ 1; 									   # Tickness direction per bolt
			set yI [expr $yCenter-$sfiber/2];
			set zI [expr -$ttab/2];
			set yJ [expr $yCenter+$sfiber/2];
			set zJ [expr $ttab/2];
			patch rect $webMatTag $numSubdivY $numSubdivZ $yI $zI $yJ $zJ; # Fibers of the steel tab;
						
		}		
		
		# Slab
		if {$Composite} {
			if {$eleDir == "Horizontal"} {	
				fiber $yslab $z $AslabFiber $slabMatTag;
			}
		}
				
	}
}