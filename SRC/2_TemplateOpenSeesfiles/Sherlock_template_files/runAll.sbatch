#!/bin/bash 

#SBATCH --qos=normal
#SBATCH -p cee
#SBATCH --job-name=runAll.job
#SBATCH --output=runAll
#SBATCH --error=runAll.err

folders=(##listOfRuns##)

job_file="MSA.sbatch"

for folder in ${folders[@]}; do	
	
	echo "#!/bin/bash"
		
	cd ${folder}

	sbatch $job_file

	cd ..

done