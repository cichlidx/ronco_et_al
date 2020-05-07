# m_matschiner Wed Oct 10 19:31:06 CEST 2018

# Load the bcftools module.
module load bcftools/1.6

# Make the log directories.
for window_size in 5000
do
    mkdir -p ../log/windows/${window_size}bp/stats
done

# Specify the vcf file.
gzvcf=../data/vcf/permissive.phased.vcf.gz

# Specify the reference.
masked_ref=../data/reference/orenil2.masked.permissive.fasta
unmasked_ref=../data/reference/orenil2.sequential.fasta

# Specify the directory with callability masks.
callability_mask_dir=../data/masks

# Make sure that callability masks are in bgzip format and indexed; reformat and index if they are not.
for i in ../data/masks/*bed*gz
do
    file_id=`basename ${i%.bgz}`
    file_id=${file_id%.gz}
    bgzip=../data/masks/${file_id}.bgz
    if [ ! -f ${bgzip} ]
    then
        echo -n "Generating the bed file ${bgzip}..."
        gunzip -c ${i} | bgzip > ${bgzip}
        echo " done."
    fi
    if [ ! -f ${bgzip}.tbi ]
    then
        echo -n "Indexing the bed file ${bgzip}..."
        tabix -p bed ${bgzip}
        echo " done."
    else
        touch ${bgzip}.tbi
    fi
done

# Define samples to be excluded.
exclude_str="Bel33,LJD1,LJC9"

# Set a threshold for the maximum robinson-foulds distance.
max_rf_distance=700

# Start an analysis for each chromosome and for each window size.
for window_size in 5000
do
    # Make window alignments and get stats for it.
    for chromosome_id in NC_0319{65..87} UNPLACED
    do
        # Set the directory with tree and info files for this chromosome.
        tree_dir=../res/windows/${window_size}bp/${chromosome_id}

        # Set the log file names.
        out=../log/windows/${window_size}bp/stats/${chromosome_id}.out
        rm -f ${out}
        log=../log/windows/${window_size}bp/stats/${chromosome_id}.log
        rm -f ${log}

        # Extract alignments for this chromosome.
        sbatch -o ${out} extract_alignments.slurm ${gzvcf} ${tree_dir} ${max_rf_distance} ${masked_ref} ${unmasked_ref} ${callability_mask_dir} ${exclude_str} ${log}
    done
done
