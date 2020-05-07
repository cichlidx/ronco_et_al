#!/bin/bash

# michaelm Sat Mar 7 01:12:49 CET 2020

# Job name:
#SBATCH --job-name=b3
#
# Wall clock limit:
#SBATCH --time=168:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=10G
#
# Outfile:
#SBATCH --output=b3.out

## Set up the job environment.
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error
module --quiet purge  # Reset the modules to the system default
module load Beast/2.5.2-GCC-8.2.0-2.31.1
module list

# Run beast.
if [ ! -f b3.log ]
then
    beast -seed ${RANDOM} -beagle b3.xml
else
    beast -seed ${RANDOM} -beagle -resume b3.xml
fi
