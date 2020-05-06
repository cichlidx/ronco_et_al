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
        if [ ! -f ../res/beagle/${lg}.${filter}.2.vcf.gz ]
        then
            out="../log/beagle/${lg}.${filter}.2.out"
            rm -f ${out}
            sbatch -o ${out} run_beagle2.slurm ${lg} ${filter}
        fi
    done
done
