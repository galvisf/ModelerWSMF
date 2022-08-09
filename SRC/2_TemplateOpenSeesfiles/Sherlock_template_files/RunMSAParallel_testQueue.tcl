##############################################################################################################
# Kuanshi Zhong
# John A. Blume Earthquake Engieering Center
# Stanford University
# Last edited: 03-Feb-2017
# Updated history: 03-Feb-2018, modified the input directories and added an option for using scaling factors
##############################################################################################################

# Initialize the total number of processors and the id of this processor
set numprocs [getNP]
set this_procid [getPID]

# Source the required files
source DriftCheck.tcl

# Initialize the list of ground motion folders to be run
# Define the sub-folder where ground motion records are stored
set gmset X
set inpath "../../4_GroundMotions/ID38/$gmset"
set inpath_length [string length $inpath]
# Find and sort the interested hazard levels
set indirlist [lsort [glob -directory $inpath -type d *]]

# Define the output path
set outpath AnalysisResult/MSA/$gmset

# Create the list of ground motions to be run by looping over all the ground motion folders
set serial 0
foreach indir $indirlist {

    # Parse the input directory from the input path
    set indir_length [string length $indir]
    set gmdir [string range $indir [expr {$inpath_length + 1}] [expr {$indir_length - 1}]]

    # Import information about each ground motion in the GMInfo.txt file and add the information to the
    # "gminfo_dict" dictionary
    set gminfofile [open $indir/GMInfo.txt r]
	
	set model_id 1
	
    while {[gets $gminfofile line] >= 0} {
        
        # Read the filename and dt
        set filename [lindex $line 1]
        set dt [lindex $line 2]
		set scalor [lindex $line 3]

        # Count the number of points
        set numpts 0
        set gmfile [open $indir/$filename r]
        while {[gets $gmfile line] >= 0} {
            incr numpts
        }
        close $gmfile
		set time_gm [expr $numpts*$dt]
		
		# Check if the ground motion has been already completed
		set filename_length [string length $filename]
		set outfilename [string range $filename 0 [expr {$filename_length - 5}]]
		set outdir $outpath/$gmdir/$outfilename
				
		if {[file exists $outdir/MSA.txt] && [file exists $outdir/story1_acc_env.out] && [file exists $outdir/story1_drift.out]} {
			# read MSA.txt file
			set fp [open $outdir/MSA.txt r]
			set msa_file [read $fp]
			
			#puts "$filename MSA.txt = $msa_file"			
			# check is MSA.txt file is empty
			if {$msa_file eq ""} {
				# MSA.txt is empty so run this gm
				set addgmtolist 1
				# puts "Run: $filename"
			} else {
				# MSA.txt is populated so skip this gm
				set addgmtolist 0				
			}
			close $fp
			
			# check is story1_acc_env.out file is empty
			set fp [open $outdir/story1_acc_env.out r]
			set acc_file [read $fp]
			if {$acc_file eq ""} {
				# story1_acc_env is empty so run this gm
				set addgmtolist 1
				# puts "Run: $filename"
			} else {
				# story1_acc_env is populated so skip this gm
				set addgmtolist 0				
			}
			close $fp
			
			# check if did not finish due to inconvergence
			set driftfile [open $outdir/story1_drift.out r]
			while {[gets $driftfile line] >= 0} {
				#puts "$line"
				set time_ran [lindex $line 0]
				#puts "$time_ran"
			}
			puts "$filename: time_ran=$time_ran; time_gm =$time_gm; acc_file = $acc_file; msa_file = $msa_file"

			if {$time_ran < $time_gm} {
				# inconvergence: ran time is lower than time_gm
				set addgmtolist 1
				# puts "Run: $filename"
			} else {
				# converged
				set addgmtolist 0				
			}
			close $driftfile
			
		} else {
			# MSA.txt does not exist so run this gm
			set addgmtolist 1
			# puts "Run: $filename"
		}
		
		# Add the ground motion information to "gminfo_dict"
		if {$addgmtolist == 1} {			
			dict set gminfo_dict $serial model_id $model_id
			dict set gminfo_dict $serial indir $indir
			dict set gminfo_dict $serial gmdir $gmdir
			dict set gminfo_dict $serial filename $filename
			dict set gminfo_dict $serial dt $dt
			dict set gminfo_dict $serial numpts $numpts
			dict set gminfo_dict $serial scalor $scalor
			incr serial
		}
		        
		if {$model_id < 70} {
			incr model_id
		} else {
			set model_id 1
		}
    }
    close $gminfofile	
	
	# Total number of RHA
	if {$this_procid == 0} {
		puts "##### Running $serial RHA in $indir #####"
	}
	
}
