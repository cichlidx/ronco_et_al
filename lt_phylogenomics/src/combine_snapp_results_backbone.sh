# m_matschiner Sun Jul 14 13:00:44 CEST 2019

# Load modules.
module load python3/3.5.0
module load beast2/2.5.0
module load ruby/2.1.5

# Set the burnin file.
burnin_file=../res/manual/snapp_log_burnins.txt

# Get the add_theta_to_log.rb script.
if [ ! -f add_theta_to_log.rb ]
then
    wget https://github.com/mmatschiner/snapp_prep/raw/master/add_theta_to_log.rb
fi

# Combine the results of the three different sets of analyses.
group=backbone
for method in free astral raxml
do
    # Make the result directories.
    res_dir=../res/snapp/${group}/${method}_topology/combined
    mkdir -p ${res_dir}

    # Remove the burnin from each log file.
    for n in `seq -w 10`
    do
        burnin=`cat ${burnin_file} | grep ${group} | grep ${method} | grep r${n} | cut -f 2`
        echo -ne "${group}\t${burnin}\n"
        if [ ${burnin} != 100 ]
        then
            python3 logcombiner.py -n 1000 -b ${burnin} ../res/snapp/${group}/${method}_topology/replicates/r${n}/${group}_${method}_topology.log > ${res_dir}/r${n}.log
            python3 logcombiner.py -n 1000 -b ${burnin} ../res/snapp/${group}/${method}_topology/replicates/r${n}/${group}_${method}_topology.trees > ${res_dir}/r${n}.trees
        fi
    done

    # Combine replicate log files for the snapp analyses.
    ls ${res_dir}/r??.log > ${res_dir}/logs.txt
    ls ${res_dir}/r??.trees > ${res_dir}/trees.txt
    python3 logcombiner.py -n 1000 -b 0 ${res_dir}/logs.txt ${res_dir}/${group}_${method}_topology.log
    python3 logcombiner.py -n 1000 -b 0 ${res_dir}/trees.txt ${res_dir}/${group}_${method}_topology.trees

    # Add population sizes to log files.
    ruby add_theta_to_log.rb -l ${res_dir}/${group}_${method}_topology.log -t ${res_dir}/${group}_${method}_topology.trees -g 3 -o ${res_dir}/${group}_${method}_topology_w_theta.log

    # Make maximum-clade-credibility consensenssus trees.
    treeannotator -b 0 -heights mean ${res_dir}/${group}_${method}_topology.trees ${res_dir}/${group}_${method}_topology.tre
done