# m_matschiner Sun Dec 16 11:39:59 CET 2018

# For each of the exons and genes in the strict dataset, copy the iqtree_constrained results from the permissive dataset.
for hypothesis in h07 h08 h09 # h01 h02 h03 h04 h05 h06
do
    for class in exons genes
    do
	echo -n "Copying result files for ${class}..."
	mkdir -p ../res/iqtree_constrained/${hypothesis}/strict/${class}
	for phylip in ../res/alignments/strict/${class}/phylip/*.phy
	do
	    marker_id=`basename ${phylip%.phy}`
	    t1_file=../res/iqtree_constrained/${hypothesis}/permissive/${class}/${marker_id}_${hypothesis}_t1.info.txt
	    t2_file=../res/iqtree_constrained/${hypothesis}/permissive/${class}/${marker_id}_${hypothesis}_t2.info.txt
	    t3_file=../res/iqtree_constrained/${hypothesis}/permissive/${class}/${marker_id}_${hypothesis}_t3.info.txt
	    if [ -f ${t1_file} ]
	    then
		cp -f ${t1_file} ../res/iqtree_constrained/${hypothesis}/strict/${class}
	    fi
	    if [ -f ${t2_file} ]
            then
                cp -f ${t2_file} ../res/iqtree_constrained/${hypothesis}/strict/${class}
            fi
	    if [ -f ${t3_file} ]
            then
                cp -f ${t3_file} ../res/iqtree_constrained/${hypothesis}/strict/${class}
            fi
	done
	echo " done."
    done
done