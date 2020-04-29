## Fabrizia Ronco
## April 2020


########################################################################
#######   requried packages  ###########################################
########################################################################
require(reshape2) ## version 1.4.3
require (geomorph) ## version 3.0.7


################################
################################
##   data body shape
################################
################################
load('../body/proc_aligned_body.RData')

###  extract classifiers 
body_names= colsplit(dimnames(body)[[3]], "_", c("ID", "sp", "rest") )
body_names$sp= as.factor(substr(body_names $sp, 1, 6))
body_names$rest=NULL
#head(body_names)

##### mean shape per species
sp_list = levels(as.factor(body_names $sp) )
sp_means_body = array(NA, dim=c(dim(body)[1],dim(body)[2], length(sp_list)))
for ( i in 1:length(sp_list)){
if( length(grep(sp_list[i], body_names $sp)) >= 2){
	sp_means_body[,,i] = mshape(body[,,grep(sp_list[i], body_names $sp)])
} else {
	sp_means_body[,,i]  = body[,,grep(sp_list[i], body_names $sp)]
}
	}

### save to file
#str(sp_means_body)
dimnames(sp_means_body)[[3]]= sp_list
save(sp_means_body, file="../body/sp_means_body.Rdata")



################################
################################
##   data oral jaw 
################################
################################
load('../oral/proc_aligned_UOJ.RData')

###  extract classifiers 
OJ_names= colsplit(dimnames(OJ2)[[3]], "_", c("ID", "sp", "rest") )
OJ_names$sp= as.factor(substr(OJ_names $sp, 1, 6))
OJ_names$rest=NULL
#head(OJ_names)

### meanshape per species:
sp_list = levels(as.factor(OJ_names $sp) )
sp_means_OJ = array(NA, dim=c(dim(OJ2)[1],dim(OJ2)[2], length(sp_list)))
for ( i in 1:length(sp_list)){
if( length(grep(sp_list[i], OJ_names $sp)) >= 2){
	sp_means_OJ[,,i] = mshape(OJ2[,,grep(sp_list[i], OJ_names $sp)])
} else {
	sp_means_OJ[,,i]  = OJ2[,,grep(sp_list[i], OJ_names $sp)]
}
	}

###. save to file
#str(sp_means_OJ)
dimnames(sp_means_OJ)[[3]]= sp_list
save(sp_means_OJ, file="../oral/sp_means_OJ.Rdata")



################################
################################
##   data LPJ
################################
################################
load('../LPJ/proc_aligned_sym_LPJ.RData')
d= LPJ

###  get classifiers from shape data
LPJ_names= colsplit(dimnames(d)[[3]], "_", c("sp", "tribe", "ID") )
#head(LPJ_names)

### meanshape per species:
sp_list = levels(as.factor(LPJ_names$sp) )
sp_means_LPJ = array(NA, dim=c(42,3, length(sp_list)))
for ( i in 1:length(sp_list)){
if( length(grep(sp_list[i], LPJ_names $sp)) >= 2){
	sp_means_LPJ[,,i] = mshape(d[,,grep(sp_list[i], LPJ_names $sp)])
} else {
	sp_means_LPJ[,,i]  = d[,,grep(sp_list[i], LPJ_names $sp)]
}
	}

### save to file
#str(sp_means_LPJ)
dimnames(sp_means_LPJ)[[3]]= sp_list
save(sp_means_LPJ, file="../LPJ/sp_means_LPJ.Rdata")


################################
################################
##   data stable isotopes
################################
################################
SI = read.csv ("../../01_Data/SI_data.csv", h=T)
#head(SI)

## add species info:
spinfo= read.csv("../../01_Data/specimen_voucher_key.csv", head=T)
SI = merge( SI, spinfo[,c(1,3)], by.x="ID", by.y="ID", all.x=T)
###. species means
sp_means_SI= aggregate( SI[,2:3], list( SI$SpeciesID), mean)
#head(sp_means_SI)

###. save to file
names(sp_means_SI)[1]="sp"
save( sp_means_SI, file="../SI/sp_means_SI.Rdata")










