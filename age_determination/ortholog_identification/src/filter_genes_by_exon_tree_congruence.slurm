#!/bin/bash

# m_matschiner Thu Jun 14 12:14:51 CEST 2018

# Job name:
#SBATCH --job-name=cctpll
#
# Wall clock limit:
#SBATCH --time=168:00:00
#
# Processor and memory usage:
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=2G

## Set up the job environment.
source /cluster/bin/jobsetup
module load ruby/2.1.5
module load python2/2.7.10.gnu

## Feedback.
echo
echo "filter_genes_by_exon_tree_congruence.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
indir=${1}
last_char=${2}
second_last_char=${3}
outdir=${4}
exon_info_table_in=${5}
exon_info_table_out=${6}
min_n_exons_per_gene=${7}
raxml_bin=${8}
concaterpillar_dir=${9}
n_cpus=${10}

# Use a ruby script to run concaterpillar.
ruby filter_genes_by_exon_tree_congruence.rb ${indir} ${last_char} ${second_last_char} ${outdir} ${exon_info_table_in} ${exon_info_table_out} ${min_n_exons_per_gene} ${raxml_bin} ${concaterpillar_dir} ${n_cpus}
