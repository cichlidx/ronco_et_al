# michaelm Sat Dec 3 21:48:33 CET 2016

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    while [ $n_jobs -gt 300 ]
    do
        sleep 10
        n_jobs=`squeue -u michaelm | wc -l`
    done
}

# Run script run_gatk1.sh for each chromosome and each specimen.
for specimen_id in `cat ../data/tables/ear.txt | cut -f 1`
do
	for lg_id in NC_0319{65..87} UNPLACED
	do
		bash run_gatk1.sh ${specimen_id} ${lg_id}
		sleep_while_too_busy
	done
done
