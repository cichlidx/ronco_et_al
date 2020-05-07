# m_matschiner Mon Jul 16 11:57:31 CEST 2018

# Load the python2 module.
module load python2/2.7.10

# Add local python packages to the path.
PATH=~/.local/bin:${PATH}

# Make summary trees for the full datasets.
for filter in strict permissive
do
    target_tree=`for i in ../res/raxml/full/${filter}.c60.thin.?.info; do echo -ne "${i}\t"; cat ${i} | grep "Final GAMMA-based Score of best tree" | cut -d " " -f 7; done | sort -k 2 | cut -f 1 | head -n 1 | sed 's/.info/.tre/g'`
    combined_tree_name=../res/raxml/full/${filter}.c60.tre
    if [ ! -f ${combined_tree_name} ]
    then
	   sumtrees.py ../res/raxml/full/${filter}.c60.s[0-9][0-9][0-9].tre -t ${target_tree} --suppress-annotations -o ${combined_tree_name}
    fi
done

# Make summary trees for subset 1.
for filter in strict permissive
do
    target_tree=`for i in ../res/raxml/full/${filter}.c60.sub1.thin.?.info; do echo -ne "${i}\t"; cat ${i} | grep "Final GAMMA-based Score of best tree" | cut -d " " -f 7; done | sort -k 2 | cut -f 1 | head -n 1 | sed 's/.info/.tre/g'`
    combined_tree_name=../res/raxml/full/${filter}.c60.sub1.tre
    if [ ! -f ${combined_tree_name} ]
    then
        sumtrees.py ../res/raxml/full/${filter}.c60.sub1.s[0-9][0-9][0-9].tre -t ${target_tree} --suppress-annotations -o ${combined_tree_name}
    fi
done


