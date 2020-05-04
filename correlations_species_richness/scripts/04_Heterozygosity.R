####. Fabrizia Ronco
# April 2020




##  get data 
HET=read.table("../input/numHetSites.txt", h=T)

#### each sample is represented multiple times in this table as calculation was done per linkage group
###  to get the genome-wide value, calculate the sum across the LGs
head(HET)
HET= aggregate(HET$nHets, list(HET$sample),FUN = sum)
names(HET) = c("sample", "nHets")

## assing species 
species_info= read.csv("../input/specimen_voucher_key.csv")
species_info[,3]=NULL
head(species_info)

het2= merge( HET, species_info, all.x=T, by.x="sample", by.y="DNA.Tube.ID", all.y=F)
head(het2)

#########  filter for species of the Lake radiation only
het2 = het2[-grep( "Serr", het2 $Tribe),]
het2 = het2[-grep( "Hapl", het2 $Tribe),]
het2 = het2[-grep( "tig", het2 $Species.ID),]
het2 = het2[-grep( "Neodev", het2 $Species.ID),]
het2 = het2[-grep( "Telluf", het2 $Species.ID),]


####. remove T. variabile which showed signs of DNA degradation or contamination 
het2 = het2[-grep( "Trevar", het2 $Species.ID),]

dim(het2)
####. calculate percentage of Het sites among all callable sites in the genome

f5 = read.table("../input/number_masked_sites.txt", h=F)
#head(f5)
names(f5) = c("sample", "maskedsites")
f5$callablesites = 1009865309 - as.numeric(f5$maskedsites)  ### genomesize - masked sites

out = merge(het2,f5, all.x = T , all.y=F)
out$percHetOverCallable = (out$nHets/out$callablesites*100)


#### calcuate species means and save to file
head(out)
sp_means_het=  aggregate( out$percHetOverCallable, list( out $Species.ID, out $Tribe), mean)

head(sp_means_het)
names(sp_means_het) = c("species", "tribe", "het")

write.csv(sp_means_het, "../output/hets_species_means.csv", row.names=F)



