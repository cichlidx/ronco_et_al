# m_matschiner Wed Oct 3 16:07:21 CEST 2018

# Make the data directory.
mkdir -p ../data/misc

# Set the gene tree file.
gene_trees=../data/misc/Compara.94.protein_default.nhx.emf

# Get the gene tree file from ensembl.
if [ ! -f ${gene_trees} ]
then
    wget http://ftp.ensembl.org/pub/release-94/emf/ensembl-compara/homologies/Compara.94.protein_default.nhx.emf.gz
    gunzip Compara.94.protein_default.nhx.emf.gz
    mv Compara.94.protein_default.nhx.emf ${gene_trees}
fi
