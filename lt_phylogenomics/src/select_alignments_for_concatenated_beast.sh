# m_matschiner Mon Oct 15 11:46:17 CEST 2018

# Load the python3 module.
module load python3/3.5.0

# Make the output directory.
mkdir -p ../res/beast/b1/alignments
rm -f ../res/beast/b1/alignments/*

# Set thresholds on the aligment length, the number of variable sites, and the number of hemiplasies.
minimum_alignment_length=2500
minimum_n_variable_sites=400
maximum_n_hemiplasies=130

# Get stats from the info files for all species alignments, and filter accordingly.
for chromosome_id in NC_0319{65..87}
do
    for phy in ../res/windows/5000bp/${chromosome_id}/${chromosome_id}_*.species.phy
    do
        phy_base=`basename ${phy}`
        nex=../res/beast/b1/alignments/${phy_base%.species.phy}.nex
        info=${phy%.species.phy}.info.txt
        alignment_length_after_bmge_calculated=`cat ${info} | grep "alignment_length_after_bmge:" | wc -l`
        n_variable_sites_after_bmge_calculated=`cat ${info} | grep "n_variable_sites_after_bmge:" | wc -l`
        n_hemiplasies_calculated=`cat ${info} | grep "n_hemiplasies:" | wc -l`
        if [[ ${alignment_length_after_bmge_calculated} == 1 && ${n_variable_sites_after_bmge_calculated} == 1 && ${n_hemiplasies_calculated} == 1 ]]
        then
            alignment_length_after_bmge=`cat ${info} | grep "alignment_length_after_bmge:" | cut -d ":" -f 2`
            n_variable_sites_after_bmge=`cat ${info} | grep "n_variable_sites_after_bmge:" | cut -d ":" -f 2`
            n_hemiplasies=`cat ${info} | grep "n_hemiplasies:" | cut -d ":" -f 2`
            if (( ${alignment_length_after_bmge} >= ${minimum_alignment_length} ))
            then
                if (( ${n_variable_sites_after_bmge} >= ${minimum_n_variable_sites} ))
                then
                    if (( ${n_hemiplasies} <= ${maximum_n_hemiplasies} ))
                    then
                        echo "Copying alignment ${phy}."
                        python3 convert.py -f nexus ${phy} ${nex}
                    fi
                fi
            fi
        else
            echo "WARNING: File ${info} seems to be incomplete!"
        fi
    done
done