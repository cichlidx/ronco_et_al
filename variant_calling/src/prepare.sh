# michaelm Fri Dec 2 15:36:51 CET 2016

# Make the log directory.
mkdir -p ../log/misc/

# Uncompress the reference.
cd ../data/reference
cp GCF_001858045.1_ASM185804v2_genomic_edit.fna orenil2.fasta
cd -

# Prepare index files for the reference.
sbatch -o ../log/misc/prepare.out prepare.slurm ../data/reference/orenil2.fasta
