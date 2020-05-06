# m_matschiner Tue Dec 4 12:49:27 CET 2018

# Copy the exon alignments from the ortholog detection analysis.
for mode in strict permissive
do
    for nex in ../data/alignments/${mode}/genes/*.nex
    do
        gene_id=`basename ${nex%.nex}`
        exon_ids=`cat ../data/tables/exons_tree_congruent.txt | grep ${gene_id} | cut -f 1`
            for exon_id in ${exon_ids}
        do
            cp ../data/alignments/08/${gene_id}/${exon_id}.seq ../data/alignments/${mode}/exons/${exon_id}.nex
        done
    done
done