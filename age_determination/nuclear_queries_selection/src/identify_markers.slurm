#!/bin/bash

# m_matschiner Wed Oct 10 17:42:32 CEST 2018

# Job name:
#SBATCH --job-name=ident_c
#
# Wall clock limit:
#SBATCH --time=168:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=20G

## Set up the job environment.
source /cluster/bin/jobsetup

## Feedback.
echo
echo "identify_markers.slurm was called with arguments ${@}."
echo

# Load the ruby and blast modules.
module load ruby/2.1.5
module load blast+/2.2.29

# Get the command-line arguments.
mart_export=${1}
mart_export_with_absolute_path=`readlink -f ${mart_export}`
gene_trees=${2}
gene_trees_with_absolute_path=`readlink -f ${gene_trees}`
ref=${3}
ref_with_absolute_path=`readlink -f ${ref}`
database_list=${4}
database_list_with_absolute_path=`readlink -f ${database_list}`
taxon_assignment_table=${5}
taxon_assignment_table_with_absolute_path=`readlink -f ${taxon_assignment_table}`
n_orthologs_allowed_missing=${6}
dump=${7}
dump_with_absolute_path=`readlink -f ${dump}`
res_genes_table=${8}
res_genes_table_with_absolute_path=`readlink -f ${res_genes_table}`
res_exons_table=${9}
res_exons_table_with_absolute_path=`readlink -f ${res_exons_table}`
res_exons_fasta=${10}
res_exons_fasta_with_absolute_path=`readlink -f ${res_exons_fasta}`
script_with_absolute_path=`readlink -f identify_markers.rb`

# Move to the temporary directory.
cd ${SCRATCH}

# Identify markers for phylogenomics.
ruby ${script_with_absolute_path} ${mart_export_with_absolute_path} ${gene_trees_with_absolute_path} ${ref_with_absolute_path} ${database_list_with_absolute_path} ${taxon_assignment_table_with_absolute_path} ${n_orthologs_allowed_missing} ${dump_with_absolute_path} ${res_genes_table_with_absolute_path} ${res_exons_table_with_absolute_path} ${res_exons_fasta_with_absolute_path}