# m_matschiner Fri Nov 30 13:40:26 CET 2018

# Get the likelihoods for the three topologies per hypothesis.
for hypothesis in h07 h08 h09 # h01 h02 h03 h04
do
    for mode in strict permissive
    do
	for class in exons genes
	do
	    table=../res/tables/constrained_likelihoods_${mode}_${class}_${hypothesis}.txt
	    if [ ! -f ${table} ]
	    then
		echo -e "gene_id\tbest\tdelta_lik\tlik_t1\tlik_t2\tlik_t3" >> ${table}
		for phylip in ../res/alignments/${mode}/${class}/phylip/*.phy
		do
		    marker_id=`basename ${phylip%.phy}`

		    # Test if all three iqtree info files exist.
		    t1_file=../res/iqtree_constrained/${hypothesis}/${mode}/${class}/${marker_id}_${hypothesis}_t1.info.txt
		    t2_file=../res/iqtree_constrained/${hypothesis}/${mode}/${class}/${marker_id}_${hypothesis}_t2.info.txt
		    t3_file=../res/iqtree_constrained/${hypothesis}/${mode}/${class}/${marker_id}_${hypothesis}_t3.info.txt
		    if [[ -f ${t1_file} && -f ${t2_file} && -f ${t3_file} ]]
		    then

			# Make sure that all files contain likelihoods.
			for t_file in ${t1_file} ${t2_file} ${t3_file}
			do
			    lik_included=`cat ${t_file} | grep "Log-likelihood of the tree" | wc -l`
			    if [[ ${lik_included} == 0 ]]
			    then
				echo "ERROR: No likelihood found in file ${t_file}!"
				exit 1
			    fi
			done

			# Get the three likelihoods.
			t1_lik=`cat ${t1_file} | grep "Log-likelihood of the tree" | cut -d ":" -f 2 | cut -d " " -f 2`
			t2_lik=`cat ${t2_file} | grep "Log-likelihood of the tree" | cut -d ":" -f 2 | cut -d " " -f 2`
			t3_lik=`cat ${t3_file} | grep "Log-likelihood of the tree" | cut -d ":" -f 2 | cut -d " " -f 2`

			# Determine the best and second-best likelihood, and their difference.
			best_lik=`echo -e "${t1_lik}\n${t2_lik}\n${t3_lik}" | sort -n -r | head -n 1`
			second_best_lik=`echo -e "${t1_lik}\n${t2_lik}\n${t3_lik}" | sort -n -r | head -n 2 | tail -n 1`
			delta_lik=`echo "${best_lik} - ${second_best_lik}" | bc`
			if (( 1 == `echo "${t1_lik} > ${t2_lik}" | bc` )) && (( 1 == `echo "${t1_lik} > ${t3_lik}" | bc` ))
			then
			    echo -e "${marker_id}\tt1\t${delta_lik}\t${t1_lik}\t${t2_lik}\t${t3_lik}" >> ${table}
			elif (( 1 == `echo "${t2_lik} > ${t1_lik}" | bc` )) && (( 1 == `echo "${t2_lik} > ${t3_lik}" | bc` ))
			then
			    echo -e "${marker_id}\tt2\t${delta_lik}\t${t1_lik}\t${t2_lik}\t${t3_lik}" >> ${table}
			elif (( 1 == `echo "${t3_lik} > ${t1_lik}" | bc` )) && (( 1 == `echo "${t3_lik} > ${t2_lik}" | bc` ))
			then
			    echo -e "${marker_id}\tt3\t${delta_lik}\t${t1_lik}\t${t2_lik}\t${t3_lik}" >> ${table}
			fi
		    fi
		done
	    fi
	done
    done
done