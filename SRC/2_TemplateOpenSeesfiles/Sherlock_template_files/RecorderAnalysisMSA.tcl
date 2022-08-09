##############################################################################################################
# Kuanshi Zhong
# John A. Blume Earthquake Engieering Center
# Stanford University
# Last edited: 03-Feb-2017
# Updated history: 03-Feb-2018, modified the input directories and added an option for using scaling factors
##############################################################################################################

# Define envelope drift recorders for all stories
for {set story 1} {$story <= $num_stories} {incr story} {
    recorder EnvelopeDrift -file $outdir/story${story}_drift_env.out -iNode [lindex $ctrl_nodes \
            [expr {$story - 1}]] -jNode [lindex $ctrl_nodes $story] -dof 1 -perpDirn 2
	
}

# # Define the displacement recorders
# for {set story 1} {$story <= $num_stories} {incr story} {
   # recorder Node -file $outdir/story${story}_disp.out \
       # -time -node [lindex $ctrl_nodes $story] -dof 1 disp
# }

# Define drift recorders
for {set story 1} {$story <= $num_stories} {incr story} {
   recorder Drift -file $outdir/story${story}_drift.out -iNode [lindex $ctrl_nodes \
           [expr {$story - 1}]] -jNode [lindex $ctrl_nodes $story] -time -dof 1 -perpDirn 2
}

# Define the ground motion time series
# puts "indir: $indir"
# puts "filename: $filename"
# puts "Serial: $serial"
# puts "dt: $dt"
# puts "g: $g"
# puts "scalor: $scalor"
timeSeries Path [expr {10 + $serial}] -dt $dt -filePath $indir/$filename -factor [expr $g*$scalor]
set eq_load_pattern 3
pattern UniformExcitation $eq_load_pattern 1 -accel [expr {10 + $serial}]

puts "$filename SF = $scalor; model = $model_id"

# Define acceleration recorders (must be defined after the GM to get absolute acc)
for {set story 0} {$story <= $num_stories} {incr story} {
    recorder EnvelopeNode -file $outdir/story${story}_acc_env.out -timeSeries [expr {10 + $serial}] \
        -node [lindex $ctrl_nodes $story] -dof 1 accel
}

# Define the time step used to run the analysis using the central difference scheme
set solvertag 1;
if {$solvertag == 1} {
    source SolverNewmark.tcl
} else {
    source SolverCentralDifference.tcl
}

# Initialize the analysis parameters and run the analysis. Check whether the structure has collapsed after
# every second and halt the analysis if it has.


# Compute the peak story drift from the recorder files if the structure hasn't collapsed
if {!$collapse_flag} {
    set max_drift [max_drift_outfile $outdir $num_stories]
    if {$max_drift >= $col_drift} {
        set collapse_flag true
    }
}

# Write the analysis results to the stripe text file
if {$collapse_flag} {
    puts $stripe_file "[format "%.5f" $col_drift]"
} else {
    puts $stripe_file "[format "%.5f" $max_drift]"
}
