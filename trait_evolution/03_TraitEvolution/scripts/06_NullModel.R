############################################
##################  ----------------------------   compare to NULL models
#############################################

###### -------- BM Null model, simulate data given the original tree:
#  this asumes continous trait evolution proportional to time and number of lineages

require(phytools)

args = commandArgs(trailingOnly=TRUE)
dirname= args[1]
TRAIT= args[2]
AXES= args[3]
STEP=0.15 #STEP= as.numeric(args[6])



##  get tree
origtree= read.tree(paste(dirname, "out_", TRAIT, "_", AXES, "_origtree.tre" , sep="") )


##  sig2 taken from fit Continous BM estimate
numsim=500

###  get parameters from the BM fitContinous run
z0=scan(paste(dirname, "z0_fitCont.txt", sep="" ),"double")
a=as.numeric(z0[3])
sig2=scan(paste(dirname, "sigsq_fitCont.txt", sep="" ),"double")
sig2 =as.numeric(sig2[3])

tmpSim= fastBM(origtree, sig2= sig2 , a=a, nsim= numsim)



#####   sample the ancestral states along time on n timeslices (same as for the real data)

H = nodeHeights(origtree)  ### get age of each node
root=max(H[,2]) ##   get age of the root  ]]

###. round down the root age to avoid problems with rounding artefacts
root2= floor(root*1000)/1000


##  define timeslices: start at the root and increas in 1.5 million years + additionally the tips  (same as for the real data)
n= STEP
v= c(seq(from=0, to=root2, by= n) , root2)

###  combine states of the nodes with nodeages
xx = node.depth.edgelength(origtree)  ### get age of each node

#####################    for each simmulation &  for each timepoint reconstruct the state linearly to the distance between the two node stages (same as for the real data)

outSIM=list()
for ( j in 1: numsim) {
        tmp = fastAnc(origtree, tmpSim[,j])
        new= c(tmpSim[,j], tmp)
        yy.bayPC =  cbind(new, xx) ###  seting reconstructed phenotype with x coolrdinate (age) of corresponding node

        Yt= list()
        for ( i in c(1: (length(v)-1)) ) {
                tmp.bayPC3      = intersect(which(H[,1]<= v[i] ), which( H[,2] >= v[i] ))  
                tmp.bayPC.node3 = origtree $edge[tmp.bayPC3,]
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
        
        outSIM [[j]]= out3[,c(3,1)]
}


out4= do.call(cbind, outSIM)
times= out4[,1]
out4= out4[,-grep("sample", colnames(out4))]

####  output for one axis states through time of 500 simulations
#head(out4)
names(out4)= paste("Sim", c(1:numsim), sep="_")
out4=cbind(times, out4)

write.table( out4, paste(dirname,  "Anc_states_BMnullModel","_", numsim, "sim", "_", TRAIT, "_", AXES, ".txt" ,sep=""), quote=F, sep="\t", row.names=F)




