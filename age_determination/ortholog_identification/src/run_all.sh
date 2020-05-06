# m_matschiner Tue Nov 6 17:11:37 CET 2018

# Copy the orenil query file.
bash prepare_query.sh

# Copy and merge local assembly files.
bash prepare_local_subjects.sh

# Download assembly files.
bash get_remote_subjects.sh

# Make a directory combining remote and local merged assembly files.
bash combine_subjects.sh

# Make blast databases for all assemblies.
bash make_blast_dbs.sh

# Use blast searches to find orthologs for queries.
bash find_orthologs.sh

# Filter sequences in alignments in directory 01 by bitscores.
bash filter_sequences_by_bitscore.sh

# Filter sequences of alignments in directory 02 by their dNdS scores in comparisons with the references.
bash filter_sequences_by_dNdS.sh

# Filter exon alignments in directory 03 by missing data (minimally 10 missing sequences, minimum length 150 bp).
bash filter_exons_by_missing_data.sh

# Filter sites in alignments in directory 04 with BMGE.
bash filter_sites_with_BMGE.sh

# Filter exon alignments in directory 05 once again by missing data (minimally 10 missing sequences, minimum length 150 bp).
bash filter_exons_again_by_missing_data.sh

# Determine the regions of each exon in the orylat reference assembly (this table will be read by filter_genes_by_exon_number.sh).
bash get_exon_regions.sh

# Filter exon alignments in directory 06 by gc content.
bash filter_exons_by_GC_content_variation.sh

# Filter genes in directory 07 by their number of exons and the distances between these on the orylat genome assembly.
bash filter_genes_by_exon_number.sh

# Filter genes by exon tree congruence, determined with concaterpillar.
bash filter_genes_by_exon_tree_congruence.sh

# Combine the output tables of the previous step.
bash combine_exon_info_tables.sh

# Run beast analyses for each gene alignment.
bash run_beast_per_gene.sh

# Resume beast analyses for each gene alignment.
bash resume_beast_per_gene.sh

# Generate maximum-clade-credibility summary trees for each gene.
bash make_mcc_trees_per_gene.sh

# Get statistics (alignment length and number of variable sites) for each gene.
bash get_gene_stats.sh

# Selection genes based on stats.
bash select_genes.sh

# Get sequence stats per species.
bash get_species_stats.sh

# Combine all mcc trees into a single file.
bash combine_mcc_trees.sh

# Make new versions of the mcc tree files in which trees have names instead of numbers.
bash add_mcc_tree_names.sh