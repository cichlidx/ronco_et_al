# m_matschiner Fri May 5 14:25:37 CEST 2017

# Load the mafft module.
module load mafft/7.300

# Make the output directory if it doesn't exist yet.
mkdir -p ../res/alignments

# Concatenate all fasta files into a single file.
echo ">orenil2" > tmp.fasta
cat ../data/reference/orenil2.NC_013663.fasta | tail -n +2 >> tmp.fasta
for i in ../res/fasta/*.fasta
do
    specimen_id=`basename ${i%.NC_013663.fasta}`
    echo ">${specimen_id}"
    cat $i | tail -n +2
done >> tmp.fasta

# Align all mitochondrial sequences.
mafft --thread 10 --auto tmp.fasta > ../res/alignments/NC_013663.fasta

# Clean up.
rm tmp.fasta