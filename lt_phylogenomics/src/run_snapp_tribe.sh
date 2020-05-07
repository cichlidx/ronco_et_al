# m_matschiner Sat Jul 13 12:30:38 CEST 2019

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    while [ $n_jobs -gt 300 ]
    do
        sleep 10
        n_jobs=`squeue -u michaelm | wc -l`
    done
}

# Launch snapp analyses for all replicate directories.
for tribe in pseudocrenilabrini orthochromini serranochromini astatotilapini ectodini1 ectodini2 lamprologini1 lamprologini5 trematocarini bathybatini benthochromini cyphotilapiini cyprichromini ectodini1 ectodini2 eretmodini lamprologini1 lamprologini2 lamprologini3 lamprologini4 lamprologini5 limnochromini orthochromis perissodini trematocarini tropheini1 tropheini2
do
    for dir in ../res/snapp/${tribe}/{astral,raxml,free}_topology/replicates/r??
    do
        cd ${dir}
        sbatch run_snapp.slurm
        cd -
        sleep_while_too_busy
    done
done