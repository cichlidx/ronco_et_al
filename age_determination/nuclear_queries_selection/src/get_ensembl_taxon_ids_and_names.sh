# m_matschiner Wed Oct 3 16:13:48 CEST 2018

# Make the output directory.
mkdir -p ../res/tables

# Set the gene tree file.
gene_trees=../data/misc/Compara.94.protein_default.nhx.emf

# Set the table file.
table=../res/tables/ensembl_ids.txt
rm -f ${table}
touch ${table}

# Make a table of species ids, names, and frequencies of occurrence.
cat ${gene_trees} | grep ^SEQ | grep " ENS" | cut -d " " -f 2,3 > tmp.gene_tree_ids.txt
cat tmp.gene_tree_ids.txt | cut -d " " -f 1 > tmp.gene_tree_ids1.txt
cat tmp.gene_tree_ids.txt | cut -d " " -f 2 > tmp.gene_tree_ids2.txt
cat tmp.gene_tree_ids2.txt | cut -c 1-7 | sort | uniq -c > tmp.uniq_gene_tree_ids.txt
while read line
do
    count=`echo ${line} | tr -s " " | cut -d " " -f 1`
    id=`echo ${line} | tr -s " " | cut -d " " -f 2`
    name=`cat tmp.gene_tree_ids.txt | grep ${id} | cut -d " " -f 1 | head -n 1`
    echo -e "${id}\t${name}\t${count}" >> ${table}
done < tmp.uniq_gene_tree_ids.txt

# Clean up.
rm tmp.gene_tree_ids*
rm tmp.uniq_gene_tree_ids.txt