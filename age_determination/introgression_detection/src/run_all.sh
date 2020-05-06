# m_matschiner Tue Dec 4 12:49:40 CET 2018

# Prepare the sets of exon and gene alignments.
bash prepare_data.sh

# Convert all alignments to phylip format.
bash convert_alignments_to_phylip.sh

# Make maximum-likelihood trees with iqtree and root them.
bash run_iqtree.sh

# Copy the iqtree results for those markers in the strict dataset.
bash copy_strict_iqtree_results.sh

# Collapse nodes connected by extremely short branches into polytomies.
bash collapse_short_branches.sh

# Analyse the sets of exon and gene trees for asymmetry of alternative topologies.
bash analyze_tree_asymmetry.sh

# Plot the asymmetries in alternative topologies as a heatmap.
bash plot_tree_asymmetry.sh

# Run iqtree once again to compare the likelihoods of three different hypothese.
bash run_iqtree_constrained.sh

# Copy the iqtree_constrained results for those markers in the strict dataset.
bash copy_strict_iqtree_constrained_results.sh

# Summarize the likelihoods of the three different hypotheses.
bash summarize_constrained_iqtree_analyses.sh

# Plot the differences between the best and second-best likelihood, per best-supported hypothesis.
bash plot_constrained_likelihoods.sh
