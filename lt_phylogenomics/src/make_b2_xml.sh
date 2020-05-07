# m_matschiner Wed Oct 17 11:49:24 CEST 2018

# Load modules.
module load R/3.4.4
module load ruby/2.1.5

# Make the result directory.
mkdir -p ../res/beast/b2/xml

# Set the astral tree file.
astral_tree=../res/astral/species_pp.tre

# Make the pruned and rerooted tree if it doesn't exist yet.
if [ ! -f tmp.reroot.tre ]
then
    # Reroot the tree.
    Rscript reroot_tree.r ${astral_tree} tmp.reroot.tre Gobeth Tilbre Hetbut
    cat tmp.reroot.tre | sed 's/Root//g' | sed 's/NaN/1.0/g'> tmp.reroot2.tre
    mv tmp.reroot2.tre tmp.reroot.tre
fi

# Use a ruby script to turn each branch of the tree into a monophyly constraint.
ruby make_constraints_from_tree.rb tmp.reroot.tre newick tmp.constraints.txt 9.7 0.3 Gobeth,Hetbut,Tilbre,Steult,Tilspa
rm -f tmp.reroot.tre

# Make the b2 xml file for beast.
ruby beautix.rb -id b2 -n ../res/beast/b1/alignments -o . -c tmp.constraints.txt

# Remove tree topology operators from the xml.
cat b2.xml | grep -v treeSubtreeSlide | grep -v treeExchange | grep -v treeNarrowExchange | grep -v treeWilsonBalding > ../res/beast/b2/xml/b2.xml

# Feedback.
echo "Wrote file ../res/beast/b2/xml/b2.xml."

# Clean up.
rm tmp.constraints.txt
rm b2.xml

