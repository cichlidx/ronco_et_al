## Fabrizia Ronco
## April 2020



########################################################################
####    making SI plot tribewise   ###################################
########################################################################


########################################################################
#######   requried packages  ###########################################

require(plyr) 	# version 1.8.4
require(scales)	# version 1.0.0


########################################################################
### get data abd add species and tribe info

scores= read.csv("../../01_Data/SI_data.csv", h=T)
## add species info:
spinfo= read.csv("../../01_Data/specimen_voucher_key.csv", head=T)
scores = merge( scores, spinfo[,c(1,3,5)], by.x="ID", by.y="ID", all.x=T)
#head(scores)
scores$Tribe= as.factor(tolower(substr(scores$Tribe,1,5)))
#levels(scores$Tribe)
#head(scores)

########################################################################
###  define tribe colours
col.sp=read.table("../../01_Data/colors_tribes.txt" ,h=T)
col.sp2= col.sp[match( levels(scores$Tribe), col.sp$tribe),]
palette( c(as.character(col.sp2$color), "grey"))



########################################################################
### calculate hulls per species and mean for adding species names 
find_hull = function(x) x[chull(x$d13C, x$d15N),]

hulls = ddply(scores, "SpeciesID", find_hull)
means = aggregate( scores[,2:3], by= list(scores$SpeciesID, scores$Tribe), mean)
names(means) = c("Species", "Tribe", "N", "C")
#head(means)

########################################################################
###. make lsit of tribes to be plotted, singel out the tribes with one species only to combine them in one of the panels
tribe_list=as.character(col.sp2[,1])
tribe_list2= tribe_list[-c(3,10,14)]
tribe_list3= tribe_list[c(3,10,14)]

########################################################################
###. panel PLOT 
quartz(width =8.3 , height=11.7, file="../Plots/Panelplot_SI.pdf", type="pdf")
par(mar=c(2,2,1,1))

split.screen(figs=c(4,3), erase=T)
for ( k in 1: length( tribe_list2)) {
	screen(k)
	plot( scores$d13C, scores$d15N, pch=16, col="grey", cex=0.5, axes=F,
	xlab= "d13C",ylab= "d15N", cex.lab=0.75, ylim=c(2,12), xlim=c(-25,-8))
	tmp_hulls_focal= hulls[hulls$Tribe == tribe_list2[k], ]
	tmp_hulls_rest= hulls[hulls$Tribe != tribe_list2[k], ]
	tmp_means_focal= means[means $Tribe == tribe_list2[k], ]
	tmp_means_rest= means[means $Tribe != tribe_list2[k], ]
	
	for ( i in 1: dim(tmp_means_focal)[1]) {
		polygon(tmp_hulls_focal $d13C[tmp_hulls_focal $Species== tmp_means_focal $Species[i]], 
		tmp_hulls_focal $d15N[tmp_hulls_focal $Species== tmp_means_focal $Species[i]], 
		col= alpha(as.numeric(tmp_means_focal $Tribe[i]),0.5), border= tmp_means_focal $Tribe[i]  )
	}
	text(tmp_means_focal $C, tmp_means_focal $N, tmp_means_focal $Species, cex=0.3 )
	axis(1, tck=-0.01, cex.axis=0.5, at=seq(-25, -8, 2));axis(2, las=1, tck=-0.01, cex.axis=0.5)
}

screen(k+1)
plot( scores$d13C, scores$d15N, pch=16, col="grey", cex=0.5, axes=F, ylim=c(2,12), xlim=c(-25,-8),
xlab= paste("d13C"), ylab= paste("d15N"), cex.lab=0.75)

tmp_hulls_focal= hulls[hulls$Tribe %in% tribe_list3, ]
tmp_hulls_rest= hulls[! hulls$Tribe %in% tribe_list3, ]
tmp_means_focal= means[means $Tribe %in% tribe_list3, ]
tmp_means_rest= means[! means $Tribe %in% tribe_list3, ]

for ( i in 1: dim(tmp_means_focal)[1]) {
	polygon(tmp_hulls_focal $d13C[tmp_hulls_focal $Species== tmp_means_focal $Species[i]], 
	tmp_hulls_focal $d15N[tmp_hulls_focal $Species== tmp_means_focal $Species[i]], 
	col= alpha(as.numeric(tmp_means_focal $Tribe[i]),0.5), border= tmp_means_focal $Tribe[i]  )
}
text(tmp_means_focal $C, tmp_means_focal $N, tmp_means_focal $Species, cex=0.3 )
axis(1, tck=-0.01, cex.axis=0.5,at=seq(-25, -8, 2));axis(2, las=1, tck=-0.01, cex.axis=0.5)


close.screen(all.screens=T)
dev.off()
