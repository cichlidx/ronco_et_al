# m_matschiner Mon Apr 8 13:49:31 CEST 2019

# Start all analyses of the starbeast test series.
for analysis_dir in ../res/beast/strict/min_10000/pop*/replicates/*
do
    cd ${analysis_dir}
    sbatch run_beast.slurm
    cd -
done