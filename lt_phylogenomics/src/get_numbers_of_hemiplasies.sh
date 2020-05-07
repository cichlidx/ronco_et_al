# m_matschiner Fri Oct 12 00:48:36 CEST 2018

# Make the log directory.
mkdir -p ../log/windows/5000bp/hemiplasies

# Reduce all window alignments to a single sequence per species.
for align_dir in ../res/windows/5000bp/*
do
    if [ -d ${align_dir} ]
    then
        chromosome_id=`basename ${align_dir}`
        out=../log/windows/5000bp/hemiplasies/${chromosome_id}.out
        rm -f ${out}
        sbatch -o ${out} get_numbers_of_hemiplasies.slurm ${align_dir}
    fi
done