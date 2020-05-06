# m_matschiner Wed Nov 7 00:54:01 CET 2018

# Make a directory for the combined assembly files.
mkdir -p ../data/subjects/combined

# Move assemblies into the common directory.
mv ../data/subjects/remote/*.fasta ../data/subjects/combined
mv ../data/subjects/local/merged/*.fasta ../data/subjects/combined

# Clean up empty directories.
rm -rf ../data/subjects/remote
rm -rf ../data/subjects/local/merged