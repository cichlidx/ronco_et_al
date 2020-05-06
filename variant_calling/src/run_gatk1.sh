# m_matschiner Wed Apr 12 00:44:13 CEST 2017

# Make the output directory if it does not exist yet.
mkdir -p ../res/gatk
mkdir -p ../log/gatk

# Get the command line arguments.
specimen_id=$1
chromosome_id=$2

# Get the name of the bam file.
bam_with_relative_path="../res/mapping/${specimen_id}.merged.sorted.dedup.realn.bam"

# Start script run_gatk1.slurm.
bam=`basename ${bam_with_relative_path}`
truncated_bam=${bam%.merged.sorted.dedup.realn.bam}
out="../log/gatk/run_gatk1.${truncated_bam}.${chromosome_id}.out"
gvcf="../res/gatk/${truncated_bam}.${chromosome_id}.g.vcf.gz"
log="../log/gatk/run_gatk1.${truncated_bam}.${chromosome_id}.log"
if [ ! -f ${gvcf} ]
then
    sbatch -o ${out} run_gatk1.slurm ../data/reference/orenil2.fasta ${bam_with_relative_path} ${gvcf} ${log} ${chromosome_id}
fi
