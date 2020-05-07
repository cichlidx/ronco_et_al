# m_matschiner Wed Jun 13 09:38:51 CEST 2018

# Make the log directory if it doesn't exist yet.
mkdir -p ../log/misc

# Define the samples to be removed.
samples_string="Bel33"

# Make subsets of the vcf files by removing certain samples.
for filter in strict permissive
do
    for completeness_in_percent in 60
    do
        gzvcf_with_relative_path="../data/vcf/${filter}.c${completeness_in_percent}.vcf.gz"
        if [ -f ${gzvcf_with_relative_path} ]
        then
            subset_gzvcf_with_relative_path=../data/vcf/${filter}.c${completeness_in_percent}.sub1.vcf.gz
            if [ ! -f ${subset_gzvcf_with_relative_path} ]
            then
                out="../log/misc/subset_by_samples.${filter}.c${completeness_in_percent}.out"
                rm -f ${out}
                sbatch -o ${out} make_vcf_subset_by_samples.slurm ${gzvcf_with_relative_path} ${subset_gzvcf_with_relative_path} ${samples_string}
            fi
        fi
    done
done