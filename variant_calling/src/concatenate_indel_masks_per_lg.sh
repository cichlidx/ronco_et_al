# m_matschiner Sun Jan 7 12:42:23 CET 2018

# Set variables.
filter="strict"

# Concatenate all bed files per linkage group.
for lg in NC_0319{65..87} UNPLACED
do
    echo -n "Concatenating bed files for lg ${lg}..."
    rm -f ../res/gatk/${lg}.${filter}.indels.bed
    cp ../res/gatk/${lg}.1_1000000.${filter}.indels.bed ../res/gatk/${lg}.${filter}.indels.bed
    cat ../res/gatk/${lg}.1000001_2000000.${filter}.indels.bed | grep -v "chrom" >> ../res/gatk/${lg}.${filter}.indels.bed
    cat ../res/gatk/${lg}.2000001_3000000.${filter}.indels.bed | grep -v "chrom" >> ../res/gatk/${lg}.${filter}.indels.bed
    cat ../res/gatk/${lg}.3000001_4000000.${filter}.indels.bed | grep -v "chrom" >> ../res/gatk/${lg}.${filter}.indels.bed
    cat ../res/gatk/${lg}.4000001_5000000.${filter}.indels.bed | grep -v "chrom" >> ../res/gatk/${lg}.${filter}.indels.bed
    cat ../res/gatk/${lg}.5000001_6000000.${filter}.indels.bed | grep -v "chrom" >> ../res/gatk/${lg}.${filter}.indels.bed
    cat ../res/gatk/${lg}.6000001_7000000.${filter}.indels.bed | grep -v "chrom" >> ../res/gatk/${lg}.${filter}.indels.bed
    cat ../res/gatk/${lg}.7000001_8000000.${filter}.indels.bed | grep -v "chrom" >> ../res/gatk/${lg}.${filter}.indels.bed
    cat ../res/gatk/${lg}.8000001_9000000.${filter}.indels.bed | grep -v "chrom" >> ../res/gatk/${lg}.${filter}.indels.bed
    cat ../res/gatk/${lg}.9000001_10000000.${filter}.indels.bed | grep -v "chrom" >> ../res/gatk/${lg}.${filter}.indels.bed
    for i in ../res/gatk/${lg}.????????_????????.${filter}.indels.bed
    do
        cat ${i} | grep -v "chrom" >> ../res/gatk/${lg}.${filter}.indels.bed
    done
    if [ ${lg} == "UNPLACED" ]
    then
        cat ../res/gatk/${lg}.99000001_100000000.${filter}.indels.bed | grep -v "chrom" >> ../res/gatk/${lg}.${filter}.indels.bed
        for i in ../res/gatk/${lg}.?????????_?????????.${filter}.indels.bed
        do
            cat ${i} | grep -v "chrom" >> ../res/gatk/${lg}.${filter}.indels.bed
        done
    fi
    echo " done."
done
