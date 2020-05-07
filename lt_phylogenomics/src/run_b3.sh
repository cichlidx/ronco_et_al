# michaelm Sat Mar 7 01:14:12 CET 2020

# Launch beast analyses for all b3 replicate directories.
for dir in ../res/beast/b3/replicates/r??
do
    cd ${dir}
    sbatch run_b3.slurm
    cd -
done
