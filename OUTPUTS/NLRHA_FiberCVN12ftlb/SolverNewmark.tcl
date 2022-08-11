#############################################################################################################
# Francisco Galvis
# Based on routines by Adam Zsarnoczay and Kuanshi Zhong				                                                      #
# John A. Blume Earthquake Engineering Center                                                               #
# Stanford University                                                                                       #
# Last edited: 01/23/2020														#	
#############################################################################################################


#Example call out
# 				doDynamicAnalysis $npts	$dtAn	$NStories $hVector	$FloorNodes	1e-08	2	0.10

proc doDynamicAnalysis {npts dt stories h nodes tol subSteps driftLimit} {

  set Astart [clock milliseconds]

  set maxDiv 1024
  set minDiv $subSteps

  constraints Transformation
  numberer RCM
  system UmfPack
  test NormDispIncr $tol 40
  algorithm NewtonLineSearch
  integrator Newmark 0.5 0.25
  analysis Transient

  set step 0
  set ok 0
  set break 0

  while {$step<=$npts && $ok==0 && $break==0} {
    set step [expr $step+1]
    set ok 2
    set div $minDiv
    set len $maxDiv
    while {$div <= $maxDiv && $len > 0 && $break == 0} {
      set stepSize [expr $dt/$div]
      set ok [analyze 1 $stepSize]  
	  # Try KrylovNewton
	  if {$ok != 0} {
		puts "Try KrylovNewton";
		algorithm KrylovNewton;
		set ok [analyze 1 $stepSize];
		# switch back NewtonLineSearch
		algorithm NewtonLineSearch;
	  }
	  # Try BFGS
	  if {$ok != 0} {
		puts "Try BFGS";
		algorithm BFGS;
		set ok [analyze 1 $stepSize];
		# switch back NewtonLineSearch
		algorithm NewtonLineSearch;
	  }	  
      if {$ok==0} {
        set len [expr $len-$maxDiv/$div]
        #check the drift
        set level 1
        while {$level <= $stories} {
		  # Check X-Direction Drifts
          set topDisp [nodeDisp [lindex $nodes [expr $level  ]] 1]
          set botDisp [nodeDisp [lindex $nodes [expr $level-1]] 1]
          set deltaDisp [expr abs($topDisp-$botDisp)]
          set drift [expr $deltaDisp/[lindex $h [expr $level-1]]]

          if {$drift >= $driftLimit} {set break 1}
		  #Move to next story
		  set level [expr $level + 1]
        }  
      } else {
        set div [expr $div*2]
        puts "number of substeps increased to $div"
      }
    }
  }
  if {$break == 1} {
    set ok 1
	puts "collapse drift has been reached"
  }

  set Afinish [clock milliseconds]
  set ArunTime [expr ($Afinish-$Astart)/1000.0]
  puts "analysis time: $ArunTime seconds"

  return $ok
}

set testTol 1.0e-6;

# puts "Tolerance: $testTol"
set subSteps 2; #2
set dtAna [expr min(0.01,$dt)];#[expr min(0.005,$dt)]  $dt the solver will divide this by 2
set tFinal [expr $numpts*$dt + 10]; # add 10s to get stable residuals
set npts [expr $tFinal/$dtAna]

set driftLimit 0.10
set ok [doDynamicAnalysis $npts $dtAna $num_stories $hVector $ctrl_nodes $testTol $subSteps $driftLimit]
set tCurrent [getTime]

# Convergence check
if {$ok != 0 && $tCurrent < $tFinal} {
    set collapse_flag 1
} else {
    set collapse_flag 0
}