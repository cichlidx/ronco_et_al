# m_matschiner Mon Feb 26 16:18:25 CET 2018

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    while [ $n_jobs -gt 350 ]
    do
        sleep 10
        n_jobs=`squeue -u michaelm | wc -l`
    done
}

# Get the sum of depths from dump files, per lg, and save it as a new dump file.
for lg in NC_0319{65..87} UNPLACED
do
    if [ ! -f ../res/gatk/${lg}.dmp ]
    then
	out="../log/miscellaneous/depth.${lg}.out"
	rm -f ${out}
	sbatch -o ${out} sum_depths.slurm ${lg}
    fi
    sleep_while_too_busy
done