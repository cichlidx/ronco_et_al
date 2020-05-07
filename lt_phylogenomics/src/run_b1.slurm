#!/bin/bash

# m_matschiner Wed Oct 17 20:29:32 CEST 2018

# Job name:
#SBATCH --job-name=b1
#
# Wall clock limit:
#SBATCH --time=168:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=10G
#
# Outfile:
#SBATCH --output=b1.out

## Set up the job environment.
source /cluster/bin/jobsetup
module load beast2/2.5.0
module load beagle-lib/2.1.2

# Run beast.
if [ ! -f b1.log ]
then
    beast -seed ${RANDOM} -beagle b1.xml
else
    beast -seed ${RANDOM} -beagle -resume b1.xml
fi
