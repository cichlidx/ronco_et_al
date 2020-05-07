# m_matschiner Wed Jan 9 16:56:30 CET 2019

# Load modules.
module load ruby/2.1.5

# Make the log directory.
mkdir -p ../log/iqtree

# Set the alignment directory.
mkdir -p ../res/iqtree/alignments

# Concatenate all per-locus nexus files.
concatenated=../res/iqtree/alignments/concatenated.nex
if [ ! -f ${concatenated} ]
then
    ruby concatenate.rb -i ../res/iqtree/alignments/*.nex -o ${concatenated} -f nexus -p
fi

# Make a maximum-likelihood tree with iqtree.
tree_dir=../res/iqtree/trees
mkdir -p ${tree_dir}
out=../log/iqtree/loci.out
rm -f ${out}
sbatch -o ${out} run_iqtree_loci.slurm ${concatenated} ${tree_dir}
