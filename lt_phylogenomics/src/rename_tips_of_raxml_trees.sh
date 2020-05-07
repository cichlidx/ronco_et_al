# m_matschiner Mon Jul 16 12:04:35 CEST 2018

# Set the name of the translation table.
translation_table=../data/tables/DNATube_2018-02-13_13-43.tsv

# Rename tips of all gene trees.
tree=../res/raxml/full/strict.c60.tre
echo -n "Renaming tips in tree ${tree}..."
cp ${tree} tmp.tre
while read line
do
	sample_id=`echo ${line} | tr -s " " | cut -d " " -f 1`
	species_id=`echo ${line} | tr -s " " | cut -d " " -f 3`
	cat tmp.tre | sed "s/${sample_id}/${sample_id}_${species_id}/g" > tmp2.tre
	mv -f tmp2.tre tmp.tre
done < cat ${translation_table} | tail -n +2 | grep -v PacBio
mv tmp.tre ${tree%.tre}_edit.tre
echo " done. Wrote file ${tree%.tre}_edit.tre"
