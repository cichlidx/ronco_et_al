# m_matschiner Sun Jan 7 13:12:27 CET 2018

# Set variables.
filter="strict"

# Remove the result file if it exists already.
rm -f ../res/gatk/${filter}.indels.bed

# Concatenate bed files for all linkage groups.
cp ../res/gatk/NC_031965.${filter}.indels.bed ../res/gatk/${filter}.indels.bed
for i in ../res/gatk/NC_0319{66..87}.${filter}.indels.bed ../res/gatk/UNPLACED.${filter}.indels.bed
do
    cat ${i} | grep -v "chrom" >> ../res/gatk/${filter}.indels.bed
done
