# m_matschiner Thu May 3 17:18:23 CEST 2018

# Set the name of the sample table.
sample_table=../data/tables/DNATube_2018-02-13_13-43.tsv

for filter in strict permissive
do
    for lg in NC_0319{65..87} UNPLACED
    do
        in_gzvcf=../res/beagle/${lg}.${filter}.3.vcf.gz
        file_id=`basename ${in_gzvcf%.3.vcf.gz}`
        out_gzvcf=../res/beagle/${lg}.${filter}.phased.vcf.gz

        # Build a string for trios for which the phasing should be improved,
        # assuming that the second species in each list is a hybrid of the other two.
        trios_string=""
        for trio in "Altfas,Neocan,Telvit"
        do
            trios_string="${trios_string} ${trio}"
        done

        # Fix the phasing of each trio.
        out="../log/miscellaneous/fix_phasing.${file_id}.out"
        if [ ! -f ${out_gzvcf} ]
        then
            rm -f ${out}
            sbatch -o ${out} fix_hybrid_phasing.slurm ${in_gzvcf} ${sample_table} ${out_gzvcf} ${trios_string}
        fi
    done
done