# m_matschiner Mon Jul 22 10:33:05 CEST 2019

# Make xmls for all within-tribe analyses.
for analysis_id in ectodini1 ectodini2 bathybatini benthochromini cyphotilapiini cyprichromini eretmodini lamprologini2 lamprologini3 lamprologini4 limnochromini orthochromis perissodini # Do not run this for the following (these are dealt with separately): pseudocrenilabrini trematocarini lamprologini1 lamprologini5 astatotilapini serranochromini orthochromini tropheini1 tropheini2
do
    # Set the name of the results directory.
    res_dir=../res/snapp/${analysis_id}/xml

    # Make the results directory.
    mkdir -p ${res_dir}

    # Set the name of the astral snapp xml file.
    xml_astral=${res_dir}/${analysis_id}_astral_topology.xml

    # Set the name of the log file.
    out=../log/misc/make_snapp_tribe_xmls.${analysis_id}.out
    rm -f ${out}
    if [ ! -f ${xml_astral} ]
    then
        sbatch -o ${out} make_snapp_tribe_xmls.slurm ${analysis_id}
    fi
done