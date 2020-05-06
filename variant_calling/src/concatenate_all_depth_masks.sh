# m_matschiner Tue Apr 3 13:11:55 CEST 2018

# Concatenate bed files with depth data over all samples.
all_samples_depth_mask_file_name="../res/gatk/depth.bed"
if [ ! -f ${all_samples_depth_mask_file_name} ]
then
    cp ../res/gatk/NC_031965.depth.bed ${all_samples_depth_mask_file_name}
    for lg in NC_0319{66..87} UNPLACED
    do
        cat ../res/gatk/${lg}.depth.bed | tail -n +2 >> ${all_samples_depth_mask_file_name}
    done
fi

# Concatenate bed files per individual.
first_sample_depth_mask_file_name="../res/gatk/A108.depth.bed"
if [ ! -f ${first_sample_depth_mask_file_name} ] # if the first file is there assume all others are, too.
then
    for i in ../res/gatk/*.NC_031965.depth.bed
    do
        spc=`basename ${i} | cut -d "." -f 1`
        echo ${spc}
        per_sample_depth_mask_file_name="../res/gatk/${spc}.depth.bed"
        cp ../res/gatk/${spc}.NC_031965.depth.bed ${per_sample_depth_mask_file_name}
        for lg in NC_0319{66..87} UNPLACED
        do
            cat ../res/gatk/${spc}.${lg}.depth.bed | tail -n +2 >> ${per_sample_depth_mask_file_name}
        done
    done
fi