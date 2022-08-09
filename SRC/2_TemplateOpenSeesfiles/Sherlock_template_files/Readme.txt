##
Notes for running IDA in OpenSeesMP on sherlock 2.0
Kuanshi Zhong, kuanshi@stanford.edu
10/2019
##

1. In command window, submit the ".sbatch" to schedule work
-1.1 Define your job names and requested resouses
-1.2 Change the mail address to monitor status
-1.3 Load modules: openmpi (environment) and opensees (load "physics" first and load "opensees" since it's categorized there)
-1.4 srun OpenSeesMP your-opensees-main-file.tcl

2. For IDA, the main file is "RunIDAParallel_FEMA.tcl" in this example
-2.1 Line 8-16 (L8-L16): standard commands initializing available processes for OpenSeesMP
-2.2 L18-L20: define the directory of ground motions ("inpath") and the folder name ("indirlist")
-2.3 L22-L23: define the directory of output results in analysis
-2.4 L25-L26: define collapse drift ratio (usually 10%)
-2.5 L28-L380: define tasks for the master processor ($this_procid == 0)
--2.5.1 L33: define the fundamental period ("T1"), which would help read the Sa data later
--2.5.2 L36-L80: create a ground motion list, reading the record file names, Sa, delta_t and length of records and saving them in dict variable ("gminfo_dict")
--2.5.3 L82-L87: define the resolution of Sa in IDA
--2.5.4 L89-L94: procedure for collapse message display (optional)
--2.5.5 L96-L101: procedure for sending terminal command to slave processors (important)
--2.5.6 L103-L226: create/update "runlist" (like a time-schedule that coordinates slave processors) and "forks_run" (like a result-table that master processor monitors), and save "forks_run" information for each ground motion in their output directories.
--2.5.7 L228-L230: update number of collapsed motions (this would control the while loop later)
--2.5.8 L232-L236: update free processors ("free_procs")
--2.5.9 L238-L245: exit check (if all ground motions scaled to cause collapse, terminate job)
--2.5.10 L247-L355: while loop to control analysis
---2.5.10.1 L249-L265: assign jobs in "runlinst" to "free_procs"
---2.5.10.2 L267-L277: receive results of a competed job and free the slave processor
---2.5.10.3 L279-L355: update the "runlist", "forks_run", and others according to the received result.  This includes two cases: (1) a coarse round where the scaling factor takes large steps (delta_sat1_coarse) up until collapse; (2) a fine round where scaling factors are in small steps ("delta_sat1_fine") around the "tipping point"
--2.5.11 L357-L358: all analyses done, so close slave processors
--2.5.12 L360-L380: finishing the tasks and writting the output
-2.6 L382-L419: define tasks for slave processors ($this_procid > 0)
--2.6.1 L385-L386: source "DriftCheck.tcl" for procedures checking maximum drift ratios
--2.6.2 L388-L393: receive command from the master processor
--2.6.3 L395-L414: for loop until the command asking to stop; otherwise, start the new analysis with delivered informations ("gm","sata","tier","gminfo")
---2.6.3.1 L405: source your structural model
---2.6.3.2 L406-L408: source your recorder and analysis .tcl file
---2.6.3.3 L410-L413: send analysis results to master processor and receive new command again


