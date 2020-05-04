### Fabrizia Ronco
# April 2020

#####################################################################
### assign species and tribe information and calculate species means

##  get data 
dup= read.csv("../output/Dupplication_final_filtered.csv", row.names=1)
head(dup)

###  assign up du date species names:
dup$speciesID =NULL
dup$fullID =NULL

species_info= read.csv("../input/specimen_voucher_key.csv")
head(species_info)
species_info[,3]=NULL

dup2= merge( dup, species_info, all.x=T, by.x="ID", by.y="DNA.Tube.ID", all.y=F)
head(dup2)
unique(as.character(dup2$speciesIDTribe) == as.character(dup2$Tribe))
dup2[is.na(dup2$Species.ID),]

## calculate species means
sp_means_dup=  aggregate( dup2[,2], list( dup2$Species.ID, dup2$Tribe), mean)
head(sp_means_dup)
names(sp_means_dup) = c("species", "tribe", "dup")
sp_means_dup= droplevels(sp_means_dup)

write.csv(sp_means_dup, "../output/Dupplication_species_means.csv")

