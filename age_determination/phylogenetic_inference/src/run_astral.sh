# m_matschiner Thu Nov 22 14:23:52 CET 2018

# Make the output directory.
mkdir -p ../res/astral

# Run astral for the strict and permissive set of gene trees.
for mode in strict permissive
do
    ls ../res/trees/${mode}/ENS*.trees > tmp.trees.txt
    java -jar -Xmx8G ../bin/Astral/astral.5.6.3.jar -i ../res/trees/${mode}/${mode}_mccs.trees -b tmp.trees.txt -o tmp.out.txt
    cat tmp.out.txt | tail -n 1 > ../res/astral/${mode}.tre
    rm -f tmp.out.txt
done

# Clean up.
rm -f tmp.trees.txt