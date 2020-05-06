# michaelm Sat Mar 11 13:41:26 CET 2017

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    while [ $n_jobs -gt 350 ]
    do
        sleep 10
        n_jobs=`squeue -u michaelm | wc -l`
    done
}

# Make the output directory if it doesn't exist yet.
mkdir -p ../log/mapping

# Get the coverage distribution of all bam files.
for i in ../res/mapping/*.merged.sorted.dedup.realn.bam
do
    id=`basename ${i%.merged.sorted.dedup.realn.bam}`
    out="../log/mapping/coverage.${id}.out"
    rm -f {out}
    sbatch -o ${out} get_coverage_distribution.slurm ${i} ../data/reference/orenil2.fasta.fai
    sleep_while_too_busy
done