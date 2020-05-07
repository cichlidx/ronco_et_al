# m_matschiner Fri Oct 5 11:24:56 CEST 2018

# Set the output table.
table=../res/tables/windows/stats.txt
rm -f ${table}

# Write the table header.
echo -ne "lg\tfrom\tto\tproportion_missing\traxml_tree_rf_distance" >> ${table}
echo -ne "\tgsi_Ectodini" >> ${table}
echo -ne "\tgsi_Lamprologini" >> ${table}
echo -ne "\tgsi_Eretmodini" >> ${table}
echo -ne "\tgsi_Tropheini" >> ${table}
echo -ne "\tgsi_Cyprichromini" >> ${table}
echo -ne "\tgsi_Benthochromini" >> ${table}
echo -ne "\tgsi_Perissodini" >> ${table}
echo -ne "\tgsi_Limnochromini" >> ${table}
echo -ne "\tgsi_Bathybatini" >> ${table}
echo -ne "\tgsi_Trematocarini" >> ${table}
echo -ne "\tgsi_Cyphotilapiini" >> ${table}
echo >> ${table}

# Analyze info files of each chromosome.
for lg in NC_0319{65..87} UNPLACED
do
    dir=../res/windows/5000bp/${lg}
    for tree in ${dir}/*.raxml.tre
    do
	info=${tree%.raxml.tre}.info.txt
	info_base=`basename ${info%.info.txt}`
	to=`echo ${info_base} | rev | cut -d "_" -f 1 | rev`
	from=`echo ${info_base} | rev | cut -d "_" -f 2 | rev`
	proportion_missing=`cat ${info} | grep "proportion_missing:" | cut -d ":" -f 2`
	raxml_tree_rf_distance=`cat ${info} | grep "raxml_tree_rf_distance:" | cut -d ":" -f 2`
	raxml_tree_gsi_Ectodini=`cat ${info} | grep "raxml_tree_gsi_Ectodini:" | cut -d ":" -f 2`
	raxml_tree_gsi_Lamprologini=`cat ${info} | grep "raxml_tree_gsi_Ectodini:" | cut -d ":" -f 2`
	raxml_tree_gsi_Eretmodini=`cat ${info} | grep "raxml_tree_gsi_Eretmodini:" | cut -d ":" -f 2`
	raxml_tree_gsi_Tropheini=`cat ${info} | grep "raxml_tree_gsi_Tropheini:" | cut -d ":" -f 2`
	raxml_tree_gsi_Cyprichromini=`cat ${info} | grep "raxml_tree_gsi_Cyprichromini:" | cut -d ":" -f 2`
	raxml_tree_gsi_Benthochromini=`cat ${info} | grep "raxml_tree_gsi_Benthochromini:" | cut -d ":" -f 2`
	raxml_tree_gsi_Perissodini=`cat ${info} | grep "raxml_tree_gsi_Perissodini:" | cut -d ":" -f 2`
	raxml_tree_gsi_Limnochromini=`cat ${info} | grep "raxml_tree_gsi_Limnochromini:" | cut -d ":" -f 2`
	raxml_tree_gsi_Bathybatini=`cat ${info} | grep "raxml_tree_gsi_Bathybatini:" | cut -d ":" -f 2`
	raxml_tree_gsi_Trematocarini=`cat ${info} | grep "raxml_tree_gsi_Trematocarini:" | cut -d ":" -f 2`
	raxml_tree_gsi_Cyphotilapiini=`cat ${info} | grep "raxml_tree_gsi_Cyphotilapiini:" | cut -d ":" -f 2`
	echo -ne "${lg}\t${from}\t${to}\t${proportion_missing}\t${raxml_tree_rf_distance}" >> ${table}
	echo -ne "\t${raxml_tree_gsi_Ectodini}" >> ${table}
	echo -ne "\t${raxml_tree_gsi_Lamprologini}" >> ${table}
	echo -ne "\t${raxml_tree_gsi_Eretmodini}" >> ${table}
	echo -ne "\t${raxml_tree_gsi_Tropheini}" >> ${table}
	echo -ne "\t${raxml_tree_gsi_Cyprichromini}" >> ${table}
	echo -ne "\t${raxml_tree_gsi_Benthochromini}" >> ${table}
	echo -ne "\t${raxml_tree_gsi_Perissodini}" >> ${table}
	echo -ne "\t${raxml_tree_gsi_Limnochromini}" >> ${table}
	echo -ne "\t${raxml_tree_gsi_Bathybatini}" >> ${table}
	echo -ne "\t${raxml_tree_gsi_Trematocarini}" >> ${table}
	echo -ne "\t${raxml_tree_gsi_Cyphotilapiini}" >> ${table}
	echo >> ${table}
    done
done