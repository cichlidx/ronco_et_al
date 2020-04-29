## Fabrizia Ronco
## April 2020


########################################################################
#######   requried packages  ###########################################
########################################################################
require(geomorph)	## version 3.0.7
require(caper)		## version 1.0.1
require(ape)		## version 5.3

########################################################################
#######  get data            ###########################################
########################################################################
load("../body/sp_means_body.Rdata")
load("../SI/sp_means_SI.Rdata")


###############################################################
####  make the data sets congruent
########################################################################

###  keep only SI data which is in morpho data
SI= sp_means_SI[sp_means_SI$sp %in%  dimnames(sp_means_body)[[3]],]

###  keep only morpho data which is in SI data
body= sp_means_body[,, dimnames(sp_means_body)[[3]] %in% SI$sp ]


################################################
######  prune tree to data
################################################

######   get tree and drop tips
tree= read.nexus(file="../../01_Data/b1.tre")
tree2 = drop.tip(tree, tree$tip.label[! tree$tip.label %in% dimnames(body)[[3]]], root.edge = F, rooted = is.rooted(tree))

############  drop morho/Si data not present in the tree..
body= body[,, dimnames(body)[[3]] %in% tree2$tip.label]
SI= SI[SI$sp %in% tree2$tip.label, ]


###  make SI matrix
#head(SI)
si= as.matrix( SI[,2:3])
rownames(si) = SI$sp
#head(si)

###  bring them in correct oreder
si_ord = si[match(   dimnames(body)[[3]], rownames( si)),]
#unique(match(  dimnames(body)[[3]], rownames( si_ord)) == 1: length( dimnames(body)[[3]]))


#####################  add tribe classifiers    ##########################

info= read.csv ("../../01_Data/Species_TO_tribe.csv")
info$tribe = substr(tolower(info$Tribe),1,5)

#head(info)
#head(dimnames(body)[[3]])
sp = data.frame("Species.ID" = dimnames(body)[[3]])
tribe= merge( sp, info, all.x=T, sort=F) [,c(1,4)]
#head(tribe)
#tribe[is.na( tribe$tribe),]
#unique(match( tribe$Species.ID, sp[,1]) == 1: length( sp[,1]))

#str(tribe)
tribe$tribe= as.factor(tribe$tribe)



################################################
######   two Block pls both bocks  free to rotate
################################################
f = two.b.pls(  si_ord, body) 

print( " ################################################# ")
print( " *** PLS bodyshape with SI data *** ")
print( " ################################################# ")

print(f)

### loading of the SI projections
print(" ---  loading of the SI projections ---")
print(f$left.pls.vectors)

###  get projected scores
f1= data.frame( "XScores"=f$ XScores[,1], "YScores"=f$ YScores[,1] , "species"= tribe $Species.ID , "tribe"= tribe $tribe)
#head(f1)


## get max min shapes
g= plot(f, shapes=T)
maxshape= g$pls2.max
minshape= g$pls2.min

print(" ---  get R^2 for the PLS fit  ---")
print(summary(lm(f1$YScores ~ f1$XScores)))

################################################
######   pGLS 

compset = comparative.data(tree2, f1, species)
print(" ---  phylogenetic GLS over the PLS scores  ---")
print(summary(pgls(YScores ~ XScores , compset, lambda= 'ML')))

### adjust upper bound 
print(" ---  phylogenetic GLS over the PLS scores, with adjusted bounds for lambda  ---")
print(summary(pgls(YScores ~ XScores , compset, lambda= 'ML', bounds=list(lambda=c(0,2)))))


################################################
######  save PLS scores to file
#head(f1)
write.csv( f1, "../body/PLS_body_SI.txt", quote=F, row.names=F)



#################
#######  plot
###################

### predict major regression line from PLS scores

pc = prcomp(cbind(f1$XScores, f1$YScores))$x[,1]
px = predict( (lm(f1$XScores~pc)))
py = predict(lm(f1$YScores~pc))
R=round(summary(lm( f$ YScores[,1] ~ f$ XScores[,1]))$r.square,3)

### outlines to draw the shapes
outline1 = c(16,17,18,19,16)
outline2 = c(1,20,2,3,4,5,6,8,9,11,12,15,1)
outline3 = c(14,10,7)

###   set color palette
col.sp = read.table( "../../01_Data/colors_tribes.txt", head=T)
col.sp2= col.sp[match (  levels(tribe $tribe) , col.sp$tribe),]
#match (col.sp2$tribe, levels(tribe $tribe))
palette(c(as.character(col.sp2$color)))

###. plot
quartz(file="../Plots/body_SI_PLS.pdf", type="pdf", width=7, height=7)

par(mar = c(5,12,2,2))
plot( f1$ XScores, f1$ YScores, col=f1$tribe, pch=16, ylab= "body shape projection", xlab="stable Isotope projection", las=1)
abline(lm(py ~ px ), lty="dashed")
legend( "topleft", paste ("cor= ", round(f$ r.pls,3) , " ; R2 = ",  R, sep=""  ), bty="n")

split.screen(figs=c(4,4), erase=F)

screen(1)
par(mar = c(0,0,0,0))
plot(maxshape, xlim=c(-0.4,0.4), ylim=c(-0.4,0.4), pch=16, cex=0.3, axes=F, xlab="", ylab="")
polygon(maxshape[c(outline1),])
lines(maxshape[c(outline2),])
lines(maxshape[c(outline3),])

screen(13)
par(mar = c(0,0,0,0))
plot(minshape, xlim=c(-0.4,0.4), ylim=c(-0.4,0.4), pch=16, cex=0.3, axes=F, xlab="", ylab="")
polygon(minshape[c(outline1),])
lines(minshape[c(outline2),])
lines(minshape[c(outline3),])


close.screen(all = TRUE) 
dev.off()













