#!/bin/bash

##########################################################################################
### Virginie Ricci, April 2020
##########################################################################################


DATE=`date '+%d-%m-%Y %H:%M:%S'`
echo 'Start of the job' $DATE
##########################################################################################


module purge
module load Perl/5.22.2-goolf-1.7.20
module load TRF/4.0.9.linux64
module load RMBlast/2.2.28 BLAST+/2.2.28  
module load RECON/1.08-goolf-1.7.20-RepeatModeler 
module load RepeatScout/1.0.5-goolf-1.7.20-RepeatModeler 
module load nseg/1.0-goolf-1.7.20

bin_RMasker='/Path/to/RepeatMasker/commands/'
export PATH=$bin_RMasker:$PATH

bin_RMasker_util='/Path/to/RepeatMasker/util/'
export PATH=$bin_RMasker_util:$PATH

bin_RModeler='/Path/to/RepeatModeler/commands/'
export PATH=$bin_RModeler:$PATH


##########################################################################################


#####
# This script can be run as an array job using the following command:
# $(sed -n ${SLURM_ARRAY_TASK_ID}p /Path/to/data/List_genome_IDs.txt)
# /Path/to/data/List_genome_IDs.txt includes Genome_IDs
#####

# Genome ID and its corresponding genome .fasta file 
ID='Genome_ID'
ID_fasta=${ID}.fasta
path_ID='/Path/to/fasta/files/'
path_ID_fasta=${path_ID}${ID_fasta}

# faidx command from SAMtools
# Get scaffold and length in .tsv file
echo 'faidx for' $ID
samtools faidx ${path_ID_fasta}
cat ${path_ID_fasta}.fai | awk '{print $1,$2}' > ${path_ID_fasta}.fai.tsv


##########################################################################################
###################################### REPEATMASKER  #####################################

path_RMasker='/Path/to/RepeatMasker/outputs/'
path_ID_RMasker=${path_RMasker}${ID}/
mkdir -p $path_ID_RMasker


# RepeatMasker command
echo 'RepeatMasker for' $ID
RepeatMasker -species cichlidae -xsmall -pa 8 -s -dir $path_ID_RMasker -e ncbi -a $path_ID_fasta

# rmOutToGFF3.pl command
# Convert RepeatMasker output to gff3 format
echo 'rmOutToGFF3.pl for' $ID
rmOutToGFF3.pl ${path_ID_RMasker}${ID_fasta}.out > ${path_ID_RMasker}${ID_fasta}.out.gff3

# buildSummary.pl command
# Build detailed summary of RepeatMasker with output
echo 'buildSummary.pl for' $ID
buildSummary.pl -species Cichlidae -genome ${path_ID_fasta}.fai.tsv -useAbsoluteGenomeSize ${path_ID_RMasker}${ID_fasta}.out > ${path_ID_RMasker}${ID_fasta}.out.detailed


##########################################################################################
###################################### REPEATMODELER #####################################

path_RModeler='/Path/to/RepeatModeler/outputs/'
path_ID_RModeler=${path_RModeler}${ID}/
mkdir -p $path_ID_RModeler


# BuildDatabase command
# Create NCBI Blast database of $ID_fasta (full path to the genome .fasta file)
echo 'BuildDatabase for' $ID
BuildDatabase -name ${path_ID_RModeler}${ID}_RM -engine ncbi $path_ID_fasta

# RepeatModeler command
# Identify de-novo repeat families and create species-specific repeat library
echo 'RepeatModeler for' $ID
cd $path_ID_RModeler
RepeatModeler -database ${path_ID_RModeler}${ID}_RM -engine ncbi -pa 5
cd $HOME


##########################################################################################
###################### REPEATMASKER LIB (WITH REPEATMODELER OUTPUT) #####################

# Create cichlidae repeats library from RepeatMasker Library
cichlidae_repeats=/Path/to/Lib/cichlidae_repeats.fa
queryRepeatDatabase.pl -species cichlidae > $cichlidae_repeats

# Genome .fasta file masked by the first run of RepeatMasker command
path_masked_ID_fasta=${path_ID_RMasker}${ID_fasta}.masked

# RepeatModeler output
RModeler_ID_lib=${path_ID_RModeler}${ID}_RM-families.fa


path_RMasker_lib='/Path/to/RepeatMasker/outputs/lib/'
path_ID_RMasker_lib=${path_RMasker_lib}${ID}/
mkdir -p $path_ID_RMasker_lib


# Merge of RepeatModeler ouput and cichlidae repeats library
cat $RModeler_ID_lib $cichlidae_repeats > ${path_ID_RMasker_lib}custom_lib.fa

# RepeatMasker with lib command 
echo 'Lib: RepeatMasker for' $ID
RepeatMasker -xsmall -pa 8 -s -dir $path_ID_RMasker_lib -e ncbi -a -lib ${path_ID_RMasker_lib}custom_lib.fa $path_masked_ID_fasta

# rmOutToGFF3.pl command
# Convert RepeatMasker output to gff3 format
echo 'Lib: rmOutToGFF3.pl for' $ID
rmOutToGFF3.pl ${path_ID_RMasker_lib}${ID_fasta}.masked.out > ${path_ID_RMasker_lib}${ID_fasta}.masked.out.gff3

# buildSummary.pl command
# Build detailed summary of RepeatMasker with lib output
echo 'Lib: buildSummary.pl for' $ID
buildSummary.pl -species Cichlidae -genome ${path_ID_fasta}.fai.tsv -useAbsoluteGenomeSize ${path_ID_RMasker_lib}${ID_fasta}.masked.out > ${path_ID_RMasker_lib}${ID_fasta}.masked.out.detailed


##########################################################################################
DATE=`date '+%d-%m-%Y %H:%M:%S'`
echo 'End of the job' $DATE
