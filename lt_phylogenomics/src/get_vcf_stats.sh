# m_matschiner Tue Apr 3 11:54:26 CEST 2018

# Calculate vcf stats with bcftools.
for gzvcf_with_relative_path in ../data/vcf/f?.c?0.vcf.gz
do
    filter=`basename ${gzvcf_with_relative_path%.vcf.gz}`
    stats_with_relative_path="${gzvcf_with_relative_path%.vcf.gz}.stats"
    if [ ! -f ${stats_with_relative_path} ]
    then
        out="../log/misc/stats.${filter}.out"
        rm -f ${out}
        sbatch -o ${out} get_vcf_stats.slurm ${gzvcf_with_relative_path} ${stats_with_relative_path}
    fi
done
