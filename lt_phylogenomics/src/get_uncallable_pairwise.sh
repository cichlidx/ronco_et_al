# m_matschiner Tue Apr 24 14:22:23 CEST 2018

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    while [ $n_jobs -gt 390 ]
    do
        sleep 10
        n_jobs=`squeue -u michaelm | wc -l`
    done
}

# Make the output directory if it doesn't exist yet.
mkdir -p ../res/tables/uncallable/pairwise

# Start analyses for each masked file.
for filter in strict permissive
do
    for gzbed1 in ../data/masks/*.${filter}.merged.bed.gz
    do
	
	# Get the sample id for the first file.
	sample1=`basename ${gzbed1%.${filter}.merged.bed.gz}`

	# Set the names of the table and log files.
	table="../res/tables/uncallable/pairwise/${sample1}.${filter}.txt"
	out="../log/misc/pairwise_uncallable.${sample1}.${filter}.out"

	# Get the number of uncallable sites in pairwise comparisons involving this sample.
	if [ ! -f ${table} ]
	then
	    rm -f ${out}
	    sbatch -o ${out} get_uncallable_pairwise.slurm ${gzbed1} ${filter} ${table}
	fi
	sleep_while_too_busy

    done
done