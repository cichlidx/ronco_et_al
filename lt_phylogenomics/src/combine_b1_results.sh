# m_matschiner Sat Oct 27 01:02:35 CEST 2018

# Load modules.
module load python3/3.5.0
module load beast2/2.5.0

# Combine log and trees files for the b1 analyses.
if [ ! -f ../res/beast/b1/combined/b1.log ]
then
    mkdir -p ../res/beast/b1/combined
    python3 logcombiner.py -n 0 -b 15 ../res/beast/b1/replicates/r01/b1.log ../res/beast/b1/combined/r01_b1.log
    python3 logcombiner.py -n 0 -b 15 ../res/beast/b1/replicates/r02/b1.log ../res/beast/b1/combined/r02_b1.log
    python3 logcombiner.py -n 0 -b 7.5 ../res/beast/b1/replicates/r03/b1.log ../res/beast/b1/combined/r03_b1.log
    python3 logcombiner.py -n 0 -b 7.5 ../res/beast/b1/replicates/r05/b1.log ../res/beast/b1/combined/r05_b1.log
    python3 logcombiner.py -n 0 -b 35 ../res/beast/b1/replicates/r06/b1.log ../res/beast/b1/combined/r06_b1.log
    python3 logcombiner.py -n 0 -b 25 ../res/beast/b1/replicates/r07/b1.log ../res/beast/b1/combined/r07_b1.log
    python3 logcombiner.py -n 0 -b 7.5 ../res/beast/b1/replicates/r08/b1.log ../res/beast/b1/combined/r08_b1.log
    python3 logcombiner.py -n 0 -b 22.5 ../res/beast/b1/replicates/r09/b1.log ../res/beast/b1/combined/r09_b1.log
    python3 logcombiner.py -n 0 -b 7.5 ../res/beast/b1/replicates/r10/b1.log ../res/beast/b1/combined/r10_b1.log
    python3 logcombiner.py -n 0 -b 7.5 ../res/beast/b1/replicates/r01/b1.trees ../res/beast/b1/combined/r01_b1.trees
    python3 logcombiner.py -n 0 -b 7.5 ../res/beast/b1/replicates/r02/b1.trees ../res/beast/b1/combined/r02_b1.trees
    python3 logcombiner.py -n 0 -b 7.5 ../res/beast/b1/replicates/r03/b1.trees ../res/beast/b1/combined/r03_b1.trees
    python3 logcombiner.py -n 0 -b 7.5 ../res/beast/b1/replicates/r05/b1.trees ../res/beast/b1/combined/r05_b1.trees
    python3 logcombiner.py -n 0 -b 35 ../res/beast/b1/replicates/r06/b1.trees ../res/beast/b1/combined/r06_b1.trees
    python3 logcombiner.py -n 0 -b 25 ../res/beast/b1/replicates/r07/b1.trees ../res/beast/b1/combined/r07_b1.trees
    python3 logcombiner.py -n 0 -b 7.5 ../res/beast/b1/replicates/r08/b1.trees ../res/beast/b1/combined/r08_b1.trees
    python3 logcombiner.py -n 0 -b 22.5 ../res/beast/b1/replicates/r09/b1.trees ../res/beast/b1/combined/r09_b1.trees
    python3 logcombiner.py -n 0 -b 7.5 ../res/beast/b1/replicates/r10/b1.trees ../res/beast/b1/combined/r10_b1.trees
    ls ../res/beast/b1/combined/r??_b1.log > ../res/beast/b1/combined/logs.txt
    ls ../res/beast/b1/combined/r??_b1.trees > ../res/beast/b1/combined/trees.txt
    python3 logcombiner.py -n 500 -b 0 ../res/beast/b1/combined/logs.txt ../res/beast/b1/combined/b1.log
    python3 logcombiner.py -n 500 -b 0 ../res/beast/b1/combined/trees.txt ../res/beast/b1/combined/b1.trees
    treeannotator -b 0 -heights mean ../res/beast/b1/combined/b1.trees ../res/beast/b1/combined/b1.tre
fi