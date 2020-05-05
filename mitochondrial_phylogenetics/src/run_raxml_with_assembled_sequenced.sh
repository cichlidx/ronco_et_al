# m_matschiner Fri May 5 19:00:07 CEST 2017

# Load the raxml module.
module load raxml/8.2.4

# Make the output directory if it doesn't exist yet.
mkdir -p ../res/raxml/assemblies

# Run raxml.
raxmlHPC-PTHREADS -T 20 -s ../res/alignments/NC_013663.partitioned.phy -q ../res/alignments/NC_013663.partitions.txt -n NC_013663.assembled -m GTRCAT -p ${RANDOM} -x ${RANDOM} -N 100 -f a -w `readlink -e ../res/raxml/assemblies`

# Clean up.
mv ../res/raxml/assemblies/RAxML_bipartitions.NC_013663.assembled ../res/raxml/assemblies/NC_013663.assembled.tre
mv ../res/raxml/assemblies/RAxML_info.NC_013663.assembled ../res/raxml/assemblies/NC_013663.assembled.info.txt
rm ../res/raxml/assemblies/RAxML_*