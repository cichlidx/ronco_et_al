# m_matschiner Wed May 3 15:32:37 CEST 2017

# Make the output directory if it doesn't exist yet.
mkdir -p ../res/fastq

# Use picard-tools' SamToFastq function to generate a fastq from each bam file.
for i in ../res/bam/*.bam
do
    file_id=`basename ${i%.bam}`
    java -jar PATH_TO_PICARD/picard.jar SamToFastq \
	I=${i} \
	FASTQ="../res/fastq/${file_id}.R1.fastq" \
	SECOND_END_FASTQ="../res/fastq/${file_id}.R2.fastq" \
	QUIET=TRUE \
	VALIDATION_STRINGENCY=SILENT
done