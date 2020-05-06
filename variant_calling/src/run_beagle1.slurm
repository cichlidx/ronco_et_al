#!/bin/bash

# m_matschiner Fri Mar 2 00:59:41 CET 2018

# Job name:
#SBATCH --job-name=beagle1
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=10

## Set up the job environment.
source /cluster/bin/jobsetup
module load java/jdk1.8.0_112

## Feedback.
echo
echo "run_beagle1.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
lg=${1}
filter=${2}
tribe=${3}

# Test whether a tribe id has been passed as an argument.
if [ -z ${tribe} ]
then
    # Run the first part of the beagle phasing analysis for the full vcf.
    echo -n "Running the first part of the beagle analysis..."
    java -jar -Xmx60G ../bin/beagle.27Jan18.7e1.jar nthreads=10 chrom=${lg} ne=10000 gtgl="../res/gatk/${lg}.${filter}.vcf.gz" out="../res/beagle/${lg}.${filter}.1"
    echo " done."
else
    # Run the first part of the beagle phasing analysis for the vcf of one tribe.
    echo -n "Running the first part of the beagle analysis..." 
    java -jar -Xmx60G ../bin/beagle.27Jan18.7e1.jar nthreads=10 chrom=${lg} ne=10000 gtgl="../res/gatk/${lg}.${tribe}.${filter}.vcf.gz" out="../res/beagle/${lg}.${tribe}.${filter}.1"
    echo " done."
fi