# m_matschiner Sat Oct 27 01:02:35 CEST 2018

# Load modules.
module load python3/3.5.0
module load beast2/2.5.0

# Combine log and trees files for the b2 analyses.
if [ ! -f ../res/beast/b2/combined/b2.log ]
then
    mkdir -p ../res/beast/b2/combined
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b2/replicates/r01/b2.log ../res/beast/b2/combined/r01_b2.log
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b2/replicates/r02/b2.log ../res/beast/b2/combined/r02_b2.log
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b2/replicates/r03/b2.log ../res/beast/b2/combined/r03_b2.log
    python3 logcombiner.py -n 0 -b 30 ../res/beast/b2/replicates/r04/b2.log ../res/beast/b2/combined/r04_b2.log
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b2/replicates/r05/b2.log ../res/beast/b2/combined/r05_b2.log
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b2/replicates/r06/b2.log ../res/beast/b2/combined/r06_b2.log
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b2/replicates/r07/b2.log ../res/beast/b2/combined/r07_b2.log
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b2/replicates/r09/b2.log ../res/beast/b2/combined/r09_b2.log
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b2/replicates/r10/b2.log ../res/beast/b2/combined/r10_b2.log
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b2/replicates/r01/b2.trees ../res/beast/b2/combined/r01_b2.trees
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b2/replicates/r02/b2.trees ../res/beast/b2/combined/r02_b2.trees
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b2/replicates/r03/b2.trees ../res/beast/b2/combined/r03_b2.trees
    python3 logcombiner.py -n 0 -b 30 ../res/beast/b2/replicates/r04/b2.trees ../res/beast/b2/combined/r04_b2.trees
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b2/replicates/r05/b2.trees ../res/beast/b2/combined/r05_b2.trees
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b2/replicates/r06/b2.trees ../res/beast/b2/combined/r06_b2.trees
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b2/replicates/r07/b2.trees ../res/beast/b2/combined/r07_b2.trees
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b2/replicates/r09/b2.trees ../res/beast/b2/combined/r09_b2.trees
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b2/replicates/r10/b2.trees ../res/beast/b2/combined/r10_b2.trees
    ls ../res/beast/b2/combined/r??_b2.log > ../res/beast/b2/combined/logs.txt
    ls ../res/beast/b2/combined/r??_b2.trees > ../res/beast/b2/combined/trees.txt
    python3 logcombiner.py -n 500 -b 0 ../res/beast/b2/combined/logs.txt ../res/beast/b2/combined/b2.log
    python3 logcombiner.py -n 500 -b 0 ../res/beast/b2/combined/trees.txt ../res/beast/b2/combined/b2.trees
    treeannotator -b 0 -heights mean ../res/beast/b2/combined/b2.trees ../res/beast/b2/combined/b2.tre
fi