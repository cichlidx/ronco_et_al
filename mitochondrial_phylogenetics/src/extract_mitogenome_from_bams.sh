# m_matschiner Tue Apr 25 09:59:50 CEST 2017

# Define the external bam directory.
bam_directory="../data/bam" # change depending on where bam files currently are located.

# Define the chromosome id of the mitochondrial genome.
mitogenome_id="NC_013663"

# Load the samtools module.
module load samtools/1.3.1

# Make the output directories if they don't exist yet.
mkdir -p ../res/sam
mkdir -p ../res/bam

# Extract the mitochondrial part from each bam file.
for i in ${bam_directory}/*.merged.sorted.dedup.realn.bam
do
    file_id=`basename ${i%.merged.sorted.dedup.realn.bam}`
    samtools view -h ${i} ${mitogenome_id} > ../res/sam/${file_id}.${mitogenome_id}.sam
done

for i in ../res/sam/*.sam
do
    file_id=`basename ${i%.sam}`
    samtools view -b -h ${i} > ../res/bam/${file_id}.bam
done