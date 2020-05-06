# m_matschiner Sun Sep 3 19:49:36 CEST 2017

# Define a function to sleep if any freqs jobs are queued or running.
function sleep_while_busy {
    n_freqs_jobs=`squeue -u michaelm | grep freqs | wc -l`
    while [ $n_freqs_jobs -gt 0 ]
    do
        sleep 10
        n_freqs_jobs=`squeue -u michaelm | grep freqs | wc -l`
    done
}

# Use vcftools to calculate allele frequencies.
for vcf_with_relative_path in ../res/gatk/strict.vcf.gz ../res/gatk/permissive.vcf.gz
do
    if [ -f ${vcf_with_relative_path} ]
    then
        id=`basename ${vcf_with_relative_path%.vcf.gz}`
        freqs_with_relative_path="${vcf_with_relative_path%.vcf.gz}.freqs"
        if [ ! -f ${freqs_with_relative_path} ]
        then
            out="../log/miscellaneous/freqs.${id}.out"
            rm -f ${out}
            sbatch -o ${out} get_vcf_freqs.slurm ${vcf_with_relative_path}
            sleep_while_busy
            mv out.frq ${freqs_with_relative_path}
            rm -f out.txt
        fi
    fi
done
