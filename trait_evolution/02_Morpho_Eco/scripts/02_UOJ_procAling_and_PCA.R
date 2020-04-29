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
####  Procrustes fit of the entire set of landmark coordinates
#########################################################################

# An important aspect of the oral jaw morphology is the orientation of the mouth relative to the body axes.  
# This component of the upper oral jaw morphology would be lost if the prucrustes fit would be performed using the oral jaw alndmarks alone 
# We therfore extracted the premaxilla-specific landmarks (1, 2, 16, and 21) after Procrustes superimposition of the entire set of landmarks and subsequently re-centred the landmarks to align the specimens without rotation. 
#Thus, the resulting landmark coordinates do not represent the pure shape of the premaxilla but additionally contain information on its orientation and size in relation to body axes and body size, respectively. 


ProcA = gpagen(A=data.tps, ProcD=T) #Using Procrustes Distance
#str(ProcA)

########################################################################
#####################  extract classifiers    ##########################
########################################################################

names1= colsplit(dimnames(ProcA$coords)[[3]], "_", c("ID", "sp", "rest") )
ID= as.factor( names1$ID)
species= as.factor(substr(names1$sp, 1, 6))


########################################################################
#####################  extract premaxilla    ##########################
########################################################################

oralJ= c( 1,2,16,21)
OJ= ProcA$coords[oralJ,,]

#####  remove body elongation from proc aligned premaxilla coordinates, by re-centering the coordinates, but no rotation change (see above).

## plots are for visualisation of the process

plot( OJ[,,1]  , xlim=  c(-0.3,-0.1), ylim=c(-0.1,0.1), pch=19, cex=0.5)
for(i in 1: 10) points(OJ[,,i] , pch=19, cex=0.5, col=i)

OJ2=OJ
for(i in 1: dim(OJ)[3]) OJ2[,,i]= scale(OJ[,,i], center = TRUE, scale = F)

plot( OJ2[,,1]  , xlim=  c(-0.04,0.04), ylim=c(-0.04,0.04), pch=19, cex=0.5)
for(i in 1: 10) points(OJ2[,,i] , pch=19, cex=0.5, col=i)



########################################################################
#####################  PCA 				   ###############################
########################################################################

PCA1 = plotTangentSpace(OJ2, groups=species, label=species)
PCAscores= data.frame(PCA1 $pc.scores,"ID"= ID, "sp"= species)
#head(PCAscores)

#####################  add tribe classifiers    ##########################
info= read.csv ("../../01_Data/Species_TO_tribe.csv")
info$tribe = substr(tolower(info$Tribe),1,5)
PCAscores2 = merge( PCAscores,info[,c(1,4)],by.x="sp", by.y= "Species.ID" , all.x=T)
#head(PCAscores2)

#####################  save PCA results to file for later plotting ##########################
write.table(PCAscores2, "../../02_Morpho_Eco/oral/PCA_pc_scores_UOJ.txt", sep="\t", row.names=F, quote=F)
write.table(data.frame(PCA1 $pc.summary$importance),"../../02_Morpho_Eco/oral/PCA_importance_UOJ.txt", sep="\t", row.names=F, quote=F)

####################  save shape changes associated with the PC- axes to file for alter plotting ##################### 
shapes= PCA1 $pc.shapes[1:8]
save(shapes, file="../../02_Morpho_Eco/oral/PCA_shapes_UOJ.RData")

#####################  save prucrustes aligned landmark coordinates to file  ##################### 
save(OJ2, file="../../02_Morpho_Eco/oral/proc_aligned_UOJ.RData")





























