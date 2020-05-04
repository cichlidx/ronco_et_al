## Fabrizia Ronco
## April 2020

# load packages
require(phytools)  ## version 0.6-60


##  get variables from comand line
args = commandArgs(trailingOnly=TRUE)
dirname=args[1]
filename=args[2]
TRAIT= args[4]
AXES= args[5]

###   get burnin from file to define the posterior sample
burn=read.table(paste(dirname,"additional_burnin.txt", sep=""), h=F)
burnin= burn[1,1]

#######  -----------------------     get man rate transforemd tree and posterior probabilities -----------------------  ##########

##  get the trees from the BayesTraits run and the original tree
trees1= read.nexus(paste(dirname, filename, ".Output.trees", sep=""))
origtree= read.nexus(args[3])

#### subset the trees with burnin
if (burnin>=1) trees1 = trees1[seq.int(burnin+1, length(trees1), 1)]
class(trees1) = "multiPhylo"

## ladderize all trees
origtree = ladderize(origtree)
trees1 = lapply(trees1, ladderize)
class(trees1) = "multiPhylo"

# check topology
        for (i in seq_along(trees1)) {
                if (sum(origtree $tip.label == trees1[[i]]$tip.label) != length(origtree$tip.label)) {
                        stop(paste("Tip labels on tree", i, "do not mactch reference tree"))
                } 
                if (sum(origtree$edge == trees1[[i]]$edge) != length(origtree$edge)) {
                        stop(paste("Tree", i, "has a different topology to reference tree"))
                }
        }



############################################################################################
####   get posterior probabillities from posterior trees + consider burin  + calcuate mean realtive and absolute rates per branch:

##  prepare outpt datafile for the tree:
treedat= data.frame("nodeID"=c(1:length(origtree$edge.length)),origtree$edge,"BL"=origtree$edge.length)

## get posterior rates, relative rates and probabilities

###  get relative rates:

out= matrix( NA, length(origtree$edge.length),length(trees1) )
for ( i in 1: dim(out)[2]) {
  out[,i] = trees1[[i]]$edge.length/ origtree$edge.length
}

#####   get mean relative rate
relRates= rowMeans(out)
treedat$relRate = relRates
treedat$BLrelMeanTransformed= treedat$BL* treedat$relRate


####  get absolute rate per iteration
###  read from logfile
d = scan(paste(dirname, filename, ".Log.txt", sep=""), what="numeric", sep="\t")
startH = grep("Iteration", d)[2]
endH = grep("Node", d)[2]+1
startD = endH +1
endD=length(d)
dimC =length(d[startH:endH])
dimR =length(d[startD:endD])/dimC
post=as.data.frame(matrix(d[startD:endD],dimR, dimC ,byrow = T))
names(post) = d[startH: endH]
post= post[,-length(post)]
for ( i in c(2,4,5,6,7)) post[,i] = as.numeric(as.character(post[,i]))
## set burnin

post= post[c( (burnin+1):length(post[,1]) ),]


out_abs= matrix(NA, dim(out)[1], dim(out)[2])
for ( k in 1: length( post$`Sigma^2 1`)){
        out_abs[,k]= out[,k]*post$`Sigma^2 1`[k]
}

####  get mean absolute rate
absRates= rowMeans( out_abs)
treedat$absRates = absRates
treedat$BLabsMeanTransformed= treedat$BL* treedat$absRates


###   get posterior probabilities for all branch length transformations:
out2= out
out2[out2 == 1] = "orig"
out2[out != 1] = "scaled"



out_node= as.data.frame(matrix(NA, length(origtree$edge.length), 1))
for ( i in 1: length(origtree$edge.length)) { out_node[i,1]= length(grep( "scaled", out2[i,]))}
#head(out_node)
out_node$PP_pc= (out_node[,1]/dim(out)[2])*100
#hist(out_node$PP_pc, br=100)
treedat$PP= out_node$PP_pc

########  transform the original tree  with mean absolute rate

mean_absTransformed_tree = origtree
mean_absTransformed_tree $edge.length = treedat$BLabsMeanTransformed

##  write out mean transformed tree + the orig tree agian, so nodenumbers are consistent when reading back in 

write.tree(mean_absTransformed_tree, file=paste(dirname, filename, "_meanTransformed.tre", sep=""))
write.tree(origtree, file=paste(dirname,filename, "_origtree.tre", sep=""))


## make Pos.prob. categories for plotting (later)

treedat$PP2=treedat$PP
treedat$PP2[treedat$PP2 <= 50] = NA
treedat$PP2[treedat$PP2 <= 75 & treedat$PP2 > 50]=0.5
treedat$PP2[treedat$PP2 <= 90 & treedat$PP2 > 75]=1
treedat$PP2[treedat$PP2 <= 100 & treedat$PP2 > 90]=1.5

write.table(treedat, file=paste(dirname, TRAIT, "_",AXES,"_", "treedat_forPlot.txt", sep=""), quote=F, row.names=F)



