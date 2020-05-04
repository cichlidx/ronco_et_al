#####################################################
##                                                ###
##              dNdS calculation                  ###
##                                                ###
#####################################################


library(dplyr)
require(gridExtra)

# Tribe information and colors:
col.sp = c("#C588BB","#9AB9D9","#86C773","#242626","#AE262A","#59595C","#FDDF13","#F04D29","#682E7A","#535CA9","#FBAC43","#845F25","#959170","#949598","#86C773")
tribes<-c("Lamprologini","Ectodini","Tropheini","Bathybatini","Benthochromini","Boulengerochromini","Cyphotilapiini","Cyprichromini","Eretmodini","Limnochromini","Perissodini","Oreochromini","Trematocarini","Tylochromini","Haplochromini")
names(col.sp) <- tribes

#####################################################
# SEQUENCE AND SPECIMEN SELECTION 
#####################################################

#### 1. General information and specimen selection:
#####################################################
# Target specimens: 
dNdS_specimen = read.table('/scicore/home/salzburg/eltaher/cichlidX/data/dNdS_genomes/speciesList_FinalSelection_RadiationTribe_minGene18000_AND_FabirziaSelection.txt',h=F,quote='"',sep='\t',stringsAsFactors = F)

# Tribes infos: 
tribeInfo = read.table('/scicore/home/salzburg/eltaher/cichlidX/data/DNATube_20181001.txt',h=T,quote='"',sep='\t',stringsAsFactors = F)
speciesInfo = read.table('/scicore/home/salzburg/eltaher/cichlidX/data/Species_2017-11-06_16-21-49.tsv',h=T,quote='"',sep='\t',stringsAsFactors = F)
tribeInfo = merge(tribeInfo,speciesInfo,by.x='Species.ID',by.y='Species.ID',all.x=T,all.y=F)

# Genome Info:
GenomeInfo = merge(dNdS_specimen,tribeInfo[,c('Species.ID','DNA.Tube.ID','Tribe')],all.x=T,all.y=F,by.x='V1',by.y='DNA.Tube.ID')


# Genes infos : 
GenesInfo = read.table('/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/GenesKept_positiveSelection_0.8per_471Genomes_15295genes_20190606.txt',h=T,quote='"',sep='\t',stringsAsFactors = F)
RepProt = read.table('/scicore/home/salzburg/eltaher/cichlidX/result/Augustus_codingseq_PlacedOnTilpiaCDS/TilapiaRepresentativeProteins_positiveSelection_0.8per_471Genomes_15294UniqueProteins_20190606.txt',h=T,quote='"',sep='\t',stringsAsFactors = F)
GeneProtInfo = merge(GenesInfo,RepProt,by.x='geneID',by.y='geneID')


### Summary: ### ### ### 
# 471 genomes:
length(GenomeInfo$Species.ID)

# In general two genomes, sometimes more (more genome available), sometimes less (missing because of quality)
barplot(table(GenomeInfo$Species.ID),las=2)
# 242 species: 
length(unique(GenomeInfo$Species.ID))


#### 2. dN values: 
#####################################################
# Open all files and store them in an list: 
## In each file: ALL specimens (471 rows); dN value or NA (=specimen for which the pairwise comparison could not be computed)
filenames <- list.files("/scicore/home/salzburg/eltaher/cichlidX/result/dNdS/codeml.dN.dS.txt", pattern=".dN.txt", full.names=TRUE) #
dN.ids = unlist(lapply(filenames, function(x) strsplit(x,'/')[[1]][10]))
dN.ids = unlist(lapply(dN.ids, function(x) strsplit(x,'.dN')[[1]][1]))
## Keep only the one in the final selection:
filenames = filenames[match(GeneProtInfo$proteinID,dN.ids)]

# Open files: 
ldf_dN <- lapply(filenames, function(x) read.table(x,header=F,quote='"',sep="\t",row.names = 1,stringsAsFactors = F))
Name2 = unlist(lapply(lapply(filenames,function(x) strsplit(x,'/')[[1]][10]),function(x) strsplit(x,'.',fixed=T)[[1]][1]))
names(ldf_dN) = Name2

## Merge all list into a dataFrame:
hugematrix = do.call("cbind", ldf_dN)
colnames(hugematrix) = Name2
df <- data.frame(specimeID = row.names(hugematrix), hugematrix)
dNtable = hugematrix

# Keep only the specimens that pass the threshold and that are in the final selection of genome paper: 
dNtable = dNtable[which(rownames(dNtable)%in%dNdS_specimen$V1),]
rowNamesMatrix = data.frame('DNA.Tube.ID'= rownames(dNtable))
GenomeSelectedForAnalysis = merge(rowNamesMatrix,tribeInfo[,c(1,2,10,19)],all.x=T,all.y=F)

## Num species: 242 species
length(unique(GenomeSelectedForAnalysis$Species.ID))

## Num tribe: 12 tribes 
length(unique(GenomeSelectedForAnalysis$Tribe))

############################################################ New version 20191128
## dN value per genome: 
dNtable_perGenome = rowSums(dNtable,na.rm = T)
############################################################


#### 3. dS values: 
#####################################################
# Open all files and store them in an list: 
## In each file: ALL specimens (490 rows); dN value or NA (=specimen for which the pairwise comparison could not be computed)
filenames <- list.files("/scicore/home/salzburg/eltaher/cichlidX/result/dNdS/codeml.dN.dS.txt", pattern=".dS.txt", full.names=TRUE)
dN.ids = unlist(lapply(filenames, function(x) strsplit(x,'/')[[1]][10]))
dN.ids = unlist(lapply(dN.ids, function(x) strsplit(x,'.dS')[[1]][1]))
## Keep only the one in the final selection:
filenames = filenames[match(GeneProtInfo$proteinID,dN.ids)]
ldf_dS <- lapply(filenames, function(x) read.table(x,header=F,quote='"',sep="\t",row.names = 1,stringsAsFactors = F))


Name2 = unlist(lapply(lapply(filenames,function(x) strsplit(x,'/')[[1]][10]),function(x) strsplit(x,'.',fixed=T)[[1]][1]))
names(ldf_dS) = Name2

## Merge all list into a dataFrame: 
hugematrix_dS = do.call("cbind", ldf_dS)
colnames(hugematrix_dS) = Name2
df_dS <- data.frame(specimeID = row.names(hugematrix_dS), hugematrix_dS)
dStable = hugematrix_dS
dStable = dStable[which(rownames(dStable)%in%dNdS_specimen$V1),]


############################################################ New version 20191128
## dN value per genome: 
dStable_perGenome = rowSums(dStable,na.rm = T)
# dNdS valuer per genome: 
dNdStable_perGenome = dNtable_perGenome/dStable_perGenome
# PlotPerTribe: 
dNdStableTribes = tribeInfo$Tribe[match(names(dNdStable_perGenome),tribeInfo$DNA.Tube.ID)]
dNdStable_perGenome_df = data.frame('id'=names(dNdStable_perGenome),'tribe'=dNdStableTribes,'dN'=dNtable_perGenome,'dS'=dStable_perGenome,'dNdS'=dNdStable_perGenome)
par(mfrow=c(1,1),mar=c(10,5,1,1))
boxplot(dNdStable_perGenome_df$dNdS~dNdStable_perGenome_df$tribe,las=2,xlab='')


dNdStable_perGenome_df = data.frame('id'=names(dNdStable_perGenome),'dN'=dNtable_perGenome,'dS'=dStable_perGenome,'dNdS'=dNdStable_perGenome)
write.table(dNdStable_perGenome_df,'/scicore/home/salzburg/eltaher/cichlidX/result/dNdS/FinalTable_codeml_dNdS_471specimens_15294_OneValuePerGenome_Sum_for_dN_dS_and_dNdS_20201601.summary.txt',row.names = F,col.names = T,sep='\t',quote=F)
save(dNdStable_perGenome_df,file='/scicore/home/salzburg/eltaher/cichlidX/result/dNdS/FinalTable_codeml_dNdS_471specimens_15294_OneValuePerGenome_Sum_for_dN_dS_and_dNdS_20201601.summary.Rdata')
############################################################
