# m_matschiner Tue Nov 6 11:53:01 CET 2018

# Merge kollector and atram assemblies with celera assemlies.
mkdir -p ../data/subjects/local/merged
while read line
do
    specimen=`echo ${line} | tr -s " " | cut -d " " -f 2`
    species=`echo ${line} | tr -s " " | cut -d " " -f 1`
    cat ../data/subjects/local/*/${specimen}*.fasta > ../data/subjects/local/merged/${species}.fasta
done < ../data/tables/cichlid_specimens.txt