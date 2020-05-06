#!/bin/bash
#SBATCH --job-name=f_ortho
# m_matschiner Tue Nov 6 23:55:19 CET 2018
#SBATCH --time=168:00:00
#SBATCH --mem-per-cpu=10G
#SBATCH --cpus-per-task=1

# Start with e.g.
# sbatch find_orthologs_nuclear.slurm ../data/queries/nuclear/exons.fasta ../data/subjects/nuclear.txt ../analysis/alignments/nuclear/01/

# Abel setup.
source /cluster/bin/jobsetup
module load python3/3.5.0
module load blast+/2.2.29
module load mafft/7.300

# Get command line arguments.
queries_file_name_w_path=$1
queries_file_name=`basename ${queries_file_name_w_path}`
subject_file_name_w_path=$2
subjects_file_name=`basename ${subject_file_name_w_path}`
alignment_dir_out=`readlink -f ${3}`

# Copy script to scratch.
echo -n "Copying file find_orthologs.py..."
cp find_orthologs.py $SCRATCH
echo " done."

# Copy input to scratch.
echo -n "Copying input files..."
cp $queries_file_name_w_path $SCRATCH
cp $subject_file_name_w_path $SCRATCH
echo " done."

# Make the alignment output directory if it doesn't exist yet.
mkdir -p ${alignment_dir_out}

cd $SCRATCH

# Run find_orthologs.py for each marker, with each of the subjects.
echo -n "Running find_orthologs.py..."
python3 find_orthologs.py -t --refine -s 1 ${queries_file_name} ${subjects_file_name}
echo " done."

# Copy fasta files to alignment directory.
echo -n "Copying alignment files back to the submission directory..."
rm ${queries_file_name}
cp *.fasta ${alignment_dir_out}
echo " done."
