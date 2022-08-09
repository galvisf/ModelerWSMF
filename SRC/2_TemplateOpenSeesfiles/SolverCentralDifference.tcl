#############################################################################################################
# Francisco Galvis 																							#
# Based on routines by Reagan Chandramohan				                                                    #
# John A. Blume Earthquake Engineering Center                                                               #
# Stanford University                                                                                       #
# Last edited: 08/08/2021                            														#	
#############################################################################################################

proc run_eigen {} {

	set num_modes 80

	# Run the eigenvalue analysis and compute all modal periods
	set eigenvalues [eigen -fullGenLapack $num_modes]
	set pi [expr {2*asin(1)}]
	foreach eigenvalue $eigenvalues {
		lappend periods [expr {2.0*$pi/sqrt($eigenvalue)}]
	}

	# Display the fundamental period and lowest period
	puts ""
	puts "Fundamental mode period: [format "%.4f" [lindex $periods 0]] s"
	puts "Lowest modal period: [format "%.4e" [lindex $periods end]] s"
	
	return [lindex $periods end]
	
}

#Example call out
# 				doDynamicAnalysisCentral $npts	$gm_length	$NStories $hVector	$FloorNodes	0.10
proc doDynamicAnalysisCentral {npts gm_length stories h nodes driftLimit} {

	set Astart [clock milliseconds]

	# Define the time step used to run the analysis using the central difference scheme
	set dt_factor 0.9
	set period_min [run_eigen]; ######
	set pi [expr {2*asin(1)}]
	set dt_analysis [expr {$dt_factor*$period_min/$pi}]
	
	# Initialize the analysis parameters and run the analysis. Check whether the structure has collapsed after
	# every second and halt the analysis if it has.
	constraints Transformation
	numberer RCM
	system SparseSPD;#UmfPack
	algorithm Linear
	integrator CentralDifference
	analysis Transient

	set total_steps [expr {int($gm_length/$dt_analysis)}]
	set steps_per_batch [expr {int(1.0/$dt_analysis)}]
	set collapse_drift 0

	for {set steps_run 0} {$steps_run < $total_steps} {incr steps_run $steps_per_batch} {
		set fail [analyze $steps_per_batch $dt_analysis]
		if {$fail} {			
			break
		} else {
			#check the drift
			set level 1
			while {$level <= $stories} {
			  # Check X-Direction Drifts
			  set topDisp [nodeDisp [lindex $nodes [expr $level  ]] 1]
			  set botDisp [nodeDisp [lindex $nodes [expr $level-1]] 1]
			  set deltaDisp [expr abs($topDisp-$botDisp)]
			  set drift [expr $deltaDisp/[lindex $h [expr $level-1]]]

			  if {$drift >= $driftLimit} {
				set collapse_drift 1
				break
			  }
			  #Move to next story
			  set level [expr $level + 1]
			}
		}
	}

	if {$collapse_drift == 1} {
		set ok 1
		puts "collapse drift has been reached"
	}
	if {$fail == 1} {
		set "non-convergence"
	}

	set Afinish [clock milliseconds]
	set ArunTime [expr ($Afinish-$Astart)/1000.0]
	puts "analysis time: $ArunTime seconds"
	
	return $fail
}

set dtAna [expr min(0.01,$dt)];#[expr min(0.005,$dt)]  $dt the solver will divide this by 2
set tFinal [expr $numpts*$dt + 0]; # add 10s to get stable residuals
set npts [expr $tFinal/$dtAna]

set driftLimit 0.10
set ok [doDynamicAnalysisCentral $npts $tFinal $num_stories $hVector $ctrl_nodes $driftLimit]
set tCurrent [getTime]

# Convergence check
if {$ok != 0 && $tCurrent < $tFinal} {
    set collapse_flag 1
} else {
    set collapse_flag 0
}