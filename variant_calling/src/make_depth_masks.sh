# m_matschiner Tue Apr 3 11:39:04 CEST 2018

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    while [ $n_jobs -gt 359 ]
    do
        sleep 10
        n_jobs=`squeue -u michaelm | wc -l`
    done
}

# Read the per-lg dump files including depth information summed across all samples and make a mask in bed file from it.
min_dp=4000
max_dp=8000
for lg in NC_0319{65..87} UNPLACED
do
    if [ ! -f ../res/gatk/${lg}.depth.bed ]
    then
	out="../log/miscellaneous/depth_mask.${lg}.out"
	rm -rf ${out}
	sbatch -o ${out} make_depth_mask.slurm ../res/gatk/${lg}.dmp ${min_dp} ${max_dp}
    fi
    sleep_while_too_busy
done

# Read the per-lg dump files including depth information per samples and make a mask in bed file from it.
min_dp=4
max_dp=8000
acct="nn9244k"
for dmp in ../res/gatk/*.{NC_0319??,UNPLACED}.dmp
do
    if [ ! -f ${dmp%.dmp}.depth.bed ]
    then
	file_id=`basename ${dmp%.dmp}`
        out="../log/miscellaneous/depth_mask.${file_id}.out"
        rm -rf ${out}
        sbatch -o ${out} make_depth_mask.slurm ${dmp} ${min_dp} ${max_dp}
    fi
    sleep_while_too_busy
done
