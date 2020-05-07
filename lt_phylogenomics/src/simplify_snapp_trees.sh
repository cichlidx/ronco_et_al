# m_matschiner Mon Aug 5 14:40:13 CEST 2019

# Load modules.
module load R/3.4.4

# Convert each of the combined snapp trees files to newick format.
for i in ../res/snapp/*/free_topology/combined/*_topology.trees
do
    # Make a list of taxa to keep, and then prune each tree to only those taxa.
    group=`echo ${i} | cut -d "/" -f 4`
    constraint_file=../data/constraints/snapp_${group}_free.txt
    line_number=1
    if [ ${group} == "astatotilapini" ] || [ ${group} == "orthochromini" ] || [ ${group} == "serranochromini" ] || [ ${group} == "pseudocrenilabrini" ]
    then
        line_number=2
    fi
    head -n ${line_number} ${constraint_file} | tail -n 1 | cut -f 3 | tr "," "\n" > tmp.keep.txt
    simple_tree=${i%.trees}.nwk 
    Rscript prune_trees.r ${i} ${simple_tree} tmp.keep.txt
    rm -f tmp.keep.txt

    # Feedback.
    echo "Wrote pruned and simplified tree to ${simple_tree}."
done