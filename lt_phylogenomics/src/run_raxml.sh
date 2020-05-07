# m_matschiner Thu Jun 14 12:04:18 CEST 2018

# Make the results directory if it doesn't exist yet.
mkdir -p ../res/raxml/full

# Make the log directory if it doesn't exist yet.
mkdir -p ../log/raxml/full

# Set the genome size (this is the sum of the chromosome lengths NC_031965..UNPLACED).
genome_size=1009865309

# Run raxml for each nexus file.
for filter in strict permissive
do
    # Get the number of callable sites.
    echo -n "Calculating the number of callable sites for filter ${filter}..."
    uncallable_mask=../data/masks/${filter}.uncallable.bed.gz
    n_uncallable=`zcat ${uncallable_mask} | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print SUM}'`
    (( n_callable = ${genome_size} - ${n_uncallable} ))
    echo " done. Found ${n_callable} callable sites."
    # Get the number of variable sites (these are taken from files strict.stats and permissive.stats).
    echo -n "Calculating the number of invariable sites for filter ${filter}..."
    if [ ${filter} == "strict" ]
    then
        n_variable=54048145
    elif [ ${filter} == "permissive" ]
    then
        n_variable=57751375
    else
        echo "ERROR! Unexpected filter: ${filter}!"
        exit 1
    fi
    # Calculate the number of invariable sites.
    (( n_invariable = ${n_callable} - ${n_variable} ))
    echo " done. Found ${n_invariable} invariable sites."

    # Run raxml for the files with distributed sets of snps.
    for alignment in ../data/nexus/${filter}.c60.s[0-9][0-9][0-9].nex ../data/nexus/${filter}.c60.sub1.s[0-9][0-9][0-9].nex
    do
        run_id=`basename ${alignment%.nex}`
        out=../log/raxml/full/${run_id}.out
        tree_file_name=../res/raxml/full/${run_id}.tre
        info_file_name=../res/raxml/full/${run_id}.info
        if [ ! -f ${tree_file_name} ]
        then
            rm -f ${out}
            sbatch -o ${out} --time=${time} run_raxml.slurm ${alignment} convert.py ${n_variable} ${n_invariable} ${tree_file_name} ${info_file_name} 5
        fi
    done

    # Run raxml for the files with thinned snps.
    for alignment in ../data/nexus/${filter}.c60.sub1.thin.nex ../data/nexus/${filter}.c60.thin.nex
    do
        for n in 1 2 3 4 5
        do
            run_id=`basename ${alignment%.nex}`.${n}
            out=../log/raxml/full/${run_id}.out
            tree_file_name=../res/raxml/full/${run_id}.tre
            info_file_name=../res/raxml/full/${run_id}.info
            if [ ${filter} == "strict" ]
            then
                cpus_per_task=10
                mem_per_cpu="20G"
                time="168:00:00"
            elif [ ${filter} == "permissive" ]
            then
                cpus_per_task=30
                mem_per_cpu="10G"
                time="240:00:00"
            else
                echo "ERROR: Unknown filter ${filter}!"
                exit 1
            fi
            if [ ! -f ${tree_file_name} ]
            then
                rm -f ${out}
                sbatch -o ${out} --cpus-per-task=${cpus_per_task} --mem-per-cpu=${mem_per_cpu} --partition=hugemem --time=${time} run_raxml.slurm ${alignment} convert.py ${n_variable} ${n_invariable} ${tree_file_name} ${info_file_name} 1
            fi
        done
    done
done