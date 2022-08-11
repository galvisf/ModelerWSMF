########################################################################################################
# matIMKBilin.tcl                                                                         
#
# Lignos, D. G. and H. Krawinkler (2011). "Deterioration Modeling of Steel Components in Support of Collapse 
# 	Prediction of Steel Moment Frames under Earthquake Loading." Journal of Structural Engineering 137(11).	
#
# Elkady, A. and D. G. Lignos (2014). "Modeling of the Composite Action in Fully Restrained Beam-to-Column
# 	Connections: ‎Implications in the Seismic Design and Collapse Capacity of Steel Special Moment Frames." 
# 	Earthquake Eng. & Structural Dynamics 43(13).
#
# Lignos, D. G., et al. (2019). "Proposed Updates to the ASCE 41 Nonlinear Modeling Parameters for Wide-Flange
#	 Steel Columns in Support of Performance-based Seismic Engineering." Journal of Structural Engineering 145(9).
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
# theta_u				Ultimate plastic rotation (to sharp moment drop to zero)
# lambda				Parameters defining the deterioration in excursion
# c 					Exponent defining the rate of cyclic deterioration 
# MrMp					Ratio of residual moment to flexural strength
# Composite     		consider or not composite slab
# compBackboneFactors 	list with the factors that modify the backbone from bare to composite
#						{MpP/Mp MpN/Mp Mc/MpP Mc/MpN Mr/MpP Mr/MpN D_P D_N theta_p_P_comp 
#						theta_p_N_comp theta_pc_P_comp theta_pc_P_comp}
#
# Written by: Francisco Galvis, Stanford University
# Based on OpenSees examples available online
#
proc matIMKBilin { matTag EIeff eleLength n Mp McMp theta_p theta_pc theta_u lambda c MrMp Composite compBackboneFactors} {
	
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
		
	set K [expr ($n+1.0) * 6 * $EIeff / $eleLength]	
	
	# Corrected rotations to account for elastic deformations
	set theta_y_p    [expr $MpP/(6 * $EIeff / $eleLength)];
	set theta_y_n    [expr $MpN/(6 * $EIeff / $eleLength)];
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
	
	# puts "XXXXXXXXXXXX"
	# puts "$theta_y_p"
	# puts "$theta_p_p"
	# puts "$theta_pc_p"
	
	# puts "$theta_y_n"	
	# puts "$theta_p_n"
	# puts "$theta_pc_n"
			
    # puts "$theta_y_p"
	# puts "$theta_p_P"
	# puts "$theta_pc_P"
	# puts "$theta_u"
	# puts "$MpP"
	# puts "$McMpP"
	# puts "$MrMpP"
	
	# puts "$theta_y_n"
	# puts "$theta_p_N"
	# puts "$theta_pc_N"
	# puts "$theta_u"
	# puts "$MpN"
	# puts "$McMpN"
	# puts "$MrMpN"
	
	# Create the material model		
	# IMKBilin material model (This is the updated version of the Bilin model)
	uniaxialMaterial IMKBilin $matTag $K $theta_p_P $theta_pc_P $theta_u $MpP $McMpP $MrMpP $theta_p_N $theta_pc_N $theta_u $MpN $McMpN $MrMpN $lambda $lambda $lambda $c $c $c $D_P $D_N;
	
}