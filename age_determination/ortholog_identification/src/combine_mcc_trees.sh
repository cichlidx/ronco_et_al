# m_matschiner Wed Nov 14 20:20:46 CET 2018

# Load modules.
module load python3/3.5.0

# Make single file of all mcc trees, for the strict and permissive settings.
if [ ! -f ../res/trees/nuclear/strict/strict.trees ]
then
    mkdir -p tmp_trees
    for tre in ../res/trees/nuclear/strict/*.tre
    do
	tre_id=`basename ${tre%.tre}`
	python3 logcombiner.py -b 0 --remove-comments ${tre} tmp_trees/${tre_id}.tre
    done
    ls tmp_trees/*.tre > tmp_trees/trees.txt
    python3 logcombiner.py -b 0 tmp_trees/trees.txt ../res/trees/nuclear/strict/strict_numbered_mccs.trees
    rm -rf tmp_trees
fi
if [ ! -f ../res/trees/nuclear/permissive/permissive.trees ]
then
    mkdir -p tmp_trees
    for tre in ../res/trees/nuclear/permissive/*.tre
    do
	tre_id=`basename ${tre%.tre}`
	python3 logcombiner.py -b 0 --remove-comments ${tre} tmp_trees/${tre_id}.tre
    done
    ls tmp_trees/*.tre > tmp_trees/trees.txt
    python3 logcombiner.py -b 0 tmp_trees/trees.txt ../res/trees/nuclear/permissive/permissive_numbered_mccs.trees
    rm -rf tmp_trees
fi