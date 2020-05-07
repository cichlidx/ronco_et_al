# m_matschiner Fri Jul 20 22:15:14 CEST 2018

# Load the ruby module.
module load ruby/2.1.5

# Use a ruby script to make a sequentialized version of the orenil2 reference fasta file.
ruby sequentialize_fasta.rb ../data/reference/orenil2.fasta ../data/reference/orenil2.sequential.fasta