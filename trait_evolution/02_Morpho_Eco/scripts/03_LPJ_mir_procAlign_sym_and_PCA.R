## Fabrizia Ronco
## April 2020


########################################################################
#######   requried packages  ###########################################
########################################################################

require(reshape2) ## version 1.4.3
require (geomorph) ## version 3.0.7


########################################################################
#######   reading tps file   ###########################################
########################################################################

########################################################################
setwd("../../")
data.tps = scan("01_Data/all_LPJ.tps", what="char", quote="", sep="\n", strip.white=T)
#head(data.tps)

#########################################################################

conf = grep("LM3=", data.tps)    #rows with "lm"
ids = grep("ID=", data.tps)    #rows with "id"
nconf = length(conf)    # times written "lm"
scal = grep("SCALE=", data.tps)      #rows with "scale"
nlms = as.numeric(unlist(strsplit(unlist(strsplit(data.tps[conf[1]], "="))[2], " "))[1])
ndims = length(unlist(strsplit(data.tps[conf[1]+1], split=" +")))
ind = vector(length=nconf)    
scale = vector (length=nconf)

d = matrix(NA, nconf, nlms)
for(i in 1:nconf){
	d[i,]=(data.tps[(conf[i]+1):(conf[i]+nlms)])
	ind[i] = as.character(unlist(strsplit(data.tps[ids[i]],"="))[2])
	scale[i] = as.numeric(unlist(strsplit(data.tps[scal[i]],"="))[2])
}

## Split the x, y and z values in each a columns (x comes first, then y, then z)
d2=matrix(as.numeric(unlist(strsplit(d[,1]," +"))),	ncol=ndims, byrow=TRUE)
for(i in 2:nlms){
	d2 = cbind(d2,matrix(as.numeric(unlist(strsplit(d[,i]," +"))),	ncol=ndims, byrow=TRUE))
}

rownames(d2) = ind
land = arrayspecs(d2, 27, 3)   ###  builds an array from matrix: land[ LM , (x,y,z) , ID ]



########################################################################
#############  Procrustes fit of the landmark coordinates
########################################################################
## As the Landamarks are recorded only from one side of the jaw bone, I first mirror the landmarks over the plane of bilateral-symmetry - this assures that the lateral symmetric properties are retained during superimosition (i.e. that Lansmarks are not superimposed over the "missing" half of the bone)


########################################################################
#######   creating mirpo function :   mirrors landmarks over the plane of bilateral-symmetry
########################################################################

mirpo = function (landmark, mid, pair)  {

	nLM = dim(landmark)[1]
	nDIM = dim(landmark)[2]
	nInd = dim(landmark)[3]
	
	vcrossp = function( a, b ) {
		result = matrix( NA, nrow( a ), 3 )
		result[,1] = a[,2] * b[,3] - a[,3] * b[,2]
		result[,2] = a[,3] * b[,1] - a[,1] * b[,3]
		result[,3] = a[,1] * b[,2] - a[,2] * b[,1]
		result
		 }

	mipo = function (landmark, mid, pair, nLM=nLM, nDIM=nDIM)  {
		row.names(landmark) = c(1:nrow(landmark))
		meanvec_mid = matrix(apply(landmark[c(mid),], 2, mean, na.rm=TRUE), byrow=TRUE, nr= nLM, nc= nDIM) 
		sca_all = landmark - meanvec_mid
		midline = sca_all[mid,]  
		paired = sca_all[pair,]    
		eigenvec = cov(sca_all[mid,])   ##  finding eigenvalues of the midline, spanning the plane
		e1 = eigenvec [1,]
		e2 = eigenvec [2,]
		e3 = eigenvec [3,]
		e12 = e2 - e1; e13= e3 - e1
		n = vcrossp(t(e12), t(e13))  ####  normal vector of the plane
		a = n[1]
		b = n[2]
		c = n[3]
		d = e1[1] * a + b * e1[2] + c * e1[3]
		new = NULL; mir = NULL
		for ( i in c(1:15)){
			new=rbind( new, (d- a*(paired[i,1])-b*(paired[i,2])-c*(paired[i,3] )) / (a^2 +b^2 + c^2 ))  ###  calculate normal vectors for each point
			mir	= rbind( mir, paired[i,] +2* new [i] * c(a,b,c))  ####  mirroring the point 
		}
		row.names(mir) = c((nLM+1):(nLM+length(pair)))
		z = rbind(midline, paired,mir)
		LM = data.frame("LM"= as.numeric (rownames(z)), z)
		ord = LM[do.call(order, LM["LM"]), ]
		comp = ord [,-1]
		as.matrix(comp)
	}

	landrecon = array(NA, dim=c(nLM+length(pair),nDIM, nInd))
	for (i in c(1:dim(landmark)[3])) {
		landrecon[,,i] =  mipo(landmark=landmark[,,i], mid=mid, pair=pair, nLM=nLM, nDIM=nDIM) 
	}
	landrecon
}


########################################################################
#######   using mirpo      #############################################
########################################################################

mid = c(1:3,8:15, 27)   #  definging Lm of the midle line
pair = c(4:7,16:26)    #  definging paired Lm to be mirrowen on midline

new1 = mirpo(landmark= land, mid,pair)


########################################################################
#######   create sliders file  for sliding landamarks along ridges of the jaw bone #########################################
#######   see Extended Data Fig. 4 for a description of landmarks
########################################################################

curveslide =(rbind(
	c(8,15,9) ,c(15,9,14 ), c(9,14,10) , c(14,10,13), c(10,13,11), c(13,11,12), c(11,12,1),
	c(7,22,16), c(22,16,21), c(16,21,17 ), c(21,17, 20 ), c( 17,20,18), c( 20,18, 19), c( 18,19,1),
	c(31,38,32), c(38,32,37), c(32,37,33 ), c(37, 33, 36 ), c( 33 ,36 ,34), c( 36, 34, 35), c( 34, 35, 1),
	c(3,23,24), c(23,24,25), c(24,25,5),
	c(3 ,39 ,40 ), c(39 ,40 ,41), c(40 ,41 ,29)
))
colnames(curveslide) = c("before", "slide", "after")


########################################################################
#### create final input file for gepagen() including coordinates =land, IDs and slidersfile, and scale
########################################################################

data1 = list("coorddata"=new1,  "curveslide"= curveslide, "ind"=dimnames(land)[[3]] )

########################################################################
############  sliding semilandmarks and perforem GPA using gpagen  #####
########################################################################

new1.2 = gpagen(A=data1$coorddata, curves=data1$curveslide, ProcD=T) #Using Procrustes Distance


########################################################################
#####################  extract classifiers    ##########################
########################################################################
labels1 = colsplit(string=dimnames(land)[[3]] , pattern="_", names=c("ID", "sex","tribe","species", "rest"))
ID1 = as.factor(labels1 $ID)
sex1 = as.factor(labels1 $sex)
tribe1 = as.factor(labels1 $tribe)
species1 = as.factor(labels1 $species)

########################################################################
#########################  symetric component only    ##################
########################################################################
### assymetrie in the data is produced by the deviation of the non-paired landmarks from the fitted plane of bilateral symmetry during miroring of the landmark set 

###   definging LM pairs: 
LMpair= cbind(c(4:7,16:26), c(28:42) )
gdf1= geomorph.data.frame(shape= new1.2$coords, ind=paste(species1,tribe1, ID1, sep="_"))
a1.sym = bilat.symmetry( A= shape, ind=ind, object.sym=T, land.pairs=LMpair, data=gdf1, iter=1)


########################################################################
#####################  PCA               ###############################
########################################################################

symm.a1 = plotTangentSpace(a1.sym$symm.shape)
PCAscores = data.frame(symm.a1$pc.scores,"ID"= ID1, "sp"= species1, "tribe" = tribe1)
#head(PCAscores)


#####################  save PCA results to file for later plotting##########################
write.table(PCAscores, "02_Morpho_Eco/LPJ/PCA_pc_scores_LPJ.txt", sep="\t", row.names=F, quote=F)
write.table(data.frame(symm.a1$pc.summary$importance),"02_Morpho_Eco/LPJ/PCA_importance_LPJ.txt", sep="\t", row.names=F, quote=F)
#####################  save shape changes associated with the PC- axes to file for alter plotting #####################  
shapes= symm.a1$pc.shapes[1:9]
save(shapes, file="02_Morpho_Eco/LPJ/PCA_shapes_LPJ.RData")


#####################  save prucrustes aligned landmark coordinates to file  #######################
LPJ= a1.sym$symm.shape
save(LPJ,  file="02_Morpho_Eco/LPJ/proc_aligned_sym_LPJ.RData")






























