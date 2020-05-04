## Fabrizia Ronco
## April 2020


############################################################################
#### Prepare input files for downstream phylogenetic comparative analyses


### allow variables from command line
args = commandArgs(trailingOnly = TRUE)

###  load packages
require(ape)  # version 5.2

######   get data
d= read.csv(args[1])

######   get trees and drop tips
tree= read.nexus(file=args[2])
tree2 = drop.tip(tree, tree$tip.label[! tree$tip.label %in% d$species], root.edge = F, rooted = is.rooted(tree))

######  output for downstream phylogenetic comparative analyses
#head(d)
out= cbind(d$YScores)
rownames(out) = d$species
#head(out)

write.table( out, args[3], quote=F, col.names=F, sep="\t")
write.nexus(tree2,file= args[4])



















