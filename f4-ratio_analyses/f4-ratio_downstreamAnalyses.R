## Script of analyses for Ronco et al. (2020) "Drivers and dynamics of a massive adaptive radiation in African cichlid fishes"
## Author: Milan Malinsky millanek@gmail.com
## Analyses of introgression based on f4-ratio statistics

setwd("/DIRECTORY/f4-ratio_analyses/")

# 1) Read the "tree" output of Dsuite
DsuiteOut <- read.table("DsuiteOutput_tree.txt.gz",as.is=T,header=T)
names(DsuiteOut) <- c("s1","s2","s3","D","pVal","fG")
allSpecies <- unique(c(DsuiteOut$s3,DsuiteOut$s2,DsuiteOut$s1))

# 2) Find the maximum f4-ratio for each pair of species
maxF4s <- aggregate(DsuiteOut$fG~ DsuiteOut$s2+DsuiteOut$s3, FUN=max)

# 3) Fill those into a matrix:
F4matrix <- matrix(rep(0,265^2),265,265,dimnames=list(allSpecies,allSpecies))
i <- 0
for (s2 in allSpecies) {
	for (s3 in allSpecies) {
		index <- which(as.character(maxF4s$"DsuiteOut$s2") == s2 & as.character(maxF4s$"DsuiteOut$s3") == s3)
		indexReverse <- which(as.character(maxF4s$"DsuiteOut$s2") == s3 & as.character(maxF4s$"DsuiteOut$s3") == s2)
		if (length(index > 0) & length(indexReverse > 0)) {
			if (maxF4s[index,3] > maxF4s[indexReverse,3]) { 
				F4matrix[s2,s3] <- maxF4s[index,3]; 
			} else { 
				F4matrix[s2,s3] <- maxF4s[indexReverse,3]; 
			}
		} else if (length(index > 0)) {
			F4matrix[s2,s3] <- maxF4s[index,3]; 
		} else if (length(indexReverse > 0)) {
			F4matrix[s2,s3] <- maxF4s[indexReverse,3]; 
		}
		i <- i + 1
		if (i %% 100 == 0) { print(i);}
	}
}

write.table(F4matrix,"F4matrix_final.txt",quote=F,sep="\t")  # This is the matrix in Extended Data Fig. 8a

# 4) Sampling from the f4-ratio distribution:
# This provides the 20 samples for simulations which show the link between introgression and heterozygosity
for (sNum in 1:20) {
	sampleF4s <- aggregate(DsuiteOut$fG~ DsuiteOut$s2+DsuiteOut$s3, FUN=sample, size=1)
	sampleF4matrix <- matrix(rep(0,265^2),265,265,dimnames=list(allSpecies,allSpecies))
	i <- 0
	for (s2 in allSpecies) {
		for (s3 in allSpecies) {
			index <- which(as.character(sampleF4s$"DsuiteOut$s2") == s2 & as.character(sampleF4s$"DsuiteOut$s3") == s3)
			indexReverse <- which(as.character(sampleF4s$"DsuiteOut$s2") == s3 & as.character(sampleF4s$"DsuiteOut$s3") == s2)
			if (length(index > 0) & length(indexReverse > 0)) {
				if (sampleF4s[index,3] > sampleF4s[indexReverse,3]) { 
					sampleF4matrix[s2,s3] <- sampleF4s[index,3]; 
				} else { 
					sampleF4matrix[s2,s3] <- sampleF4s[indexReverse,3]; 
				}
			} else if (length(index > 0)) {
				sampleF4matrix[s2,s3] <- sampleF4s[index,3]; 
			} else if (length(indexReverse > 0)) {
				sampleF4matrix[s2,s3] <- sampleF4s[indexReverse,3]; 
			}
			i <- i + 1
			if (i %% 100 == 0) { print(i);}
		}
	}
	write.table(sampleF4matrix,paste0("F4matrix_sample",sNum ,".txt"), quote=F, sep="\t")
}


# 5) Separate the f4-ratios by tribe:
# This is then the basis for the f4-ratio distribution in Fig. 4e
fo <- scan("order.txt",what=character())
Trematocarini <- fo[2:8]; Bathybatini <- fo[9:17]; Lamprologini <- fo[18:124]; Cyphotilapiini <- fo[125:128]; Limnochromini <- fo[129:138]; Ectodini <- fo[139:178]; Cyprichromini <- fo[179:190]
Benthochromini <- fo[191:194]; Perissodini <- fo[195:202]; Eretmodini <- fo[203:207]; Haplochromini <- fo[208:225]; Tropheini <-fo[226:265]

iLamprologini <- numeric(dim(DsuiteOut)[1]); iHaplochromini <- numeric(dim(DsuiteOut)[1]); iEretmodini <- numeric(dim(DsuiteOut)[1]); iPerissodini <- numeric(dim(DsuiteOut)[1]); 
iBenthochromini <- numeric(dim(DsuiteOut)[1]); iCyprichromini <- numeric(dim(DsuiteOut)[1]); iLimnochromini <- numeric(dim(DsuiteOut)[1]); iEctodini <- numeric(dim(DsuiteOut)[1]); 
iCyphotilapiini <- numeric(dim(DsuiteOut)[1]); iBathybatini <- numeric(dim(DsuiteOut)[1]); iTrematocarini <- numeric(dim(DsuiteOut)[1]); iTropheini <- numeric(dim(DsuiteOut)[1]);
for (i in 1:(dim(DsuiteOut)[1])) {
	sp1 <- as.character(DsuiteOut$s1[i]); sp2 <- as.character(DsuiteOut$s2[i]); sp3 <- as.character(DsuiteOut$s3[i])
	if (sp1 %in% Lamprologini) { if (sp2 %in% Lamprologini) { if (sp3 %in% Lamprologini) { iLamprologini[i] <- 1; } }}
	else if (sp1 %in% Tropheini) { if (sp2 %in% Tropheini) { if (sp3 %in% Tropheini) { iTropheini[i] <- 1; } } }
	else if (sp1 %in% Haplochromini) { if (sp2 %in% Haplochromini) { if (sp3 %in% Haplochromini) { iHaplochromini[i] <- 1; } } }
	else if (sp1 %in% Eretmodini) { if (sp2 %in% Eretmodini) { if (sp3 %in% Eretmodini) { iEretmodini[i] <- 1; } } }
	else if (sp1 %in% Perissodini) { if (sp2 %in% Perissodini) { if (sp3 %in% Perissodini) { iPerissodini[i] <- 1; } } }
	else if (sp1 %in% Benthochromini) { if (sp2 %in% Benthochromini) { if (sp3 %in% Benthochromini) { iBenthochromini[i] <- 1; } } }
	else if (sp1 %in% Cyprichromini) { if (sp2 %in% Cyprichromini) { if (sp3 %in% Cyprichromini) { iCyprichromini[i] <- 1; } } }
	else if (sp1 %in% Limnochromini) { if (sp2 %in% Limnochromini) { if (sp3 %in% Limnochromini) {  iLimnochromini[i] <- 1; } } }
	else if (sp1 %in% Ectodini) { if (sp2 %in% Ectodini) { if (sp3 %in% Ectodini) {   iEctodini[i] <- 1; } } }
	else if (sp1 %in% Cyphotilapiini) { if (sp2 %in% Cyphotilapiini) { if (sp3 %in% Cyphotilapiini) {  iCyphotilapiini[i] <- 1; } } }
	else if (sp1 %in% Bathybatini) { if (sp2 %in% Bathybatini) { if (sp3 %in% Bathybatini) { iBathybatini[i] <- 1; } } }
	else if (sp1 %in% Trematocarini) { if (sp2 %in% Trematocarini) { if (sp3 %in% Trematocarini) { iTrematocarini[i] <- 1; } } }
	if (i %% 100000 == 0) { print(i);}
}

F4.Lamprologini <- cbind(DsuiteOut[which(iLamprologini==1),],rep("Lamprologini",length(which(iLamprologini ==1)))); names(F4.Lamprologini)[7] <- "tribe"
F4.Tropheini <- cbind(DsuiteOut[which(iTropheini ==1),],rep("Tropheini",length(which(iTropheini ==1)))); names(F4.Tropheini)[7] <- "tribe"
F4.Eretmodini <- cbind(DsuiteOut[which(iEretmodini ==1),],rep("Eretmodini",length(which(iEretmodini ==1)))); names(F4.Eretmodini)[7] <- "tribe"
F4.Perissodini <- cbind(DsuiteOut[which(iPerissodini==1),],rep("Perissodini",length(which(iPerissodini ==1)))); names(F4.Perissodini)[7] <- "tribe"
F4.Benthochromini <- cbind(DsuiteOut[which(iBenthochromini ==1),],rep("Benthochromini",length(which(iBenthochromini ==1)))); names(F4.Benthochromini)[7] <- "tribe"
F4.Cyprichromini <- cbind(DsuiteOut[which(iCyprichromini ==1),],rep("Cyprichromini",length(which(iCyprichromini ==1)))); names(F4.Cyprichromini)[7] <- "tribe"
F4.Limnochromini <- cbind(DsuiteOut[which(iLimnochromini ==1),],rep("Limnochromini",length(which(iLimnochromini ==1)))); names(F4.Limnochromini)[7] <- "tribe"
F4.Ectodini <- cbind(DsuiteOut[which(iEctodini ==1),],rep("Ectodini",length(which(iEctodini ==1)))); names(F4.Ectodini)[7] <- "tribe"
F4.Cyphotilapiini <- cbind(DsuiteOut[which(iCyphotilapiini ==1),],rep("Cyphotilapiini",length(which(iCyphotilapiini ==1)))); names(F4.Cyphotilapiini)[7] <- "tribe"
F4.Bathybatini <- cbind(DsuiteOut[which(iBathybatini ==1),],rep("Bathybatini",length(which(iBathybatini ==1)))); names(F4.Bathybatini)[7] <- "tribe"
F4.Trematocarini <- cbind(DsuiteOut[which(iTrematocarini ==1),],rep("Trematocarini",length(which(iTrematocarini ==1)))); names(F4.Trematocarini)[7] <- "tribe"
F4.Haplochromini <- cbind(DsuiteOut[which(iHaplochromini ==1),],rep("Haplochromini",length(which(iHaplochromini ==1)))); names(F4.Haplochromini)[7] <- "tribe"
F4.withinTribes <- rbind(F4.Lamprologini, F4.Tropheini, F4.Eretmodini, F4.Perissodini, F4.Benthochromini, F4.Cyprichromini, F4.Limnochromini, F4.Ectodini, F4.Cyphotilapiini, F4.Bathybatini, F4.Trematocarini, F4.Haplochromini)
boxplot(F4.withinTribes$fG ~ F4.withinTribes$tribe)
write.table(F4.withinTribes,"F4_withinTribes.txt",quote=F,row.names=F,sep="\t")
# remove the species/groups that are not with Lake Tanganyika for Fig. 4e
s1_s2_s3 <- paste(F4.withinTribes$s1, F4.withinTribes$s2, F4.withinTribes$s3, sep="_")
F4.withinTribesFig4e <- cbind(F4.withinTribes, s1_s2_s3)
F4.withinTribesFig4e <- F4.withinTribesFig4e[-grep("Telluf", F4.withinTribesFig4e$s1_s2_s3),];
F4.withinTribesFig4e <- F4.withinTribesFig4e[-grep("Lamtig", F4.withinTribesFig4e$s1_s2_s3),];
F4.withinTribesFig4e <- F4.withinTribesFig4e[-grep("Neodev", F4.withinTribesFig4e$s1_s2_s3),];
F4.withinTribesFig4e <- F4.withinTribesFig4e[-grep("Haplochromini", F4.withinTribesFig4e$tribe),]; F4.withinTribesFig4e$tribe <- droplevels(F4.withinTribesFig4e$tribe)
boxplot(F4.withinTribesFig4e$fG ~ F4.withinTribesFig4e$tribe)
write.table(F4.withinTribesFig4e,"F4_withinTribesFig4e.txt",quote=F,row.names=F,sep="\t")

# 6) Subsetting the max f4-ratio matrix from Extended Data Fig. 8a by tribe:
# This is done to abtain some statistics quoted in the Supplementary Discussion
length(which(F4matrix > 0.1))/2
F4matrix.Lamprologini <- F4matrix[Lamprologini,Lamprologini]; lt.Lamprologini <- lower.tri(F4matrix.Lamprologini); F4maxVals.Lamprologini <- F4matrix.Lamprologini[lt.Lamprologini]; length(which(F4maxVals.Lamprologini > 0.1))
F4matrix.Tropheini <- F4matrix[Tropheini,Tropheini]; lt.Tropheini <- lower.tri(F4matrix.Tropheini); F4maxVals.Tropheini <- F4matrix.Tropheini[lt.Tropheini]; length(which(F4maxVals.Tropheini > 0.1))
F4matrix.Eretmodini <- F4matrix[Eretmodini,Eretmodini]; lt.Eretmodini <- lower.tri(F4matrix.Eretmodini); F4maxVals.Eretmodini <- F4matrix.Eretmodini[lt.Eretmodini]; length(which(F4maxVals.Eretmodini > 0.1))
F4matrix.Perissodini <- F4matrix[Perissodini,Perissodini]; lt.Perissodini <- lower.tri(F4matrix.Perissodini); F4maxVals.Perissodini <- F4matrix.Perissodini[lt.Perissodini]; length(which(F4maxVals.Perissodini > 0.1))
F4matrix.Benthochromini <- F4matrix[Benthochromini,Benthochromini]; lt.Benthochromini <- lower.tri(F4matrix.Benthochromini); F4maxVals.Benthochromini <- F4matrix.Benthochromini[lt.Benthochromini]; length(which(F4maxVals.Benthochromini > 0.1))
F4matrix.Cyprichromini <- F4matrix[Cyprichromini,Cyprichromini]; lt.Cyprichromini <- lower.tri(F4matrix.Cyprichromini); F4maxVals.Cyprichromini <- F4matrix.Cyprichromini[lt.Cyprichromini]; length(which(F4maxVals.Cyprichromini > 0.1))
F4matrix.Limnochromini <- F4matrix[Limnochromini,Limnochromini]; lt.Limnochromini <- lower.tri(F4matrix.Limnochromini); F4maxVals.Limnochromini <- F4matrix.Limnochromini[lt.Limnochromini]; length(which(F4maxVals.Limnochromini > 0.1))
F4matrix.Ectodini <- F4matrix[Ectodini,Ectodini]; lt.Ectodini <- lower.tri(F4matrix.Ectodini); F4maxVals.Ectodini <- F4matrix.Ectodini[lt.Ectodini]; length(which(F4maxVals.Ectodini > 0.1))
F4matrix.Cyphotilapiini <- F4matrix[Cyphotilapiini,Cyphotilapiini]; lt.Cyphotilapiini <- lower.tri(F4matrix.Cyphotilapiini); F4maxVals.Cyphotilapiini <- F4matrix.Cyphotilapiini[lt.Cyphotilapiini]; length(which(F4maxVals.Cyphotilapiini > 0.1))
F4matrix.Bathybatini <- F4matrix[Bathybatini,Bathybatini]; lt.Bathybatini <- lower.tri(F4matrix.Bathybatini); F4maxVals.Bathybatini <- F4matrix.Bathybatini[lt.Bathybatini]; length(which(F4maxVals.Bathybatini > 0.1))
F4matrix.Trematocarini <- F4matrix[Trematocarini,Trematocarini]; lt.Trematocarini <- lower.tri(F4matrix.Trematocarini); F4maxVals.Trematocarini <- F4matrix.Trematocarini[lt.Trematocarini]; length(which(F4maxVals.Trematocarini > 0.1))
F4matrix.Haplochromini <- F4matrix[Haplochromini,Haplochromini]; lt.Haplochromini <- lower.tri(F4matrix.Haplochromini); F4maxVals.Haplochromini <- F4matrix.Haplochromini[lt.Haplochromini]; length(which(F4maxVals.Haplochromini > 0.1))


# 7) Plot the matrix as in Extended Data Fig. 8a:
# First the plotting function:
plotF4matrix<-function(tmpmat,# this is the heatmap to be plotted
		labelsx,# the x,y labels to be plotted
		labelsy=NULL,# assumed equal to labelsx unless otherwise specified
		cols=NULL,# colour scale. 
		labmargin=8, # margin for x,y labels
		layoutf=0.1,# proportion of the plot to be used by the scale
		cex.axis=0.5, # cex.axis applies to the x,y labels
		scalemar=c(2,5,2,1), # additional modification to the margins of the scale
		hmmar=c(0,0,0,1), # additional modification to the margins of the heatmap
		cex.scale=1, # size of the characters in the scale
		scalenum=10, # the number of points to label on the scale
		scalesignif=3, # number of significant digits on scale
		scalelabel="" # label for the scale
        ) 
{
	layout(matrix(c(2,1), 1, 2, byrow=TRUE),widths=c(1-layoutf,layoutf))
	
	## RIGHT: SCALE
	ttmpmat<-na.omit(as.numeric(tmpmat))
	colscale<-c(min(ttmpmat),max(ttmpmat))
	par(mar=c(labmargin,0,0,0)+scalemar)
	colindex<-t(matrix(seq(min(colscale),max(colscale),length.out=100),ncol=1,nrow=100)) # colour scale
	image(1,1:100,colindex,xaxt="n",yaxt="n",xlab=scalelabel,ylab="",col=cols,zlim=range(colindex))
	scalelocs <- min(colindex)+(max(colindex)-min(colindex))*seq(0,1,length.out=scalenum)
	scalephysicalpos <- seq(1,100,length.out=scalenum)
	axis(2,at=scalephysicalpos,labels=signif(scalelocs,scalesignif),las=2,cex.axis=cex.scale)
	
	## LEFT: MAIN HEATMAP
	par(mar=c(labmargin,labmargin,0,0)+hmmar)
	labelsatx<-seq(1:dim(tmpmat)[2]) 
	labelsaty<-seq(1:dim(tmpmat)[1]) 
	if(is.null(labelsy)) {  labelsy<-labelsx } # y labels
	
	tmpmat<-tmpmat[dim(tmpmat)[1]:1,,drop=FALSE]
	labelsaty<-dim(tmpmat)[1] - labelsaty + 1
	
	#plot the heatmap
	image(1:dim(tmpmat)[2],1:dim(tmpmat)[1],t(tmpmat),xaxt="n",yaxt="n",xlab="",ylab="",col=cols,zlim=colscale)
	# draw the axes
	axis(1,at=labelsatx,labels=labelsx,las=2,cex.axis=cex.axis)
	axis(2,at=labelsaty,labels=labelsy,las=2,cex.axis=cex.axis)
}

# Then the actual plotting:
fo <- scan("order.txt",what=character())
cr <- colorRampPalette(c(rgb(25,203,236, maxColorValue=255),rgb(233,15,41, maxColorValue=255)))
some.colors<- cr(60)
some.colorsStartEnd <- c("#F2F2F2",some.colors,"#333333")
pdf("MatrixForExtendedDataFig8a.pdf",width=20,height=20)
datamatrix<-F4matrix[fo, fo] # reorder the f4-ratio matrix to place tribes together
tmpmat<-datamatrix; maxIndv <- 0.1; minIndv <- 0.03; 
tmpmat[tmpmat>maxIndv]<-maxIndv #  # cap the heatmap
tmpmat[tmpmat<minIndv]<-minIndv;  # put lower limit on the heatmap
plotCols <- some.colorsStartEnd;
plotF4matrix(as.matrix(tmpmat),colnames(datamatrix),cols=plotCols,cex.axis=0.7)
dev.off()
