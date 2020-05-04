# Reconstruction of Cichlidx representative
#!/usr/bin/env Rscript

##### ##### ##### ##### ##### command line argument # ##### ##### ##### ##### #####
CichlidXSpecimen = commandArgs(TRUE)[1] 
Exonselection = commandArgs(TRUE)[2] 
UniqTranscriptselection = commandArgs(TRUE)[3] 
thresholrd = commandArgs(TRUE)[4] 
##### ##### ##### ##### ##### module load ##### ##### ##### ##### ##### ##### #####

#
#
#

#import libraries:
library(Biostrings)
library(IRanges)
library(seqinr)



dateToday=Sys.Date()


## Open Exon placed on tilapia for this specimen: 
ExonListFinal = read.table(Exonselection,h=T,sep='\t',quote='"',stringsAsFactors = F)
cichlidX_ExonInfo =  read.table(paste('/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/Augustus_codingseq_',CichlidXSpecimen,'_PlacedOnTilpiaCDS.txt',sep=''),h=T,sep='\t',quote='"',stringsAsFactors = F)


## Open the inital fasta: 
Inital = readDNAStringSet("/scicore/home/salzburg/GROUP/RNA_seq/FASTA_GTF_GFF/otilapia/GCF_001858045.1_ASM185804v2_genomic.fa", "fasta")
Inital_contigs = names(Inital)


cichlidX_fasta = readDNAStringSet(paste("/scicore/home/salzburg/eltaher/cichlidX/result/Augustus/",CichlidXSpecimen,"/GenePrediction_Augustus_",CichlidXSpecimen,"3.codingseq",sep=''), "fasta")
cichlidX_contigs = names(cichlidX_fasta)

# Representative sequences: 
Representatif_transcrip_BPcoverage = read.table(UniqTranscriptselection,h=T,sep='\t',quote='"',stringsAsFactors = F)

# All TranscriptRepresentation: 
TranscriptRepresentation = read.table('/scicore/home/salzburg/eltaher/cichlidX/data/ProteinCatalogue.txt',h=T,quote='"',stringsAsFactors = F,sep='\t')


## Replace all exon present in the transcript by its real nucleotid:
transcript_fasta_with_NN = list()

for (i in as.vector(Representatif_transcrip_BPcoverage$proteinID)) {

  # Tilapia information related to the this transcript:
  transcriptExon_info = ExonListFinal[which(ExonListFinal$proteinID==i),]
  transcriptExon_info = transcriptExon_info[order(transcriptExon_info$cds_coord,decreasing = F),]
  strand = transcriptExon_info$strand[1]
  
  # All exon belonging to this exon: 
  TranscriptRepresentation_exons = TranscriptRepresentation$proteinCDSStructure[which(TranscriptRepresentation$proteinID==i)]
  
  # All exon belonging to the this transcript in list: (from smaller exon to bigger exon) 
  ExonList = unlist(strsplit(TranscriptRepresentation_exons,';'))
  
  if (strand == '-'){
    ExonList = rev(ExonList)
  }
  
  
  # Which of the inital exons of transcript i are present in at least 80% genomes: 
  pos_existing = seq(1:length(ExonList))[which(ExonList%in%transcriptExon_info$cds_coord)]
  pos_notexisting = seq(1:length(ExonList))[-which(ExonList%in%transcriptExon_info$cds_coord)]
  
  
  # Select the same for the cichlidx Info: 
  transcriptExon_Cichlidx_info = cichlidX_ExonInfo[which(cichlidX_ExonInfo$proteinID==i),]
  transcriptExon_Cichlidx_info = transcriptExon_Cichlidx_info[order(transcriptExon_Cichlidx_info$cds_coord,decreasing = F),]
  
  
  Vector_transcriptL = list()  
  Non_Na_exon = list()
  
  
  for (a in 1:length(ExonList)) {
    
    if (a%in%pos_existing) {
      
      ## CichlidX info: 
      ExonTarget_cichlidx = transcriptExon_Cichlidx_info[which(transcriptExon_Cichlidx_info$cds_coord==ExonList[a]),]
      
      if (is.na(ExonTarget_cichlidx$Coord.Augustus)=='TRUE') {
        
        exon_coo = strsplit(ExonList[a],':')[[1]][2]
        start = strsplit(exon_coo,'-')[[1]][1]
        stop = strsplit(exon_coo,'-')[[1]][2]
        Len = as.numeric(stop)-as.numeric(start)+1
        nonNucleotidic_rep= paste(rep('N',Len),collapse = '')
        Non_Na_exon = append(Non_Na_exon,nonNucleotidic_rep)
        
        
      } else {
        
        genID = strsplit(ExonTarget_cichlidx$Coord.Augustus,':')[[1]][1]
        geneID_coord = strsplit(ExonTarget_cichlidx$Coord.Augustus,':')[[1]][2]
        
        pos_gen = grep(genID,cichlidX_contigs)
        start = strsplit(geneID_coord ,'-')[[1]][1]
        stop = strsplit(geneID_coord ,'-')[[1]][2]
        Sequence_exon = as.character(cichlidX_fasta[[pos_gen]][as.numeric(start):as.numeric(stop)])
        Non_Na_exon = append(Non_Na_exon,Sequence_exon)
      }

      
    } else {
      
      exon_coo = strsplit(ExonList[a],':')[[1]][2]
      start = strsplit(exon_coo,'-')[[1]][1]
      stop = strsplit(exon_coo,'-')[[1]][2]
      Len = as.numeric(stop)-as.numeric(start)+1
      nonNucleotidic_rep= paste(rep('N',Len),collapse = '')
      Non_Na_exon = append(Non_Na_exon,nonNucleotidic_rep)
    }
  }
  
  # Compare reconstructed and the substitution new: 
  reconstructed_seq = paste(Non_Na_exon,collapse = '')
  LEN_TRANSCRIPT = nchar(reconstructed_seq)
  
  # Transform to list: 
  pos_list = length(transcript_fasta_with_NN) + 1
  transcript_fasta_with_NN = append(transcript_fasta_with_NN, as.list(strsplit(reconstructed_seq, "")))
  names(transcript_fasta_with_NN)[pos_list] = paste(i,'|Geneid:',transcriptExon_info$geneID[1], '|ProteinLen:',LEN_TRANSCRIPT,'|strand:',strand,'|specimenID:',CichlidXSpecimen, sep='') 
  
}
write.fasta(sequences = transcript_fasta_with_NN, names = names(transcript_fasta_with_NN), nbchar = 80, file.out = paste("/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/",CichlidXSpecimen,"_reconstructed_sequences_seqCDS_",thresholrd,"per_",nrow(Representatif_transcrip_BPcoverage),"Genomes_",dateToday,".fna",sep=''))




