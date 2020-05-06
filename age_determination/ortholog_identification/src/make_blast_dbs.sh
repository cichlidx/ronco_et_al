# m_matschiner Wed Nov 7 00:55:47 CET 2018

# Load the blast module.
module load blast+/2.2.29

# Make a blast database for each fasta subject.
for i in ../data/subjects/combined/*.fasta
do
    if [ ! -f ${i}*.nhr ]
    then
	makeblastdb -in ${i} -dbtype nucl
    fi
done