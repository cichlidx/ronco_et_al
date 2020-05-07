# m_matschiner Sat Jul 13 12:30:31 CEST 2019

# Copy the snapp xmls and slurm scripts to 10 replicate directories.
for tribe in pseudocrenilabrini orthochromini serranochromini astatotilapini ectodini1 ectodini2 lamprologini1 lamprologini5 trematocarini bathybatini benthochromini cyphotilapiini cyprichromini ectodini1 ectodini2 eretmodini lamprologini1 lamprologini2 lamprologini3 lamprologini4 lamprologini5 limnochromini orthochromis perissodini trematocarini tropheini1 tropheini2
do
    for id in raxml_topology astral_topology free_topology
    do
        for n in `seq -w 1 10`
        do
            dir=../res/snapp/${tribe}/${id}/replicates/r${n}
            mkdir -p ${dir}
            if [ ! -f ${dir}/${tribe}_${id}.xml ]
            then
                if [ -f ../res/snapp/${tribe}/xml/${tribe}_${id}_alt.xml ]
                then
                    cp ../res/snapp/${tribe}/xml/${tribe}_${id}_alt.xml ${dir}/${tribe}_${id}.xml
                else
                    cp ../res/snapp/${tribe}/xml/${tribe}_${id}.xml ${dir}/${tribe}_${id}.xml
                fi
                cat run_snapp.slurm | sed "s/QQQQQQ/${tribe}_${id}/g" > ${dir}/run_snapp.slurm
            fi
        done
    done
done