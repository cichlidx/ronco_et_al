#!/bin/bash

# m_matschiner Fri Jul 5 22:54:11 CEST 2019

# Job name:
#SBATCH --job-name=snapp
#
# Wall clock limit:
#
#SBATCH --time=100:00:00
#
# Processor and memory usage:
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu=2G
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
    beast -threads 8 -seed ${RANDOM} -beagle QQQQQQ.xml
else
    beast -threads 8 -seed ${RANDOM} -beagle -resume QQQQQQ.xml
fi
