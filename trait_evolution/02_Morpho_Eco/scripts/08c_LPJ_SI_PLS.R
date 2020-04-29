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

load("../LPJ/sp_means_LPJ.Rdata")
load("../SI/sp_means_SI.Rdata")



###############################################################
####  make the data sets congruent
########################################################################


###  keep only SI data which is in morpho data
SI= sp_means_SI[sp_means_SI$sp %in%  dimnames(sp_means_LPJ)[[3]],]

###  keep only morpho data which is in SI data
LPJ= sp_means_LPJ[,, dimnames(sp_means_LPJ)[[3]] %in% SI$sp ]

################################################
######  prune tree to data
################################################

######   get tree and drop tips
tree= read.nexus(file="../../01_Data/b1.tre")
tree2 = drop.tip(tree, tree$tip.label[! tree$tip.label %in% dimnames(LPJ)[[3]]], root.edge = F, rooted = is.rooted(tree))

############  drop morho/Si data not present in the tree..
LPJ= LPJ[,, dimnames(LPJ)[[3]] %in% tree2$tip.label]
SI= SI[SI$sp %in% tree2$tip.label, ]

###  make SI matrix
si= as.matrix( SI[,2:3])
rownames(si) = SI$sp

###  bring them in correct oreder
si_ord = si[match(   dimnames(LPJ)[[3]], rownames( si)),]
#unique(match(  dimnames(LPJ)[[3]], rownames( si_ord)) == 1: length( dimnames(LPJ)[[3]]))


#####################  add tribe classifiers    ##########################
info= read.csv ("../../01_Data/Species_TO_tribe.csv")
info$tribe = substr(tolower(info$Tribe),1,5)
sp = data.frame("Species.ID" = rownames( si_ord))
tribe= merge( sp, info, all.x=T, sort=F) [,c(1,4)]
#tribe[is.na( tribe$tribe),]
#unique(match( tribe$Species.ID, sp[,1]) == 1: length( sp[,1]))
#str(tribe)
tribe$tribe= as.factor(tribe$tribe)

################################################
######   two Block pls both bocks  free to rotate
################################################
f = two.b.pls( si_ord, LPJ) 

print( " ################################################# ")
print( " *** PLS LPJ with SI data *** ")
print( " ################################################# ")
print(f)

### loading of the SI projections
print(" ---  loading of the SI projections ---")
print(f$left.pls.vectors)
###  get projected scores

###  get projected scores
f1= data.frame( "XScores"=f$ XScores[,1], "YScores"=f$ YScores[,1] , "species"= tribe $Species.ID , "tribe"= tribe $tribe)

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
print(summary(pgls(YScores ~ XScores , compset, lambda= 'ML', bounds=list(lambda=c(0,1.02)))))


################################################
######  save PLS scores to file
write.csv( f1, "../LPJ/PLS_LPJ_SI.txt", quote=F, row.names=F)


#################
#######  plot
###################

### predict major regression line from PLS scores
pc = prcomp(cbind(f1$XScores, f1$YScores))$x[,1]
px = predict( (lm(f1$XScores~pc)))
py = predict(lm(f1$YScores~pc))
R=round(summary(lm( f$ YScores[,1] ~ f$ XScores[,1]))$r.square,3)


### outlines to draw the shapes
outline1=c(1,12,11,13,10,14,9,15,8,3,23,24,25,5,6,7,22,16,21,17,20,18,19,1)
outline2=c(1,19,18,20,17,21,16,22,7,6,5,25,24,23,3,39,40,41,29,30,31,38,32,37,33,36,34,35,1)
outline3=c(1,12,11,13,10,14,9,15,8,3)


###   set color palette
col.sp = read.table( "../../01_Data/colors_tribes.txt", head=T)
col.sp2= col.sp[match (  levels(tribe $tribe) , col.sp$tribe),]
#match (col.sp2$tribe, levels(tribe $tribe))
palette(c(as.character(col.sp2$color)))


quartz(file="../Plots/LPJ_SI_PLS.pdf", type="pdf", width=7, height=7)

par(mar = c(5,12,2,2))
plot( f1$ XScores, f1$ YScores, col=f1$tribe, pch=16, ylab= "LPJ shape projection", xlab="stable Isotope projection", las=1)
abline(lm(py ~ px ), lty="dashed")
legend( "topleft", paste ("cor= ", round(f$ r.pls,3) , " ; R2 = ",  R, sep=""  ), bty="n")

split.screen(figs=c(4,4), erase=F)

screen(1)
par(mar = c(0,0,0,0))
plot(maxshape[c(1:27),1], -1* maxshape[c(1:27),3], xlim=c(-0.25,0.75), ylim=c(-0.5,0.5), pch=16, type="n", axes=F, xlab="", ylab="")
polygon(maxshape[c(outline1),1]  +0.5 , -1* maxshape[c(outline1),3]  +0.1 )
segments(maxshape[15,1]  +0.5 ,-1* maxshape[15,3]  +0.1 , maxshape[26,1]  +0.5 , -1* maxshape[26,3]  +0.1 )
segments(maxshape[7,1]  +0.5 ,-1* maxshape[7,3]  +0.1 , maxshape[26,1]  +0.5 ,  -1* maxshape[26,3]  +0.1 )
polygon(maxshape[c(4,2,27),1]  +0.5 , -1* maxshape[c(4,2,27),3]  +0.1, col= rgb(0.51,0.5,0.5,alpha=0.2) )

lines( y= maxshape[outline3,1],-1* maxshape[outline3,2], col="grey")
segments( y0= maxshape[15,1],-1* maxshape[15,2],  y1= maxshape[26,1],  -1* maxshape[26,2], col="grey")
segments( y0= maxshape[7,1],-1* maxshape[7,2],  y1=  maxshape[26,1],  -1* maxshape[26,2], col="grey")
segments( y0= maxshape[42,1],-1* maxshape[42,2],   y1= maxshape[15,1],  -1* maxshape[15,2], col="grey")
segments( y0= maxshape[42,1],-1* maxshape[42,2],   y1= maxshape[31,1],  -1* maxshape[31,2], col="grey")
polygon( y= maxshape[c(outline2),1], -1* maxshape[c(outline2),2])
polygon( y= maxshape[c(4,2,28,27),1], -1* maxshape[c(4,2,28,27),2], col= rgb(0.51,0.5,0.5,alpha=0.2))

polygon(maxshape[c(outline2),2]  +0.5 , -1* maxshape[c(outline2),3]  -0.1 )
lines(maxshape[outline3,2]  +0.5 ,-1* maxshape[outline3,3]  -0.1 , col="black")
segments(maxshape[15,2]  +0.5 ,-1* maxshape[15,3]  -0.1 , maxshape[26,2]  +0.5 ,  -1* maxshape[26,3]  -0.1 , col="black")
segments(maxshape[7,2]  +0.5 ,-1* maxshape[7,3]  -0.1 , maxshape[26,2]  +0.5 ,  -1* maxshape[26,3]  -0.1 , col="black")
segments(maxshape[42,2]  +0.5 ,-1* maxshape[42,3]  -0.1 , maxshape[15,2]  +0.5 ,  -1* maxshape[15,3]  -0.1 , col="black")
segments(maxshape[42,2]  +0.5 ,-1* maxshape[42,3]  -0.1 , maxshape[31,2]  +0.5 ,  -1* maxshape[31,3]  -0.1 , col="black")
polygon(maxshape[c(4,2,28,27),2]+0.5, -1* maxshape[c(4,2,28,27),3] -0.1, col= rgb(0.51,0.5,0.5,alpha=0.2))

screen(13)
par(mar = c(0,0,0,0))
plot(minshape[c(1:27),1], -1* minshape[c(1:27),3], xlim=c(-0.25,0.75), ylim=c(-0.5,0.5), pch=16, col="white", axes=F, xlab="", ylab="")
polygon(minshape[c(outline1),1]  +0.5 , -1* minshape[c(outline1),3]  +0.1 )
segments(minshape[15,1]  +0.5 ,-1* minshape[15,3]  +0.1 , minshape[26,1]  +0.5 , -1* minshape[26,3]  +0.1 )
segments(minshape[7,1]  +0.5 ,-1* minshape[7,3]  +0.1 , minshape[26,1]  +0.5 ,  -1* minshape[26,3]  +0.1 )
polygon(minshape[c(4,2,27),1]  +0.5 , -1* minshape[c(4,2,27),3]  +0.1, col= rgb(0.51,0.5,0.5,alpha=0.2) )

lines( y= minshape[outline3,1],-1* minshape[outline3,2], col="grey")
segments( y0= minshape[15,1],-1* minshape[15,2],  y1= minshape[26,1],  -1* minshape[26,2], col="grey")
segments( y0= minshape[7,1],-1* minshape[7,2],  y1=  minshape[26,1],  -1* minshape[26,2], col="grey")
segments( y0= minshape[42,1],-1* minshape[42,2],   y1= minshape[15,1],  -1* minshape[15,2], col="grey")
segments( y0= minshape[42,1],-1* minshape[42,2],   y1= minshape[31,1],  -1* minshape[31,2], col="grey")
polygon( y= minshape[c(outline2),1], -1* minshape[c(outline2),2])
polygon( y= minshape[c(4,2,28,27),1], -1* minshape[c(4,2,28,27),2], col= rgb(0.51,0.5,0.5,alpha=0.2))

polygon(minshape[c(outline2),2]  +0.5 , -1* minshape[c(outline2),3]  -0.1 )
lines(minshape[outline3,2]  +0.5 ,-1* minshape[outline3,3]  -0.1 , col="black")
segments(minshape[15,2]  +0.5 ,-1* minshape[15,3]  -0.1 , minshape[26,2]  +0.5 ,  -1* minshape[26,3]  -0.1 , col="black")
segments(minshape[7,2]  +0.5 ,-1* minshape[7,3]  -0.1 , minshape[26,2]  +0.5 ,  -1* minshape[26,3]  -0.1 , col="black")
segments(minshape[42,2]  +0.5 ,-1* minshape[42,3]  -0.1 , minshape[15,2]  +0.5 ,  -1* minshape[15,3]  -0.1 , col="black")
segments(minshape[42,2]  +0.5 ,-1* minshape[42,3]  -0.1 , minshape[31,2]  +0.5 ,  -1* minshape[31,3]  -0.1 , col="black")
polygon(minshape[c(4,2,28,27),2]+0.5, -1* minshape[c(4,2,28,27),3] -0.1, col= rgb(0.51,0.5,0.5,alpha=0.2))

close.screen(all = TRUE) 

dev.off()






