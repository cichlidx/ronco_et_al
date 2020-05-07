# m_matschiner Tue Mar 27 15:43:03 CEST 2018

# Make the log directory if it doesn't exist yet.
mkdir -p ../log/misc

# Make thinned vcf files containing only unlinked snps.
for gzvcf_with_relative_path in ../data/vcf/{strict,permissive}.c60.vcf.gz ../data/vcf/{strict,permissive}.c60.sub1.vcf.gz
do
    if [ -f ${gzvcf_with_relative_path} ]
    then
        file_id=`basename ${gzvcf_with_relative_path%.vcf.gz}`
        thinned_gzvcf_with_relative_path="../data/vcf/${file_id}.thin.vcf.gz"
        if [ ! -f ${thinned_gzvcf_with_relative_path} ]
        then
            out="../log/misc/thin.${file_id}.out"
            rm -f ${out}
            sbatch -o ${out} make_thinned_vcf.slurm ${gzvcf_with_relative_path} ${thinned_gzvcf_with_relative_path} 100
        fi
    fi
done
