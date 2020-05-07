# m_matschiner Fri Aug 17 12:10:41 CEST 2018

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    have_been_waiting=false
    while [ $n_jobs -gt 200 ]
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

# Load the bcftools and htslib modules.
module load bcftools/1.6

# Make the results directories.
for window_size in 5000
do
    for chromosome_id in NC_0319{65..87} UNPLACED
    do
        mkdir -p ../res/windows/${window_size}bp/${chromosome_id}
    done
done

# Make the log directories.
for window_size in 5000
do
    for chromosome_id in NC_0319{65..87} UNPLACED
    do
        mkdir -p ../log/windows/${window_size}bp/${chromosome_id}/raxml
    done
done

# Specify the vcf file.
gzvcf=../data/vcf/permissive.phased.vcf.gz

# Specify the reference.
masked_ref=../data/reference/orenil2.masked.permissive.fasta
unmasked_ref=../data/reference/orenil2.sequential.fasta

# Specify the sample table.
sample_table=../data/tables/DNATube_2018-02-13_13-43.tsv

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

# Set thresholds for the proportion of missing data and for the standard deviation of it.
missing_threshold_overall=0.7
missing_threshold_stdev=0.02 

# Start an analysis for each chromosome and for each window size.
for window_size in 5000
do
    for chromosome_id in NC_0319{65..87} UNPLACED
    do
        # Set the window start and end positions.
        from=1
        (( to = ${from} + ${window_size} - 1 ))
    
        # Get the chromosome length.
        chr_length=`cat ../data/tables/chr_lengths.txt | grep ${chromosome_id} | cut -f 2`

        # Start an analysis for each window on this chromosome.
        while [ ${to} -lt ${chr_length} ]
        do
            # Specify the region.
            region="${chromosome_id}:${from}-${to}"

            # Specify the tree and log files (not the info file) resulting from the raxml run.
            tree=../res/windows/${window_size}bp/${chromosome_id}/${chromosome_id}_${from}_${to}.raxml.tre
            info=../res/windows/${window_size}bp/${chromosome_id}/${chromosome_id}_${from}_${to}.info.txt
            out=../log/windows/${window_size}bp/${chromosome_id}/raxml/${chromosome_id}_${from}_${to}.out
            rm -f ${out}
            log=../log/windows/${window_size}bp/${chromosome_id}/raxml/${chromosome_id}_${from}_${to}.log
            rm -f ${log}

            # Calculate completeness, remove low-signal sites with bmge, then run raxml if completeness is sufficient.
            run_raxml=false
            if [ ! -f ${info} ] # Run raxml if the info file does not exist yet.
            then
                run_raxml=true
            else
                raxml_launched=`cat ${info} | grep "raxml_launched:yes" | wc -l`
                if [ ${raxml_launched} == 0 ] # Run raxml if the info file does not indicate that raxml has been launched before.
                then
                    run_raxml=true
                fi
            fi
            if [ ${run_raxml} == true ]
            then
                if [ ! -f ${info} ]
                then
                    proportion_missing_calculated=0
                else
                            proportion_missing_calculated=`cat ${info} | grep "proportion_missing:" | wc -l`
                fi
                if [ ${proportion_missing_calculated} == 0 ]
                then
                    sbatch -o ${out} run_raxml_for_window.slurm ${gzvcf} ${region} ${masked_ref} ${unmasked_ref} ${sample_table} ${callability_mask_dir} ${exclude_str} ${missing_threshold_overall} ${missing_threshold_stdev} ${tree} ${log} ${info}
                else
                    proportion_missing=`cat ${info} | grep "proportion_missing:" | cut -d ":" -f 2`
                    if (( $(echo "${proportion_missing} > ${missing_threshold_overall}" | bc -l) ))
                    then
                        echo "Skipping window ${region} due to large overall proportion of missing data (${proportion_missing})."
                    else
                        proportion_missing_stdev=`cat ${info} | grep "proportion_missing_stdev:" | cut -d ":" -f 2`
                        if (( $(echo "${proportion_missing_stdev} > ${missing_threshold_stdev}" | bc -l) ))
                        then
                            echo "Skipping window ${region} due to large standard deviation of the proportion of missing data (${proportion_missing_stdev})."
                        else
                            sbatch -o ${out} run_raxml_for_window.slurm ${gzvcf} ${region} ${masked_ref} ${unmasked_ref} ${sample_table} ${callability_mask_dir} ${exclude_str} ${missing_threshold_overall} ${missing_threshold_stdev} ${tree} ${log} ${info}
                        fi
                    fi
                fi
                sleep_while_too_busy

            else
                echo "Skipping window ${region} because raxml has been run before for this window."
            fi

            # Shift the window.
            (( from = ${to} + 1 ))
            (( to = ${to} + ${window_size} ))

        done
    done
done
