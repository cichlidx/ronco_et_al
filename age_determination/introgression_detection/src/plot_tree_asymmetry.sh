# m_matschiner Fri Dec 14 09:28:00 CET 2018

# Load modules
module load ruby/2.1.5

# Make the output directory.
mkdir -p ../res/plots

# Set the name order table file.
heatmap_name_order=../data/tables/heatmap_name_order.txt

# Plot pairwise maximum asymmetry values.
for mode in strict permissive
do
    for class in exons genes
    do
	# Set the name of the asymmetry table file.
	table=../res/tables/tree_asymmetry_${mode}_${class}.txt
	if [ -f ${table} ]
	then
	    
	    # Set the name of the plot file.
	    plot=../res/plots/tree_asymmetry_${mode}_${class}.svg
	    
	    # Plot the reduced and folded matrix as a heatmap.
	    if [ ! -f ${plot} ]
	    then
		ruby plot_tree_asymmetry.rb ${table} ${heatmap_name_order} ${plot}	       
		echo "Wrote file ${plot}."
	    fi
	fi
    done
done
