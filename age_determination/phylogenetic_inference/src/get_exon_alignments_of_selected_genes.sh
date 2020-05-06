# m_matschiner Mon Nov 19 21:58:21 CET 2018

# Copy exons remaining in the final data set to a new directory.
for mode in strict permissive
do
    # Make the results directory.
    mkdir -p ../res/alignments/02_${mode}

    # Get the ids of all genes remaining in the data set.
    for gene in `ls ../data/trees/${mode}/ENS*.trees | rev | cut -d "/" -f 1 | rev | sed 's/.trees//g'`
    do
	# Get the ids of all remaining exons for that gene.
	for exon in `cat ../data/tables/exons_tree_congruent.txt | grep ${gene} | cut -f 1`
	do
	    cp ../data/alignments/02/${exon}_nucl.fasta ../res/alignments/02_${mode}
	done
    done
done
