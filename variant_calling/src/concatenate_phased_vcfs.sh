# m_matschiner Mon Apr 23 15:14:40 CEST 2018

# Concatenate phased vcf files.
for filter in strict permissive
do
    gzvcf_dir="../res/beagle"
    gzvcf_suffix="${filter}.phased.vcf.gz"
    merged_gzvcf="${gzvcf_dir}/${gzvcf_suffix}"
    if [ ! -f ${merged_gzvcf} ]
    then
        out="../log/miscellaneous/concatenate_phased.${filter}.out"
        rm -f ${out}
        sbatch -o ${out} concatenate_phased_vcfs.slurm ${gzvcf_dir} ${gzvcf_suffix} ${merged_gzvcf}
    fi
done