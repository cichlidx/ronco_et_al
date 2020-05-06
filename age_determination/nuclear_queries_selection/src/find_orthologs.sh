# m_matschiner Mon Oct 15 15:09:33 CEST 2018

# Make the output directory if it doesn't exist yet.
mkdir -p ../res/queries/orenil2

# Make the log directory if it doesn't exist yet.
mkdir -p ../log/misc

# Split the query file into a suitable number of files.
rm -f exons_??.fasta
split -l 600 -d ../res/queries/orylat_exons_miss0.fasta orylat_exons_miss0_
for i in orylat_exons_miss0_??
do
    mv -f ${i} ../res/queries/${i}.fasta
done

# Search for orthologs to orylat queries in orenil2.
for query in ../res/queries/orylat_exons_miss0_??.fasta
do
    exon_set_id=`basename ${i%.fasta}`
    out=../log/misc/find_orthologs.${exon_set_id}.out
    rm -f ${out}
    sbatch -o ${out} find_orthologs.slurm ${query} `readlink -f ../data/subjects/orenil2.fasta` ../res/queries/orenil2
done

