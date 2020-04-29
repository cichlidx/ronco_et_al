

##  get variables from comand line

TREE="b1"
TRAIT="PLS"
n= 0.15    ####  recunstructed in n timeinterval

max.value=37 ##BEAST;


# load packages
require(phytools)
require(scales)
require(gplots)



#####--------  make function for normalization
normalize = function(x){(x-min(x,na.rm=T))/(max(x,na.rm=T)-min(x,na.rm=T))}


####  make asymetric color ramp, centered in 1
 
ramp1 = colorRampPalette(c("blue","grey"))
ramp2 = colorRampPalette(c("grey","gold","tomato","red", "darkred", "#3D0404"))

# now specify the range and the center value
 min.value=0; mid.value=1
#range(treedat$meanRate)

       
col_per_step=500/max.value
max.breaks = max.value - mid.value
min.breaks = mid.value - min.value
       
low.ramp = ramp1(min.breaks*(col_per_step))
high.ramp = ramp2(max.breaks*(col_per_step))
       
myColors= c(low.ramp, high.ramp)  

#####. remove duplicates:
myColors=unique(myColors)

# create breaks corresponding to the color ramp
breaks = 0:length(myColors)/length(myColors) * (max.value - min.value) + min.value
# make a function to assign colors from the palette with its breaks to the values you wanna plot
whichColor = function(p, cols, breaks) {
        i = 1
        while (p >= breaks[i] && p > breaks[i + 1]) i = i +1
        cols[i]
    }








###  open the pdf to write in all the plot parts

quartz( width =8.3 , height=11.7 , type="pdf", file=paste("../output/",TRAIT,"_", TREE, "_all_traits_panel.pdf", sep=""))
split.screen(figs=c(5,4), erase=T)


	

	#AXLIST=read.table(paste("axlist_", TRAIT, ".txt", sep=""))
	AXLIST=as.data.frame(c("body", "oral", "LPJ"))
	pos=c(1,5,9,13)
k=2
	for ( k in 1: 4){
	

		if ( k !=4) AXES= as.character(AXLIST[k,1])
		if ( k ==4){ 
			AXES= "color"
			TRAIT="singletrait"}

		dirname= paste("../output/output",TREE, TRAIT, AXES ,sep="_")
		filename=paste(dirname,"/out","_", TRAIT, "_",AXES, sep="")


# get orig. tree
		origtree= read.nexus(paste("../input/",TREE,"_pruned_to_", TRAIT,"_", AXES,"_" ,"data_nexus.tre", sep=""))
		origtree= ladderize(origtree)
		treedat =read.table(paste(dirname,"/",TRAIT,"_" ,AXES,"_", "treedat_forPlot.txt", sep=""), h=T)

if(any(origtree$edge != treedat[,2:3])) stop("tree is in the wrong order!")


H = nodeHeights(origtree)  ### get age of each node
root=max(H[,2]) ##   get age of the root  ]]
root2=ceiling(root)

##########################################  get sigma per trait, need burnin and log file
#head(treedat)
####  assign colors
		treedat$LogRate = treedat$relRate
 		colors = sapply(treedat$LogRate, whichColor, cols = myColors, breaks = breaks)
		print(range(treedat$LogRate))
		treedat$PP2=treedat$PP2*0.5

		screen(pos[k])
		par(mar= c(0.25,0.25,0.25,0.25))
		plot.phylo(origtree,cex=0.5, edge.width =1 , type="fan", edge.color=colors, show.tip.label=F, 	open.angle=20, rotate.tree=20, no.margin=F)
		edgelabels(pch=19, cex=treedat$PP2, col = alpha("tomato", 0.4))
		mtext(paste(" ",AXES,sep=""), side=3, adj=1.1, padj=1.75)

#	add.color.bar(leg=5, cols= myColors, titel="Relative rates", outline=F, lims=range(breaks), prompt=F, x=5, y=1.5, lwd=5 )



barlen=( 5/diff(range(breaks)))*diff(range(treedat$LogRate))
colforbar= myColors [myColors %in% colors]

mincol=grep(colforbar[1], myColors)
maxcol=grep(colforbar[length(colforbar)], myColors)
colforbar2 = myColors[mincol: maxcol]


	add.color.bar(leg= barlen, cols= colforbar2, titel="Relative rates", outline=F, lims=range(treedat$LogRate), prompt=F, x=5, y=1.5, lwd=5 )

	


####   get  densities and maek 2d hist

		den = read.table(paste(dirname, "/" ,"AncRec_sampled_by_",n, "_", TRAIT, "_", AXES, ".txt", sep=""), h=T)
		nbins = trunc(root/n)
		

		a = hist2d( den $sample, den $y3, nbins= nbins, axes=F, show=F)
		maxa = max(a$counts)
		tck = -0.02
		xlim=c(0-(root2-root),root2)

		screen(pos[k]+1)
		par(mar=c(2,2,2,2))
		hm_col_scale = colorRampPalette(c( "grey80", "black"))(maxa)
		hm_col_scale2= c("white", hm_col_scale)
		hist2d( den $sample, den $y3, nbins= nbins, col= hm_col_scale2, axes=F, xlim=xlim)
		axis(1,at= rev(root2- c(seq(0, root2, 1)))-(root2-root), rev(c(seq(0, root2, 1))), tck= tck, las=1, cex.axis=0.5, padj=-3)   ######  fitx this, axies is shifted (only raphically)
		axis(2, tck= tck, las=1, cex.axis=0.5,  mgp=c(3, 0.3, 0))
		mtext("Time (Ma)", 1, line=1.4, cex=0.75)
		range= c(0:maxa)
		topl= matrix(rep(range, length(range)), length(range), length(range))
		par(mar=c(2.1,2.1,7,8), new=T)
		image(t(topl), col= hm_col_scale2, axes=F)
		##  for even
		if((maxa %% 2) == 0) {
			at=c((1/maxa),seq(0,1,by=2/maxa)[-1])
			label=c(1,seq(0, maxa, by=2)[-1])
		}
		##  for odd
		if((maxa %% 2) != 0) {
			at=c(seq(0+(1/(maxa)),1, 2/(maxa)))
			label=seq(1, maxa, by=2)
		}
	
		axis(4, at= at , label= label , las=1, line=-0.8, cex.axis=0.3, lwd=0)




#		load(paste(dirname, "stats_over_time_observed.Rdata", sep="/"))
#		load(paste(dirname, "stats_over_time_BM.Rdata", sep="/"))
		load(paste(dirname, "Diff_slope_to_sim_over_time.Rdata", sep="/"))
		cex.axis=0.5
		
		
		t1=Dif_slopeBMrange2[,1]
		Dif_slopeBMrange= Dif_slopeBMrange2[,-1]

		MEAN_DIF_SLOPE_RANGE=apply(Dif_slopeBMrange, 1, mean)
		###  get the timevector of the center of each sliding window
		
		###  calucualte teh 95% polygon
		f=nrow(Dif_slopeBMrange)
		dd=c(0.05/2, 1-0.05/2)
		tmp=sapply(1:f, function(x) quantile(Dif_slopeBMrange[x,], probs=dd, na.rm=TRUE))
		yy=c(tmp[1,], rev(tmp[2,]))
		xx=c(t1 , rev(t1))
		polyRANG_E_RANGE =cbind(x=xx, y=yy)
		
		
		screen(pos[k]+2)
		par(mar=c(2,2,2,2))

		ylim= range(c(polyRANG_E_RANGE[, "y"], polyRANG_E_RANGE[, "y"] )*1.25)
		load(paste(dirname, "stats_over_time_observed.Rdata", sep="/"))
		

		
		plot(statsOtime$time, statsOtime$numLineages/ max(statsOtime$numLineages)*100, col="grey30" , lwd=1.5, type="l", ylim=c(0,100), axes=F, xlab="", ylab="", xlim=xlim)
		axis(4, at=c(seq(0,100,20)), labels= c(seq(0,100,20)), las=1,cex.axis= cex.axis , col="grey30",tck= tck)





		par(new = TRUE)

		plot(t1, MEAN_DIF_SLOPE_RANGE, ylim=ylim,xlim=xlim ,t="n", axes=F, xlab="", ylab="")
		axis(1, at= rev(root2- c(seq(0, root2, 1)))-(root2-root), rev(c(seq(0, root2, 1))),tck= tck, cex.axis= cex.axis, padj=-3)
		axis(2, tck= tck, las=1, cex.axis= cex.axis, mgp=c(3, 0.3, 0))
		polygon(polyRANG_E_RANGE[, "x"], polyRANG_E_RANGE[, "y"], col = alpha("deepskyblue4",0.2), border = NA)
		abline(h=0, col="grey", lty="dashed")
		lines(t1, MEAN_DIF_SLOPE_RANGE, type="l",col="deepskyblue4", lwd=1.5)
		mtext("Time (Ma)", 1, line=1.4, cex=0.75)
		mtext("Difference in slope \n(observed - BM)", 2, line=1, cex=0.75)
	

	
	
		screen(pos[k]+3)
		par(mar=c(2,2,2,2))

		plot(statsOtime$time, statsOtime$numLineages/ max(statsOtime$numLineages)*100, col="grey30" , lwd=1.5, type="l", ylim=c(0,100), axes=F, xlab="", ylab="", xlim=xlim)
		axis(4, at=c(seq(0,100,20)), labels= c(seq(0,100,20)), las=1,cex.axis= cex.axis , col="grey30",tck= tck)


		par(new = TRUE)
		mean_rateTT= read.csv(paste(dirname, "/mean_rate_tt.csv", sep=""))
		CI_rateTT= read.csv(paste(dirname, "/SD_rate_tt.csv", sep=""))

		
		ylim= c(0, max(CI_rateTT[, "y"]) *1.25)
	#	ylim= c(0, max(rate95TT[, "y"]) *1.25)
		
		plot(mean_rateTT$v, mean_rateTT$mean_rate, ylim=ylim,xlim=xlim ,t="n", axes=F, xlab="", ylab="")
		polygon(CI_rateTT[, "x"], CI_rateTT[, "y"], col = alpha("deepskyblue4",0.2), border = NA)
	#	polygon(rate95TT[, "x"], rate95TT[, "y"], col = alpha("deepskyblue4",0.2), border = NA)
		lines(mean_rateTT$v, mean_rateTT$mean_rate, type="l",col="deepskyblue4", lwd=1.5)
		axis(1,at= rev(root2- c(seq(0, root2, 1)))-(root2-root), rev(c(seq(0, root2, 1))), tck= tck, cex.axis= cex.axis, padj=-3)
		axis(2, tck= tck, las=1, cex.axis= cex.axis, mgp=c(3, 0.3, 0))
		mtext("Time (Ma)", 1, line=1.4, cex=0.75)
		mtext("Relative rate of evolution", 2, line=1, cex=0.75)
		abline(h=1, col="grey", lty="dashed")


	}		
	

		

close.screen(all.screens=T)
dev.off()



#legend("topright", legend=c("> 50", "> 75", "> 90"), pch=19, col=alpha("tomato", 0.3), bty="n", cex= 1,pt.cex=c( 0.5, 1, 1.5) , title ="PP")





