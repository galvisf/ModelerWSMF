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
# FySplice				Yielding AXIAL STRESS of the tab steel [ksi]
# FuTab				Ultimate AXIAL STRESS of the tab steel [ksi]
# Es	         	Young's modulus [ksi]
#
# Written by: Francisco Galvis, Stanford University
#
proc fracSectionSplice {secTag eleDir hingeSecTag sigCr webMatTag d bf tf ttab dtab FySplice Es} {

	##################################################
	###              Pre-calculations              ###
	##################################################
	set widthDivNum 1; # Vertical direction to discretize the effective width per bolt
	set sfiber 2; # Vertical separation of fibers
	set Nfibers [expr  floor($dtab/$sfiber)]; # Number of fibers
	
	set dassigned [expr $sfiber*$Nfibers] 
	#puts "dtab=$dtab"
	#puts "dassigned=$dassigned"
	
	##################################################
	###          Create welded-web material        ###
	##################################################
	
	# Bilinear material with low hardening
	set b 0.01; # Stillmaker assumed 0.05
	uniaxialMaterial Steel01 $webMatTag [expr min($sigCr, $FySplice)] [expr $Es/10] $b
	
	##################################################
	####          Create flange materials         ####
	##################################################
	
	set fracMatTag1 [expr $hingeSecTag+21]	
	set fracMatTag2 [expr $hingeSecTag+22]	
	set fracMatTag3 [expr $hingeSecTag+23]	
	set fracMatTag4 [expr $hingeSecTag+24]	
	set fracMatTag5 [expr $hingeSecTag+25]
	
	set FI_lim1 1.00
	set FI_lim2 0.90
	set FI_lim3 1.10
	set FI_lim4 0.80
	set FI_lim5 1.20
	
	set betaC 1.0
	set dStress 0.1
	uniaxialMaterial SteelFractureDI $fracMatTag1 $FySplice $FySplice $Es $b 10 0.9 0.15 0 1 0 1 $dStress $betaC [expr $sigCr - $dStress] $FI_lim1;
	uniaxialMaterial SteelFractureDI $fracMatTag2 $FySplice $FySplice $Es $b 10 0.9 0.15 0 1 0 1 $dStress $betaC [expr $sigCr - $dStress] $FI_lim2;
	uniaxialMaterial SteelFractureDI $fracMatTag3 $FySplice $FySplice $Es $b 10 0.9 0.15 0 1 0 1 $dStress $betaC [expr $sigCr - $dStress] $FI_lim3;
	uniaxialMaterial SteelFractureDI $fracMatTag4 $FySplice $FySplice $Es $b 10 0.9 0.15 0 1 0 1 $dStress $betaC [expr $sigCr - $dStress] $FI_lim4;
	uniaxialMaterial SteelFractureDI $fracMatTag5 $FySplice $FySplice $Es $b 10 0.9 0.15 0 1 0 1 $dStress $betaC [expr $sigCr - $dStress] $FI_lim5;
	
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
	
	# define fiber section
	section Fiber $secTag {	
	
		# top and bottom flanges
		fiber $ytop $z [expr $AFlange/5] $fracMatTag1; 
		fiber $ybot $z [expr $AFlange/5] $fracMatTag1; 
		
		fiber $ytop $z [expr $AFlange/5] $fracMatTag2; 
		fiber $ybot $z [expr $AFlange/5] $fracMatTag2; 
		
		fiber $ytop $z [expr $AFlange/5] $fracMatTag3; 
		fiber $ybot $z [expr $AFlange/5] $fracMatTag3; 
		
		fiber $ytop $z [expr $AFlange/5] $fracMatTag4; 
		fiber $ybot $z [expr $AFlange/5] $fracMatTag4; 
		
		fiber $ytop $z [expr $AFlange/5] $fracMatTag5; 
		fiber $ybot $z [expr $AFlange/5] $fracMatTag5; 
		
		# web springs
		for {set i 0} {$i < $Nfibers} {incr i} {
			set yCenter [expr -1*$sfiber*$Nfibers/2 + ($i + 0.5)*$sfiber];   # Center of the fiber
			#puts "yCenter=$yCenter"
			set numSubdivY $widthDivNum;  # Vertical direction per bolt
			set numSubdivZ 1; 	# Tickness direction per bolt
			set yI [expr $yCenter-$sfiber/2];
			set zI [expr -$ttab/2];
			set yJ [expr $yCenter+$sfiber/2];
			set zJ [expr $ttab/2];
			patch rect $webMatTag $numSubdivY $numSubdivZ $yI $zI $yJ $zJ; # Fibers of the steel tab;		
		}			
	}
}