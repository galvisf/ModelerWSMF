source ElasticModel.tcl

# ----- LATERAL LOAD PATTERN ----- #
source WL_UBC1982.tcl

# create load pattern for lateral load when using linear load pattern
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
recorder Element -file $outdir/EPL_base.out -ele 2010100 2010200 2010300 globalForce;

# Drift recorders #
for {set story 1} {$story <= $num_stories} {incr story} {
	recorder EnvelopeDrift -file $outdir/story${story}_drift_env.out -iNode [lindex $ctrl_nodes [expr {$story - 1}]] -jNode [lindex $ctrl_nodes $story] -dof 1 -perpDirn 2
}

# ----- ELF analyses commands ----- #
constraints Plain;
numberer Plain;
system BandGeneral;
test RelativeEnergyIncr 1.0e-12 20;
algorithm Newton;
integrator LoadControl 0.100000;
analysis Static;
if {[analyze 10]} {puts "Application of ELF failed"};
wipeAnalysis;
