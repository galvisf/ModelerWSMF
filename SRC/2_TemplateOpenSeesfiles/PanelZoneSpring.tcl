########################################################################################################
# PanelZoneSpring.tcl                                                                         
#
# SubRoutine to construct panel zone spring model
#                                                      
########################################################################################################
#
# Input Arguments:
#------------------
# eleID			Element ID
# NodeI			Node i ID
# NodeJ			Node j ID
# Es         	Young's modulus [ksi]
# mu			Poisson's Ratio
# Fy			Expected Yield Stress [ksi]
# dc			Column Depth [in]
# bc			Column Flange Width [in]
# tcf 			Column Flange Thickness [in]
# tcw			Column Web Thickness [in]
# tdp			Doubler Plate(s) Thickness [in]
# db     		Beam Depth [in]
# Ic			Column second-moment-of-area about the axis of the frame [in^4]
# Acol			Column gross area [in^2]
# alpha			Hardening ratio
# Pr			Column axial gravity load [kip]
# trib			Steel deck rib depth [in]
# tslab			Concrete slab depth above the rib [in]
# pzModelTag    1 -> Gupta and Krawinkler
#               2 -> NIST, 2017
#               3 -> Kim et al. 2015
#               4 -> Skiadopoulos et al. 2021 
#				5 -> Elastic spring
# isExterior    panel zone type
# Composite     consider or not composite slab
#
# Written by: Francisco Galvis, Stanford University
#
proc PanelZoneSpring {eleID NodeI NodeJ Es mu Fy dc bc tcf tcw tdp db Ic Acol alpha Pr trib tslab pzModelTag isExterior Composite} {

	set tp [expr $tcw + $tdp]; # effective panel thickness

	##################################################
	#                                                #
	#         Compute backbone parameters            #
	#     (For alternative bare section modes)       #
	#                                                #
	##################################################

	set G [expr $Es / (2.0 * (1.0 + 0.3))];
	if {$pzModelTag == 1} { 
	##################################################
	### Gupta and Krawinkler, 1999: Section 3.2.3) ###
	##################################################

		set Vy [expr 0.55 * $Fy * $dc * $tp];
		set Ke [expr 0.95 * $dc * $tp * $G];
		set Kp [expr 0.95 * $bc * pow($tcf, 2) * $G / $db];

		set gamma_y [expr $Vy / $Ke];
		set gamma_p [expr 4*$gamma_y];
		set gamma_3 [expr 100*$gamma_y];
	}
	if {$pzModelTag == 2}  {
	##################################################
	###            NIST, 2017 Guidelines           ###
	##################################################
		set Vy [expr 0.60 * $Fy * $dc * $tp];
		
		set Vp [expr 0.60 * $Fy * $dc * $tp * (1 + 3*$bc*pow($tcf,2)/($db*$dc*$tp))];
		set Py [expr $Fy * $Acol];
		if {$Pr >= [expr 0.75*$Py]} {
			set AxialFactor [expr 1.9 - 1.2 * $Pr / $Py];
			set Vp [expr $Vp*$AxialFactor];
		}
		
		set gamma_y [expr 0.60 * $Fy / $G];
		set gamma_p [expr 0.475*$Fy/$Es*($db/$tcf + 3.45*$tcf/$db)]; # Eq. 3-3 2017 NIST modeling guideline Vol. 2
		set gamma_3 [expr 100*$gamma_y];
		
		set Ke [expr $Vy/$gamma_y];
		set Kp [expr ($Vp - $Vy)/($gamma_p - $gamma_y)];
	}
	if {$pzModelTag == 3}  {
	##################################################
	###               Kim et al. 2015              ###
	##################################################
		set gamma_y [expr 0.60 * $Fy / $G];
		set gamma_p [expr 0.475*$Fy/$Es*($db/$tcf + 3.45*$tcf/$db)]; # Eq. 3-3 2017 NIST modeling guideline Vol. 2

		set Vcwy [expr 0.60 * $Fy * 0.95 * $dc * $tp];
		set Kcw [expr $Vcwy/$gamma_y];
		
		set Mpcf [expr $bc*pow($tcf,2)/4*$Fy];
		set Kcf [expr 2*$Mpcf/(0.95*$db*$gamma_p)];
		
		set Vy [expr $Vcwy + 2*$Kcf*$gamma_y];
		
		set Py [expr $Fy * $Acol];
		if {$Pr >= [expr 0.25*$Py]} {
			set AxialFactor [expr 1-pow($Pr/(2*$Py),2)];		
			set gamma_p [expr $gamma_p*$AxialFactor]
		}
		set Vp [expr $Vcwy + 0.03*$Kcw*($gamma_p-$gamma_y) + 2*$Kcf*$gamma_p];		
		
		set gamma_3 [expr 100*$gamma_y];
		
		set Ke [expr $Vy/$gamma_y];
		set Kp [expr ($Vp - $Vy)/($gamma_p - $gamma_y)];	
	}

	##################################################
	#                                                #
	#           Create panel zone spring             #
	#                                                #
	##################################################

	if {$pzModelTag <= 3}  {
		# Transition to M-gamma relationship
		# K_moment = db * K_shear

		set My [expr $gamma_y * ($Ke * $db)];
		set Mp [expr $My + ($Kp * $db) * ($gamma_p - $gamma_y)];
		set M3 [expr $Mp + ($Ke * $alpha * $db) * ($gamma_3 - $gamma_p)];	

		# material with no pinching and damage, matID same as eleID
		uniaxialMaterial Hysteretic $eleID $My $gamma_y $Mp $gamma_p $M3 $gamma_3 \
				[expr -$My] [expr -$gamma_y] [expr -$Mp] [expr -$gamma_p] [expr -$M3] [expr -$gamma_3] \
				1 1 0.0 0.0 0.0;

		element zeroLength $eleID $NodeI $NodeJ -mat $eleID -dir 6

	} elseif {$pzModelTag == 4} {
	##################################################
	###           Skiadopoulos et al. 2021         ###
	### This function computes the backbone and    ###
	### creates the element                        ###
	##################################################	
		# axial load ratio of the column
		set n [expr $Pr / ($Fy * $Acol)];
		#second moment of area of column about strong axis
		#set Ix_Col [expr 1/12*$tp * pow($dc - 2*$tcf, 3) + 2*(1/12*$bc * pow($tcf, 3) + $bc*$tcf*pow($dc/2-$tcf/2,2))]
		
		# Identify panel zone response
		if {$Composite == 0} {
			set Response_ID 2
		} elseif {$isExterior} {
			set Response_ID 1
		} else {
			set Response_ID 0
		}
		
		Spring_PZ $eleID $NodeI $NodeJ $Es $mu $Fy  $tcw $tdp $dc $db $tcf $bc $Ic $n $trib $tslab $isExterior
	} else {
		########################
		#### Elastic spring ####
		########################
		# axial load ratio of the column
		set n [expr $Pr / ($Fy * $Acol)];
		
		# Identify panel zone response
		if {$Composite == 0} {
			set Response_ID 2
		} elseif {$isExterior} {
			set Response_ID 1
		} else {
			set Response_ID 0
		}
		
		Elastic_Spring_PZ $eleID $NodeI $NodeJ $Es $mu $Fy  $tcw $tdp $dc $db $tcf $bc $Ic $n $trib $tslab $isExterior
	}
}


##################################################################################################################
# Spring_PZ.tcl
#
# SubRoutine to construct a rotational spring with a trilinear hysteretic response representative of steel 
# panel zone response with/without the consideration of composite action                                                           
#      
# References: 
#--------------	
# Elkady, A. and D. G. Lignos (2014). "Modeling of the Composite Action in Fully Restrained Beam-to-Column
# 	Connections: ‎Implications in the Seismic Design and Collapse Capacity of Steel Special Moment Frames." 
# 	Earthquake Eng. & Structural Dynamics 43(13). DOI: 10.1002/eqe.2430.
#
# Skiadopoulos, A., Elkady, A. and D. G. Lignos (2020). "Proposed Panel Zone Model for Seismic Design of 
#   Steel Moment-Resisting Frames." ASCE Journal of Structural Engineering. DOI: 10.1061/(ASCE)ST.1943-541X.0002935. 
#
##################################################################################################################
#
# Input Arguments:                                                                               
#------------------
# SpringID		Spring ID
# NodeI			Node i ID
# NodeJ			Node j ID
# E				Young's Modulus [ksi]
# mu			Poisson's Ratio
# fy			Yield Stress (Expected, measured or nominal) [ksi]
# tw_Col		Column Web Thickness [in]
# tdp			Doubler Plate(s) Total Thickness [in]
# d_Col			Column Depth [in]
# d_Beam		Beam Depth [in]
# tf_Col		Column Flange Thickness [in]
# bf_Col		Column Flange Width [in]
# Ix_Col		Column second-moment-of-interia about the strong axis [in^4]
# n				Axial load ratio (P/Py)
# trib			Steel deck rib depth [in]
# ts			Concrete slab depth above the rib [in]
# Response_ID	ID for Panel Zone Response: 0 --> Interior Steel Panel Zone with Composite Action
#								   			1 --> Exterior Steel Panel Zone with Composite Action
#								   			2 --> Bare Steel Interior/Exterior Steel Panel Zone
#                                                                                                      
# Written by: Dr. Ahmed Elkady, University of Southampton, UK
# 
##################################################################################################################


proc Spring_PZ {SpringID NodeI NodeJ E mu fy  tw_Col tdp d_Col d_Beam tf_Col bf_Col Ix_Col n trib ts Response_ID} {
	
	# puts "XXXX $SpringID XXXX" 
	# puts "$d_Col"
	# puts "$bf_Col"	
	# puts "$tf_Col"
	# puts "$tw_Col"
	# puts "$d_Beam"
	
	set tpz [expr $tw_Col + $tdp]; # total PZ thickness

	set G [expr $E/(2.0 * (1.0 + $mu))];     # Shear Modulus

	# Beam's effective depth
	if {$Response_ID==2} {
	set d_BeamP $d_Beam;
	} else {
	set d_BeamP [expr $d_Beam + $trib + 0.5 * $ts]; # Effective Depth in Positive Moment
	}
	set d_BeamN $d_Beam; 						   # Effective Depth in Negative Moment

	# Stiffness Calculation
	set Ks [expr $tpz * ($d_Col - $tf_Col) * $G];   											    # PZ Stiffness: Shear Contribution
	set Kb [expr 12 * $E * ($Ix_Col + $tdp * pow(($d_Col - 2*$tf_Col),3)/12.) /pow($d_Beam,3) * $d_Beam];  # PZ Stiffness: Bending Contribution
	set Ke [expr ($Ks * $Kb) / ($Ks + $Kb)];   												    # PZ Stiffness: Total

	set Ksf [expr 2 * ($bf_Col * $tf_Col) * $G];   								   # Flange Stiffness: Shear Contribution
	set Kbf [expr 2 * 12 * $E * $bf_Col * pow($tf_Col,3)/12. /pow($d_Beam,3) * $d_Beam];   # Flange Stiffness: Bending Contribution
	set Kef [expr ($Ksf * $Kbf) / ($Ksf + $Kbf)];   								   # Flange Stiffness: Total

	set ay [expr (0.58 * $Kef / $Ke  + 0.88) / (1 - $Kef / $Ke)];

	set aw_eff_4gamma 1.10;
	set aw_eff_6gamma 1.15;

	set af_eff_4gamma [expr 0.93 * $Kef / $Ke  + 0.015];
	set af_eff_6gamma [expr 1.05 * $Kef / $Ke  + 0.020];

	set r [expr sqrt(1- pow($n,2))]; # Reduction factor accounting for axial load

	set Vy 		     [expr $r * 0.577 * $fy *  $ay			 * ($d_Col - $tf_Col) * $tpz];  										    # Yield Shear Force
	set Vp_4gamma 	[expr $r * 0.577 * $fy * ($aw_eff_4gamma * ($d_Col - $tf_Col) * $tpz + $af_eff_4gamma * ($bf_Col - $tw_Col) * 2*$tf_Col)];  # Plastic Shear Force @ 4 gammaY
	set Vp_6gamma 	[expr $r * 0.577 * $fy * ($aw_eff_6gamma * ($d_Col - $tf_Col) * $tpz + $af_eff_6gamma * ($bf_Col - $tw_Col) * 2*$tf_Col)];  # Plastic Shear Force @ 6 gammaY

	set gamma_y  [expr $Vy/$Ke]; 
	set gamma4_y [expr 4.0 * $gamma_y];  
	set gamma6_y [expr 6.0 * $gamma_y];

	set My_P        [expr $Vy 	    * $d_BeamP];
	set Mp_4gamma_P [expr $Vp_4gamma * $d_BeamP];
	set Mp_6gamma_P [expr $Vp_6gamma * $d_BeamP];

	set My_N 	  [expr $Vy 	    * $d_BeamN];
	set Mp_4gamma_N [expr $Vp_4gamma * $d_BeamN];
	set Mp_6gamma_N [expr $Vp_6gamma * $d_BeamN];

	set Slope_4to6gamma_y_P [expr ($Mp_6gamma_P - $Mp_4gamma_P) / (2 * $gamma_y) ];
	set Slope_4to6gamma_y_N [expr ($Mp_6gamma_N - $Mp_4gamma_N) / (2 * $gamma_y) ];

	# Defining the 3 Points used to construct the trilinear backbone curve
	set gamma1 $gamma_y; 
	set gamma2 $gamma4_y;  
	set gamma3 [expr 100 * $gamma_y];

	set M1_P [expr $My_P];
	set M2_P [expr $Mp_4gamma_P];
	set M3_P [expr $Mp_4gamma_P + $Slope_4to6gamma_y_P * (100 * $gamma_y - $gamma4_y)];

	set M1_N [expr $My_N];
	set M2_N [expr $Mp_4gamma_N];
	set M3_N [expr $Mp_4gamma_N + $Slope_4to6gamma_y_N * (100 * $gamma_y - $gamma4_y)];

	set gammaU_P   0.3;
	set gammaU_N  -0.3;

	set Dummy_ID [expr   12 * $SpringID]; 

	# Hysteretic Material without pinching and damage
	# uniaxialMaterial Hysteretic $matTag $s1p $e1p $s2p $e2p <$s3p $e3p> $s1n $e1n $s2n $e2n <$s3n $e3n> $pinchX $pinchY $damage1 $damage2

	# Composite Interior Steel Panel Zone
		
	# puts "$M1_P"
	# puts "$gamma1"
	# puts "$M2_P"	
	# puts "$gamma2"
	# puts "$M3_P"
	# puts "$gamma3"
	
	if { $Response_ID == 0.0 } {
	 uniaxialMaterial Hysteretic $Dummy_ID  $M1_P $gamma1  $M2_P $gamma2 $M3_P $gamma3 [expr -$M1_P] [expr -$gamma1] [expr -$M2_P] [expr -$gamma2] [expr -$M3_P] [expr -$gamma3] 0.25 0.75 0. 0. 0.;
	 uniaxialMaterial MinMax 	 $SpringID $Dummy_ID -min $gammaU_N -max $gammaU_P;
	}

	# Composite Exterior Steel Panel Zone
	if { $Response_ID == 1.0 } {
	 uniaxialMaterial Hysteretic $Dummy_ID  $M1_P $gamma1  $M2_P $gamma2 $M3_P $gamma3 [expr -$M1_N] [expr -$gamma1] [expr -$M2_N] [expr -$gamma2] [expr -$M3_N] [expr -$gamma3] 0.25 0.75 0. 0. 0.;
	 uniaxialMaterial MinMax 	 $SpringID $Dummy_ID -min $gammaU_N -max $gammaU_P;
	}

	# Bare Steel Interior/Exterior Steel Panel Zone
	if { $Response_ID == 2.0 } {
	 uniaxialMaterial Hysteretic $Dummy_ID  $M1_N $gamma1  $M2_N $gamma2 $M3_N $gamma3 [expr -$M1_N] [expr -$gamma1] [expr -$M2_N] [expr -$gamma2] [expr -$M3_N] [expr -$gamma3] 0.25 0.75 0. 0. 0.;
	 uniaxialMaterial MinMax 	 $SpringID $Dummy_ID -min $gammaU_N -max $gammaU_P;
	} 

	element zeroLength $SpringID $NodeI $NodeJ -mat $SpringID -dir 6;

}


##################################################################################################################
# Elastic_Spring_PZ.tcl
#
# SubRoutine to construct an elastic rotational spring using a realistic stiffness of the panel zone
#      
# References: 
#--------------	
# Elkady, A. and D. G. Lignos (2014). "Modeling of the Composite Action in Fully Restrained Beam-to-Column
# 	Connections: ‎Implications in the Seismic Design and Collapse Capacity of Steel Special Moment Frames." 
# 	Earthquake Eng. & Structural Dynamics 43(13). DOI: 10.1002/eqe.2430.
#
# Skiadopoulos, A., Elkady, A. and D. G. Lignos (2020). "Proposed Panel Zone Model for Seismic Design of 
#   Steel Moment-Resisting Frames." ASCE Journal of Structural Engineering. DOI: 10.1061/(ASCE)ST.1943-541X.0002935. 
#
##################################################################################################################
proc Elastic_Spring_PZ {SpringID NodeI NodeJ E mu fy  tw_Col tdp d_Col d_Beam tf_Col bf_Col Ix_Col n trib ts Response_ID} {
	
	# puts "XXXX $SpringID XXXX" 
	# puts "$d_Col"
	# puts "$bf_Col"	
	# puts "$tf_Col"
	# puts "$tw_Col"
	# puts "$d_Beam"
	
	set tpz [expr $tw_Col + $tdp]; # total PZ thickness

	set G [expr $E/(2.0 * (1.0 + $mu))];     # Shear Modulus

	# Beam's effective depth
	if {$Response_ID==2} {
	set d_BeamP $d_Beam;
	} else {
	set d_BeamP [expr $d_Beam + $trib + 0.5 * $ts]; # Effective Depth in Positive Moment
	}
	set d_BeamN $d_Beam; 						   # Effective Depth in Negative Moment

	# Stiffness Calculation
	set Ks [expr $tpz * ($d_Col - $tf_Col) * $G];   											    # PZ Stiffness: Shear Contribution
	set Kb [expr 12 * $E * ($Ix_Col + $tdp * pow(($d_Col - 2*$tf_Col),3)/12.) /pow($d_Beam,3) * $d_Beam];  # PZ Stiffness: Bending Contribution
	set Ke [expr ($Ks * $Kb) / ($Ks + $Kb)];   												    # PZ Stiffness: Total

	set Ksf [expr 2 * ($bf_Col * $tf_Col) * $G];   								   # Flange Stiffness: Shear Contribution
	set Kbf [expr 2 * 12 * $E * $bf_Col * pow($tf_Col,3)/12. /pow($d_Beam,3) * $d_Beam];   # Flange Stiffness: Bending Contribution
	set Kef [expr ($Ksf * $Kbf) / ($Ksf + $Kbf)];   								   # Flange Stiffness: Total

	set ay [expr (0.58 * $Kef / $Ke  + 0.88) / (1 - $Kef / $Ke)];

	set aw_eff_4gamma 1.10;
	set aw_eff_6gamma 1.15;

	set af_eff_4gamma [expr 0.93 * $Kef / $Ke  + 0.015];
	set af_eff_6gamma [expr 1.05 * $Kef / $Ke  + 0.020];

	set r [expr sqrt(1- pow($n,2))]; # Reduction factor accounting for axial load

	set Vy 		     [expr $r * 0.577 * $fy *  $ay			 * ($d_Col - $tf_Col) * $tpz];  										    # Yield Shear Force
	set Vp_4gamma 	[expr $r * 0.577 * $fy * ($aw_eff_4gamma * ($d_Col - $tf_Col) * $tpz + $af_eff_4gamma * ($bf_Col - $tw_Col) * 2*$tf_Col)];  # Plastic Shear Force @ 4 gammaY
	set Vp_6gamma 	[expr $r * 0.577 * $fy * ($aw_eff_6gamma * ($d_Col - $tf_Col) * $tpz + $af_eff_6gamma * ($bf_Col - $tw_Col) * 2*$tf_Col)];  # Plastic Shear Force @ 6 gammaY

	set gamma_y  [expr $Vy/$Ke]; 
	set gamma4_y [expr 4.0 * $gamma_y];  
	set gamma6_y [expr 6.0 * $gamma_y];

	set My_P        [expr $Vy 	    * $d_BeamP];
	
	set Kspring [expr $My_P/$gamma_y]
	
	uniaxialMaterial Elastic $SpringID $Kspring
	element zeroLength $SpringID $NodeI $NodeJ -mat $SpringID -dir 6;

}
