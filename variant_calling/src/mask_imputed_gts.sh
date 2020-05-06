# m_matschiner Thu Apr 12 21:21:13 CEST 2018

# Make the log directory if it doesn't exist yet.
mkdir -p ../log/miscellaneous

# Mask imputed genotypes based on unimputed vcfs.
for filter in strict permissive
do
    for lg in NC_0319{65..87} UNPLACED
    do
        unimputed_gzvcf="../res/gatk/${lg}.${filter}.vcf.gz"
        imputed_gzvcf="../res/beagle/${lg}.${filter}.2.vcf.gz"
        masked_gzvcf="../res/beagle/${lg}.${filter}.3.vcf.gz"
        if [ ! -f ${unimputed_gzvcf} ]
        then
            echo "ERROR: File ${unimputed_gzvcf} cannot be found!"
            exit 1
        elif [ ! -f ${imputed_gzvcf} ]
        then
            echo "WARN: File ${imputed_gzvcf} cannot be found!"
        elif [ ! -f ${masked_gzvcf} ]
        then
            out="../log/miscellaneous/mask_imputed_gts.${lg}.out"
            rm -rf ${out}
            if [ ${lg} == NC_031972 ]
            then
                sbatch --mem-per-cpu=20G -o ${out} mask_imputed_gts.slurm ${unimputed_gzvcf} ${imputed_gzvcf} ${masked_gzvcf}
            else
                sbatch -o ${out} mask_imputed_gts.slurm ${unimputed_gzvcf} ${imputed_gzvcf} ${masked_gzvcf}
            fi
        fi
    done
done