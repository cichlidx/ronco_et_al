# m_matschiner Tue Oct 2 11:59:01 CEST 2018

# Load the blast module.
module load blast+/2.2.29

# Make blast databases for each cdna fasta file in the data directory.
for i in ../data/subjects/*.cdna.fasta
do
    if [ ! -f ${i}.nhr ]
    then
    	makeblastdb -in ${i} -dbtype nucl
    fi
done
ls ../data/subjects/*.cdna.fasta | rev | cut -d "/" -f 1 | rev > ../data/subjects/databases.txt