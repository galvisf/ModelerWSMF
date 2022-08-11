########################################################################################################
# sigCrNIST2017.tcl                                                                         
#
# Computes the critical stress for fracture using classical fracture mechanics per NIST 2017
#
# NIST (National Institute of Standards and Technology). (2017). Guidelines for Nonlinear Structural Analysis for Design of Buildings Part IIa–Steel Moment Frames.
#
# Böhme, W., Mayer, U., & Reichert, T. (2013). Assessment of Dynamic Fracture Toughness Values KJc and Reference Temperatures T0, x determined for a German RPV steel at elevated loading rates according to ASTM E1921.
#                                                      
########################################################################################################
#
# Input Arguments:
#------------------
# flange		'bottom'
#				'top'
# cvn			Charpy-V-Notch thoughness tests at service temperature (70 F) [ft-lb]
# a0			weld flaw size [in]
# alpha			7.6 (Stillmaker et al. 2015 for an unbiased mean estimate for steel materials)
#               5.0 (Barsom and Rolfe (1999) for a concervative estimate
# T_service_F	Service temprature [70 F]
# Es			Steel elastic modulus in [ksi]
# FyWeld		Steel yielding stress of the weld/HAZ [ksi]
#
# Written by: Francisco Galvis, Stanford University
#
proc sigCrNIST2017 {flange cvn a0 alpha T_service_F Es FyWeld} {
	
	# ---- Compute the stress intensity factor, KIC, per ASTM E1921 ---- #
	set imperial_to_metric [expr 1 / (6.8947 * pow(0.0254, 0.5))]; # ksi*in^0.5 to MPa*in^0.5

	set k_ic_dynamic [expr pow(($alpha * $cvn * $Es / 1000), 0.5)]; # [ksi*in^0.5]
	set k_ic_dynamic [expr max($k_ic_dynamic, 30 / $imperial_to_metric + 1e-6)];  # to avoid negative values in Eq. 24 ASTM E1921

	# Compute k_ic static (median)
	set T_shift [expr 215 - 1.5 * $FyWeld];  # Equivalent temperature from dynamic k_ic to make it static
	set dT_F [expr $T_service_F - $T_shift];  # [F]
	set dT [expr ($dT_F - 32) / 1.8];  # [C]
	set T0 [expr $dT - log(($imperial_to_metric * $k_ic_dynamic - 30) / 70) / 0.019];  # [C] Eq. 24 ASTM E1921
	set T_service [expr ($T_service_F - 32) / 1.8];  # [C]

	set k_ic_median_SI [expr 30 + 70 * exp(0.019 * ($T_service - $T0))];  # [MPa*in^0.5]
	set k_ic_median [expr $k_ic_median_SI / $imperial_to_metric];  # [ksi*in^0.5]
	
	# ---- Compute critical stress, sigCr, per NIST 2017 --- #
	if {$flange == "bottom"} {
		set F_a0 [expr 1.2 + 2.0 * $a0];
		set sigcr [expr $k_ic_median/$F_a0];
	} else {
		set F_a0 [expr 0.5 + 2.0 * $a0];
		set sigcr [expr $k_ic_median/$F_a0];
	}
		
	return $sigcr
	
}