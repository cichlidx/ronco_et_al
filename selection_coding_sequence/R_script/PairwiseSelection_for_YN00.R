# Reconstruction of Cichlidx representative
#!/usr/bin/env Rscript

##### ##### ##### ##### ##### command line argument # ##### ##### ##### ##### #####
SeqProt = commandArgs(TRUE)[1] 
CichlidXSpecimen = commandArgs(TRUE)[2] 
##### ##### ##### ##### ##### module load ##### ##### ##### ##### ##### ##### #####



library(Biostrings)

Inital = readDNAStringSet(paste("/scicore/home/salzburg/eltaher/cichlidX/result/macse/",SeqProt,".macse.nucl.fasta",sep=''), "fasta")
Inital_contigs = names(Inital)

# select and rename:

posRef = grep('GCF_001858045.1_ASM185804v2',Inital_contigs)
posHeadRef = Inital_contigs[posRef]

posTar = grep(CichlidXSpecimen,Inital_contigs)
posHeader = Inital_contigs[posTar]

targetSeq = Inital[which(names(Inital)%in%c(posHeadRef,posHeader))]

# A. Rename: 
headerInital = unlist(lapply(names(targetSeq),function(x) strsplit(x,'specimenID:')[[1]][2]))
grepPos1 = grep('GCF_001858045.1_ASM185804v2',headerInital)
grepPos2 = grep(CichlidXSpecimen,headerInital)
headerInital[grepPos1] = 'OnilRef'
names(targetSeq) = headerInital
  
# B. Delete the last 3 nucleotide:
sequenceRef = as.character(targetSeq)[[grepPos1]]
sequenceTarget = as.character(targetSeq)[[grepPos2]]
sequenceRef = subseq(sequenceRef,1,(nchar(sequenceRef)-3))
sequenceTarget = subseq(sequenceTarget,1,(nchar(sequenceTarget)-3))

targetSeq[[grepPos1]]= sequenceRef
targetSeq[[grepPos2]] = sequenceTarget

OnilRefPos = which(names(targetSeq)=='OnilRef')
ChicliDPos = which(names(targetSeq)==CichlidXSpecimen)

targetSeqfinal = c(targetSeq[OnilRefPos],targetSeq[ChicliDPos])
  
writeXStringSet(targetSeqfinal, file = paste("/scicore/home/salzburg/eltaher/cichlidX/result/PAML/",SeqProt,"/",CichlidXSpecimen,"/",SeqProt,".",CichlidXSpecimen,".Pairwise.macse.nucl.fasta",sep='') , format="fasta")

# Find and replace 
# Input File:   sed 's/input.fasta/replace.fasta/' Template.txt  > 
# Output File : sed 's/input.fasta/replace.fasta/' Template.txt  > 



