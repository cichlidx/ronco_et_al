# m_matschiner Mon Jul 22 10:33:05 CEST 2019

# Make xmls for all within-tribe analyses.
for analysis_id in haplochromini1 haplochromini3 haplochromini4 lamprologini1 lamprologini5 trematocarini bathybatini benthochromini cyphotilapiini cyprichromini ectodini1 ectodini2 eretmodini haplochromini1 haplochromini2 haplochromini3 haplochromini4 lamprologini1 lamprologini2 lamprologini3 lamprologini4 lamprologini5 limnochromini orthochromis perissodini trematocarini
do
    # Set the name of the results directory.
    res_dir=../res/snapp/${analysis_id}/xml

    # Set the name of the primary astral snapp xml file.
    xml_astral=${res_dir}/${analysis_id}_astral_topology.xml

    # Get the number of sites in the primary xml file.
    n_sites=`cat ${xml_astral} | grep sequence | head -n1 | cut -d "=" -f 5 | tr -d "\"" | tr -d ">" | tr -d "/" | wc -m`

    # Make an alternative xml file based on the permissive vcf if the number of sites is below 1000.
    if (( ${n_sites} < 1000 ))
    then
        # Set the name of the alternative astral snapp xml file.
        xml_astral_alt=${res_dir}/${analysis_id}_astral_topology_alt.xml

        # Set the name of the log file.
        out=../log/misc/make_snapp_tribe_xmls.${analysis_id}_alt.out
        rm -f ${out}
        if [ ! -f ${xml_astral_alt} ]
        then
            sbatch -o ${out} make_snapp_tribe_alt_xmls.slurm ${analysis_id}
        fi
    fi
done