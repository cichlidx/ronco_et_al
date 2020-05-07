# m_matschiner Sat Jul 13 12:30:38 CEST 2019

# Launch snapp analyses for all replicate directories.
for tribebb in tropheinibb ectodinibb lamprologinibb
do
    for dir in ../res/snapp/${tribebb}/{astral,raxml,free}_topology/replicates/r??
    do
        cd ${dir}
        sbatch run_snapp.slurm
        cd -
    done
done