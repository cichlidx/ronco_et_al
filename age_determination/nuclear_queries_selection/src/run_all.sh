# m_matschiner Wed Oct 3 16:00:56 CEST 2018

# Download subject fasta files from ensembl.
bash get_subjects.sh

# Make blast databases for each cdna fasta file.
bash make_blast_dbs.sh

# Download the gene tree file from ensembl.
bash get_gene_tree_file.sh

# Get a list of ensemble taxon ids and names, with occurrence frequencies in gene trees.
bash get_ensembl_taxon_ids_and_names.sh

# Identiy nuclear markers for phylogenetic inference.
bash identify_markers.sh

# Download the latest assembly for tilapia.
bash get_orenil2.sh

# Make a blast database for the tilapia assembly.
bash make_orenil2_blast_db.sh

# Get orthologous sequences in amino-acid and nucleotide format for all medaka queries from tilapia.
bash find_orthologs.sh

# Combine orenil2 ortholog fasta files.
bash combine_orenil2_ortholog_fastas.sh