# m_matschiner Sun Jul 22 16:12:24 CEST 2018

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    have_been_waiting=false
    while [ $n_jobs -gt 350 ]
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
mkdir -p ../res/atram

# Make the log directory if it doesn't exist yet.
mkdir -p ../log/atram

# Define the query file.
query_w_relative_path_prefix="../data/queries/orenil_exons"

# Start a slurm script per specimen.
specimens=`for i in ../res/kollector/*.kollector.fasta; do echo -ne "${i}\t"; cat ${i} | wc -m; done | sort -n -k 2 | head -n 15 | cut -f 1 | cut -d "/" -f 4 | cut -d "." -f 1`
for specimen in ${specimens}
do
    for query_w_relative_path in ${query_w_relative_path_prefix}??.fa
    do
	query_id=`basename ${query_w_relative_path%.fa}`
	out="../log/atram/${specimen}_${query_id}.out"
	log="../log/atram/${specimen}_${query_id}.log"
	res_dir="../res/atram/${specimen}_${query_id}"

	# Remove empty files from the results directory.
	for file in ${res_dir}/*
	do
	    if [ ! -s ${file} ]
	    then
		rm -f ${file}
	    fi
	done

	# Make a list of gene ids that are already in the results directory.
	rm -f tmp.in_dir.txt
	for file in ${res_dir}/*
	do
	    file_base=`basename ${file}`
	    echo ${file_base} | tr "_" "\n" | grep ENS
	done | sort >> tmp.in_dir.txt

	# Make a list of gene ids that are in the query.
	cat ${query_w_relative_path} | grep ">" | tr -d ">" | sort > tmp.in_query.txt
	
	# Make a list of gene ids that are in the query but not in the results directory.
	comm -23 tmp.in_query.txt tmp.in_dir.txt > tmp.in_query_but_not_in_dir.txt

	# Make a temporary query file with only the genes that are not already in the results directory.
	tmp_query_file=tmp.${specimen}_${query_id}.txt
	rm -f ${tmp_query_file}
	for gene_id in `cat tmp.in_query_but_not_in_dir.txt`
	do
	    fastagrep -t -p ${gene_id} ${query_w_relative_path} >> ${tmp_query_file}
	done
	
	# Clean up.
	rm -f tmp.in_query.txt
	rm -f tmp.in_dir.txt
	rm -f tmp.in_query_but_not_in_dir.txt

	# Set the database directory.
	database_dir="../res/atram/databases/${specimen}"

	# Run atram.
    rm -f ${out}
	mkdir -p ${res_dir}
	if [ -d ${database_dir} ]
	then
	    echo "Submitting job with database:"
	    sbatch -o ${out} run_atram.slurm ${specimen} ${tmp_query_file} ${res_dir} ${log} ${database_dir}
	else
	    echo "Submitting job without database:"
	    sbatch -o ${out} run_atram.slurm ${specimen} ${tmp_query_file} ${res_dir} ${log}
	fi
	sleep_while_too_busy

    done
done