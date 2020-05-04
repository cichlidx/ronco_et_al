
#!/usr/bin/env Rscript

##### ##### ##### ##### ##### command line argument # ##### ##### ##### ##### #####
id = commandArgs(TRUE)[1] # Genome id
##### ##### ##### ##### ##### command line argument # ##### ##### ##### ##### #####


### Intersection GTF : 
tilapia_exon = read.table('/scicore/home/salzburg/GROUP/RNA_seq/FASTA_GTF_GFF/otilapia/GCF_001858045.1_ASM185804v2_genomic_CDSInfos.txt',header = T,quote='"',sep='\t',stringsAsFactors = F)
augustus_exon =  read.table(paste('/scicore/home/salzburg/eltaher/cichlidX/result/GMAP/augustus_coding_sequence/',id,'/GMAP_GenePrediction_Augustus_',id,'_codingseqCDS_qcov50_iden80.txt',sep=''),header = T,quote='"',sep='\t',stringsAsFactors = F)


# Add exon coordination: 
tilapia_exon$exon_coord = paste(tilapia_exon$Chrom,':',tilapia_exon$start,'-',tilapia_exon$stop,sep='')
augustus_exon$augustus_exon_coord = paste(augustus_exon$chromOnil,':',augustus_exon$startOnil,'-',augustus_exon$stopOnil,sep='')

# Delete "not" unique entry in Tilapia : 
unique_entries = paste(tilapia_exon$exon_coord,tilapia_exon$proteinID,sep=':')
if (length(which(duplicated(unique_entries)))!=0) {
  tilapia_exon= tilapia_exon[-which(duplicated(unique_entries)),]
} 

## Exon length : 
tilapia_exon$Exonlength = tilapia_exon$stop-tilapia_exon$start+1

## Merge Tilapia exons information with Cichlidx genome infos:  
TILAPIA_AUGUSTUS_DF = merge(tilapia_exon,augustus_exon,by.x='exon_coord',by.y='augustus_exon_coord',all.x=T,all.y = F)


# Delete one of the augustus link if they point to the same exon in the same Tilapia transcript: 
UNIQUE_ENTRY = paste(TILAPIA_AUGUSTUS_DF$exon_coord,TILAPIA_AUGUSTUS_DF$proteinID,sep=':')
TILAPIA_AUGUSTUS_DF_UNIQUE = TILAPIA_AUGUSTUS_DF[!duplicated(UNIQUE_ENTRY),]


# Rename and order the final table: 
TILAPIA_AUGUSTUS_DF_UNIQUE = TILAPIA_AUGUSTUS_DF_UNIQUE[order(TILAPIA_AUGUSTUS_DF_UNIQUE$exon_coord),]
TILAPIA_AUGUSTUS_DF_exon = TILAPIA_AUGUSTUS_DF_UNIQUE[,c('Chrom','geneID','proteinID','cdsID','exon_coord','start.x','stop.x','strand.x','Exonlength','cdsID','codingseqId','start.y','stop.y','strand.y')]
colnames(TILAPIA_AUGUSTUS_DF_exon) = c('Chrom','geneID','proteinID','cdsID','cds_coord','start','stop','strand','Exonlength','cdsID.Augustus','Codingseq.Augustus','start.Augustus','stop.Augustus','strand.Augustus')



write.table(TILAPIA_AUGUSTUS_DF_exon,paste('/scicore/home/salzburg/eltaher/cichlidX/result/GMAP/augustus_coding_sequence/',id,'/GMAP_GenePrediction_Augustus_',id,'_codingseq_qcov50_iden80_PlacedOnTilpiaCDS.txt',sep=''),row.names = F,col.names = T,sep='\t',quote=F)


Augustus_infos = paste(TILAPIA_AUGUSTUS_DF_exon$Codingseq.Augustus,':',TILAPIA_AUGUSTUS_DF_exon$start.Augustus,'-',TILAPIA_AUGUSTUS_DF_exon$stop.Augustus,sep='')
Augustus_infos[grep('NA',Augustus_infos)] = 'NA'
TILAPIA_AUGUSTUS_DF_exon$Coord.Augustus = Augustus_infos
Augustus_transcript = TILAPIA_AUGUSTUS_DF_exon[,c(1:9,15)]

write.table(Augustus_transcript,paste('/scicore/home/salzburg/eltaher/cichlidX/result/GMAP/augustus_coding_sequence/',id,'/Augustus_codingseq_',id,'_PlacedOnTilpiaCDS.txt',sep=''),row.names = F,col.names = T,sep='\t',quote=F)


