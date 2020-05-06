# m_matschiner Sun Sep 3 19:49:36 CEST 2017

# Calculate vcf stats with bcftools.
for vcf_with_relative_path in ../res/gatk/strict.vcf.gz ../res/gatk/permissive.vcf.gz
do
    if [ -f ${vcf_with_relative_path} ]
    then
        filter=`basename ${vcf_with_relative_path%.vcf.gz}`
        stats_with_relative_path="${vcf_with_relative_path%.vcf.gz}.stats"
        if [ ! -f ${stats_with_relative_path} ]
        then
            out="../log/miscellaneous/stats.${filter}.out"
            rm -f ${out}
            sbatch -o ${out} get_vcf_stats.slurm ${vcf_with_relative_path} ${stats_with_relative_path}
        fi
    fi
done
