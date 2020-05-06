# m_matschiner Mon Jun 18 17:48:05 CEST 2018

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
    else
        echo "ERROR: Unexpected filter: ${filter}!"
        exit 1
    fi

    # Set the name of the merged output bed file.
    merged_gzbed=../res/gatk/${filter}.uncallable.bed.gz

    # Merge the masks.
    if [ ! -f ${merged_gzbed} ]
    then
        out="../log/miscellaneous/merge_masks.${filter}.out"
        sbatch -o ${out} merge_all_masks_all_samples.slurm ${depth_mask} ${indel_mask} ${mappability_mask} ${merged_gzbed}
    fi

done