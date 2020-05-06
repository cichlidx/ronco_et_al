# m_matschiner Sun Dec 16 13:37:12 CET 2018

# Load modules.
module load ruby/2.1.5

# Plot results for likelihood comparisons with all datasets.
for hypothesis in h07 h08 h09 h01 h02 h03 h04 h05 h06 h07
do
    for mode in strict permissive
    do
	for class in exons genes
	do
	    table=../res/tables/constrained_likelihoods_${mode}_${class}_${hypothesis}.txt
	    plot=../res/plots/constrained_likelihoods_${mode}_${class}_${hypothesis}.svg
	    ruby plot_constrained_likelihoods.rb ${table} ${plot}
	done
    done
done