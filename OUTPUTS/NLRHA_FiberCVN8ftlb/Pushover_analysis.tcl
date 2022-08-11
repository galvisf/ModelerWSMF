source InelasticModel.tcl

# ----- PUSHOVER INPUTS ----- #
set sign 1
set CtrlNode [lindex $ctrl_nodes end]
set CtrlDOF 1
set Dmax [expr $sign*0.025000*7.730400e+02];	# maximum displacement of pushover
set Dincr [expr 0.005*$Dmax ];	# displacement increment

# ----- LATERAL LOAD PATTERN ----- #
source EQ_Mode1.tcl
# create load pattern for lateral pushover load coefficient when using linear load pattern
pattern Plain 300 Linear {;			# define load pattern
	for {set level 2} {$level <=[expr $num_stories]} {incr level 1} {
		set Fi [expr [lindex $iFi [expr $level-1]]];		# lateral load coefficient
		# all force in right column (that is continuous from bottom to top)
		set nodeID [lindex $ctrl_nodes $level]
		# puts "$nodeID"
		load $nodeID $Fi 0.0 0.0
	}
}
# ----- RECORDERS FOR ELF ----- #
# Base shear columns recorders #
recorder Element -file $outdir/baseShear.out -ele 2010100 2010200 globalForce;

# Displacement recorders #
for {set story 1} {$story <= $num_stories} {incr story} {
	recorder Node -file $outdir/story${story}_disp.out -time -node [lindex $ctrl_nodes $story] -dof 1 disp
}

# ----- PUSHOVER analysis commands ----- #
source SolverPushover.tcl
