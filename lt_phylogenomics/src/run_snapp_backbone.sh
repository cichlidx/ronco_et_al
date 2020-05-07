# m_matschiner Fri Jul 5 23:05:45 CEST 2019

# Launch snapp analyses for all replicate directories.
for dir in ../res/snapp/backbone/{astral,raxml,free}_topology/replicates/r??
do
    cd ${dir}
    sbatch run_snapp.slurm
    cd -
done