########################################################################################################
# matBilin02.tcl                                                                         
#
# SubRoutine to construct an IMK spring as uniaxial material using Bilin02 implementation
# See the following papers for details on the materials selected:
#
# Ribeiro et al. 2017, Implementation and Calibration of Finite-Length Plastic Hinge Elements for Use in Seismic Structural Collapse Analysis, Journal of Earthquake Engineering
#
# Lignos and Krawinkler 2009, Sidesway collapse of deterio- rating structural systems under seismic excitations, Blume center
#                                                      
########################################################################################################
#
# Input Arguments:
#------------------
# matTag		Spring ID
# EIeff			Flexural spring stiffness [kip-in^2]
# Mp			bare section flexural strength [kip-in]
# McMp			Ratio of maximum (or capping) moment to flexural strength
# theta_p		Plastic rotation to the maximum (or capping) point
# theta_pc		Plastic rotation from capping point to residual
# theta_u		Ultimate plastic rotation (to complete moment drop)
# lambda		Parameters defining the deterioration in excursion
# c 			Exponent defining the rate of cyclic deterioration 
# MrMp			Ratio of residual moment to flexural strength
# n				Flexural coefficient
# eleLength		Length of the element [in]
# Composite     		consider or not composite slab
# compBackboneFactors 	list with the factors that modify the backbone from bare to composite
#						{MpP/Mp MpN/Mp Mc/MpP Mc/MpN Mr/MpP Mr/MpN D_P D_N theta_p_P_comp 
#						theta_p_N_comp theta_pc_P_comp theta_pc_P_comp}
#
# Written by: Francisco Galvis, Stanford University
# Based on OpenSees examples available online
#
proc matBilin02 { matTag EIeff Mp McMp theta_p theta_pc theta_u lambda c MrMp n eleLength Composite compBackboneFactors} {
	
	if {$Composite} {
		# Modify backbone for composite action
		set MpPMp [lindex $compBackboneFactors 0]
		set MpNMp [lindex $compBackboneFactors 1]
		set McMpP [lindex $compBackboneFactors 2]
		set McMpN [lindex $compBackboneFactors 3]
		set MrMpP [lindex $compBackboneFactors 4]
		set MrMpN [lindex $compBackboneFactors 5]
		set D_P [lindex $compBackboneFactors 6]
		set D_N [lindex $compBackboneFactors 7]
		set theta_p_P_comp [lindex $compBackboneFactors 8]
		set theta_p_N_comp [lindex $compBackboneFactors 9]
		set theta_pc_P_comp [lindex $compBackboneFactors 10]
		set theta_pc_N_comp [lindex $compBackboneFactors 11]
		
		set MpP [expr $MpPMp*$Mp]
		set MpN [expr -1*$MpNMp*$Mp]
	} else {		
		# Keep bare section backbone
		set McMpP $McMp
		set McMpN $McMp
		set MrMpP $MrMp
		set MrMpN $MrMp
		set D_P 1.0
		set D_N 1.0
		set theta_p_P_comp 1.0
		set theta_p_N_comp 1.0
		set theta_pc_P_comp 1.0
		set theta_pc_N_comp 1.0
		
		set MpP $Mp
		set MpN [expr -1*$Mp]
	}
	
	set Ks_element [expr $n* 6 * $EIeff / $eleLength];							# Element stiffness
		
	set theta_p_P   [expr $theta_p_P_comp*$theta_p];
	set theta_p_N   [expr $theta_p_N_comp*$theta_p];
	set theta_pc_P  [expr $theta_pc_P_comp*$theta_pc];
	set theta_pc_N  [expr $theta_pc_N_comp*$theta_pc];
		
	set a_hard_P [expr ($n+1.0)*(($MpP*($McMpP-1.0)) / $theta_p_P) / $Ks_element];	# strain hardening ratio of spring
	set b_hard_P [expr $a_hard_P/(1.0+$n*(1.0-$a_hard_P))];						    # modified strain hardening ratio of spring (Ibarra & Krawinkler 2005, note: Eqn B.5 is incorrect)		
	
	set a_hard_N [expr ($n+1.0)*((-1*$MpN*($McMpN-1.0)) / $theta_p_N) / $Ks_element];	# strain hardening ratio of spring
	set b_hard_N [expr $a_hard_N/(1.0+$n*(1.0-$a_hard_N))];						    # modified strain hardening ratio of spring (Ibarra & Krawinkler 2005, note: Eqn B.5 is incorrect)	
	
	# Create the material model		
	uniaxialMaterial Bilin02 $matTag $Ks_element $b_hard_P $b_hard_N $MpP $MpN $lambda $lambda $lambda $lambda $c $c $c $c $theta_p_P $theta_p_N $theta_pc_P $theta_pc_N $MrMpP $MrMpN $theta_u $theta_u $D_P $D_N;
	
	# puts "$Ks_element"
	# puts "$b_hard_P"
	# puts "$MpP"
	# puts "$b_hard_N"
	# puts ""
	# puts "$MpN"
	# puts "$lambda"
	# puts "$c"
	# puts "$theta_p_P"
	# puts "$theta_p_N"
	# puts "$theta_pc_P"
	# puts "$theta_pc_N"
	# puts "$MrMyP"
	# puts "$MrMyN"
	# puts "$theta_u"
	# puts "$theta_u"
	
	
}