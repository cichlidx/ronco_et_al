# m_matschiner Thu Nov 15 12:19:38 CET 2018

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    while [ $n_jobs -gt 300 ]
    do
        sleep 10
        n_jobs=`squeue -u michaelm | wc -l`
    done
}

# Go to each alignment directory and start beast analyses from there.
for align_dir in ../res/alignments/nuclear/09/ENS*
do
    sleep_while_too_busy
    cd ${align_dir}
    sbatch --time=24:00:00 start.slurm
    cd -
done
