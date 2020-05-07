# m_matschiner Fri Apr 20 14:54:51 CEST 2018

# Load the python2 module.
module load python2/2.7.10

# Add local python packages to the path.
PATH=~/.local/bin:${PATH}

# Make a summary strict tree.
combined_tree_name=../res/svdquartets/strict.c60.tre
if [ ! -f ${combined_tree_name} ]
then
    sumtrees.py ../res/svdquartets/strict.c60.s[0-9][0-9][0-9].tre -t ../res/svdquartets/strict.c60.thin.tre --suppress-annotations -o ${combined_tree_name}
fi

# Make a summary permissive tree.
combined_tree_name=../res/svdquartets/permissive.c60.tre
if [ ! -f ${combined_tree_name} ]
then
    sumtrees.py ../res/svdquartets/permissive.c60.s[0-9][0-9][0-9].tre -t ../res/svdquartets/permissive.c60.thin.tre --suppress-annotations -o ${combined_tree_name}
fi

# Make a summary strict tree for subset sub1.
combined_tree_name=../res/svdquartets/strict.c60.sub1.tre
if [ ! -f ${combined_tree_name} ]
then
    sumtrees.py ../res/svdquartets/strict.c60.sub1.s[0-9][0-9][0-9].tre -t ../res/svdquartets/strict.c60.sub1.thin.tre --suppress-annotations -o ${combined_tree_name}
fi

# Make a summary permissive tree for subset sub1.
combined_tree_name=../res/svdquartets/permissive.c60.sub1.tre
if [ ! -f ${combined_tree_name} ]
then
    sumtrees.py ../res/svdquartets/permissive.c60.sub1.s[0-9][0-9][0-9].tre -t ../res/svdquartets/permissive.c60.sub1.thin.tre --suppress-annotations -o ${combined_tree_name}
fi