# m_matschiner Tue May 1 16:31:41 CEST 2018

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    have_been_waiting=false
    while [ $n_jobs -gt 300 ]
    do
        have_been_waiting=true
        echo -ne "\rWaiting for job capacity..."
        sleep 60
        n_jobs=`squeue -u michaelm | wc -l`
    done
    if [ ${have_been_waiting} == true ]
    then
        echo " done."
    fi
}

# Make the output directory if it doesn't exist yet.
mkdir -p ../res/kollector

# Make the log directory if it doesn't exist yet.
mkdir -p ../log/kollector

# Set the query file.
query=../data/queries/orenil_exons_nucl.fasta

# Start a slurm script per specimen.
for specimen in `ls ../data/fastq | cut -d "_" -f 1 | sort | uniq`
do
    out=../log/kollector/${specimen}.out
    log=../log/kollector/${specimen}.log
    res=../res/kollector/${specimen}.kollector.fasta
    if [ ! -f ${res} ]
    then
	rm -f ${out}
	rm -f ${log}
	echo -n "Submitting job for specimen ${specimen}..."
	sbatch -o ${out} run_kollector.slurm ${specimen} ${query} ${res} ${log} &> /dev/null
	echo " done."
	sleep_while_too_busy
    fi
done