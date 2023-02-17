source ElasticModel.tcl

# ----- RESPONSE SPECTRUM ----- #
source RS_ASCE7.tcl
set tsTag 1; # use the timeSeries 1 as response spectrum function
timeSeries Path $tsTag -time $timeSeries_list_of_times_1 -values $timeSeries_list_of_values_1 -factor $g

# ----- MODAL ANALYSIS ----- #
# run the eigenvalue analysis with $modes_RSA modes and obtain the eigenvalues
set modes_RSA 20
set eigs [eigen -genBandArpack $modes_RSA]

# compute the modal properties
modalProperties -print -file "$outdir/ModalReport.txt" -unorm
# ----- RECORDERS FOR RSA ----- #
# Base shear columns recorders #
recorder Element -file $outdir/RSA_base.out -closeOnWrite -precision 16 -ele 2010100 2010200 0 2010400 2010500 2010600 globalForce;

recorder Element -file $outdir/RSA_base.out -closeOnWrite -precision 16 -ele 2010700 # Drift recorders #
for {set story 1} {$story <= $num_stories} {incr story} {
	recorder Drift -file $outdir/story${story}_drift.out -closeOnWrite -precision 16 -iNode [lindex $ctrl_nodes [expr {$story - 1}]] -jNode [lindex $ctrl_nodes $story] -dof 1 -perpDirn 2
}

# ----- ELF analyses commands ----- #
constraints Plain;
numberer Plain;
system BandGeneral;
test RelativeEnergyIncr 1.0e-04 10;
algorithm Newton;
integrator LoadControl 0.00;
analysis Static
set direction 1; # excited DOF = Ux
responseSpectrum $tsTag $direction
wipeAnalysis;
