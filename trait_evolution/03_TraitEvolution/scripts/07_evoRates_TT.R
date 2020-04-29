
############################################
##################  ------ calculate mean and sd of evolutionary rates (estimated by the araible rates model) through time 
#############################################


## load libraries
require(phytools)

##  get variables from comand line
args = commandArgs(trailingOnly=TRUE)
dirname= args[1]
TRAIT= args[2]
AXES= args[3]
STEP=0.15 #STEP= as.numeric(args[6])



###   get burnin from file
burn=read.table(paste( dirname,  "additional_burnin.txt", sep=""), h=F)
burnin=burn[1,1]


# get trees
trees1= read.nexus(paste(dirname,"out_",TRAIT,"_", AXES , ".Output.trees", sep=""))
origtree= read.nexus(args[4])
#### subset the trees with burnin
if (burnin>=1) trees1 = trees1[seq.int(burnin+1, length(trees1), 1)]
class(trees1) = "multiPhylo"

## ladderize the trees
origtree = ladderize(origtree)
trees1 = lapply(trees1, ladderize)
class(trees1) = "multiPhylo"

if(any(trees1[[1]]$edge != origtree$edge)){stop("topology of reference tree is not the same as transformed tree")}

###  get relative rates:

out= matrix( NA, length(origtree$edge.length),length(trees1) )
for ( i in 1: dim(out)[2]) {
        out[,i] = trees1[[i]]$edge.length/ origtree$edge.length
}


################################ ################################ ################################ 
################################   sample relative rates in time slices  -
################################ ################################ ################################


H = nodeHeights(origtree)  ### get age of each node
root=max(H[,2]) ##   get age of the root  ]]

###. round down the root age to avoid problems with rounding artefacts
root2= floor(root*1000)/1000

##  define timeslices: start at the root and increas in 1.5 million years + additionally the tips
n= STEP
v= c(seq(from=0, to=root2, by= n) , root2)

###  combine states of the nodes with nodeages
xx = node.depth.edgelength(origtree)  ### get age of each node



Yt= matrix( NA,length(v) ,dim(out)[2])
for ( i in c(1: length(v)) ) {
        tmp.bayPC3 = intersect(which(H[,1]<= v[i] ), which( H[,2] >= v[i] ))  ###  get row number for the nodesHeights within root and timepoint  ---   get all edges crossing the timeslcie v:tips, but not ending before ( not adding nodes which are not present anymore)
        tmp_rates= out[tmp.bayPC3,]     ###  find those edges in the tree data:
        if (length(tmp.bayPC3)>=2) {
                Yt[i,] = apply( tmp_rates, 2, mean)
        } else {
                Yt[i,] = mean(tmp_rates)        
        }
}



###  calucualte the sd polygon
mean_rate= rowMeans(Yt, na.rm=T)
tmp=apply(Yt ,1, sd)
yy=c(mean_rate+tmp, rev(mean_rate-tmp))
xx=c(v , rev(v))
polySD =cbind(x=xx, y=yy)


mean_rates= cbind(v,mean_rate)

write.csv(mean_rates, paste(dirname,"mean_rate_tt.csv",sep=""), row.names=F)
write.csv(polySD, paste(dirname,"SD_rate_tt.csv",sep=""), row.names=F)

