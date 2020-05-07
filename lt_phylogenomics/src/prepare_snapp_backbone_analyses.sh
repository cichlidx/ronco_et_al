# m_matschiner Fri Jul 5 00:04:11 CEST 2019

# Copy the snapp xmls and slurm scripts to 10 replicate directories.
for id in raxml_topology astral_topology free_topology
do
    for n in `seq -w 1 10`
    do
        dir=../res/snapp/backbone/${id}/replicates/r${n}
        mkdir -p ${dir}
        rm -f ${dir}/*
        cp ../res/snapp/backbone/xml/backbone_${id}.xml ${dir}
        cat run_snapp.slurm | sed "s/QQQQQQ/backbone_${id}/g" > ${dir}/run_snapp.slurm
    done
done