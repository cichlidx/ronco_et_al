## Fabrizia Ronco
## April 2020


########################################################################
#######   requried packages  ###########################################
########################################################################

require(reshape2) ## version 1.4.3
require (geomorph) ## version 3.0.7

########################################################################
#######   reading tps file   ###########################################
########################################################################

data.tps = readland.tps("../../01_Data/all_bodyshape.tps", specID="ID")
paste("n")
#str(data.tps)

#########################################################################
####  Procrustes fit of the landmark coordinates
#########################################################################

ProcA = gpagen(A=data.tps, ProcD=T) #Using Procrustes Distance
#str(ProcA)

########################################################################
#####################  extract classifiers    ##########################
########################################################################

names1= colsplit(dimnames(ProcA$coords)[[3]], "_", c("ID", "sp", "rest") )
ID= as.factor( names1$ID)
species= as.factor(substr(names1$sp, 1, 6))
#str(ProcA)

########################################################################
#####################  PCA 				   #############################
########################################################################

### landmark 16 (which marks the lateral end of the premaxilla) is excluded for the quantification of body shape to reduce the effect of the orientation of the oral jaw - which is analysed separately as upper oral jaw morphology using different landmark subset
ProcA$coords= ProcA $coords[-16,,]

PCA1 = plotTangentSpace(ProcA $coords, groups=species, label=species)

PCAscores = data.frame(PCA1 $pc.scores,"ID"= ID, "sp"= species)
#head(PCAscores)

#####################  add tribe classifiers    ##########################

info= read.csv ("../../01_Data/Species_TO_tribe.csv")
info$tribe = substr(tolower(info$Tribe),1,5)

PCAscores2 = merge( PCAscores,info[,c(1,4)],by.x="sp", by.y= "Species.ID" , all.x=T)
#head(PCAscores2)

#####################  save PCA results to file for later plotting##########################
write.table(PCAscores2, "../../02_Morpho_Eco/body/PCA_pc_scores_body.txt", sep="\t", row.names=F, quote=F)
write.table(data.frame(PCA1 $pc.summary$importance),"../../02_Morpho_Eco/body/PCA_importance_body.txt", sep="\t", row.names=F, quote=F)


#####################  save shape changes associated with the PC- axes to file for alter plotting #####################  
shapes= PCA1 $pc.shapes[1:8]
save(shapes, file="../../02_Morpho_Eco/body/PCA_shapes_body.RData")


#####################  save prucrustes aligned landmark coordinates to file  #####################  
body= ProcA$coords
save(body, file="../../02_Morpho_Eco/body/proc_aligned_body.RData")






























