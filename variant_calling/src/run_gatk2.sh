# m_matschiner Thu May 4 12:24:07 CEST 2017

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    while [ $n_jobs -gt 350 ]
    do
    sleep 10
    n_jobs=`squeue -u michaelm | wc -l`
    done
}

# Define a function to sleep if any unc_idx jobs are queued or running.
function sleep_while_busy {
    n_unc_idx_jobs=`squeue -u michaelm | grep unc_idx | wc -l`
    while [ $n_unc_idx_jobs -gt 0 ]
    do
        sleep 10
        n_unc_idx_jobs=`squeue -u michaelm | grep unc_idx | wc -l`
    done
}

# Make a log directory if it doesn't exist yet.
mkdir -p ../log/prepare

# Get the command-line arguments.
chromosome_id=$1
from=$2
to=$3
list_file=$4

if [ ! -z ${list_file} ]
then
    if [ -f ${list_file} ]
    then
        tribe_name=`basename ${list_file%.txt}`
        vcfgz="../res/gatk/${chromosome_id}.${tribe_name}.${from}_${to}.vcf.gz"
        log="../log/gatk/run_gatk2.${chromosome_id}.${tribe_name}.${from}_${to}.log"
        out="../log/gatk/run_gatk2.${chromosome_id}.${tribe_name}.${from}_${to}.out"
        list=`cat ${list_file}`
    gvcf_string=`for i in ${list}; do echo -n "../res/gatk/${i}.${chromosome_id}.g.vcf "; done`
    else
        echo "ERROR: File ${list_file} could not be found!"
        exit 1
    fi
else
    vcfgz="../res/gatk/${chromosome_id}.${from}_${to}.vcf.gz"
    log="../log/gatk/run_gatk2.${chromosome_id}.${from}_${to}.log"
    out="../log/gatk/run_gatk2.${chromosome_id}.${from}_${to}.out"
    gvcf_string=`for i in ../res/gatk/*${chromosome_id}.g.vcf; do echo -n "${i} "; done`
fi

# Only run this if the respective result file is not found.
if [ ! -f ${vcfgz} ]
then

    # Make sure that vcf files have been uncompressed.
    sleep_while_too_busy
    for i in ${gvcf_string}
    do
        if [ ! -f ${i} ]
        then
            file_id=`basename ${i%.g.vcf}`
            echo "Starting uncompression of file ${i}.gz."
            sbatch -o "../log/prepare/${file_id}.out" uncompress_and_index.slurm ${i}.gz ${chromosome_id} ../data/reference/orenil2.fasta
            sleep_while_too_busy
        fi
    done
    sleep_while_busy

    # Make sure index files have been created for each vcf file.
    n_vcf_files=`ls ../res/gatk/*.${chromosome_id}.g.vcf | wc -l`
    n_idx_files=`ls ../res/gatk/*.${chromosome_id}.g.vcf.idx | wc -l`
    if [ $n_vcf_files -gt $n_idx_files ]
    then
        echo "ERROR: Not all index files have been created (currently present: ${n_idx_files})!"
        exit 1
    fi

    # Run run_gatk2.slurm with all vcf files of a given chromosome.
    sbatch -o ${out} run_gatk2.slurm ${chromosome_id} ${from} ${to} ../data/reference/orenil2.fasta ${vcfgz} ${log} ${gvcf_string}

fi