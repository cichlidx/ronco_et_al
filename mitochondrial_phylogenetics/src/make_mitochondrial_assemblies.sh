# m_matschiner Thu May 4 00:50:07 CEST 2017

for i in ../res/bam/*.bam
do
    sample_id=`basename ${i%.NC_013663.bam}`
    if [ ! -f ../res/fasta/${sample_id}.NC_013663.fasta ]
    then
	bash make_mitochondrial_assembly.sh ${sample_id}
    fi
done