# m_matschiner Tue Jul 24 10:13:39 CEST 2018

# This script needs the following dependencies.
# convert.py
# beauti.rb

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    while [ $n_jobs -gt 300 ]
    do
        sleep 10
        n_jobs=`squeue -u michaelm | wc -l`
    done
}

# Load the ruby and python3 modules.
module load ruby/2.1.5
module load python3/3.5.0

# Generate XML input files for beast, for each gene.
for align in ../res/alignments/nuclear/09/*/*.nex
do
    align_id=`basename ${align%.nex}`
    align_dir=`dirname ${align}`
    if [ ! -f ${align_dir}/${align_id}.xml ]
    then
	ruby beauti.rb -id ${align_id} -n ${align_dir} -u -s -o ${align_dir} -c ../data/constraints/root.xml -l 5000000
    fi
done

# Go to each alignment directory and start beast analyses from there.
for align_dir in ../res/alignments/nuclear/09/ENS*
do
    sleep_while_too_busy
    cd ${align_dir}
    trees_file=`basename ${align_dir}.trees`
    if [ -f ${trees_file} ]
    then
        echo "Skipping directory ${dir} as file ${trees_file} exists."
    else
        sbatch --time=24:00:00 start.slurm
    fi
    cd -
done
