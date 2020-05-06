# m_matschiner Fri Mar 2 00:55:04 CET 2018

# Make the output directory if it doesn't exist yet.
mkdir -p ../res/beagle

# Make the log directory if it doesn't exist yet.
mkdir -p ../log/beagle

# Run beagle for each linkage group separately for the full vcf file.
for filter in strict permissive
do
   for lg in NC_0319{65..87} UNPLACED
   do
    if [ ! -f ../res/beagle/${lg}.${filter}.1.vcf.gz ]
    then
        out="../log/beagle/${lg}.${filter}.out"
        rm -f ${out}
        if [ ${lg} == NC_031972 ]
        then
            sbatch --partition=long --time=400:00:00 -o ${out} run_beagle1.slurm ${lg} ${filter}
        else
            sbatch --time=168:00:00 -o ${out} run_beagle1.slurm ${lg} ${filter}
        fi
    fi
   done
done
