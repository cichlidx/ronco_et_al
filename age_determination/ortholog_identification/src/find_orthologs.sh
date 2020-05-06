# m_matschiner Tue Nov 6 23:51:52 CET 2018

# Make the output directory.
mkdir -p ../res/alignments/nuclear/01

# Make the log directory.
mkdir -p ../log/misc/

# Generate a list of all subject sequence fasta files
# (use readlink and -d so that the absolute paths are specified).
ls -d `readlink -f ../data/subjects/combined/`/orylat.fasta > ../data/subjects/combined/subjects.txt
ls -d `readlink -f ../data/subjects/combined/`/*.fasta | grep -v "orylat" >> ../data/subjects/combined/subjects.txt

# Split the query file into a suitable number of files.
split -a 3 -l 200 -d ../data/queries/orylat_exons.fasta orylat_exons_
for i in orylat_exons_*
do
    mv -f ${i} ../data/queries/${i}.fasta
done

# Search for orthologs to all queries in all subject sequences.
for i in ../data/queries/orylat_exons_*.fasta
do
    exon_set_id=`basename ${i%.fasta}`
    out=../log/misc/find_orthologs.${exon_set_id}.out
    rm -f ${out}
    sbatch -o ${out} find_orthologs.slurm ${i} ../data/subjects/combined/subjects.txt ../res/alignments/nuclear/01/
done
