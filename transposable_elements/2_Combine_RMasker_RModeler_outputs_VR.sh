#!/bin/bash
  
##########################################################################################
### Virginie Ricci, April 2020
##########################################################################################


DATE=`date '+%d-%m-%Y %H:%M:%S'`
echo 'Start of the job' $DATE
##########################################################################################


module purge
module load Python/3.5.2-goolf-1.7.20
module load Biopython/1.72-goolf-1.7.20-Python-3.5.2


##########################################################################################


#####
# This script executes 2_Combine_RMasker_RModeler_outputs_VR.py in a for loop
#####

path_data='/Path/to/data/'

for ID in $(cat ${path_data}List_genome_IDs.txt); do
	ID_fasta=${ID}.fasta

	RM_type='RMasker'

	path_RMasker='/Path/to/RepeatMasker/outputs/'
	path_ID_RMasker=${path_RMasker}${ID}/

	tbl=${ID_fasta}.out.detailed

	python Combine_RepeatMasker_outputs.py $tbl $path_ID_RMasker $path_data $RM_type


	RM_type='RMasker_RModeler'

	path_RMasker_lib='/Path/to/RepeatMasker/outputs/lib/'
	path_ID_RMasker_lib=${path_RMasker_lib}${ID}/

	tbl=${ID_fasta}.masked.out.detailed

	python Combine_RepeatMasker_outputs.py $tbl $path_ID_RMasker_lib $path_data $RM_type

done


##########################################################################################
DATE=`date '+%d-%m-%Y %H:%M:%S'`
echo 'End of the job' $DATE
