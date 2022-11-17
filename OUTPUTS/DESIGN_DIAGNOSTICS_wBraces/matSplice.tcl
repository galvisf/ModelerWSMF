########################################################################################################
# matSplice.tcl                                                                         
#
# SubRoutine to construct the flange material that represents a column splice.
#
# Stillmaker, K., Kanvinde, A., & Galasso, C. (2016). Fracture mechanics-based design of column splices with partial joint penetration welds. Journal of Structural Engineering, 142(2), 04015115.
#
# Stillmaker, K., Lao, X., Galasso, C., & Kanvinde, A. (2017). Column splice fracture effects on the seismic performance of steel moment frames. Journal of Constructional Steel Research, 137, 93-101.
#                                                      
########################################################################################################
#
# Input Arguments:
#------------------
# matTag		Spring ID				
# maxStress		Fracture critical stress [ksi]
# E 			Elastic modulus for splice section materials [ksi]
# Fy 			Yielding strength for splice materials [ksi]
#
# Written by: Francisco Galvis and Wen-Yi Yen, Stanford University
# Based on OpenSees examples available online
#
proc matSplice {matTag maxStress E Fy} {
	set matTag2 [expr $matTag + 1]
	set steelTag [expr $matTag + 2]
	set minMaxTag [expr $matTag + 3]
	set elasticTag [expr $matTag + 4]
	set zeroTensionTag [expr $matTag + 5]
	
	# elastic and minmax
	uniaxialMaterial Elastic $elasticTag 10e9
	uniaxialMaterial MinMax $minMaxTag $elasticTag -min -3.00000E+7 -max [expr $maxStress/10e9]; # Make sure to use same modulus as elasticTag material

	# steel material
	# steel02
	set R0 18
	set cR1 0.95
	set cR2 1
	set b 0.02
	uniaxialMaterial Steel02 $steelTag $Fy $E $b $R0 $cR1 $cR2;

	# zero tension material
	uniaxialMaterial ENT $zeroTensionTag 10e9

	# series and parallel
	uniaxialMaterial Parallel $matTag2 $minMaxTag $zeroTensionTag;
	uniaxialMaterial Series $matTag $steelTag $matTag2;

}