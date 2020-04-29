## Fabrizia Ronco
## April 2020


########################################################################
#######   requried packages  ###########################################
########################################################################

require(scales)	# version 1.0.0


########################################################################
#######   Ploting BASELINE data sets on the cichlid data ###############
########################################################################

### get baseline data
base= read.csv("../../01_Data/baseline.csv", h=T)
#head(base)

## define colors and sybols for the different samples 
base$pch = base$Sample_ID
levels(base$pch) =c("24","25" )
#levels(base$Tribe)
palette(c("grey20", "aquamarine", "darkgreen", "hotpink", "gold", "darkolivegreen4", "pink"))


### get cichlid data and make species means with CI
SI= read.csv("../../01_Data/SI_data.csv", h=T)
## add species info:
spinfo= read.csv("../../01_Data/specimen_voucher_key.csv", head=T)
SI = merge( SI, spinfo[,c(1,3,8,9)], by.x="ID", by.y="ID", all.x=T)
#head(SI)

SI_means = aggregate( SI[,2:3], list(SI$SpeciesID), mean)
SI_CI = aggregate( SI[,2:3], list(SI$SpeciesID), function(x) (1.96*(sd(x)/sqrt(length(x))) )  )

##. define range fro plotting limits
Nrange = range(c( SI_means$d15N-SI_CI$d15N, SI_means$d15N+SI_CI$d15N,  base$d15N), na.rm=T)
Crange = range(c( SI_means$d13C-SI_CI$d13C, SI_means$d13C+SI_CI$d13C,  base$d13C), na.rm=T)



###. PLot
quartz(width =5 , height=5, file="../Plots/SI_cichlid_vs_Baseline_overall_N_S.pdf", type="pdf")
plot( SI_means$d13C, SI_means$d15N, pch=16, col="grey", cex=0.5, axes=F, 	xlab= "d13C",ylab= "d15N", cex.lab=1, ylim=c(-2,11), xlim=c(-25,-9))

segments(x0= SI_means$d13C-SI_CI$d13C ,y0=SI_means$d15N  ,x1=SI_means$d13C+ SI_CI$d13C  , y1=SI_means$d15N , col="grey")
segments(x0= SI_means$d13C, y0=SI_means$d15N-SI_CI$d15N  ,x1=SI_means$d13C, y1=SI_means$d15N+ SI_CI$d15N , col="grey")

axis(1, las=1, cex=0.5,tck=-0.01 )
axis(2, las=1, cex=0.5,tck=-0.01)

points(base$d13C,  base$d15N, pch=as.numeric(as.character(base$pch)), cex=0.5, col= alpha(as.numeric(base$Tribe), 0.5) )
legend( "bottomleft", legend= levels(base$Tribe), col=as.factor(levels(base$Tribe)), cex=0.75, bty="n", pch=19)

dev.off()



########################################################################
#######   Use the cichlid data to test effects of sampling localites  ##
########################################################################


############. approach 1: test for an effect of sampling laclaitiy over the entire data set:
##### one using species as covariate and once using ecologial categories as covariate

#. get ecological categories

cats= read.csv("../../01_Data/Species_ecoCat.csv", h=T)
new3 = merge( SI, cats, by.x="SpeciesID", by.y="SpeciesID")
#head(new3)


#### make multiple regression models and calcualte percentage of variance explained 


##.------------ N 

## --- species 

fit1 = lm ( new3$d15N ~ new3$latitude * new3$longitude * new3$SpeciesID)
af = anova(fit1)
afss = af$"Sum Sq"

print(fit1$call)
print(cbind(af,PctExp=afss/sum(afss)*100))

## --- trophic category
 
fit2= lm ( new3$d15N ~ new3$latitude * new3$longitude * new3$food)
af= anova(fit2)
afss <- af$"Sum Sq"

print(fit2$call)
print(cbind(af,PctExp=afss/sum(afss)*100))



##.------------ C
## --- species 
fit1 = lm ( new3$d13C ~ new3$latitude * new3$longitude * new3$SpeciesID)
af = anova(fit1)
afss = af$"Sum Sq"

print(fit1$call)
print(cbind(af,PctExp=afss/sum(afss)*100))


## --- habitat category
fit2= lm ( new3$d13C ~ new3$latitude * new3$longitude * new3$habitat)
af= anova(fit2)
afss <- af$"Sum Sq"

print(fit2$call)
print(cbind(af,PctExp=afss/sum(afss)*100))



#################. approach 2 test species set with lakewide distribution for a difference between northern and southern samples

####. get dataset which contains this info 

sn = read.csv("../../01_Data/SI_data_n_s_distribution.csv", h=T)
#head(sn)
#head(SI)

sloc_sp_means = aggregate(sn[,2:3], list(sn$loc, sn$Species), mean)
#summary(sloc_sp_means)
#head(sloc_sp_means)

#par(mfcol=c(3,2))
#plot( sloc_sp_means$N ~ sloc_sp_means$Group.1)
t.test(sloc_sp_means$N[sloc_sp_means$Group.1 == "s"] , sloc_sp_means$N[sloc_sp_means$Group.1 == "n"] )
#plot( sloc_sp_means$C ~ sloc_sp_means$Group.1)
t.test(sloc_sp_means$C[sloc_sp_means$Group.1 == "s"] , sloc_sp_means$C[sloc_sp_means$Group.1 == "n"] )



