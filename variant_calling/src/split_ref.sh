# michaelm Sun Mar 12 12:21:40 CET 2017

# Use fastagrep to split the edited reference (which was done with convert_ref.rb) into individual linkage groups.
for i in `cat ../data/reference/GCF_001858045.1_ASM185804v2_genomic_edit.fna | grep ">" | sed 's/>//g'`
do
    echo $i
    ./fastagrep -t -p $i ../data/reference/GCF_001858045.1_ASM185804v2_genomic_edit.fna > ../data/reference/orenil2_$i.fasta
done