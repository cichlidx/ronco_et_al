# m_matschiner Mon Jul 23 00:40:36 CEST 2018

# Make the result directory.
mkdir -p ../res/tables

# Load the blast module.
module load blast+/2.6.0

# Get the regions of orthologs in the orylat assembly.
for alignment in ../res/alignments/nuclear/06/*.fasta
do
    alignment_id=`basename ${alignment%_nucl.fasta}`
    echo -ne "${alignment_id}\t"
    cat ${alignment} | grep -A 1 orylat > tmp.fasta
    blastn -query tmp.fasta -db ../data/subjects/combined/orylat.fasta -culling_limit 1 -num_alignments 1 -max_hsps 1 -outfmt "6 sseqid pident sstart send" 2> /dev/null
    echo
done | sed '/^$/d' > ../res/tables/orylat_ortholog_regions.txt