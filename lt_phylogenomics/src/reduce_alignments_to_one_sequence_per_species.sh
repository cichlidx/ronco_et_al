# m_matschiner Fri Oct 12 00:25:56 CEST 2018

# Make the log directory.
mkdir -p ../log/windows/5000bp/reduce

# Set the completeness table.
completeness_table=../data/tables/call_probability.permissive.txt

# Set the sample table.
sample_table=../data/tables/DNATube_2018-02-13_13-43.tsv

# Reduce all window alignments to a single sequence per species.
for align_dir in ../res/windows/5000bp/*
do
    if [ -d ${align_dir} ]
    then
        chromosome_id=`basename ${align_dir}`
        out=../log/windows/5000bp/reduce/${chromosome_id}.out
        rm -f ${out}
        sbatch -o ${out} reduce_alignments_to_one_sequence_per_species.slurm ${align_dir} ${completeness_table} ${sample_table}
    fi
done