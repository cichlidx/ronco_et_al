# m_matschiner Thu Dec 13 14:01:30 CET 2018

# Copy iqtree results for both the exons and genes datasets.
for class in exons genes
do
    # Make the results directory.
    mkdir -p ../res/iqtree/strict/${class}
    
    # Copy iqtree results for markers of the strict dataset.
    for align in ../res/alignments/strict/${class}/phylip/*.phy
    do
	marker_id=`basename ${align%.phy}`
	cp -f ../res/iqtree/permissive/${class}/${marker_id}.tre ../res/iqtree/strict/${class}
	cp -f ../res/iqtree/permissive/${class}/${marker_id}.info.txt ../res/iqtree/strict/${class}
    done
done