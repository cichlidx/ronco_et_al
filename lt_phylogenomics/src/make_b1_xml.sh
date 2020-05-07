# m_matschiner Wed Oct 17 11:49:24 CEST 2018

# Load modules.
module load R/3.4.4
module load ruby/2.1.5

# Make the result directory.
mkdir -p ../res/beast/b1/xml

# Set the raxml tree file.
raxml_tree=../res/raxml/full/permissive.c60.sub1.tre

# Set the completeness table.
completeness_table=../data/tables/call_probability.permissive.txt

# Set the sample table.
sample_table=../data/tables/DNATube_2018-02-13_13-43.tsv

# Make the pruned and rerooted tree if it doesn't exist yet.
if [ ! -f tmp.pruned.renamed.reroot.tre ]
then

    # Simplify the raxml tree.
    Rscript simplify_nexus_tree.r ${raxml_tree} tmp.tre

    # Make a list of the one specimen per species that has the lowest proportion of missing data.
    rm -f tmp.best_specimens.txt
    touch tmp.best_specimens.txt
    cat tmp.tre | grep -v ";" | grep -v "#" | grep -v TAXLABELS | grep -v "_1" | grep -v "_2" | grep -v "\[" | tr -d "\t" | grep . > tmp.specimens_in_tree.txt
    cat ${sample_table} | grep -f tmp.specimens_in_tree.txt | cut -f 3 | sort | uniq> tmp.species_in_tree.txt
    cat ${sample_table} | grep -f tmp.specimens_in_tree.txt | cut -f 1,3 > tmp.species_and_specimens_in_tree.txt
    while read line
    do
        cat tmp.species_and_specimens_in_tree.txt | grep ${line} | cut -f 1 > tmp.specimens_for_this_species.txt
        cat ${completeness_table} | grep -f tmp.specimens_for_this_species.txt | sort -n -k 4 | head -n 1 | cut -f 1 >> tmp.best_specimens.txt
    done < tmp.species_in_tree.txt
    cat tmp.species_and_specimens_in_tree.txt | grep -f tmp.best_specimens.txt > tmp.species_and_best_specimens_in_tree.txt
    rm -f tmp.specimens_in_tree.txt
    rm -f tmp.species_in_tree.txt
    rm -f tmp.species_and_specimens_in_tree.txt
    rm -f tmp.specimens_for_this_species.txt

    # Prune the tree to include only the best specimens per species.
    cat tmp.tre | grep UNTITLED | cut -d "]" -f 2 | tr -d " " > tmp.nwk
    Rscript prune_tree.r tmp.nwk tmp.pruned.tre tmp.best_specimens.txt
    rm -f tmp.nwk
    rm -f tmp.tre
    rm -f tmp.best_specimens.txt

    # Rename tip labels.
    cat tmp.pruned.tre > tmp.pruned.renamed.tre
    while read line
    do
        sample_id=`echo ${line} | tr -s " " | cut -d " " -f 1`
        species_id=`echo ${line} | tr -s " " | cut -d " " -f 2`
        cat tmp.pruned.renamed.tre | sed "s/${sample_id}/${species_id}/g" > tmp.pruned.renamed2.tre
        mv -f tmp.pruned.renamed2.tre tmp.pruned.renamed.tre
    done < tmp.species_and_best_specimens_in_tree.txt
    rm -f tmp.pruned.tre
    rm - tmp.species_and_best_specimens_in_tree.txt

    # Reroot the tree.
    Rscript reroot_tree.r tmp.pruned.renamed.tre tmp.pruned.renamed.reroot.tre Gobeth Tilbre Hetbut
    cat tmp.pruned.renamed.reroot.tre | sed 's/Root//g' > tmp.pruned.renamed.reroot2.tre
    mv tmp.pruned.renamed.reroot2.tre tmp.pruned.renamed.reroot.tre
    rm -f tmp.pruned.renamed.tre
fi

# Use a ruby script to turn each branch of the tree into a monophyly constraint.
ruby make_constraints_from_tree.rb tmp.pruned.renamed.reroot.tre newick tmp.constraints.txt 14.7
rm -f tmp.pruned.renamed.tre

# Make the b1 xml file for beast.
ruby beautix.rb -id b1 -n ../res/beast/b1/alignments -o . -c tmp.constraints.txt

# Remove tree topology operators from the xml.
cat b1.xml | grep -v treeSubtreeSlide | grep -v treeExchange | grep -v treeNarrowExchange | grep -v treeWilsonBalding > ../res/beast/b1/xml/b1.xml

# Feedback.
echo "Wrote file ../res/beast/b1/xml/b1.xml."

# Clean up.
rm tmp.constraints.txt
rm b1.xml

