# m_matschiner Thu Mar 29 10:30:06 CEST 2018

# Make the log directory if it doesn't exist yet.
mkdir -p ../log/misc

# Make thinned vcf files containing only unlinked snps.
for filter in strict permissive
do
    gzvcf_with_relative_path="../data/vcf/${filter}.phased.vcf.gz"
    for completeness_in_percent in 50 60 70 80
    do
        completeness=$(echo "scale=2; ${completeness_in_percent}/100" | bc)
        subset_gzvcf_with_relative_path="../data/vcf/${filter}.c${completeness_in_percent}.vcf.gz"
        if [ ! -f ${subset_gzvcf_with_relative_path} ]
        then
            out="../log/misc/subset.${filter}.c${completeness_in_percent}.out"
            rm -f ${out}
            sbatch -o ${out} make_vcf_subset_by_completeness.slurm ${gzvcf_with_relative_path} ${subset_gzvcf_with_relative_path} ${completeness}
        fi
    done
done