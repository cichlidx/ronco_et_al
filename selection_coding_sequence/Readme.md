
# Pipeline for selection of coding sequence


## 1. Augustus on DNA denovo assemblies: 
### AUGUSTUS, a software for gene prediction in eukaryotic genomic sequences that is based on a generalized hidden Markov model, a probabilistic model of a sequence and its gene structure.
### Parameters: --species=zebrafish
### ARRAY JOB on all assemblies:
### 1.1 script:
/scicore/home/salzburg/eltaher/cichlidX/script/Augustus/sbatch_abInitio_DNAassembly
### 1.2 output:     # Format = gff3
/scicore/home/salzburg/eltaher/cichlidX/result/Augustus/${SPECIMEN}/GenePrediction_Augustus_${SPECIMEN}.gff3

## 2. get annotation for coding sequence: from gff3 to fasta ####
### Loop or array job on all gff3 gene prediction file:
### script:
/scicore/home/salzburg/eltaher/cichlidX/script/Augustus/getAnnotFasta
### cat /scicore/home/salzburg/eltaher/cichlidX/script/Augustus/getAnnotFasta:
cd /scicore/home/salzburg/eltaher/cichlidX/result/Augustus
for SPECIMEN in `ls`; do /scicore/soft/apps/Augustus/3.2.3-goolf-1.7.20/scripts/getAnnoFasta.pl  ${SPECIMEN}/GenePrediction_Augustus_${SPECIMEN}.gff3; done
### output:     # Format = Fasta: amino acid (aa) and nuclotidic sequences (codingseq)
/scicore/home/salzburg/eltaher/cichlidX/result/Augustus/${SPECIMEN}/GenePrediction_Augustus_${SPECIMEN}3.codingseq
/scicore/home/salzburg/eltaher/cichlidX/result/Augustus/${SPECIMEN}/GenePrediction_Augustus_${SPECIMEN}3.aa

## 3. GMAP coding sequences against tilapia genome GCF_001858045.1_ASM185804v2 ####
### ARRAY JOB on all assemblies:
### script:
/scicore/home/salzburg/eltaher/cichlidX/script/GMAP/sbatch_GenePrediction_Augustus_codingseq_against_tilapia
### output:   # Format = gff3 and sam
/scicore/home/salzburg/eltaher/cichlidX/result/GMAP/augustus_coding_sequence/${SPECIMEN}/GMAP_GenePrediction_Augustus_${SPECIMEN}_codingseq_qcov50_iden80.gff3
/scicore/home/salzburg/eltaher/cichlidX/result/GMAP/augustus_coding_sequence/${SPECIMEN}/GMAP_GenePrediction_Augustus_A108_codingseq_qcov50_iden80.sam
/scicore/home/salzburg/eltaher/cichlidX/result/GMAP/augustus_coding_sequence/${SPECIMEN}/GMAP_GenePrediction_Augustus_A108_codingseq_qcov50_iden80_mapped.bam
/scicore/home/salzburg/eltaher/cichlidX/result/GMAP/augustus_coding_sequence/${SPECIMEN}/GMAP_GenePrediction_Augustus_A108_codingseq_qcov50_iden80_mapped.sortedByCoord.out.bam
/scicore/home/salzburg/eltaher/cichlidX/result/GMAP/augustus_coding_sequence/${SPECIMEN}/GMAP_GenePrediction_Augustus_A108_codingseq_qcov50_iden80_mapped.sortedByCoord.out.fasta


## 4. Translate cichlidx coding sequences mapping to Tilapia genome from gff3 to txt (keep only exon info) (4.1) and then place all exon mapping information on all Tilapia exon info (4.2) 
### Loop or array job on all assemblies:
### Full script:
/scicore/home/salzburg/eltaher/cichlidX/script/Augustus/sbatch_From_GFF3_to_PlacedOnTilpiaCDSTxt
### cat /scicore/home/salzburg/eltaher/cichlidX/script/Augustus/From_GFF3_to_PlacedOnTilpiaExonTxt:
cd /scicore/home/salzburg/eltaher/cichlidX/result/GMAP/augustus_coding_sequence
export SPECIMEN=`cat /scicore/home/salzburg/eltaher/cichlidX/data/dNdS_genomes/speciesList.txt | head -n $SLURM_ARRAY_TASK_ID | tail -n 1`
python /scicore/home/salzburg/eltaher/cichlidX/script/Augustus/Gff3_parser_CichlidX_genomes_CDS.py -i /scicore/home/salzburg/eltaher/cichlidX/result/GMAP/augustus_coding_sequence/${SPECIMEN}/GMAP_GenePrediction_Augustus_${SPECIMEN}_codingseq_qcov50_iden80.gff3 -o /scicore/home/salzburg/eltaher/cichlidX/result/GMAP/augustus_coding_sequence/${SPECIMEN}/GMAP_GenePrediction_Augustus_${SPECIMEN}_codingseqCDS_qcov50_iden80.txt
Rscript /scicore/home/salzburg/eltaher/cichlidX/script/Augustus/CondingSequences_predictionCDS.R ${SPECIMEN}
### output:
/scicore/home/salzburg/eltaher/cichlidX/result/GMAP/augustus_coding_sequence/${SPECIMEN}/GMAP_GenePrediction_Augustus_${SPECIMEN}_codingseqCDS_qcov50_iden80.txt
### 4.1 (python):
### All cichlidx specimen exon (or CDS) information. Only exon information are kept and store in txt format
### 4.2: R output:
### All cichlidx exon information placed (intersection) on the tilapia features "CDS":
### 4.2.1
### Detailed (exonID.Augustus/Codingseq.Augustus/start.Augustus/stop.Augustus/strand.Augustus) information on all Augustus exons placed on all tilpia exons
/scicore/home/salzburg/eltaher/cichlidX/result/GMAP/augustus_coding_sequence/${SPECIMEN}/GMAP_GenePrediction_Augustus_${SPECIMEN}_codingseq_qcov50_iden80_PlacedOnTilpiaCDS.txt
### 4.2.2
### Summary (Coord.Augustus which is a combination of Codingseq.Augustus/start.Augustus/stop.Augustus/strand.Augustus) information on all Augustus exons placed on all tilpia exons
### ALL tilapia exon are there even if they don't exist in the specimen ==> Coord.Augustus = 'NA' if the exon boundries are not 100% identical in the GMAP_GenePrediction_Augustus_${SPECIMEN}_codingseq_qcov50_iden80.txt
/scicore/home/salzburg/eltaher/cichlidX/result/GMAP/augustus_coding_sequence/${SPECIMEN}/Augustus_codingseq_${SPECIMEN}_PlacedOnTilpiaCDS.txt

## 5. Exon mapping information placed on tilapia (4.2) to another directory  ####
### Loop on all assemblies directories:
### Command:
cd /scicore/home/salzburg/eltaher/cichlidX/result/GMAP/augustus_coding_sequence
for SPECIMEN in `ls`
do
mv /scicore/home/salzburg/eltaher/cichlidX/result/GMAP/augustus_coding_sequence/${SPECIMEN}/Augustus_codingseq_${SPECIMEN}_PlacedOnTilpiaCDS.txt /scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/Augustus_codingseq_${SPECIMEN}_PlacedOnTilpiaCDS.txt
done
### output:
### For one file:
/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/Augustus_codingseq_${SPECIMEN}_PlacedOnTilpiaCDS.txt
### For all files:
ls /scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaExon/Augustus_codingseq_*_PlacedOnTilpiaCDS.txt

## 6. GCF_001858045.1_ASM185804v2 representative transcripts selection and transcript reconstruction
### 6.1 Selection of representative exons (and the genes they are included in): exon that are fully present (same boundries, start and stop) in at least 80% of the specimen (80% is a threshold and can be changed)
### 6.2 Select all GCF_001858045.1_ASM185804v2 transcripts that have those representative exons
### 6.3 Select the most representative transcript for each geneID (most representative = How much much of its exon are consider as "reprensative" * the transcript length)
### 6.4 Reconstruct the most representative GCF_001858045.1_ASM185804v2 transcript with "NNNN" entries for exons present in that most representative transcript but not part of the most reprensative exon list.
### 6.5 Reverse and complement all transcripts present on the negative strand
### Full script:
Rscript /scicore/home/salzburg/eltaher/cichlidX/script/Augustus/SharedCDS.R 0.8 [threshold minimum of presence]
### Output:
### 6.1:
### Most representive exons (same exon boundries in the coding sequence as the tilapia for at least 80% of the specimens):
/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/TilapiaCDSKept_positiveSelection_0.8per_528Genomes_250992CDS_2018-10-03.txt
### Genes (id and description) for all selected exons (same exon boundries for at least 80% of the specimens):
/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/GenesKept_positiveSelection_0.8per_528Genomes_14973genes_2018-10-03.txt
### 6.2: Select all GCF_001858045.1_ASM185804v2 transcripts that have those representative exons
/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/TilapiaProteinForRepresentativeCDS_positiveSelection_0.8per_528Genomes_34084proteins_2018-10-03.txt
### 6.3: Select the most representative transcript for each geneID (Not the same amount than genes selected before (16201 instead of 1614) because some genes have no transcript ==> Not present in the output !
/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/TilapiaRepresentativeProteins_positiveSelection_0.8per_528Genomes_14972UniqueProteins_2018-10-03.txt


### 6.4 Reconstruct the most representative GCF_001858045.1_ASM185804v2 transcript with "NNNN" entries for exons present in that most representative transcript but not part of the most reprensative exon list.
### WARNING !! In that fasta file, the transcript on the negative strand are not yet "reversed and completed" !! the sequence are written like they would be on the positive strand:
### Twice because one file is with the reference fully presented (no NNN) and one with the missing CDS with (NNN)
/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/GCF_001858045.1_ASM185804v2_reconstructed_Full_sequences_seqCDS_0.8per_528Genomes_notreversedSequences_2018-10-03.fna
/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/GCF_001858045.1_ASM185804v2_reconstructed_sequences_seqCDS_0.8per_528Genomes_notreversedSequences_2018-10-03.fna
### 6.5 Reverse and complement all transcript present on the negative strand:
### here we grep the "strand:-" in the headers and use the function "reverseComplement(x = ids_to_reverse)" from the biostring package in R to reverse and complement the transcripts present on the negative strand
### Final selection:
/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/GCF_001858045.1_ASM185804v2_reconstructed_Full_sequences_seqCDS_0.8per_471Genomes_reversedSequences_20190606.fna

## 7. Reconstruct the cichlidX coding sequences that correspond to the most representative GCF_001858045.1_ASM185804v2 Tilapia transcripts
### 7.1 Reconstruct the most representative GCF_001858045.1_ASM185804v2 transcript with the corresponding cichlidx coding sequences [See Augustus_codingseq_${SPECIMEN}_PlacedOnTilpiaExon.txt column "Coord.Augustus"] for the most reprenstative exons and "NNNN" for exons that are not part of the most reprensative exon list.
# CARFUL: If the exon is in part of the most representative exon list, but it does not exist in that specimen (must be present in 80% of the genomes to be in the list and not 100% so it is normal than some of thoese representative exons will not be in all specimen) the sequence "NNN" (number of time =size of the exon) must be added !
### 7.2 Reverse and complement all transcripts present on the negative strand
### Full script:
### Array on all specimens
/scicore/home/salzburg/eltaher/cichlidX/script/Augustus/sbatch_Representative_sequences_reconstruction_cichlidx_cds
### Outputs:
### 7.1 : most representative GCF_001858045.1_ASM185804v2 transcript with the corresponding cichlidx coding sequences, but negative strand genes are in the wrong direction and not complemented
/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/${SPECIMEN}_reconstructed_sequences_seqExon_shared80perGenomes_notreversedSequences.fna
### 7.2: Final sequence for the most representative GCF_001858045.1_ASM185804v2 transcript with the corresponding cichlidx coding sequences : Negative stranded genes have been reveresed and complemented
/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/${SPECIMEN}_reconstructed_sequences_seqExon_shared80perGenomes_reversedSequences.fna

## 8. Delete the fasta with the negative stranded genes in the wrong direction:
rm /scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/*_reconstructed_sequences_seqExon_shared80perGenomes_notreversedSequences.fna


## 9. Make one alignement per sequences (Reference sequence aligned with all reconstructed specimens for each selected protein sequence):
### Account for frameshift ==> macse2 developpement by inera
### Full script:
### Array on all sequences:
/scicore/home/salzburg/eltaher/cichlidX/script/macse/sbatch_MultipleAlignment_of_Coding_SEquences
### Outputs:
### All outputs in the directory: /scicore/home/salzburg/eltaher/cichlidX/result/macse (3 outputs per sequence)
### 9.1: Index each reconstructed sequences fasta for each specimen (and the reference): (Array for each sequences, so it index the fasta per specimen only for the first sequence (array task #1 and then use it for the other sequences)
/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/A108_reconstructed_sequences_seqCDS_0.8per_14972Genomes_2018-10-04.fna.fai
### 9.2: create one fasta file per sequences with the corresponding reference sequence and the corresponding reconstructed sequence for each specimen. For eg for the sequences NP_001266382:
/scicore/home/salzburg/eltaher/cichlidX/result/macse/NP_001266382.fasta
### 9.3: Alignment for each sequences all specimen with the reference on an acidamino base and on a nucleotide base:
/scicore/home/salzburg/eltaher/cichlidX/result/macse/NP_001266382.macse.aa.fasta
/scicore/home/salzburg/eltaher/cichlidX/result/macse/NP_001266382.macse.nucl.fasta


## 10. Calculate the dNdS for all pairwise "reference-specimen" sequences:
### Cut from the "all specimen alignement" per sequence and then calculte the dNdS with the YN00 from PAML:
### Loop tough across all sequences and calculte one dNdS value for each reference-specimen pair: create 5 file per pair (too much for the cluster).
### To avoid multiple file, we keep only the standard summary file of the test which keeps all results (equivalent to a logfile) ==>
### Full script:
### Array on all sequences:
### CODEML:
/scicore/home/salzburg/eltaher/cichlidX/script/YN00/sbatch_codeml
### output:
/scicore/home/salzburg/eltaher/cichlidX/result/PAML
### Outputs:
### Create one intermediate directory with multiple information:
### the standard output file copy into dNdS directory:
mkdir /scicore/home/salzburg/eltaher/cichlidX/result/PAML/${SEQUENCE}/${specimen}

## 11. Parse for each sequence all information related to dNdS in the summary output file:
### Run a custom-made python script on LOCAL COMPUTER
### Be carful that the computer is linked to scicore:
/Users/athimed/Dropbox/PycharmProjects/PhD/PhD/parse_yn00.py
### Outputs:
### Table with dN and dS outputs for each sequence separate, with all specimen:
/scicore/home/salzburg/eltaher/cichlidX/result/dNdS/dN.dS.txt
### I previously deleted the sequence that had NaN for all the pairwise dNdS  ! ==> Probleme with the alignement (coming from the inital assemblies or the linked with the reference made by gmap)

## 12. dNdS calculation per specimen:
### script
/scicore/home/salzburg/eltaher/cichlidX/script/YN00/dNdS_codeml_20201601_FinalGenomeSelection.R
### output:
/scicore/home/salzburg/eltaher/cichlidX/result/dNdS/FinalTable_codeml_dNdS_471specimens_15294_OneValuePerGenome_Sum_for_dN_dS_and_dNdS_20201601.summary.txt
