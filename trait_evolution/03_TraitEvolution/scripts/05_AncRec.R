## Fabrizia Ronco
## April 2020



#######
#####
#       character state reconstruction:  Estimating the ancestral states based on varRates model
######


## load libraries
require(phytools) ## version 0.6-60

##  get variables from command line
args = commandArgs(trailingOnly=TRUE)

dirname= args[1]
TRAIT= args[2]
AXES= args[3]
STEP=0.15 #STEP= as.numeric(args[5])


# get mean rate transformd tree and the data:
tree = read.tree( file=paste(dirname,"out_", TRAIT, "_", AXES,  "_meanTransformed.tre", sep=""))
tree=ladderize(tree)
d = read.table(args[4], head=F)
d2= d[,2];names(d2)= d[,1]
#head(d2)

###  reconstruct ancestral states
tmp = fastAnc(tree, d2)

tmp2= data.frame( c(tmp))
names(tmp2)= paste(AXES)
tmp2$node=rownames(tmp2)

##########################   ---  map the ancestral states on the original phylogeny
# get orig. tree
origtree= read.tree(paste(dirname, "out_", TRAIT, "_", AXES, "_origtree.tre" , sep="") )
origtree= ladderize(origtree)

#############  make sure the transformed tree and the original tree match
if(any(tree $edge != origtree$edge)){stop("topology of reference tree is not the same as transformed tree")}
if(any(tree $tip.label != origtree$tip.label)){stop("tips of the reference tree do not match the tips of the transformed tree")}


###  combine tip data and ancestral state data
        # bring tip data in the order matching the tiplabels in the tree
d2= d[match( origtree$tip.label, d[,1]), ]
        # combine with anc. states and names accoringly
new= c(d2[,2], tmp2[,1]); names(new)= c(as.character(d2[,1]), tmp2[,2] )
####  write out states and tips
write.table( new, paste(dirname, "AncRec_", TRAIT, "_", AXES, ".txt", sep=""), row.names=F, quote=F, sep="\t" )

################################ ################################ ################################ 
################################   sample Ancetral states in time slices  
################################ ################################ ################################

H = nodeHeights(origtree)  ### get age of each node
root=max(H[,2]) ##   get age of the root  ]]

###. round down the root age to avoid problems with rounding artefacts
root2= floor(root*1000)/1000


##  define timeslices: start at the root and increas in 1.5 Million years + additionally the tips
n= STEP
v= c(seq(from=0, to=root2, by= n) , root2)

###  combine states of the nodes with nodeages
xx = node.depth.edgelength(origtree)  ### get age of each node
yy.bayPC =  cbind(new, xx)            ###  seting reconstructed phenotype with x coolrdinate (age) of corresponding node



##### for each timepoint reconstruct the state linearly to the distance between the two node stages
Yt= list()
for ( i in c(1: (length(v)-1)) ) {      
        tmp.bayPC3      = intersect(which(H[,1]<= v[i] ), which( H[,2] >= v[i] ))  ###  get row number for the nodesHeights within root and timepoint  ---   get all edges crossing the timeslcie v:tips, but not ending before ( not adding nodes which are not present anymore)
        tmp.bayPC.node3 = origtree $edge[tmp.bayPC3,]                   ### get nodes of all branches between root and timepoint 
        start           = yy.bayPC[tmp.bayPC.node3[,1],]
        end             = yy.bayPC[tmp.bayPC.node3[,2],]
        t               = rep(v[i],times= length(end[,1]))
        y3              =(((end[,1]-start[,1])/(end[,2]-start[,2])) * (v[i] - start[,2])) + start[,1]
        Yt[[i]]         =cbind(y3, t)
}

v2= v[-(length(v)-1)]

out3=NULL
for ( k in 1: length(v2)){
        tmp3= unlist(Yt[[k]])
        tmp3.2= data.frame(tmp3, "sample" = v2[k])
        out3= rbind(out3, tmp3.2)
}

out4=out3[,c(1,3)]
#head(out4)

######## save to file
write.table(out4,paste(dirname,  "AncRec_sampled_by_",n, "_", TRAIT, "_", AXES, ".txt", sep=""), row.names=F, quote=F, sep="\t" )



