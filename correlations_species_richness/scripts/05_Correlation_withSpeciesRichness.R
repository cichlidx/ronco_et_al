### Fabrizia Ronco
## April 2020


############################################################################
### testing the different genomic summary satistics for a correlation with taxonmic diversity (across tribes)


###  load packages
require(scales) 	## version 1.0.1 
require(phytools) 	## version 0.6-60
require(caper)		## version 1.0.1 
require(picante)	## version 1.8 



#### calculate for each statistics the per tribe the mean with CI

######################
#########  dN/dS
#######################
sp_means_dNDS = read.csv("../output/dN_dS_dNdS_genomewide_species_means.csv")
head(sp_means_dNDS)

dNDS_mean = aggregate( sp_means_dNDS$dNdS, list(sp_means_dNDS $tribe2), mean)
dNDS_CI = aggregate( sp_means_dNDS$dNdS, list(sp_means_dNDS $tribe2), function(x) (1.96*(sd(x)/sqrt(length(x))) )  )

######################
#########  dups
#######################
sp_means_dup = read.csv("../output/Dupplication_species_means.csv", row.names=1)
head(sp_means_dup)
sp_means_dup$tribe2 = substr(tolower(sp_means_dup$tribe),1,5)

dups_mean = aggregate( sp_means_dup$dup, list(sp_means_dup $tribe2), mean)
dups_CI = aggregate( sp_means_dup$dup, list(sp_means_dup $tribe2), function(x) (1.96*(sd(x)/sqrt(length(x))) )  )


######################
#########  TE's
#######################

sp_means_TE = read.table("../input/TEs_percent_per_species.tsv", h=T)
dim(sp_means_TE)

head(sp_means_TE)
sp_means_TE $tribe2 = substr(tolower(sp_means_TE $Tribe),1,5)

TE_mean = aggregate( sp_means_TE$TEs_percent, list(sp_means_TE $tribe2), mean)
TE_CI = aggregate( sp_means_TE$TEs_percent, list(sp_means_TE $tribe2), function(x) (1.96*(sd(x)/sqrt(length(x))) )  )


######################
#########  D-stats
#######################Dstats_ready_to_plot.csv

sp_means_D = read.table("../input/F4_withinTribes.txt", h=T)
head(sp_means_D)

D_mean = aggregate( sp_means_D$fG, list(sp_means_D $tribe), mean)
D_CI = aggregate( sp_means_D$fG, list(sp_means_D $tribe), function(x) (1.96*(sd(x)/sqrt(length(x))) )  )


######################
#########  hets
#######################
sp_means_het = read.csv("../output/hets_species_means.csv")
head(sp_means_het)
sp_means_het$tribe2 = substr(tolower(sp_means_het$tribe),1,5)

het_mean = aggregate( sp_means_het$het, list(sp_means_het $tribe2), mean)
het_CI = aggregate( sp_means_het$het, list(sp_means_het $tribe2), function(x) (1.96*(sd(x)/sqrt(length(x))) )  )


####################################################################
####  rename colums to merge in one data frame for plotting
colnames(dNDS_mean)	[2] = "dNDS_mean"
colnames(dups_mean)	[2] = "dups_mean"
colnames(TE_mean)	[2] = "TE_mean"
colnames(het_mean)	[2] = "het_mean"
colnames(D_mean)	[2] = "F_mean"

tmp1 = merge( TE_mean	, dups_mean , all.y=T, all.x=T)
tmp2 = merge( tmp1	, dNDS_mean , all.y=T, all.x=T)
tmp3 = merge( tmp2	, het_mean , all.y=T, all.x=T)
out = merge( tmp3	, D_mean , all.y=T, all.x=T)

head(out)
### same for CI

colnames(dNDS_CI)	[2] = "dNDS_CI"
colnames(dups_CI)	[2] = "dups_CI"
colnames(TE_CI)		[2] = "TE_CI"
colnames(het_CI)	[2] = "het_CI"
colnames(D_CI)		[2] = "F_CI"


tmp5 = merge( TE_CI	, dups_CI , all.y=T, all.x=T)
tmp6 = merge( tmp5	, dNDS_CI , all.y=T, all.x=T)
tmp7 = merge( tmp6	, het_CI , all.y=T, all.x=T)
out2 = merge( tmp7	, D_CI , all.y=T, all.x=T)

head(out2)


## add number of species
sp_num = read.table("../input/species_number.txt", h=T)   ### estimated number fo species per tribe from Ronco et al. 2019
sp_num$tribe2= tolower(substr( sp_num $tribe,1,5))
use_for_order= sp_num[order(sp_num $est_num_sp),]

out = merge( out, sp_num, by.x="Group.1", by.y="tribe2", all.x=T, all.y=F)
out2 = merge( out2, sp_num, by.x="Group.1", by.y="tribe2", all.x=T, all.y=F)


########################################################################
##########  clean up the origianl input files
sp_means_dNDS$dN=NULL; sp_means_dNDS$dS=NULL; sp_means_dNDS$bp=NULL
sp_means_dup$X=NULL
sp_means_TE$X=NULL; sp_means_TE$Genome_ID=NULL
sp_means_D$X=NULL; sp_means_D$D=NULL; sp_means_D$pVal=NULL
sp_means_het$X=NULL


############################  merge estimated number of species and drop levels. --> make sure the dataframes have exacetly the same data structure 


sp_means_dNDS2 = merge(sp_means_dNDS ,sp_num, all.x=T, all.y=F)
sp_means_dup2 = merge(sp_means_dup ,sp_num, all.x=T, all.y=F)
sp_means_het2 = merge(sp_means_het ,sp_num, all.x=T, all.y=F)
sp_means_TE2 = merge(sp_means_TE ,sp_num, all.x=T, all.y=F, by.x="Tribe", by.y="tribe")
sp_means_TE2 =sp_means_TE2[, c(1,4,2,3,5)]
names(sp_means_TE2) = c ( "tribe","tribe2","species","TE","est_num_sp")
sp_means_D2 = merge(sp_means_D, sp_num ,all.x=T, all.y=F, by.x="tribe", by.y="tribe2")
sp_means_D2$Species = paste(sp_means_D2$s1, sp_means_D2$s2, sp_means_D2$s3, sep="_")
sp_means_D2[,2:4] =NULL
sp_means_D2 = sp_means_D2[,c(3,1,5,2,4)]
names(sp_means_D2) = c ( "tribe","tribe2","species","F4","est_num_sp")

###. add tribe colum with levels in plotting order for coloring the data points

sp_means_dNDS2$tribe3	= droplevels(factor(as.character(sp_means_dNDS2$tribe2) , levels = use_for_order $tribe2) )
sp_means_dup2$tribe3		= droplevels(factor(as.character(sp_means_dup2$tribe2	) , levels = use_for_order $tribe2) )
sp_means_TE2$tribe3		= droplevels(factor(as.character(sp_means_TE2$tribe2	) , levels = use_for_order $tribe2) )
sp_means_D2$tribe3		=factor(as.character(sp_means_D2$tribe2	) , levels = use_for_order$tribe2[-c(2,3,4,7)])  
sp_means_het2$tribe3		= droplevels(factor(as.character(sp_means_het2$tribe2	) , levels = use_for_order $tribe2)) 


######  set in each datasets groups that are >10 datapoints per tribe to NA (only for visulaisation)

NdNdS = aggregate(sp_means_dNDS2[,4], list(sp_means_dNDS2$tribe3), length)
Ndup = aggregate(sp_means_dup2[,4], list(sp_means_dup2 $tribe3), length)
NTE = aggregate(sp_means_TE2[,4], list(sp_means_TE2 $tribe3), length)
ND = aggregate(sp_means_D2[,4], list(sp_means_D2 $tribe3), length)
Nhet = aggregate(sp_means_het2[,4], list(sp_means_het2$tribe3), length)

NdNdS[NdNdS$x >= 40,]
Ndup[Ndup$x >= 40,]
NTE[NTE$x >= 40,]
ND[ND$x <= 40,]
Nhet[Nhet$x >= 35,]

###  all troph, all ectod, all lampr  for all data sets

setNA = NdNdS[NdNdS$x >= 40,1]

sp_means_dNDS2[sp_means_dNDS2 $tribe3 %in% setNA,4] =NA
sp_means_dup2[sp_means_dup2 $tribe3 %in% setNA,4] =NA
sp_means_TE2[sp_means_TE2 $tribe3 %in% setNA,4] =NA
sp_means_het2[sp_means_het2 $tribe3 %in% setNA,4] =NA



#####  all but benth, cypho and eret for D-stats

keep = ND[ND$x <= 40,1]
sp_means_D2[! sp_means_D2 $tribe3 %in% keep,4] =NA

head(sp_means_D2)




all_points= list( sp_means_TE2, sp_means_dup2, sp_means_dNDS2, sp_means_het2, sp_means_D2)

#################################################### ---------------------------------------   set colors
col1= read.table("../input/colors_tribes.txt", h=T)
out$Group.1 = droplevels(factor(out$Group.1 , levels = use_for_order $tribe2 ))
col2= col1[match(levels(out$Group.1), col1$tribe ),]
palette(as.character(col2$color))



###  prepare plot

axlabels= c("Number of TEs", "Number of gene duplications", "dN/dS",  "Heterozygosity", "f4-ratio")

Yranges=matrix(NA, 5,2)
Yranges[1,1:2]= c(12,16)		#TE
Yranges[2,1:2]= c(30,80)		#dups
Yranges[3,1:2]= c(0.18,0.20)  	#dNDS
Yranges[4,1:2]= c(0,0.25)		#het
Yranges[5,1:2]= c(0,0.15)		#D



################################################
######  plot
################################################



#####  set ploting parameters
tck=-0.01
cex.lab=0.6
cex.axis= 0.5
cex=0.8


quartz( width =3.6 , height=8.19  , type="pdf", file="../output/correlations_means_species_richness.pdf")

#quartz( width =3.6 , height=8.19 )
#head(all_points)
split.screen(figs=c(5,2), erase=T)

for (i in 1:5) {
	screen(i)
	par(mar=c(1.5,2,0.5,0.5))
	ylim= Yranges[i,]
	

	plot(all_points[[i]][,4] ~ jitter(all_points[[i]][,5], factor= 1), las=2, xlab="", ylab="",  pch=16, cex=0.4,  axes=F, col=alpha( as.numeric(all_points[[i]]$tribe3),0.3) , 	ylim=ylim , log="x", xlim=c(1,100))
	axis(1, tck=tck, las=1, cex.axis= cex.axis, padj=-4 )
	axis(2, tck=-tck, las=1, cex.axis= cex.axis , hadj = 0)
	mtext(paste(axlabels[i]), 2, line=1, cex=cex.lab)
	mtext("Number of species (log scale) ", 1, line=0.3, cex=cex.lab)
	segments(x0=out$est_num_sp, y0=out[,(1+i)]+out2[,(1+i)] ,x1=out$est_num_sp, y1=out[,(1+i)]-out2[,(1+i)] , col= out$Group.1)
	points (out[,(1+i)] ~ out$est_num_sp  , pch=16, cex=cex, col= out$Group.1 )


	if ( i == 4){
		par(new = TRUE) 
		plot(out[,(1+i)] ~ log(out$est_num_sp) , type="n", xlab="", ylab="",  axes=F, 	ylim=ylim, xlim= c(log(1),log(100)) )
		pca= prcomp(cbind(log(out$est_num_sp),out[,i+1]))$x
		px = predict( (lm(log(out$est_num_sp)~pca)))
		py = predict( (lm(out[,i+1]~pca)))
		abline(lm (py ~ px + 0 ), col="grey", lty="dashed")
	}

}


	#if( i == 7) text(D_sig$tribe2, -0.04, round(D_sig$ratio*100,1), cex=0.45 )

screen(6)
par(mar=c(1.5,1.5,0,0.5))
plot(c(1: length(levels(sp_means_dup2$tribe))), c(1: length(levels(sp_means_dup2$tribe))), type="n", axes=F, ylim=c(1,15))
points( rep(1, length(levels(out$Group.1))), c(1: length(levels(out$Group.1))), cex=0.6, pch=16, col=rev(c(1: length(levels(out$Group.1))) ))
text(1.5,c(1: length(levels(out$Group.1))), rev(levels(out$Group.1)[match( levels(out$Group.1), levels(out$Group.1))]), cex=cex, adj=0)

close.screen(all.screens=T)

dev.off()








################################################
######  stats
################################################




tree = read.nexus( "../input/b1_tribes.tre")
tree$tip.label = tolower(substr(tree$tip.label, 1, 5))

##### ##### ##### ##### ##### ##### ##### ##### ##### 
#####  correltion  using Pic transformed values
##### ##### ##### ##### ##### ##### ##### ##### ##### 

head(out)
tree$tip.label

stat_out3= as.data.frame(matrix ( NA, 5, 4))
stat_out3[,1] = names(out)[2:6]
colnames(stat_out3)= c("predictor", "r","df" ,"p")

for (i in 1:4) {
	tmp = log(out$est_num_sp)
	names(tmp) = out$Group.1

	tmp2 = out[,i+1]
	names(tmp2) = out$Group.1

	x= pic(tmp, tree)
	y =pic(tmp2, tree)
	
	f= data.frame(x,y)
	coTab = cor.table( f, cor.method = "pearson", cor.type="contrast")
	stat_out3[i,2] = coTab$r[1,2]
	stat_out3[i,3] = coTab$df
	stat_out3[i,4] = coTab$P[1,2]
}


Ftree= drop.tip(tree, "boule")
x= pic(tmp[-3] , Ftree)

tmp2 = out[,5+1]
names(tmp2) = out$Group.1
y =pic(tmp2[-3], Ftree)
f= data.frame(x,y)
coTab = cor.table( f, cor.method = "pearson", cor.type="contrast")
stat_out3[5,2] = coTab$r[1,2]
stat_out3[5,3] = coTab$df
stat_out3[5,4] = coTab$P[1,2]


print(stat_out3)





