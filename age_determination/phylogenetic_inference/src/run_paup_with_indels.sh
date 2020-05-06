# m_matschiner Tue Nov 20 16:10:32 CET 2018

# Load modules.
module load paup/4.0a164

# Make the results directory.
mkdir -p ../res/paup

# Make maximum-parsimony trees based on indel information.
for mode in strict permissive
do
    # Write a file with paup commands.
    echo "#nexus" > tmp.paup.nex
    echo "begin paup;" >> tmp.paup.nex
    echo "  log start file='../res/paup/${mode}_indels.log' replace=yes;" >> tmp.paup.nex
    echo "  execute ../res/alignments/02_${mode}_indels.nex;" >> tmp.paup.nex
    echo "  outgroup orylat krymar cypvar funhet notfur poefor xipmac;" >> tmp.paup.nex
    echo "  root;"
    echo "  pset;" >> tmp.paup.nex
    echo "  hsearch;" >> tmp.paup.nex
    echo "  contree / showtree=no treefile='../res/paup/${mode}_indels.tre';" >> tmp.paup.nex
    echo "  describetrees / brlens=yes apolist;" >> tmp.paup.nex
    echo "  log stop;" >> tmp.paup.nex
    echo "  quit;" >> tmp.paup.nex
    echo "end;" >> tmp.paup.nex

    # Run paup.
    paup -n tmp.paup.nex
done

# Clean up.
rm -r tmp.paup.nex