# m_matschiner Tue Aug 6 01:15:01 CEST 2019

# Load modules.
module load beast2/2.5.0

# Make maximum-clade-credibility trees.
for trees in ../res/snapp/connected/?????/snapp_*_topology.trees
do
    treeannotator -b 0 -heights mean ${trees} ${trees%es}
done