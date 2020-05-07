# m_matschiner Fri Jul 5 00:08:43 CEST 2019

# Launch beast analyses for all b2 replicate directories.
for dir in ../res/beast/b2/replicates/r??
do
    cd ${dir}
    sbatch run_b2.slurm
    cd -
done