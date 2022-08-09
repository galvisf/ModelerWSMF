########################################################################################################
# matHysteretic.tcl                                                                         
#
# SubRoutine to construct an hystereic spring as uniaxial material
#                                                      
########################################################################################################
#
# Input Arguments:
#------------------
# matTag				Spring ID
# EIeff					Flexural spring stiffness [kip-in^2]
# eleLength				Length of the element [in]
# n						Flexural coefficient
# Mp					flexural plastic moment of the bare section [kip-in]
# McMp					Ratio of maximum (or capping) moment to flexural strength
# theta_p				Plastic rotation to the maximum (or capping) point
# theta_pc				Plastic rotation from capping point to zero strength with a gradual slope
# MrMp					Ratio of residual moment to flexural strength
# Composite     		consider or not composite slab
# compBackboneFactors 	list with the factors that modify the backbone from bare to composite
#						{MpP/Mp MpN/Mp Mc/MpP Mc/MpN Mr/MpP Mr/MpN D_P D_N theta_p_P_comp 
#						theta_p_N_comp theta_pc_P_comp theta_pc_P_comp}
#
# Written by: Francisco Galvis, Stanford University
# Based on OpenSees examples available online
#
proc matHysteretic { matTag EIeff eleLength n Mp McMp theta_p theta_pc MrMp Composite compBackboneFactors} {

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
		set MpN [expr $MpNMp*$Mp]
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
		set MpN $Mp
	}
		
	set K [expr $n * 6 * $EIeff / $eleLength]	
	
	# Corrected rotations to account for elastic deformations
	set theta_y_p  [expr $MpP/$K];
	set theta_y_n  [expr $MpN/$K];
	set theta_p_p  [expr $theta_p  - ($McMpP-1.0)*$Mp/(6 * $EIeff / $eleLength)];
	set theta_p_n  [expr $theta_p  - ($McMpN-1.0)*$Mp/(6 * $EIeff/ $eleLength)];
	set theta_pc_p [expr $theta_pc + $theta_y_p + ($McMpP-1.0)*$Mp/(6 * $EIeff / $eleLength)];
	set theta_pc_n [expr $theta_pc + $theta_y_n + ($McMpN-1.0)*$Mp/(6 * $EIeff / $eleLength)];
	
	# For sections with theta_p too low, assume a theta_p = theta_y after adjustment
	if {$theta_p_p < 0} {
		set theta_p_p $theta_y_p
	}
	if {$theta_p_n < 0} {
		set theta_p_n $theta_y_n
	}
	
	set theta_p_P   [expr $theta_p_P_comp*$theta_p_p];
	set theta_p_N   [expr $theta_p_N_comp*$theta_p_n];
	set theta_pc_P  [expr $theta_pc_P_comp*$theta_pc_p];
	set theta_pc_N  [expr $theta_pc_N_comp*$theta_pc_n];
	
	set theta_res_P [expr $MpP*($McMpP - $MrMpP)/($MpP*$McMpP/$theta_pc_P)]; # Increased to help convergence
	set theta_res_N [expr $MpN*($McMpN - $MrMpN)/($MpN*$McMpN/$theta_pc_N)]; # Increased to help convergence
	
	# puts "XXXX $matTag XXXX"
	# puts "$compBackboneFactors"
	# puts "$theta_y_p"
	# puts "$theta_p_P"
	# puts "$theta_res_P"
	# puts "$theta_pc_P"
	
	# puts "$theta_y_n"	
	# puts "$theta_p_N"
	# puts "$theta_res_N"
	# puts "$theta_pc_N"
			
	# puts "$MpP"
	# puts "$McMpP"
	# puts "$MrMpP"

	# puts "$MpN"
	# puts "$McMpN"
	# puts "$MrMpN"	
	
	# Create the material model		
	uniaxialMaterial Hysteretic $matTag $MpP $theta_y_p [expr $McMpP*$MpP] [expr $theta_p_P + $theta_y_p] \
	[expr $MrMpP*$MpP] [expr $theta_res_P + $theta_p_P + $theta_y_p] [expr -$MpN] [expr -$theta_y_n] [expr -$McMpN*$MpN] [expr -($theta_p_N + $theta_y_n)] \
	[expr -$MrMpN*$MpN] [expr -($theta_res_N + $theta_p_N + $theta_y_n)] 1.00 1.00 0.00 0.00
	

	
}