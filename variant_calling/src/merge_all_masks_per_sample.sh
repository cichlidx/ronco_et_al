# m_matschiner Tue Apr 24 09:29:37 CEST 2018

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    while [ $n_jobs -gt 355 ]
    do
        sleep 10
        n_jobs=`squeue -u michaelm | wc -l`
    done
}

# Set the name of the depth mask bed file.
depth_mask="../res/gatk/depth.bed"

# Merge masks separately for the strict and permissive filters.
for filter in strict permissive
do
    # Set the names of indel and mappability mask bed files.
    if [ ${filter} == "strict" ]
    then
        indel_mask="../res/gatk/strict.indels.bed"
        mappability_mask="../data/masks/mapability_mask_100_95.bed"
    elif [ ${filter} == "permissive" ]
    then
        indel_mask="../res/gatk/strict.indels.bed" # a permissive indel mask was not generated, it would be equal to this one.
        mappability_mask="../data/masks/mapability_mask_100_90.bed"
    fi

    # Merge masks for each sample.
    for bed in ../res/gatk/{[A-L],Z}*.depth.bed
    do
        sample_id=`basename ${bed%.depth.bed}`
        merged_gzbed=${bed%.depth.bed}.${filter}.merged.bed.gz
    if [ ! -f ${merged_gzbed} ]
    then
        out="../log/miscellaneous/merge_masks.${sample_id}.out"
        sbatch -o ${out} merge_all_masks_per_sample.slurm ${depth_mask} ${indel_mask} ${mappability_mask} ${bed} ${merged_gzbed}
        sleep_while_too_busy
    fi
    done

done