# m_matschiner Wed Oct 17 11:49:24 CEST 2018

# Load modules.
module load R/3.5.1-foss-2018b
module load Ruby/2.6.1-GCCcore-7.3.0

# Make the result directory.
mkdir -p ../res/beast/b3/xml

# Set the snapp tree file.
snapp_tree=../res/snapp/connected/24535/snapp_free_topology.tre

# Remove the translate block from the snapp tree.
Rscript simplify_nexus_tree.r ${snapp_tree} tmp.simple.tre

# Use a ruby script to turn each branch of the tree into a monophyly constraint.
ruby make_constraints_from_tree.rb tmp.simple.tre nexus tmp.constraints.txt 9.7 0.3

# Make the b3 xml file for beast.
ruby beautix.rb -id b3 -n ../res/beast/b1/alignments -o . -c tmp.constraints.txt

# Remove tree topology operators and outgroup sequences from the xml.
cat b3.xml | grep -v treeSubtreeSlide | grep -v treeExchange | grep -v treeNarrowExchange | grep -v treeWilsonBalding | grep -v Gobeth | grep -v Hetbut | grep -v Tilbre | grep -v Steult | grep -v Tilspa > ../res/beast/b3/xml/b3.xml

# Feedback.
echo "Wrote file ../res/beast/b3/xml/b3.xml."

# Clean up.
rm tmp.constraints.txt
rm b3.xml

