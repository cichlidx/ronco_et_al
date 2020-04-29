## Fabrizia Ronco
## April 2020



########################################################################
####    making PCA plots tribewise   ###################################
########################################################################



########################################################################
#######   requried packages  ###########################################

require(plyr) 	# version 1.8.4
require(scales)	# version 1.0.0



########################################################################
###  get trait from command line

args = commandArgs(trailingOnly = TRUE)
TRAIT = args[1]


########################################################################
### get data

if ( TRAIT == "body") {
	scores= read.table("../body/PCA_pc_scores_body.txt", h=T)
	importance= read.table("../body/PCA_importance_body.txt", h=T)
}
if ( TRAIT == "UOJ") {
	scores= read.table("../oral/PCA_pc_scores_UOJ.txt", h=T)
	importance= read.table("../oral/PCA_importance_UOJ.txt", h=T)
}
if ( TRAIT == "LPJ") {
	scores= read.table("../LPJ/PCA_pc_scores_LPJ.txt", h=T)
	importance= read.table("../LPJ/PCA_importance_LPJ.txt", h=T)
}


########################################################################
### rearrange data frame, so that plotting is the same for all 3 phenotypes
scores = data.frame(
	"sp" = scores[,names(scores) == "sp"],
	"tribe" = scores[,names(scores) == "tribe"],
	"PC1" = scores[,names(scores) == "PC1"],
	"PC2" = scores[,names(scores) == "PC2"])


########################################################################
###  define tribe colours
col.sp=read.table("../../01_Data/colors_tribes.txt" ,h=T)
col.sp2= col.sp[match( levels(scores$tribe), col.sp$tribe),]
palette( c(as.character(col.sp2$color), "grey"))

########################################################################
### calculate hulls per species and mean for adding species names 
find_hull = function(x) x[chull(x$PC1, x$PC2),]
hulls = ddply(scores, "sp", find_hull)
means = aggregate( scores[,3:4], by= list(scores$sp, scores$tribe), mean)
names(means) = c("species", "tribe", "PC1", "PC2")
#head(hulls)
#head(means)

########################################################################
###. make lsit of tribes to be plotted, singel out the tribes with one species only to combine them in one of the panels
tribe_list=as.character(col.sp2[,1])
###. get tribes with one species only 
tribe_list2= tribe_list[-c(3,10,14)]
tribe_list3= tribe_list[!tribe_list %in% tribe_list2]

########################################################################
###. panel PLOT 

quartz(width =8.3 , height=11.7, file=paste("../Plots/Panelplot_PCA_", TRAIT, ".pdf", sep="" ), type="pdf")
par(mar=c(2,2,1,1))
split.screen(figs=c(4,3), erase=T)

for ( k in 1: length( tribe_list2)) {
	screen(k)
	plot( scores$PC1, scores$PC2, pch=16, col="grey", cex=0.5, axes=F,
	xlab= paste("PC1 (",round(importance$PC1[2]*100,1), "%)", sep="" ), 
	ylab= paste("PC2 (",round(importance$PC2[2]*100,1), "%)", sep=""), cex.lab=0.75)
	segments( min(scores$PC1), 0,max(scores$PC1), 0 , lty="dashed", col="grey", lwd=1.5)
	segments( 0,min(scores$PC2), 0,max(scores$PC2) , lty="dashed", col="grey", lwd=1.5)

	tmp_hulls_focal= hulls[hulls$tribe == tribe_list2[k], ]
	tmp_hulls_rest= hulls[hulls$tribe != tribe_list2[k], ]
	tmp_means_focal= means[means $tribe == tribe_list2[k], ]
	tmp_means_rest= means[means $tribe != tribe_list2[k], ]
	
	for ( i in 1: dim(tmp_means_focal)[1]) {
		polygon(tmp_hulls_focal $PC1[tmp_hulls_focal $sp== tmp_means_focal $species[i]], 
		tmp_hulls_focal $PC2[tmp_hulls_focal $sp== tmp_means_focal $species[i]], 
		col= alpha(as.numeric(tmp_means_focal $tribe[i]),0.5), border= tmp_means_focal $tribe[i]  )
	}
	text(tmp_means_focal $PC1, tmp_means_focal $PC2, tmp_means_focal $species, cex=0.5 )
	axis(1, tck=-0.01, cex.axis=0.5);axis(2, las=1, tck=-0.01, cex.axis=0.5)
}

screen(k+1)
plot( scores$PC1, scores$PC2, pch=16, col="grey", cex=0.5, axes=F,
xlab= paste("PC1 (",round(importance$PC1[2]*100,1), "%)", sep=""), 
ylab= paste("PC2 (",round(importance$PC2[2]*100,1), "%)", sep=""),  cex.lab=0.75)
segments( min(scores$PC1), 0,max(scores$PC1), 0 , lty="dashed", col="grey", lwd=1.5)
segments( 0,min(scores$PC2), 0,max(scores$PC2) , lty="dashed", col="grey", lwd=1.5)

tmp_hulls_focal= hulls[hulls$tribe %in% tribe_list3, ]
tmp_hulls_rest= hulls[! hulls$tribe %in% tribe_list3, ]
tmp_means_focal= means[means $tribe %in% tribe_list3, ]
tmp_means_rest= means[! means $tribe %in% tribe_list3, ]

for ( i in 1: dim(tmp_means_focal)[1]) {
	polygon(tmp_hulls_focal $PC1[tmp_hulls_focal $sp== tmp_means_focal $species[i]], 
	tmp_hulls_focal $PC2[tmp_hulls_focal $sp== tmp_means_focal $species[i]], 
	col= alpha(as.numeric(tmp_means_focal $tribe[i]),0.5), border= tmp_means_focal $tribe[i]  )
}
text(tmp_means_focal $PC1, tmp_means_focal $PC2, tmp_means_focal $species, cex=0.5 )
axis(1, tck=-0.01, cex.axis=0.5);axis(2, las=1, tck=-0.01, cex.axis=0.5)

close.screen(all.screens=T)
dev.off()
