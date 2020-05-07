# m_matschiner Thu Nov 22 14:23:52 CET 2018

# Make the output directory.
mkdir -p ../res/astral

# Run astral for the set of gene trees produced by iqtree.
java -jar -Xmx8G ../bin/Astral/astral.5.6.3.jar -i ../res/iqtree/trees/loci.treefile -o ../res/astral/species_pp.tre
