# m_matschiner Fri May 5 17:25:01 CEST 2017

# Extract all reads mapping to the mitochondrial genome from each of the
# bam files (in an external directory) and generate both sam and bam files
# from them.
bash extract_mitogenome_from_bams.sh

# Make a mitochondrial reference sequence by extracting the corrsponding scaffold
# from the orenil2 genome.
bash make_mitochondrial_reference.sh

# Prepare fastq files from the mitochondrial bam files.
bash convert_bams_to_fastqs.sh

# Generate mitochondrial assemblies with mitobim and mira.
bash make_mitochondrial_assemblies.sh

# Align the full mitochondrial genomes produced with mitobim and mira.
bash make_mitochondrial_alignment.sh

# Split the full mitochondrial genome alignment into individual genes.
bash extract_gene_alignments.sh

# Prepare a partitioned alignment for use with raxml.
bash make_partitioned_alignment.sh

# Run raxml with the partitioned alignment based on assemblies.
bash run_raxml_with_assembled_sequenced.sh

# Translate tree ids.
bash translate_tree_ids.sh