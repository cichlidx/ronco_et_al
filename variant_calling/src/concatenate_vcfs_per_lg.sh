# m_matschiner Sun Sep 3 19:49:36 CEST 2017

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    have_been_waiting=false
    while [ $n_jobs -gt 355 ]
    do
        have_been_waiting=true
        echo -ne "\rWaiting for job capacity..."
        sleep 60
        n_jobs=`squeue -u michaelm | wc -l`
    done
    if [ ${have_been_waiting} == true ]
    then
        echo " done."
    fi
}

# Specify the name of the reference file.
ref="../data/reference/orenil2.fasta"

# Start a slurm script for each linkage group to concatenate all vcfs of that linkage group.
for filter in strict permissive
do
    if [ ${filter} == strict ] || [ ${filter} == permissive ]
    then
    for lg in NC_0319{65..87} UNPLACED
    do
        if [ ! -f ../res/gatk/${lg}.${filter}.vcf.gz ]
        then
            out="../log/miscellaneous/concatenate.${lg}.${filter}.out"
            rm -f ${out}
            sbatch -o ${out} concatenate_vcfs_per_lg.slurm ${lg} ${filter} ${ref}
            sleep_while_too_busy
        fi
    done
    fi
done