## Fabrizia Ronco
## April 2020


############################################################################
#### Fitting single process models of trait evolution


## load packages
require(geiger)		# version 2.0.6.1
require(phytools)	# version 0.6-60
require(parallel)	# version 3.6.1

### allow variables from command line
args = commandArgs(trailingOnly = TRUE)


################
#  get data 

# get tree:
tree= read.nexus(args[1])

if( !is.ultrametric(tree))
	tree= force.ultrametric(tree, method="nnls")

# get data:
d= read.table(args[2], h=F)

################  
## check data concruence 

if ( any(! d[,1] %in% tree$tip.label)) { stop( "not all taxa from data occure in the tree" )}
if ( any(! tree$tip.label %in% d[,1] )) { stop( "not all taxa from the tree occure in data" )}

################ 
###  set parameters:
niter= 10000
ncores= 4
options(mc.cores=4)


cat("\n\n################ ################ ################ ################ ################ ################\n")

cat("\n################ ################ ################ ################ ################ ################")
cat("\n\n\n\t\t\t\t***  fitting singel process models of trait evolution using geiger::fitContinuous and compare results",""," *** \n",sep="") 
cat("################ ################ ################ ################ ################ ################")
cat( "\n\n")
cat("niter = ");cat(niter) 
cat( "\n\n")


################ ################ ################ 

x= d[,2]; names(x)= d[,1]

##############



# prepare output	
summaries=c("BM", "Ornstein-Uhlenbeck", "early burst")
aic=matrix( NA ,1, length( summaries))
lnl=matrix(NA,  1,length( summaries))


cat("\n\n\n\t\t\t\t***  BM model  *** \n\n",sep="")
BM= 	fitContinuous(tree, x, model="BM", SE= 0, ncores= ncores, control=list(niter=niter))
print(BM)

cat("\n\n\n\t\t\t\t*** ","OU model "," *** \n\n",sep="")
OU= 	fitContinuous(tree, x, model="OU", SE= 0, ncores= ncores, control=list(niter= niter))
print(OU)

cat("\n\n\n\t\t\t\t*** EB model  *** \n\n")
EB= 	fitContinuous(tree, x, model="EB", SE= 0, ncores= ncores, control=list(niter= niter))
print(EB)


## COMPARE AIC ##
aic[1]=BM$opt$aicc; lnl[1]=BM$opt$lnL
aic[2]=OU$opt$aicc; lnl[2]=OU$opt$lnL
aic[3]=EB$opt$aicc; lnl[3]=EB$opt$lnL


names(aic) = names(lnl) = summaries
delta_aic=function(x) x-x[which(x==min(x))]

cat("\n\n################ ################ ################ ################ ################ ################\n\n")
cat("################ ################ ################ ################ ################ ################")


cat("\n\n\n\t\t\t\t*** compare models *** \n")
cat("\t\t delta-AIC values for models \t\t\t\t zero indicates the best model\n\n")
daic=delta_aic(aic)
#print(daic, digits=2)
cat("\n\n\n")
res_aicc=rbind( aic, daic)
colnames(res_aicc) = summaries
rownames(res_aicc)=c("AICc_SE", "dAICc_SE")
print(res_aicc, digits=2)



cat("\n\n################ ################ ################ ################ ################ ################\n\n")
cat("################ ################ ################ ################ ################ ################")
cat("\n\n\n\t\t\t\t***  calculate phy signal for the trait; using  phytools:: phylosig; two differnt methods *** \n") 
 

cat ("#####   method lamda \n")
phylam= phylosig(tree, x, method="lambda", test=TRUE)
phylam
cat ("#####  method K \n")
phyK= phylosig(tree, x, method="K", test=TRUE)
phyK

cat("\n\n################ ################ ################ ################ ################ ################\n\n")
cat("################ ################ ################ ################ ################ ################")











