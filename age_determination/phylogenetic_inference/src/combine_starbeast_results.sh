# m_matschiner Fri Jul 19 09:35:17 CEST 2019

# Load modules.
module load python3/3.5.0
module load beast2/2.5.0

# Set the results directory.
dir=../res/beast/strict/min_10000

# Combine all results for popsize pop025.
pop_size=pop025
if [ ! -f ${dir}/${pop_size}/combined/${pop_size}.tre ]
then
    mkdir -p ${dir}/${pop_size}/combined
    rm -f ${dir}/${pop_size}/combined/logs.txt
    rm -f ${dir}/${pop_size}/combined/trees.txt
    for rep in r01 r02 r03 r04 r05 r07 r08 r10 r11 r12 r13 r15 r16 r17 r18 r20
    do
	ls ${dir}/${pop_size}/replicates/${rep}/strict.log >> ${dir}/${pop_size}/combined/logs.txt
	ls ${dir}/${pop_size}/replicates/${rep}/strict_species.trees >> ${dir}/${pop_size}/combined/trees.txt
    done
    python3 logcombiner.py -n 100 -b 55 ${dir}/${pop_size}/combined/logs.txt ${dir}/${pop_size}/combined/${pop_size}_tmp.log
    python3 logcombiner.py -n 1000 -b 0 ${dir}/${pop_size}/combined/${pop_size}_tmp.log ${dir}/${pop_size}/combined/${pop_size}.log
    python3 logcombiner.py -n 100 -b 55 ${dir}/${pop_size}/combined/trees.txt ${dir}/${pop_size}/combined/${pop_size}_tmp.trees
    python3 logcombiner.py -n 1000 -b 0 ${dir}/${pop_size}/combined/${pop_size}_tmp.trees ${dir}/${pop_size}/combined/${pop_size}.trees
    treeannotator -b 0 -heights mean ${dir}/${pop_size}/combined/${pop_size}.trees ${dir}/${pop_size}/combined/${pop_size}.tre
    rm -f ${dir}/${pop_size}/combined/${pop_size}_tmp.log
    rm -f ${dir}/${pop_size}/combined/${pop_size}_tmp.trees
fi
pop_size=pop05
if [ ! -f ${dir}/${pop_size}/combined/${pop_size}.tre ]
then
    mkdir -p ${dir}/${pop_size}/combined
    rm -f ${dir}/${pop_size}/combined/logs.txt
    rm -f ${dir}/${pop_size}/combined/trees.txt
    for rep in r01 r02 r03 r04 r05 r07 r08 r10 r11 r12 r13 r15 r16 r17 r18 r20
    do
        ls ${dir}/${pop_size}/replicates/${rep}/strict.log >> ${dir}/${pop_size}/combined/logs.txt
        ls ${dir}/${pop_size}/replicates/${rep}/strict_species.trees >> ${dir}/${pop_size}/combined/trees.txt
    done
    python3 logcombiner.py -n 100 -b 55 ${dir}/${pop_size}/combined/logs.txt ${dir}/${pop_size}/combined/${pop_size}_tmp.log
    python3 logcombiner.py -n 1000 -b 0 ${dir}/${pop_size}/combined/${pop_size}_tmp.log ${dir}/${pop_size}/combined/${pop_size}.log
    python3 logcombiner.py -n 100 -b 55 ${dir}/${pop_size}/combined/trees.txt ${dir}/${pop_size}/combined/${pop_size}_tmp.trees
    python3 logcombiner.py -n 1000 -b 0 ${dir}/${pop_size}/combined/${pop_size}_tmp.trees ${dir}/${pop_size}/combined/${pop_size}.trees
    treeannotator -b 0 -heights mean ${dir}/${pop_size}/combined/${pop_size}.trees ${dir}/${pop_size}/combined/${pop_size}.tre
    rm -f ${dir}/${pop_size}/combined/${pop_size}_tmp.log
    rm -f ${dir}/${pop_size}/combined/${pop_size}_tmp.trees
fi
pop_size=pop1
if [ ! -f ${dir}/${pop_size}/combined/${pop_size}.tre ]
then
    mkdir -p ${dir}/${pop_size}/combined
    rm -f ${dir}/${pop_size}/combined/logs.txt
    rm -f ${dir}/${pop_size}/combined/trees.txt
    for rep in r01 r02 r03 r04 r05 r07 r08 r10 r11 r12 r13 r15 r16 r17 r18 r20
    do
        ls ${dir}/${pop_size}/replicates/${rep}/strict.log >> ${dir}/${pop_size}/combined/logs.txt
        ls ${dir}/${pop_size}/replicates/${rep}/strict_species.trees >> ${dir}/${pop_size}/combined/trees.txt
    done
    python3 logcombiner.py -n 100 -b 55 ${dir}/${pop_size}/combined/logs.txt ${dir}/${pop_size}/combined/${pop_size}_tmp.log
    python3 logcombiner.py -n 1000 -b 0 ${dir}/${pop_size}/combined/${pop_size}_tmp.log ${dir}/${pop_size}/combined/${pop_size}.log
    python3 logcombiner.py -n 100 -b 55 ${dir}/${pop_size}/combined/trees.txt ${dir}/${pop_size}/combined/${pop_size}_tmp.trees
    python3 logcombiner.py -n 1000 -b 0 ${dir}/${pop_size}/combined/${pop_size}_tmp.trees ${dir}/${pop_size}/combined/${pop_size}.trees
    treeannotator -b 0 -heights mean ${dir}/${pop_size}/combined/${pop_size}.trees ${dir}/${pop_size}/combined/${pop_size}.tre
    rm -f ${dir}/${pop_size}/combined/${pop_size}_tmp.log
    rm -f ${dir}/${pop_size}/combined/${pop_size}_tmp.trees
fi
pop_size=pop2
if [ ! -f ${dir}/${pop_size}/combined/${pop_size}.tre ]
then
    mkdir -p ${dir}/${pop_size}/combined
    rm -f ${dir}/${pop_size}/combined/logs.txt
    rm -f ${dir}/${pop_size}/combined/trees.txt
    for rep in r01 r02 r03 r04 r05 r07 r08 r10 r11 r12 r13 r15 r16 r17 r18 r20
    do
        ls ${dir}/${pop_size}/replicates/${rep}/strict.log >> ${dir}/${pop_size}/combined/logs.txt
        ls ${dir}/${pop_size}/replicates/${rep}/strict_species.trees >> ${dir}/${pop_size}/combined/trees.txt
    done
    python3 logcombiner.py -n 100 -b 55 ${dir}/${pop_size}/combined/logs.txt ${dir}/${pop_size}/combined/${pop_size}_tmp.log
    python3 logcombiner.py -n 1000 -b 0 ${dir}/${pop_size}/combined/${pop_size}_tmp.log ${dir}/${pop_size}/combined/${pop_size}.log
    python3 logcombiner.py -n 100 -b 55 ${dir}/${pop_size}/combined/trees.txt ${dir}/${pop_size}/combined/${pop_size}_tmp.trees
    python3 logcombiner.py -n 1000 -b 0 ${dir}/${pop_size}/combined/${pop_size}_tmp.trees ${dir}/${pop_size}/combined/${pop_size}.trees
    treeannotator -b 0 -heights mean ${dir}/${pop_size}/combined/${pop_size}.trees ${dir}/${pop_size}/combined/${pop_size}.tre
    rm -f ${dir}/${pop_size}/combined/${pop_size}_tmp.log
    rm -f ${dir}/${pop_size}/combined/${pop_size}_tmp.trees
fi
