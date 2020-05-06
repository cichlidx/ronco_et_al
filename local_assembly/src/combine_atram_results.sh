# m_matschiner Mon Sep 24 14:51:31 CEST 2018

# Load modules.
module load ruby/2.1.5

# Clean up in current directory.
rm -f tmp.*_orenil_exons??.txt

# Get a list of all specimens analyzed with atram.
specimens=`ls ../res/atram/*_orenil_exons* | cut -d "/" -f 4 | cut -d "." -f 2 | cut -d "_" -f 1 | sort | uniq`

# Combine the results of all atram analyses.
for specimen in ${specimens}
do
    combined_fasta=../res/atram/${specimen}.atram.fasta
    if [ ! -f ${combined_fasta} ]
    then
	echo -n "Writing file ${combined_fasta}..."
	cat ../res/atram/${specimen}_orenil_exons??/${specimen}.${specimen}_orenil_exons??_*.filtered_contigs.fasta > ${combined_fasta}
	echo " done."
    else
	echo "ERROR: File ${combined_fasta} already exists!"
	exit 1
    fi
done

# Change the ids in all fasta file so that they are unique per file.
for specimen in ${specimens}
do
    combined_fasta=../res/atram/${specimen}.atram.fasta
    ruby rename_fasta_ids.rb ${combined_fasta} atram tmp.fasta
    mv -f tmp.fasta ${combined_fasta}
done

# Clean up in results directory.
rm -rf ../res/atram/*_orenil_exons*