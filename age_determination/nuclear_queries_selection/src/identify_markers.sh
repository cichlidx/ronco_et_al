# m_matschiner Mon Oct 8 20:01:11 CEST 2018

# Make the output directories.
mkdir -p ../res/tables
mkdir -p ../res/queries
mkdir -p ../res/dump

# Make the log directory.
mkdir -p ../log/misc

# Set the input files.
mart_export=../data/tables/mart_export.txt
gene_trees=../data/misc/Compara.94.protein_default.nhx.emf
ref=../data/subjects/orylat.fasta
database_list=../data/subjects/databases.txt
taxon_assignment_table=../data/tables/taxa.txt

# Identify markers for different missingness thresholds.
for n_orthologs_allowed_missing in 0 1 2
do
    # Set the result file names.
    dump=../res/dump/miss${n_orthologs_allowed_missing}.dmp
    res_genes_table=../res/tables/nuclear_queries_genes_miss${n_orthologs_allowed_missing}.txt
    res_exons_table=../res/tables/nuclear_queries_exons_miss${n_orthologs_allowed_missing}.txt
    res_exons_file=../res/queries/orylat_exons_miss${n_orthologs_allowed_missing}.fasta

    # Set the log file.
    out=../log/misc/identify.miss${n_orthologs_allowed_missing}.txt
    rm -f ${out}

    # Identify markers.
    sbatch -o ${out} identify_markers.slurm ${mart_export} ${gene_trees} ${ref} ${database_list} ${taxon_assignment_table} ${n_orthologs_allowed_missing} ${dump} ${res_genes_table} ${res_exons_table} ${res_exons_file}

done