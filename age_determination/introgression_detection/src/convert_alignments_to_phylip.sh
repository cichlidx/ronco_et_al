# m_matschiner Tue Dec 4 13:36:39 CET 2018

# Load modules.
module load python3/3.5.0

# Convert all alignments to fasta format.
for mode in strict permissive
do
    for class in exons genes
    do
	echo -n "Converting ${mode} ${class}..."
	mkdir -p ../res/alignments/${mode}/${class}/phylip
	for align in ../data/alignments/${mode}/${class}/*.nex
	do
	    align_id=`basename ${align%.nex}`
	    python3 convert.py -m 0.9 -f phylip ${align} ../res/alignments/${mode}/${class}/phylip/${align_id}.phy
	done
	echo " done."
    done
done