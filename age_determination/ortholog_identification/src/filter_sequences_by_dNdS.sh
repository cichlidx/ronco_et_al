# m_matschiner Sun Nov 11 13:19:08 CET 2018

# Make the output directory if it doesn't exist yet.
mkdir -p ../res/alignments/nuclear/03

# Specify the input and output directories.
indir=../res/alignments/nuclear/02/
outdir=../res/alignments/nuclear/03/
threshold=0.25

# Filter sequences by dNdS.
out=../log/misc/filter_sequences_by_dNdS.out
rm -f ${out}
sbatch -o ${out} filter_sequences_by_dNdS.slurm ${indir} ${outdir} ${threshold}
