#!/bin/bash 
#
#all commands that start with SBATCH contain commands that are just used by SLURM for scheduling
#################
#set a job name  
#SBATCH --job-name=IDAne1
#################  
#a file for job output, you can check job progress, append the job ID with %j to make it unique
#SBATCH --output=IDAne1.out
#################
# a file for errors from the job
#SBATCH --error=IDAne1.err
#################
#time you think you need; default is 2 hours
#format could be dd-hh:mm:ss, hh:mm:ss, mm:ss, or mm
#SBATCH --time=16:00:00
#################
#Quality of Service (QOS); think of it as job priority, there is also --qos=long for with a max job length of 7 days, qos normal is 48 hours.
# REMOVE "normal" and set to "long" if you want your job to run longer than 48 hours,  
# NOTE- in the hns partition the default max run time is 7 days , so you wont need to include qos
 
#SBATCH --qos=normal

# We are submitting to the dev partition, there are several on sherlock: normal, gpu, owners, hns, bigmem (jobs requiring >64Gigs RAM) 
# 
#SBATCH -p cee 
#################
#number of nodes you are requesting, the more you ask for the longer you wait
#SBATCH --nodes=5
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4000
#################

# Have SLURM send you an email when the job ends or fails, careful, the email could end up in your clutter folder
# Also, if you submit hundreds of jobs at once you will get hundreds of emails.
 
#SBATCH --mail-type=END,FAIL # notifications for job done & fail
# Remember to change this to your email 
#SBATCH --mail-user=galvisf@stanford.edu

#now run normal batch commands
module load openmpi
module load scalapack
module load mumps
module load metis
module load parmetis
module load petsc

#chmod +x /home/users/wyen/bin/OpenSeesMP_test_env
# You can use srun if your job is parallel
srun /home/users/galvisf/bin/OpenSeesMP30 RunIDAParallel_NESTED.tcl
