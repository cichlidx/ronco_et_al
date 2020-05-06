# m_matschiner Mon Mar 19 14:37:15 CET 2018

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    while [ $n_jobs -gt 355 ]
    do
        sleep 10
        n_jobs=`squeue -u michaelm | wc -l`
    done
}

# Generate filtered versions of all vcf files.
for i in ../res/gatk/*.{NC_0319??,UNPLACED}.g.vcf.gz
do
    id=`basename ${i%.g.vcf.gz}`
    gvcfgz_with_relative_path=${i}
    dump_with_relative_path="${i%.g.vcf.gz}.dmp"
    if [ ! -f ${dump_with_relative_path} ]
    then
        out=../log/gatk/depth.${id}.out
        # Remove log files if they exist already.
        rm -f ${out}
        sbatch -o ${out} get_depth_from_gvcf.slurm ${gvcfgz_with_relative_path} ${dump_with_relative_path}
        sleep_while_too_busy
    fi
done