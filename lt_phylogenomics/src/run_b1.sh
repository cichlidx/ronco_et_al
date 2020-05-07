# m_matschiner Wed Oct 17 20:31:48 CEST 2018

# Launch beast analyses for all b1 replicate directories.
for dir in ../res/beast/b1/replicates/r??
do
    cd ${dir}
    sbatch run_b1.slurm
    cd -
done