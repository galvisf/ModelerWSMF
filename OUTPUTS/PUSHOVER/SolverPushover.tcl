#############################################################################################################
# Francisco Galvis (based on examples from OS website                              #
# John A. Blume Earthquake Engineering Center                                                               #
# Stanford University                                                                                       #
# Last edited: 02/17/2020		
#############################################################################################################

puts "\nRunning pushover analysis ...\n"

# ########################### PUSHOVER ################################
# ----- SOLVER PARAMETERS ----- #
set minDiv 2; # division of basic displacement step
set maxDiv 64; # maximim step division
set TolMax 1e-8; # maximum tolerance to force convergence
set TolCurr 1e-8;
set Dbase $Dincr
set fmt1 "%s Pushover analysis: CtrlNode %.3i, dof %.1i, Disp=%.4f %s";	# format for screen/file output of DONE/PROBLEM analysis

# constraints Plain
# numberer Plain 
# system BandGeneral 
constraints Transformation
numberer RCM
system UmfPack
set maxNumIter 100;         # Convergence Test: maximum number of iterations that will be performed before "failure to converge" is returned
set printFlag 0;            # Convergence Test: flag used to print information on convergence (optional)        # 1: print information on each step; 
set testTypeStatic EnergyIncr ;	# Convergence-test type
test $testTypeStatic $TolCurr $maxNumIter $printFlag;
algorithm NewtonLineSearch; 

# ----- Pushover in one blow ----- #
set deltaD $Dmax; # Total displacement increment to reach desired Dmax 
if {$deltaD == 0} {
	return
}
set signDmax [expr $deltaD/abs($deltaD)]
set Nsteps [expr int(abs($deltaD)/$Dincr)];     # number of pushover analysis steps

integrator DisplacementControl  $CtrlNode $CtrlDOF [expr $Dincr*$signDmax]
analysis Static 

set ok [analyze $Nsteps];  # this will return zero or negative if no convergence problems were encountered

# ---------------------- Repeat if convergence issues ------------------ #
if {$ok != 0} { 	
	set controlDisp [nodeDisp $CtrlNode $CtrlDOF ];		# start from where push failed
	set div $minDiv
	set DremainNorm [expr $controlDisp/$deltaD]; # normalized number to control when to finish (DremainNorm = 1 means we reached the deltaD)
	
	while {$DremainNorm < 1 && $TolCurr <= $TolMax} {
		puts "controlDisp = $controlDisp"
		while {$DremainNorm < 1 && $div <= $maxDiv} {
		# ----------------------------------- Reduces displacement step ---------------------------- #
			set Dincr [expr $Dbase/$div]
			integrator DisplacementControl  $CtrlNode $CtrlDOF [expr $Dincr*$signDmax]
			analysis Static
		# ---------------------------------------------- analyze command --------------------------- #
			set ok [analyze 1]
			# if still does not converge tries other algorithms
			if {$ok != 0} {
				test NormDispIncr  $TolCurr 2000  0
				algorithm Newton -initial
				set ok [analyze 1 ]
				test $testTypeStatic $TolCurr $maxNumIter $printFlag;
				algorithm NewtonLineSearch
			
				#puts "Newton initial tangent: OK = $ok; DremainNorm = $DremainNorm; div = $div"
			
				if {$ok != 0} {
					#puts "Trying Broyden .."
					algorithm Broyden 8
					set ok [analyze 1 ]
					algorithm NewtonLineSearch
				
					#puts "Broyden: OK = $ok; DremainNorm = $DremainNorm; div = $div"
				}
			
				# if still does not converge reduces disp step further
				if {$ok != 0} {			
					set div [expr 2*$div]
				
					#puts "Reduces disp step $div times"
				}
			} else {
				# if converges update the DremainNorm
				set div $minDiv; #  Comment if want whole deltaD solved with the minimum disp increment)
				set controlDisp [nodeDisp $CtrlNode $CtrlDOF ]
				set DremainNorm [expr $controlDisp/$deltaD]
			
				#puts "No need: DremainNorm = $DremainNorm; Dprev = $Dprev; controlDisp = $controlDisp"
			}
		# ------------------------------------------------------------------------------------------ #
		}
		
		# if still does not converge increases tolerance and resets disp. reduction variables
		if {$ok != 0} {
			set TolCurr [expr $TolCurr*100];
			set div $minDiv; #  Comment if want whole deltaD solved with the minimum disp increment)
			set controlDisp [nodeDisp $CtrlNode $CtrlDOF ]
			set DremainNorm [expr $controlDisp/$deltaD]
			puts "/n New tolerance = $TolCurr /n"
			
		}
	}
}

set LunitTXT "in";
if {$ok != 0 } {
	puts [format $fmt1 "PROBLEM" $CtrlNode $CtrlDOF [nodeDisp $CtrlNode $CtrlDOF] $LunitTXT]
} else {
	puts [format $fmt1 "DONE"  $CtrlNode $CtrlDOF [nodeDisp $CtrlNode $CtrlDOF] $LunitTXT]
}

puts "Pushover analysis done"