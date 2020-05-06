# m_matschiner Tue Oct 2 11:59:01 CEST 2018

# Load the blast module.
module load blast+/2.2.29

# Make a blast database for the tilapia assembly
makeblastdb -in ../data/subjects/orenil2.fasta -dbtype nucl
