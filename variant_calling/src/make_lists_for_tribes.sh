# m_matschiner Wed Feb 14 18:50:15 CET 2018

# Make lists of ids for individual tribes.
for i in haplochromini lamprologini tropheini cyprichromini bathybatini benthochromini boulengerochromini cyphotilapiini ectodini eretmodini limnochromini perissodini trematocarini
do
    if [ ! -f ../data/tables/${i}.txt ]
    then
	cat ../data/tables/DNATube_2018-02-13_13-43.tsv | grep -i ${i} | cut -f 1 > tmp.txt
	for j in `cat tmp.txt`
	do
	    cat ../data/tables/ear.txt | grep ${j}
	done | cut -f 1 > ../data/tables/${i}.txt
    fi
done
cat ../data/tables/haplochromini.txt ../data/tables/tropheini.txt > ../data/tables/haplotropheini.txt