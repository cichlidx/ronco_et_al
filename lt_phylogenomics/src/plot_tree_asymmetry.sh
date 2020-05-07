# m_matschiner Fri May 31 15:33:23 CEST 2019

# Combine all tree asymmetry tables into a single temporary file.
if [ ! -f tmp.txt ]
then
    head -n 1 ../res/tree_asymmetry/topology_frequencies_Altcal.txt > tmp.txt
    for i in ../res/tree_asymmetry/topology_frequencies_??????.txt
    do
        cat ${i} | tail -n +2 >> tmp.txt
    done
fi

# Plot tree asymmetry.
out=../log/tree_asymmetry/plot.out
rm -f ${out}
sbatch -o ${out} plot_tree_asymmetry.slurm tmp.txt ../data/tables/order.txt ../res/tree_asymmetry/tree_asymmetry.svg
