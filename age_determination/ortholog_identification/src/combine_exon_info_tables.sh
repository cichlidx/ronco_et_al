# m_matschiner Wed Nov 14 09:14:47 CET 2018

# Write a new table file.
cat ../res/tables/nuclear_queries_exons_miss0_00.txt | head -n 1 > tmp.table.txt
for i in ../res/tables/nuclear_queries_exons_miss0_??.txt
do
	cat ${i} | tail -n +2
done | sort -n -k 1 >> tmp.table.txt
mv tmp.table.txt ../res/tables/exons_tree_congruent.txt
rm -f ../res/tables/nuclear_queries_exons_miss0_??.txt