##############################################################################################################
# Kuanshi Zhong		                                                                                     #
# John A. Blume Earthquake Engineering Center                                                                #
# Stanford University                                                                                        #
# Last edited: 08/09/2019													       #
##############################################################################################################

# Script called from "RunIDAParallel.tcl".
# Define recorders and run one ground motion at one Sa(T1) level.

##############################################################################################################

#source buildRecorderBeams.tcl;
#source buildRecorderColumn.tcl;
#source buildRecorderPZ.tcl;

# Define drift recorders for all stories
for {set story 1} {$story <= $num_stories} {incr story} {
    recorder EnvelopeDrift -file $outdir/story${story}_drift_env.out -iNode [lindex $ctrl_nodes \
            [expr {$story - 1}]] -jNode [lindex $ctrl_nodes $story] -dof 1 -perpDirn 2
}

# Define the displacement recorders
#for {set story 1} {$story <= $num_stories} {incr story} {
#    recorder Node -file $outdir/story${story}_disp.out \
#        -time -node [lindex $ctrl_nodes $story] -dof 1 disp
#}

# Define the drift recorders
#for {set story 1} {$story <= $num_stories} {incr story} {
#    recorder Drift -file $outdir/story${story}_drift.out -iNode [lindex $ctrl_nodes \
#            [expr {$story - 1}]] -jNode [lindex $ctrl_nodes $story] -time -dof 1 -perpDirn 2
#}

# Define the ground motion time series
set g 386.2
set pi 3.1416
set SF [expr {$sat1/$sat1_gm}];
puts "$filename with SF=$SF, SaT1=$sat1"
timeSeries Path [expr {10+$i}] -dt $dt -filePath $inpath/$indir/$filename -factor [expr $g*$SF]
set eq_load_pattern 3
pattern UniformExcitation $eq_load_pattern 1 -accel [expr {10 + $i}]

# Define acceleration recorders (must be defined after the GM to get absolute acc)
for {set story 1} {$story <= $num_stories} {incr story} {
    recorder EnvelopeNode -file $outdir/story${story}_acc.out -timeSeries [expr {10 + $i}] \
        -node [lindex $ctrl_nodes $story] -dof 1 accel
}

# initialize collapse / convergence variables
set collapse_flag false;
set tLast 0.0;
set max_drift_last 0.0;
set state AtStart;

# Conduct analysis
source SolverNewmark.tcl;

# Review data and determin collapse
if {$ok != 0} {
	# changed here
	set max_drift inf; # max_drift == inf, then there is convergence issue
	set collapse_flag true;
	set tLast $tCurrent;
	set max_drift_last [max_drift_outfile $outdir $num_stories];	
	if {$max_drift_last >= $driftLimit} {
		set state "Max Drift Reached";
		puts "Max Drift Reached";
    } else {
		set state "inconvergence";
		puts "Convergence issue at $tCurrent";
	}
	
} elseif {$ok == 0 && !$collapse_flag} {
	# changed here
	set max_drift [max_drift_outfile $outdir $num_stories];
	set tLast $tCurrent;
	set max_drift_last $max_drift;
	set state "completeNotCollapse";
    puts "Complete analysis";
}

# append result to tolerance note file
set tol_note_file [open $outpath/$indir/$outfilename/tolerance_note.txt a];
puts $tol_note_file "[format "%.3f" $sat1]\t[format "%.5f" $max_drift]\t$tier\t[format "%.5f" $tLast]\t[format "%.5f" $max_drift_last]\t[format "%s" $state]\t[format "%.0e" $elemConvTol]"; # changed here
close $tol_note_file


