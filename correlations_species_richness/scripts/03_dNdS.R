#### Fabrizia Ronco 
### April 2020

require(scales) ## version 1.0.0

## get data 
gwdNdS = read.table( "../input/genomewide_dNdS.txt", h=T)
head(gwdNdS)

####  get species and tribe info and make mean per species
tri_info= read.csv("../input/specimen_voucher_key.csv")
tmp =merge( gwdNdS, tri_info[,c(1,2,4)], by.x="id", by.y="DNA.Tube.ID", all.x=T)
out= aggregate( tmp[,2:5], list(tmp$Species.ID, tmp$Tribe), mean)

head(out)
names(out)[1:2]= c("species", "tribe")
out$tribe2=as.factor(tolower(substr(out$tribe,1,5)))

####  write out, for extenden data plot
write.csv( out, "../output/dN_dS_dNdS_genomewide_species_means.csv", row.names=F)



### Plot  genomewide dN and dS per bp per tribe

head(out)

## assign colors

col1= read.table("../input/colors_tribes.txt", h=T)
col2= col1[match(levels(out$tribe2), col1$tribe ),]
palette(as.character(col2$color))

out= droplevels(out)
range(out$dN/out$bp)
range(out$dS/out$bp)

quartz( width =4 , height=4  , type="pdf", file="../output/dN_over_bp.pdf")
par ( mar = c(7,7,1,1))
plot( out$dN/out$bp ~ out$tribe, col=alpha(as.numeric(as.factor(levels(out$tribe2))),0.5), border=as.factor(levels(out$tribe2)), pch=16, las=2, xlab="", ylab="dN/bp", cex=0.5)
dev.off()


quartz( width =4 , height=4  , type="pdf", file="../output/dS_over_bp.pdf")
par ( mar = c(7,7,1,1))
plot( out$dS/out$bp ~ out$tribe, col=alpha(as.numeric(as.factor(levels(out$tribe2))),0.5), border=as.factor(levels(out$tribe2)), pch=16,las=2, xlab="", ylab="dS/bp", cex=0.5)
dev.off()


