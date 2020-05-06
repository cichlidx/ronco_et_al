#!/bin/bash

# m_matschiner Wed Apr 3 23:31:02 CEST 2019

# Job name:
#SBATCH --job-name=beast
#
# Wall clock limit:
#
#SBATCH --time=168:00:00
#
# Processor and memory usage:
#SBATCH --ntasks-per-node=3
#SBATCH --mem-per-cpu=5G
#
# Outfile:
#SBATCH --output=QQQQQQ.out

## Set up job environment:
source /cluster/bin/jobsetup
module load beast2/2.5.0
module load beagle-lib/2.1.2

## Run or resume beast analysis.
if [ ! -f QQQQQQ.log ]
then
    beast -threads 3 -seed ${RANDOM} -beagle QQQQQQ.xml
else
    beast -threads 3 -seed ${RANDOM} -beagle -resume QQQQQQ.xml
fi
