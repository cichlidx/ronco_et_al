# Presence threshold:
#!/usr/bin/env Rscript

thresholrd = commandArgs(TRUE)[1] 

#########################################################

##      Idnetification and reconstruction of          ##
##      Tilapia representative transcripts            ##
##      (% exon TOTALY present in Genomes)            ##

#########################################################

dateToday=Sys.Date()

##########################################################
#### 1. Open all mapping information per CichlidX genome: 
##########################################################

## Input : table with all Tilapia exons info [columns 1:9] with the corresponding position in the cichlidX genomes
# List the output directory:
filenames <- list.files("/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS", pattern="Augustus_codingseq", full.names=TRUE) # 528 files

## If we need a subset: 
# Work only with specimens found in the radition (except we added Oretan)
# Selection of specimen in the radiation:
SpecimenInRad = read.table('/scicore/home/salzburg/eltaher/cichlidX/data/dNdS_genomes/speciesList.txt',h=F,quote='"',stringsAsFactors = F,sep='\t')
filenamesIds = unlist(lapply(filenames, function(x) strsplit(x,'_')[[1]][5]))
pos_keep = which(filenamesIds%in%SpecimenInRad$V1)
filenames = filenames[pos_keep]

# Read.table on input files and store in list
# All tables are stored in a list with ONLY the cichlidX cds corrdinate infromation [,10], the Tilapa cds info in another variable bellow
ldf <- lapply(filenames, function(x) read.table(x,header=T,quote='"',sep='\t',stringsAsFactors = F)[,10])

# Name the element in the list with the corresponding specimenID: 
Name2 = unlist(lapply(lapply(filenames,function(x) strsplit(x,'/')[[1]][9]),function(x) strsplit(x,'_')[[1]][3]))

# Add tribe infos to specimen ids
AssemblyStatus = read.table('/scicore/home/salzburg/eltaher/cichlidX/data/AssemblyStatus_20180816.txt',h=T,sep='\t',quote='"',stringsAsFactors = F)
AssemblyStatus = AssemblyStatus[which(AssemblyStatus$DNA_Tube%in%Name2),]
AssemblyStatus = AssemblyStatus[match(Name2,AssemblyStatus$DNA_Tube),]
names(ldf) = paste(AssemblyStatus$speciesID,AssemblyStatus$DNA_Tube,AssemblyStatus$speciesIDTribe,AssemblyStatus$sex,sep='_')

########################################################
#### 2. Find shared CDS between the different genomes:
########################################################

# Merge all input file into a huge matrix: 
# 2.1 Matrix with only the cichlidx EconCoordinate information
ldf_values = ldf
LDF_MATRIX_allSpecimen = do.call("cbind", ldf_values)
dim(LDF_MATRIX_allSpecimen) # 697'818 (number of tilapia cds) and 490 (number of specimen)  

# How many tilapia's CDS represented as NA (missing value) in the specimens:
CDS_per_specimen = apply(LDF_MATRIX_allSpecimen,2,function(x) length(which(is.na(x))))
par(mfrow=c(1,1))
CDS_per_specimen = as.data.frame(CDS_per_specimen)
CDS_per_specimen$tribe = unlist(lapply(rownames(CDS_per_specimen),function(x) strsplit(x,'_')[[1]][3]))
boxplot(CDS_per_specimen$CDS_per_specimen~CDS_per_specimen$tribe,las=2)




# 2.2 Tilapia cds information: 
LDF_MATRIX_specimenInfo = read.table(filenames[1],header=T,quote='"',sep='\t',stringsAsFactors = F)[,1:9]
LDF_MATRIX_allSpecimenColNames = data.frame('DNA_Tube'=colnames(LDF_MATRIX_allSpecimen))

#allMatrix = cbind(LDF_MATRIX_specimenInfo,LDF_MATRIX_allSpecimen)
write.table(allMatrix,paste('/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/TilapiaCDS_placed_DenovoGenomes_',thresholrd,'per_490Genomes_',dateToday,'.txt',sep=''),row.names = F,col.names = T,sep='\t',quote=F)

# 2.3 Calculate: Each cds, present in how many specimen: 
VECTOR_VAL = apply(LDF_MATRIX_allSpecimen,1,function(x) length(x)-length(which(is.na(x))))
names(VECTOR_VAL) = LDF_MATRIX_specimenInfo$cds_coord
boxplot(as.vector(VECTOR_VAL))

# 2.4 Statistics: 
# Totaly absent in all genome (the CDS has NA in all cichlidX)
table(VECTOR_VAL)[1] # 76'176 cds found un zero chichlid genome


# Boxplot for the respresentation of the cds in each category. 
# Category = cds present x genomes; cds must be present in at least 1 genome, we exluded cds absent in all genomes

# 1. Barplot with number of cds, shared by all x genomes
# Exon totaly covred in at least 1 genome: 
ExonTab = table(VECTOR_VAL)[2:length(table(VECTOR_VAL))]

# 2. Barplot with the toal of length of cds each category
ExonLen_sumExonTab = list()
for (a in names(ExonTab)) {
  exonCoor = names(VECTOR_VAL)[which(VECTOR_VAL==a)]
  A = sum(LDF_MATRIX_specimenInfo$Exonlength[which(LDF_MATRIX_specimenInfo$cds_coord%in%exonCoor)])
  ExonLen_sumExonTab = append(ExonLen_sumExonTab,A)
}

# 3. Barplot with the number of gene represented by the exon in each category
GeneIDNum_ExonTab = list()
GeneIDList_ExonTab = list()
for (a in names(ExonTab)) {
  exonCoor = names(VECTOR_VAL)[which(VECTOR_VAL==a)]
  A = length(unique((LDF_MATRIX_specimenInfo$geneID[which(LDF_MATRIX_specimenInfo$cds_coord%in%exonCoor)])))
  B = unique((LDF_MATRIX_specimenInfo$geneID[which(LDF_MATRIX_specimenInfo$cds_coord%in%exonCoor)]))
  GeneIDNum_ExonTab = append(GeneIDNum_ExonTab,A)
  GeneIDList_ExonTab = append(GeneIDList_ExonTab,list(B))
}


########################################################
#### 3. CDS kept for the rest of the analysis
########################################################

# Argument = CDS shared between at least ... of the genomes 

## 80% of the genomes: (round so that we never have half individual) 
Target = round(as.numeric(thresholrd)*length(ldf_values)) # Number of genome

## barplot of selection: 
pdf(paste('/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/CDS_occurance_',dateToday,'_490genomes.pdf',sep=''),height = 10,width = 20)
par(mfrow=c(2,2))
barplot(ExonTab,las=2,cex.names=0.3,main='Number of cds shared by x genome')
abline(v=Target,col='red')
barplot(unlist(ExonLen_sumExonTab),main='size of cds shared by x genome')
abline(v=Target,col='red')
barplot(unlist(GeneIDNum_ExonTab),main='Number of transcript shared by x genome')
abline(v=Target,col='red')
dev.off()

## Keep only exon that are in Target number of genome (from Target to max in ExonTab )
## Calculate how many genes this represent and what kind of genes: 
posTarget = which(names(ExonTab)==Target)
GeneIDList_out = GeneIDList_ExonTab[posTarget:length(GeneIDList_ExonTab)]
PosSelGen= length(unique(unlist(GeneIDList_out))) # this represent 16214 genes
Positive_selection_on_genes = data.frame('geneID'=unique(unlist(GeneIDList_out)))
GFF_annotation = read.table('cichlidX/data/GCF_001858045.1_ASM185804v2_genomic_exonProductInfo_Annotation_20170725.txt',stringsAsFactors = F,quote='"',h=T,sep='\t')
Positive_selection_on_genes_GFF = merge(Positive_selection_on_genes,GFF_annotation,all.x=T)
write.table(Positive_selection_on_genes_GFF,paste('/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/GenesKept_positiveSelection_',thresholrd,'per_',length(ldf_values),'Genomes_',PosSelGen,'genes_',dateToday,'.txt',sep=''),row.names = F,col.names = T,sep='\t',quote=F)



### CDS selection (80% of genomes): 
TargetExonTab = ExonTab[posTarget:length(ExonTab)]
ExonListFinal = NULL
for (a in names(TargetExonTab)) {
  exonCoor = names(VECTOR_VAL)[which(VECTOR_VAL==a)]
  A = LDF_MATRIX_specimenInfo[which(LDF_MATRIX_specimenInfo$cds_coord%in%exonCoor),]
  ExonListFinal = rbind(ExonListFinal,A)
}
ExonListFinal = ExonListFinal[order(ExonListFinal$cds_coord,decreasing = F),]
PosSelExo = nrow(ExonListFinal)
write.table(ExonListFinal,paste('/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/TilapiaCDSKept_positiveSelection_',thresholrd,'per_',length(ldf_values),'Genomes_',PosSelExo,'CDS_',dateToday,'.txt',sep=''),row.names = F,col.names = T,sep='\t',quote=F)

##############################################################################################
#### 4. Choose for each gene the protein that is the most represented with the selected cds
##############################################################################################
## Best respresented = Length of protein * the number of base pair covred in at least 80% of the genomes

# import libraries:
# to write the fasta with represented transcripts:
library(seqinr)

## 4.1 Each Transcript with a list of all its exon (made from GFF):
TranscriptRepresentation = read.table('cichlidX/data/ProteinCatalogue.txt',h=T,quote='"',stringsAsFactors = F,sep='\t')

## 4.2 Number of transcript represented by the 80% shared exon:
length(unique(ExonListFinal$proteinID)) # 34'085 protein represented 

## 4.3 Determine how many percentage of the protein is covered by shared cds

# For each proteinID, reconstruct his full length CDS-protein but replace the cds not shared by 80% of the genome with "N"
TranscriptsIDS_final = unique(ExonListFinal$proteinID)

# Delete the transcript belonging to 'noID' category (NOT CODING SEQUENCES!) ==> 34'084 transcripts left
TranscriptsIDS_final = TranscriptsIDS_final[-which(TranscriptsIDS_final=='noId')]

Transcript_cov = NULL
for (i in TranscriptsIDS_final) {
  
  # Tilapia information related to the this transcript:
  transcriptExon_info = ExonListFinal[which(ExonListFinal$proteinID==i),]
  transcriptExon_info = transcriptExon_info[order(transcriptExon_info$cds_coord,decreasing = F),]
  
  # All exon belonging to this exon: 
  TranscriptRepresentation_exons = TranscriptRepresentation$proteinCDSStructure[which(TranscriptRepresentation$proteinID==i)]

  # All exon belonging to the this transcript in list: (from smaller exon to bigger exon) 
  ExonList = unlist(strsplit(TranscriptRepresentation_exons,';'))

  # Which of the inital exons of transcript i are present in at least 80% genomes: 
  pos_existing = seq(1:length(ExonList))[which(ExonList%in%transcriptExon_info$cds_coord)]
  pos_notexisting = seq(1:length(ExonList))[-which(ExonList%in%transcriptExon_info$cds_coord)]
  
  Vector_transcriptL = list()  
  
  for (a in 1:length(ExonList)) {
    
    if (a%in%pos_existing) {
      exon_coo = strsplit(ExonList[a],':')[[1]][2]
      start = strsplit(exon_coo,'-')[[1]][1]
      stop = strsplit(exon_coo,'-')[[1]][2]
      Len = as.numeric(stop)-as.numeric(start)+1
      Nucleotidic_rep= paste(rep('V',Len),collapse = '')
      #Vector_transcriptL = append(Vector_transcriptL,ExonList[a])
      Vector_transcriptL = append(Vector_transcriptL,Nucleotidic_rep)
      
    } else {
      
      exon_coo = strsplit(ExonList[a],':')[[1]][2]
      start = strsplit(exon_coo,'-')[[1]][1]
      stop = strsplit(exon_coo,'-')[[1]][2]
      Len = as.numeric(stop)-as.numeric(start)+1
      nonNucleotidic_rep= paste(rep('N',Len),collapse = '')
      Vector_transcriptL =  append(Vector_transcriptL,nonNucleotidic_rep)
    }
  }
  
  ## Same than sumN and sumV and SumN+SumV:
  #sum(unlist(lapply(Vector_transcriptL,function(x) nchar(x)))[pos_existing])
  #sum(unlist(lapply(Vector_transcriptL,function(x) nchar(x)))[pos_notexisting])
  #sum(unlist(lapply(Vector_transcriptL,function(x) nchar(x)))[c(pos_existing,pos_notexisting)])
  
  
  TranscriptFinal_representation = paste(Vector_transcriptL,collapse = '')
  sumN = sum(charToRaw(TranscriptFinal_representation) == charToRaw('N'))
  sumV = sum(charToRaw(TranscriptFinal_representation) == charToRaw('V'))
  lengtTrans = sumV+sumN
  perCov = sumV / lengtTrans
  Transcript_cov=rbind(Transcript_cov,c(i,lengtTrans,round(perCov,3)))

}

colnames(Transcript_cov) = c('proteinID','lenProt','cov')
Transcript_cov = as.data.frame(Transcript_cov)
write.table(Transcript_cov,paste('/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/TilapiaProteinForRepresentativeCDS_positiveSelection_',thresholrd,'per_',length(ldf_values),'Genomes_',nrow(Transcript_cov),'proteins_',dateToday,'.txt',sep=''),row.names = F,col.names = T,sep='\t',quote=F)

## 4.4 Identify which transcript represent the best each gene (BP covered with shared exon * length of the transcript ==> % of the gene covred with shared BP)
# Merge with the geneIDs:

# 4.4.1 Gene Ids represented by the shared exons: 
geneInfos = ExonListFinal[which(!duplicated(ExonListFinal$proteinID)),c('geneID','proteinID','strand')]

# 4.4.2 Which transcripts correspond to those geneIDs:
CoverageInfo = merge(Transcript_cov,geneInfos,by.x='proteinID',by.y='proteinID',all.x=T)
CoverageInfo$lenProt = as.numeric(as.vector(CoverageInfo$lenProt))
CoverageInfo$cov = as.numeric(as.vector(CoverageInfo$cov))
CoverageInfo$BPcoverage = CoverageInfo$cov*CoverageInfo$lenProt
MaxVal_perGene = aggregate(CoverageInfo$BPcoverage,list(CoverageInfo$geneID),FUN=max)
colnames(MaxVal_perGene) = c('geneID','BPcoverage')
Representatif_transcrip_BPcoverage = merge(MaxVal_perGene,CoverageInfo,all.y=F,all.x=T)

# Delete one entry if two transcript represente the same the gene: 
# Take randomly the first
Representatif_transcrip_BPcoverage = Representatif_transcrip_BPcoverage[!duplicated(Representatif_transcrip_BPcoverage$geneID),]
write.table(Representatif_transcrip_BPcoverage,paste('/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/TilapiaRepresentativeProteins_positiveSelection_',thresholrd,'per_',length(ldf_values),'Genomes_',nrow(Representatif_transcrip_BPcoverage),'UniqueProteins_',dateToday,'.txt',sep=''),row.names = F,col.names = T,sep='\t',quote=F)

# Statistics on the final transcript we use: 
boxplot(Representatif_transcrip_BPcoverage$cov,main='PerTranscriptCovred')

##############################################################################################
#### 5. Reconstruct the Transcript with NNN values and Tilapia exons
##############################################################################################

# import libraries:
library(Biostrings)
library(IRanges)
library(seqinr) 


## Open the inital fasta: 
Inital = readDNAStringSet("/scicore/home/salzburg/GROUP/RNA_seq/FASTA_GTF_GFF/otilapia/GCF_001858045.1_ASM185804v2_genomic.fa", "fasta")
Inital_contigs = names(Inital)

#transcript_fasta = readDNAStringSet("/scicore/home/salzburg/GROUP/RNA_seq/FASTA_GTF_GFF/otilapia/GCF_001858045.1_ASM185804v2_rna.fna", "fasta")
#transcript_contigs  =  names(transcript_fasta)

## Replace all exon present in the transcript by its real nucleotid:
transcript_fasta_with_NN = list()
transcript_fasta_without_NN = list()

for (i in as.vector(Representatif_transcrip_BPcoverage$proteinID)) {

  # Tilapia information related to the this transcript:
  transcriptExon_info = ExonListFinal[which(ExonListFinal$proteinID==i),]
  transcriptExon_info = transcriptExon_info[order(transcriptExon_info$cds_coord,decreasing = F),]
  strand = transcriptExon_info$strand[1]
  
  # All exon belonging to this exon: 
  TranscriptRepresentation_exons = TranscriptRepresentation$proteinCDSStructure[which(TranscriptRepresentation$proteinID==i)]
  
  # All exon belonging to the this transcript in list: (from smaller exon to bigger exon) 
  ExonList = unlist(strsplit(TranscriptRepresentation_exons,';'))
  
  # Which of the inital exons of transcript i are present in at least 80% genomes: 
  pos_existing = seq(1:length(ExonList))[which(ExonList%in%transcriptExon_info$cds_coord)]
  pos_notexisting = seq(1:length(ExonList))[-which(ExonList%in%transcriptExon_info$cds_coord)]
  
  Vector_transcriptL = list()  
  Non_Na_exon = list()
  Full_sequence_reconstruction = list()
  
  for (a in 1:length(ExonList)) {
  
    chrom = strsplit(ExonList[a],':')[[1]][1]
    exon_coo = strsplit(ExonList[a],':')[[1]][2]
    start = strsplit(exon_coo,'-')[[1]][1]
    stop = strsplit(exon_coo,'-')[[1]][2]
    Len = as.numeric(stop)-as.numeric(start)+1
    pos_chrom_gen = grep(chrom,Inital_contigs)
    Sequence_exon = as.character(Inital[[pos_chrom_gen]][as.numeric(start):as.numeric(stop)])
    Full_sequence_reconstruction = append(Full_sequence_reconstruction,Sequence_exon)
    
    if (a%in%pos_existing) {
      
      chrom = strsplit(ExonList[a],':')[[1]][1]
      exon_coo = strsplit(ExonList[a],':')[[1]][2]
      start = strsplit(exon_coo,'-')[[1]][1]
      stop = strsplit(exon_coo,'-')[[1]][2]
      Len = as.numeric(stop)-as.numeric(start)+1
      
      ## If we take the info from the fasta: 
      Nucleotidic_rep= paste(rep('V',Len),collapse = '')
      
      
      pos_chrom_gen = grep(chrom,Inital_contigs)
      Sequence_exon = as.character(Inital[[pos_chrom_gen]][as.numeric(start):as.numeric(stop)])
      
      Vector_transcriptL = append(Vector_transcriptL,Nucleotidic_rep)
      Non_Na_exon = append(Non_Na_exon,Sequence_exon)
      
    } else {
      
      exon_coo = strsplit(ExonList[a],':')[[1]][2]
      start = strsplit(exon_coo,'-')[[1]][1]
      stop = strsplit(exon_coo,'-')[[1]][2]
      Len = as.numeric(stop)-as.numeric(start)+1
      nonNucleotidic_rep= paste(rep('N',Len),collapse = '')
      Vector_transcriptL =  append(Vector_transcriptL,nonNucleotidic_rep)
      Non_Na_exon = append(Non_Na_exon,nonNucleotidic_rep)
    }
  }
  
  ### Sequence with NN reconstruction:
  # Compare reconstructed and the substitution new: 
  reconstructed_seq = paste(Non_Na_exon,collapse = '')
  LEN_TRANSCRIPT = nchar(reconstructed_seq)
  
  # Transform to list: 
  TranscriptFinal_representation_pos = as.list(strsplit(reconstructed_seq, ""))
  pos_list = length(transcript_fasta_with_NN) + 1
  transcript_fasta_with_NN = append(transcript_fasta_with_NN, as.list(strsplit(reconstructed_seq, "")))
  names(transcript_fasta_with_NN)[pos_list] = paste(i,'|Geneid:',transcriptExon_info$geneID[1], '|ProteinLen:',LEN_TRANSCRIPT,'|strand:',strand,'|specimenID:GCF_001858045.1_ASM185804v2', sep='')
  
  ### Full sequences reconstruction: 
  Fully_reconstructed_seq= paste(Full_sequence_reconstruction,collapse = '')
  transcript_fasta_without_NN = append(transcript_fasta_without_NN, as.list(strsplit(Fully_reconstructed_seq, "")))
  names(transcript_fasta_without_NN)[pos_list] = paste(i,'|Geneid:',transcriptExon_info$geneID[1], '|ProteinLen:',LEN_TRANSCRIPT,'|strand:',strand,'|specimenID:GCF_001858045.1_ASM185804v2', sep='')
  #names(transcript_fasta_without_NN)[pos_list] = 'OnilRef'
  
  }

write.fasta(sequences = transcript_fasta_without_NN, names = names(transcript_fasta_without_NN), nbchar = 80, file.out = paste("/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/GCF_001858045.1_ASM185804v2_reconstructed_Full_sequences_seqCDS_",thresholrd,"per_",length(ldf_values),"Genomes_notreversedSequences_",dateToday,".fna",sep=''))
#write.fasta(sequences = transcript_fasta_with_NN, names = names(transcript_fasta_with_NN), nbchar = 80, file.out = paste("/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/GCF_001858045.1_ASM185804v2_reconstructed_sequences_seqCDS_",thresholrd,"per_",length(ldf_values),"Genomes_notreversedSequences_",dateToday,".fna",sep=''))



# - stranded sequences:
# reverse sequences: 
Inital = readDNAStringSet(paste("/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/GCF_001858045.1_ASM185804v2_reconstructed_Full_sequences_seqCDS_",thresholrd,"per_",length(ldf_values),"Genomes_notreversedSequences_",dateToday,".fna",sep=''), "fasta")
Inital_contigs = names(Inital)
# Reverse ids with strand negative :   
reverse_headers =Inital_contigs[grep('strand:-', Inital_contigs)]
# control that only strand -
table(unlist(lapply(reverse_headers,function(x) strsplit(x,'|',fixed = T)[[1]][4])))
ids_to_reverse = Inital[which(names(Inital)%in%reverse_headers)]
ids_reversed = reverseComplement(x = ids_to_reverse)

# + stranded sequences: 8054 sequences
header_positif_strand = Inital_contigs[-which(Inital_contigs%in%names(ids_reversed))]
# control that only strand + 
table(unlist(lapply(header_positif_strand,function(x) strsplit(x,'|',fixed = T)[[1]][4])))
ids_not_to_reverse = Inital[which(names(Inital)%in%header_positif_strand)]

final_fasta = c(ids_reversed,ids_not_to_reverse)

writeXStringSet(final_fasta, file = paste("/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/GCF_001858045.1_ASM185804v2_reconstructed_Full_sequences_seqCDS_",thresholrd,"per_",length(ldf_values),"Genomes_reversedSequences_",dateToday,".fna",sep=''), format="fasta")


