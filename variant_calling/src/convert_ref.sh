# m_matschiner Wed May 6 16:35:45 CEST 2020

# Load modules.
module load ruby

# Convert the orenil2 reference (named GCF_001858045.1_ASM185804v2_genomic.fna) so that
# all unplaced scaffolds are combined into one and linkage group ids are simplified.
ruby convert_ref.rb
