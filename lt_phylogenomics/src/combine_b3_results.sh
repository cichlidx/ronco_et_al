# michaelm Sat Mar 21 23:11:23 CET 2020

# Load modules.
module load Beast/2.5.2-GCC-8.2.0-2.31.1
module load Python/3.7.2-GCCcore-8.2.0

# Combine log and trees files for the b3 analyses.
if [ ! -f ../res/beast/b3/combined/b3.log ]
then
    mkdir -p ../res/beast/b3/combined
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r01/b3.log ../res/beast/b3/combined/r01_b3.log
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r02/b3.log ../res/beast/b3/combined/r02_b3.log
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r03/b3.log ../res/beast/b3/combined/r03_b3.log
    python3 logcombiner.py -n 0 -b 30 ../res/beast/b3/replicates/r04/b3.log ../res/beast/b3/combined/r04_b3.log
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r05/b3.log ../res/beast/b3/combined/r05_b3.log
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r06/b3.log ../res/beast/b3/combined/r06_b3.log
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r07/b3.log ../res/beast/b3/combined/r07_b3.log
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r09/b3.log ../res/beast/b3/combined/r09_b3.log
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r10/b3.log ../res/beast/b3/combined/r10_b3.log
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r01/b3.trees ../res/beast/b3/combined/r01_b3.trees
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r02/b3.trees ../res/beast/b3/combined/r02_b3.trees
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r03/b3.trees ../res/beast/b3/combined/r03_b3.trees
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r04/b3.trees ../res/beast/b3/combined/r04_b3.trees
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r05/b3.trees ../res/beast/b3/combined/r05_b3.trees
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r06/b3.trees ../res/beast/b3/combined/r06_b3.trees
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r07/b3.trees ../res/beast/b3/combined/r07_b3.trees
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r09/b3.trees ../res/beast/b3/combined/r09_b3.trees
    python3 logcombiner.py -n 0 -b 10 ../res/beast/b3/replicates/r10/b3.trees ../res/beast/b3/combined/r10_b3.trees
    ls ../res/beast/b3/combined/r??_b3.log > ../res/beast/b3/combined/logs.txt
    ls ../res/beast/b3/combined/r??_b3.trees > ../res/beast/b3/combined/trees.txt
    python3 logcombiner.py -n 500 -b 0 ../res/beast/b3/combined/logs.txt ../res/beast/b3/combined/b3.log
    python3 logcombiner.py -n 500 -b 0 ../res/beast/b3/combined/trees.txt ../res/beast/b3/combined/b3.trees
    treeannotator -b 0 -heights mean ../res/beast/b3/combined/b3.trees ../res/beast/b3/combined/b3.tre
fi
