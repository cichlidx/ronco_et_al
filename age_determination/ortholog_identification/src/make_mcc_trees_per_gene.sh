# m_matschiner Wed Nov 14 16:59:33 CET 2018

# Load modules.
module load beast2/2.5.0

# Generate a maximum-clade-credibility consensus tree for each gene.
for trees in ../res/alignments/nuclear/09/*/*.trees
do
    tre=${trees%.trees}.tre
    if [ ! -f ${tre} ]
    then
	treeannotator  -burnin 10 -heights mean ${trees} ${tre}
    fi
done
