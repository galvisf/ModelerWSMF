#############################################################################################################
# Francisco Galvis (based on script by Reagan and Kuanshi                                                   #
# John A. Blume Earthquake Engineering Center                                                               #
# Stanford University                                                                                       #
# Last edited: 02/17/2020														#	
#############################################################################################################


# Build the model
set outdir RSN28_PARKF_C12050.AT2;
source Frame1C_Grid16_1.tcl

# Ground motion inputs
file mkdir $outdir; 	# create data directory
set indir "GroundMotion";  # directory with input data
set filename "RSN28_PARKF_C12050.AT2";  # GM filename
set scalor [expr 9.344];  # GM SF
set dt 0.01; # GM dt
set numpts 4430; # GM number of points
set serial 1;  # GM tag
set solvertag 1

# Define the drift recorders
for {set story 1} {$story <= $num_stories} {incr story} {
    recorder Drift -file $outdir/story${story}_drift.out -dT 0.01 -time -iNode [lindex $ctrl_nodes \
            [expr {$story - 1}]] -jNode [lindex $ctrl_nodes $story] -dof 1 -perpDirn 2
}

for {set story 1} {$story <= $num_stories} {incr story} {
    recorder EnvelopeDrift -file $outdir/story${story}_drift_env.out -iNode [lindex $ctrl_nodes \
            [expr {$story - 1}]] -jNode [lindex $ctrl_nodes $story] -dof 1 -perpDirn 2
	
}

# Define the ground motion time series
timeSeries Path [expr {10 + $serial}] -dt $dt -filePath $indir/$filename -factor [expr $g*$scalor]
set eq_load_pattern 3
pattern UniformExcitation $eq_load_pattern 1 -accel [expr {10 + $serial}]

# Define acceleration recorders (must be defined after the GM to get absolute acc)
for {set story 1} {$story <= $num_stories} {incr story} {
    recorder EnvelopeNode -file $outdir/story${story}_acc_env.out -timeSeries [expr {10 + $serial}] \
        -node [lindex $ctrl_nodes $story] -dof 1 accel
}

# Define the time step used to run the analysis using the central difference scheme
if {$solvertag == 1} {
    source SolverNewmark.tcl
} elseif {$solvertag == 2} {
	set collapse_flag 0;
	set col_drift 0.1;
	source SolverGeneral.tcl
} else {
    source SolverCentralDifference.tcl
}
