# m_matschiner Tue Mar 27 14:56:28 CEST 2018

# Get the numbers of callable sites per sample.
bash get_uncallable_single.sh

# Get the numbers of callable sites in pairwise comparisons of samples.
bash get_uncallable_pairwise.sh

# Make subsets of the main full vcf files with different amounts of per-site missing data.
bash make_vcf_subsets_by_completeness.sh

# Make subsets of the vcf files by removing certain species.
bash make_vcf_subsets_by_samples.sh

# Calculate stats for the vcf subsets.
bash get_vcf_stats.sh

# Make 100 vcf files for each main vcf, with only every 100th site.
bash distribute_snps.sh

# Thin the main vcf files so that they only contain one snp per 100 bp.
bash make_thinned_vcfs.sh

# Convert the vcf file to nexus format, splitting gts of selected samples according to phasing.
bash convert_vcfs_to_unphased_nexus.sh

# Add a paup block with svdquartets instructions to all nexus files.
bash add_paup_block_to_nexs.sh

# Make a species tree with svdquartets.
bash run_svdquartets.sh

# Make consensus trees for the svdquartets results.
bash sum_svdquartets_trees.sh

# Generate plots for the states of sites at which parental species are fixed.
bash analyze_fixed_site_ancestry.sh

# Make raxml phylogenies with samples as tips.
bash run_raxml.sh

# Summarize the raxml phylogenies.
bash sum_raxml_trees.sh

# Rename the tips of the raxml phylogenies to add species ids.
bash rename_tips_of_raxml_trees.sh

# Mask the orenil2 reference sequence according to callable sites in the strict and permissive datasets.
bash mask_reference.sh

# Make a sequentialized version of the orenil2 reference fasta file.
bash sequentialize_fasta.sh

# Run raxml for sliding windows.
bash run_raxml_per_window.sh

# Get statistics for missing data, robinson-foulds distances, gsi etc for sliding-window trees.
bash get_window_phylogeny_stats.sh

# Summarize the statistics for sliding-window trees in one table.
bash sum_window_phylogeny_stats.sh

# Make a series of plots of the statistics for sliding-window trees.
bash plot_window_stats.sh

# Extract alignments in phylip format for all windows that have phylogenies with robinson-foulds distance from the concatenated permissive tree of less than 700.
bash extract_alignments.sh

# Reduce the alignments to a single sequence per species, using the specimen with the lowest proportion of missing data.
bash reduce_alignments_to_one_sequence_per_species.sh

# Calculate the number of hemiplasies for each reduced alignment.
bash get_numbers_of_hemiplasies.sh

# Select reduced alignments for iqtree analyses based on alignment length, number of variable sites, and number of hemiplasies.
bash select_alignments_for_iqtree.sh

# Run iqtree with concatenated alignments, partitioned by window.
bash run_iqtree_concatenated.sh

# Run iqtree per window alignment.
bash run_iqtree_loci.sh

# Run iqtree a third time to calculate gene and site concordance factors based on the results of the two previous iqtree analyses.
bash run_iqtree_concord.sh

# Run astral with the per-window iqtree trees as input.
bash run_astral.sh

# Analyse asymmetry in the topologies estimated with iqtree per window as evidence for introgression.
bash analyze_tree_asymmetry.sh

# Plot tree asymmetry.
bash plot_tree_asymmetry.sh

# Select reduced alignments for beast analyses based on alignment length, number of variable sites, and number of hemiplasies.
bash select_alignments_for_concatenated_beast.sh

# Write the b1 beast xml file.
bash make_b1_xml.sh

# Prepare directories for the b1 beast analysis.
bash prepare_b1_analyses.sh

# Run b1 beast analyses.
bash run_b1.sh

# Combine the replicate results of b1 beast analyses.
bash combine_b1_results.sh

# Write the b2 beast xml file.
bash make_b2_xml.sh

# Prepare directories for the b2 beast analysis.
bash prepare_b2_analyses.sh

# Run b2 beast analyses.
bash run_b2.sh

# Combine the replicate results of b2 beast analyses.
bash combine_b2_results.sh

# Make xml files for backbone snapp analyses.
bash make_snapp_backbone_xmls.sh

# Prepare directories for backbone snapp analyses.
bash prepare_snapp_backbone_analyses.sh

# Run backbone snapp analyses.
bash run_snapp_backbone.sh

# Manually determine the burnin percentage for each replicate backbone snapp analysis (write to ../res/manual/snapp_log_burning.txt).

# Make xml files for within-tribe backbone snapp analyses.
bash make_snapp_tribebb_xmls.sh

# Prepare directories for within-tribe backbone snapp analyses.
bash prepare_snapp_tribebb_analyses.sh

# Run within-tribe backbone snapp analyses.
bash run_snapp_tribebb.sh

# Manually determine the burnin percentage for each replicate within-tribe backbone snapp analysis (write to ../res/manual/snapp_log_burning.txt).

# Make xml files for tribe snapp analyses.
bash make_snapp_tribe_xmls.sh

# For certain tribes with outgroups, make xml files for snapp analyses based on manually prepared input files.
bash make_snapp_tribe_xmls_manual.sh

# For certain tribes with too few variable sites in the strict dataset, make xml files for snapp analyses based on the permissive snp dataset.
bash make_snapp_tribe_alt_xmls.sh

# Prepare directories for tribe snapp analyses.
bash prepare_snapp_tribe_analyses.sh

# Run tribe snapp analyses.
bash run_snapp_tribe.sh

# Manually determine the burnin percentage for each replicate tribe snapp analysis (write to ../res/manual/snapp_log_burning.txt).

# Simplfy the posterior tree distributions generated by snapp for subsequent connection.
bash simplify_snapp_trees.sh

# Connect the backbone, within-tribe backbone, and tribe tree distributions generated by snapp.
bash connect_snapp_trees.sh

# Visualize how the tree connections were made.
bash plot_connection_times.sh

# Make maximum-clade-credibility summary trees for the connected posterior distributions.
bash summarize_connected_snapp_trees.sh

# Write the b3 beast xml file.
bash make_b3_xml.sh

# Prepare directories for the b3 beast analysis.
bash prepare_b3_analyses.sh

# Run b3 beast analyses.
bash run_b3.sh

# Combine the replicate results of b3 beast analyses.
bash combine_b3_results.sh
