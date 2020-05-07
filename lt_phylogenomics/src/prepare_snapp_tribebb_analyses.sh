# m_matschiner Sat Jul 13 12:30:31 CEST 2019

# Copy the snapp xmls and slurm scripts to 10 replicate directories.
for tribebb in tropheinibb ectodinibb lamprologinibb
do
    for id in raxml_topology astral_topology free_topology
    do
        for n in `seq -w 1 10`
        do
            dir=../res/snapp/${tribebb}/${id}/replicates/r${n}
            mkdir -p ${dir}
            rm -f ${dir}/*
            cp ../res/snapp/${tribebb}/xml/${tribebb}_${id}.xml ${dir}
            cat run_snapp.slurm | sed "s/QQQQQQ/${tribebb}_${id}/g" > ${dir}/run_snapp.slurm
        done
    done
done