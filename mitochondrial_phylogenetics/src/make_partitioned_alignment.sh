# m_matschiner Fri May 5 17:45:35 CEST 2017

# Load the ruby and python modules.
module load ruby/2.1.5
module load python3/3.5.0

# Remove previously generated nexus and phylip files.
rm -f ../res/alignments/*.{nex,phy}

# Use convert.py to turn the gene alignments into nexus format.
for i in ../res/alignments/{ATP,COX,CYTB,ND}*.fasta
do
    python3 convert.py -f nexus ${i} ${i%.fasta}.nex
done

# Use split_by_cp.rb to split each gene alignment by codon position.
for i in ../res/alignments/*.nex
do
    ruby split_by_cp.rb -i ${i}
done

# Concatenate all alignments for the 1st, 2nd, and 3rd codon position.
for i in 1 2 3
do
    ruby concatenate.rb -f nexus -o ../res/alignments/cp${i}.nex -i ../res/alignments/*_${i}.nex
done

# Make a single concatenated phylip file with partitions for raxml.
sites_per_partition=`head -n 4 ../res/alignments/cp1.nex | tail -n 1 | cut -d "=" -f 3 | sed 's/;//g'`
ruby concatenate.rb -f phylip -o ../res/alignments/NC_013663.partitioned.phy -i ../res/alignments/cp?.nex

echo "DNA, cp1 = 1-${sites_per_partition}" > ../res/alignments/NC_013663.partitions.txt
echo "DNA, cp2 = $((sites_per_partition+1))-$((2*sites_per_partition))" >> ../res/alignments/NC_013663.partitions.txt
echo "DNA, cp3 = $((2*sites_per_partition+1))-$((3*sites_per_partition))" >> ../res/alignments/NC_013663.partitions.txt