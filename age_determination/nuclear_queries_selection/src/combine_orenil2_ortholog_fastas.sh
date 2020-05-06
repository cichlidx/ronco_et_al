# m_matschiner Mon Oct 15 17:02:49 CEST 2018

# Load the ruby module.
module load ruby/2.1.5

# Combine the nuclear sequences for all tilapia queries into a single file.
rm -f tmp.fasta
touch tmp.fasta
for fasta in ../res/queries/orenil2/ENS*[0-9]_nucl.fasta
do
    id=`basename ${fasta%_nucl.fasta}`
    seq=`head -n 2 ${fasta} | tail -n 1 | tr -d "-"`
    echo -e ">${id}\n${seq}" >> tmp.fasta
done
ruby remove_empty_seqs_from_fasta.rb tmp.fasta ../res/queries/orenil_nucl.fasta

# Combine the amino-acid sequences for all tilapia queries into a single file.
rm -f tmp.fasta
touch tmp.fasta
for fasta in ../res/queries/orenil2/ENS*[0-9].fasta
do
    id=`basename ${fasta%.fasta}`
    seq=`head -n 4 ${fasta} | tail -n 1 | tr -d "-"`
    echo -e ">${id}\n${seq}" >> tmp.fasta
done
ruby remove_empty_seqs_from_fasta.rb tmp.fasta ../res/queries/orenil.fasta
rm -f tmp.fasta

# Clean up.
rm -r ../res/queries/orenil2
