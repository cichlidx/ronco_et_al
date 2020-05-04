### Astrid Böhne 
# April 2020

#####################################################################
#####################################################################
## applying additional filters on the gene dupliction counts


library(vcfR)	###version: vcfR 1.8.0.9000
library(UpSetR)	###version: UpSetR 1.3.3
library(pheatmap)	###version: pheatmap 1.0.12

############################################################
###### read dupliction count based on the smoove pipeline:
 
###read in quality and depth filtered output containing only duplications and those of at least 1kb length
vcf <- read.vcfR("duplications.vcf.gz", verbose = FALSE )
InfoColumn<-(vcf@fix[,8])
QualColumn<-as.numeric(vcf@fix[,6])
InfoColumnLength <- sapply(strsplit(as.character(InfoColumn),';'), "[", 2)
InfoColumnLength2 <- sapply(strsplit(as.character(InfoColumnLength),'='), "[", 2)

#head(QualColumn)
#boxplot(QualColumn)
gt <- extract.gt(vcf)
###plot all together###
SpeciesInfo <- read.delim("SpeciesInfo")

#####################
###check for length
###filter for too many NAs
####heatmap of all dups rownames dup length
###no filter for gene feature
gtDF<-as.data.frame(gt)
gtDFrecode<-gtDF
gtDFrecode[] <- lapply(gtDFrecode, gsub, pattern = "0/0", replacement = 0, fixed = TRUE)
gtDFrecode[] <- lapply(gtDFrecode, gsub, pattern = "1/1", replacement = 1, fixed = TRUE)
gtDFrecode[] <- lapply(gtDFrecode, gsub, pattern = "0/1", replacement = 0.5, fixed = TRUE)
###plot all together###
##get length
###length are not unique
SpeciesInfo$fullID<-paste(SpeciesInfo$speciesID, SpeciesInfo$sex, SpeciesInfo$DNA_Tube, sep="_")
SpeciesInfosub<-subset(SpeciesInfo, SpeciesInfo$DNA_Tube %in% colnames(gtDFrecode))
SpeciesInfosub<-(SpeciesInfosub[match(colnames(gtDFrecode), SpeciesInfosub$DNA_Tube),])
colnames(gtDFrecode)<-SpeciesInfosub$fullID
gtDFrecode<-data.frame(apply(gtDFrecode, 2, as.numeric))
rownames(gtDFrecode)<-paste(rownames(gtDFrecode),InfoColumnLength2, sep="_")
gtDFrecodematrix<-as.matrix(gtDFrecode)
#my_palette <- colorRampPalette(c("grey50","slateblue4", "aquamarine"))(n = 3)
#pdf("HeatmapAllDups.pdf", width = 10, height = 20)
#pheatmap(gtDFrecodematrix, color=my_palette,cluster_rows = T,show_rownames=T, fontsize=3, fontsize_col=2, width=9, height=16)
#dev.off()

###NA Filter
gtDFrecode$sumofNA<-apply(gtDFrecode, 1, function(x) sum(is.na(x)))
##there are 492 individuals in the file
##missing 50 would be 246
gtDFrecodeNAFilt50<-subset(gtDFrecode, gtDFrecode$sumofNA<(length(colnames(gtDFrecode))-1)/2)
##639 dups
gtDFrecodeNAFilt80<-subset(gtDFrecode, gtDFrecode$sumofNA<(length(colnames(gtDFrecode))-1)*0.2)
##608 dups
gtDFrecodeNAFilt50$sumofNA<-NULL
gtDFrecodeNAFilt80$sumofNA<-NULL
#pdf("HeatmapAllDups50NAFIlt.pdf", width = 10, height = 20)
#pheatmap(as.matrix(gtDFrecodeNAFilt50), color=my_palette,cluster_rows = T,show_rownames=T, fontsize=3, fontsize_col=2, width=9, height=16)
#dev.off()
#pdf("HeatmapAllDups80NAFIlt.pdf", width = 10, height = 20)
#pheatmap(as.matrix(gtDFrecodeNAFilt80), color=my_palette,cluster_rows = T,show_rownames=T, fontsize=3, fontsize_col=2, width=9, height=16)
#dev.off()



###remove length outliers
gtDFrecodeNAFilt80$length<-sapply(strsplit(as.character(row.names(gtDFrecodeNAFilt80)),'_'), "[", 2)
gtDFrecodeNAFilt80$length<-as.numeric(gtDFrecodeNAFilt80$length)

boxpgtDFrecode<-boxplot(gtDFrecodeNAFilt80$length)
###get upper outlier level
boxpgtDFrecode$stats[5]
gtDFrecodeNAFilt80<-subset(gtDFrecodeNAFilt80, gtDFrecodeNAFilt80$length<boxpgtDFrecode$stats[5])
####476 remaining
gtDFrecodeNAFilt80$length<-NULL

#pdf("HeatmapAllDups80NAFiltLengthFilt.pdf", width = 10, height = 20)
#pheatmap(as.matrix(gtDFrecodeNAFilt80), color=my_palette,cluster_rows = T,show_rownames=T, fontsize=3, fontsize_col=2, width=9, height=16)
#dev.off()

####count unique per tribe and do intersection of those
###plot all together###
perTribe80<-gtDFrecodeNAFilt80
perTribe80[] <- lapply(perTribe80, gsub, pattern = "0.5", replacement = 1, fixed = TRUE)
perTribe80[1:ncol(perTribe80)] <- lapply(perTribe80[1:ncol(perTribe80)], as.numeric)

###count dubs per species and do a boxplot of the counts per Tribe
gtSumsSpecies80<-as.data.frame(colSums(perTribe80, na.rm = T))
colnames(gtSumsSpecies80)<-c("DUPcounts")
gtSumsSpecies80$ID<-sapply(strsplit(as.character(row.names(gtSumsSpecies80)),'_'), "[", 3)
gtSumsSpeciesFullInfo80<-merge(gtSumsSpecies80, SpeciesInfo, by.x = "ID", by.y="DNA_Tube", all.x = T, all.y = F)
gtSumsSpeciesFullInfo80$speciesIDTribe<-droplevels(gtSumsSpeciesFullInfo80$speciesIDTribe)
#pdf("boxplotDupSums1kb.pdf")
#boxplot(gtSumsSpeciesFullInfo80$DUPcounts ~ gtSumsSpeciesFullInfo80$speciesIDTribe, las=2,par(cex.axis=0.6), main="1kb Duplications per Individual Tribewise")
#dev.off()

head(gtSumsSpeciesFullInfo80)
write.csv(gtSumsSpeciesFullInfo80, "Dupplication_final_filtered.csv")










