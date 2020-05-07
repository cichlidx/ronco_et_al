#!/bin/bash

# m_matschiner Fri Jul 5 00:07:22 CEST 2019

# Job name:
#SBATCH --job-name=b2
#
# Wall clock limit:
#SBATCH --time=168:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=10G
#
# Outfile:
#SBATCH --output=b2.out

## Set up the job environment.
source /cluster/bin/jobsetup
module load beast2/2.5.0
module load beagle-lib/2.1.2

# Run beast.
if [ ! -f b2.log ]
then
    beast -seed ${RANDOM} -beagle b2.xml
else
    beast -seed ${RANDOM} -beagle -resume b2.xml
fi
