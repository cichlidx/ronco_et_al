# m_matschiner Mon Nov 19 17:04:53 CET 2018

# Load modules.
module load ruby/2.1.5

# Make a list of tree names.
ls ../res/trees/nuclear/permissive/ENS*.tre | rev | cut -d "/" -f 1 | rev | sed 's/.tre//g' > tmp.tree_names.txt

# Make new versions of mcc tree files that contain tree names instead of numbers.
for mode in strict permissive
do
    ls ../res/trees/nuclear/${mode}/ENS*.tre | rev | cut -d "/" -f 1 | rev | sed 's/.tre//g' > tmp.tree_names.txt
    ruby add_mcc_tree_names.rb ../res/trees/nuclear/${mode}/${mode}_numbered_mccs.trees tmp.tree_names.txt ../res/trees/nuclear/${mode}/${mode}_named_mccs.trees
done

# Clean up.
rm -f tmp.tree_names.txt