# m_matschiner Sun Sep 3 15:07:20 CEST 2017

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    while [ $n_jobs -gt 300 ]
    do
        sleep 10
        n_jobs=`squeue -u michaelm | wc -l`
    done
}

# Generate filtered versions of all vcf files.
for i in ../res/gatk/{NC_,UN}??????.[0-9]*_*[0-9][0-9].vcf.gz
do
    window_id=`basename ${i%.vcf.gz}`
    vcfgz=${i}
    filtered_vcfgz=${vcfgz%.vcf.gz}.strict.vcf.gz
    if [ ! -f ${filtered_vcfgz} ]
    then
    	out=../log/gatk/filter.${window_id}.strict.out
    	log=../log/gatk/filter.${window_id}.strict.log
    	# Remove log files if they exist already.
        rm -f ${out}
        rm -f ${log}
    	sbatch -o ${out} apply_strict_filter.slurm ${vcfgz} ../data/reference/orenil2.fasta ../data/masks/mapability_mask_100_95.bed ${filtered_vcfgz} ${log}
    	sleep_while_too_busy
    fi
done