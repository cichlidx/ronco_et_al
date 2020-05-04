## Fabrizia Ronco
## April 2020

############################################################################
#### Prepare input files for downstream phylogenetic comparative analyses



### allow variables from command line
args = commandArgs(trailingOnly = TRUE)


###  load packages 
require(phytools) 		## version 0.6-60
require(logisticPCA)	## version 0.2


###  get data 
d2= read.csv("../01_Data/color_pattern.csv")
#head(d2)

lo= logisticPCA( d2[,2:21], k=4)   ####  ignore "LSF"
str(lo)


###  reassamble a data frame with species and tribe info
head(d2)
out= d2[,23:27]
out$PC1= lo$PCs[,1]
out$tribe2= as.factor(tolower(substr(out$Tribe, 1,5)))

###  make species means
d = aggregate( out[,6], by= list(out$Species.ID, out$tribe2), mean)
names(d) = c("species", "tribe", "PC1")

head(d)

##  get trees:
tree= read.nexus(args[1])
###  prune trees
tree_pruned= drop.tip(tree, tree$tip.label[! tree$tip.label %in% d[,1]])
###  prune data 
d2 = d[ d[,1]  %in% tree$tip.label,] ####. PC1

###  write out data 

write.table( d2, "input/singletrait_color.txt", quote=F, row.names=F, col.names=F)
write.nexus(tree_pruned,file= args[2])









