# michaelm Wed Mar 8 00:08:44 CET 2017

# Set the data directory.
data_dir="../res/mapping/"

# Read the list of bam files in the data directory.
bams_with_relative_path=`ls ${data_dir}*.sorted.dedup.realn.rgadd.bam`

# Produce a list of unique sample identifiers.
truncated_bams_with_relative_path=()
for bam_with_relative_path in ${bams_with_relative_path[@]}
do
    split_ary=(${bam_with_relative_path//_/ })
    split_ary_size=(${#split_ary[@]})
    trim_part=${split_ary[$split_ary_size-1]}
    truncated_bam_with_relative_path=${bam_with_relative_path%_$trim_part}
    truncated_bams_with_relative_path+=($truncated_bam_with_relative_path)
done
unique_truncated_bams_with_relative_path=$(echo "${truncated_bams_with_relative_path[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

# For each item in that list, start merging with all bam files that match that item.
for unique_truncated_bam_with_relative_path in ${unique_truncated_bams_with_relative_path[@]}
do
    infiles=(`ls ${unique_truncated_bam_with_relative_path}_*.sorted.dedup.realn.rgadd.bam`)
    number_of_infiles=(${#infiles[@]})
    # If the individual has sequence data for only a single library, just give it a new name.
    if [ ${number_of_infiles} -eq 1 ]
    then
    if [ ! -f ${unique_truncated_bam_with_relative_path}.merged.sorted.dedup.realn.bam ]
    then
        mv -v ${infiles[0]} ${unique_truncated_bam_with_relative_path}.merged.sorted.dedup.realn.bam
        mv -v ${infiles[0]}.bai ${unique_truncated_bam_with_relative_path}.merged.sorted.dedup.realn.bam.bai
    fi
    # If not, merge all sequence files for this individual.
    else
        unique_truncated_bam=`basename ${unique_truncated_bam_with_relative_path}`
        out=merge.${unique_truncated_bam}.out
        sbatch -o ${out} merge.slurm ../data/reference/orenil2.fasta ${unique_truncated_bam_with_relative_path}*.sorted.dedup.realn.rgadd.bam
    fi
done