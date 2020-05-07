# m_matschiner Thu Jun 14 12:43:29 CEST 2018

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    while [ $n_jobs -gt 300 ]
    do
        sleep 10
        n_jobs=`squeue -u michaelm | wc -l`
    done
}

# Define a function to sleep if any jobs are queued or running.
function sleep_while_busy {
    n_jobs=`squeue -u michaelm | grep unclsg | wc -l`
    while [ $n_jobs -gt 0 ]
    do
        sleep 10
        n_jobs=`squeue -u michaelm | grep unclsg | wc -l`
    done
}

# Make the output directory if it doesn't exist yet.
mkdir -p ../res/tables/uncallable/single

# Start analyses for each masked file.
for filter in strict permissive
do
    for gzbed in ../data/masks/*.${filter}.merged.bed.gz
    do
	
	# Get the sample id for the first file.
	sample_id=`basename ${gzbed%.${filter}.merged.bed.gz}`

	# Set the names of the table and log files.
	table="../res/tables/uncallable/single/${sample_id}.${filter}.txt"
	out="../log/misc/single_uncallable.${sample_id}.${filter}.out"

	# Get the number of uncallable sites in this sample.
	if [ ! -f ${table} ]
	then
	    rm -f ${out}
	    sbatch -o ${out} get_uncallable_single.slurm ${gzbed} ${filter} ${table}
	fi
	sleep_while_too_busy

    done
    
    # Merge all results into a single file per filter.
    sleep_while_busy
    cat ../res/tables/uncallable/single/*.${filter}.txt > ../res/tables/uncallable/single/${filter}.txt
done
