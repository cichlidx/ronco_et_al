## Fabrizia Ronco
## April 2020


########################################################################
####    density plots of morphospce and ecospace   #####################
########################################################################


########################################################################
#######   requried packages  ###########################################
########################################################################
require(ggplot2) ## version 3.2.1
require(hexbin) ## version 1.28.1

########################################################################
#######   get data and calculate species means of PC1 and PC2, and d15N and d13C, respectively
########################################################################

SI= read.csv("../../01_Data/SI_data.csv", h=T)
#head(SI)
## add species info:
spinfo= read.csv("../../01_Data/specimen_voucher_key.csv", head=T)
SI = merge( SI, spinfo[,c(1,3)], by.x="ID", by.y="ID", all.x=T)
SI_means= aggregate(SI[,c(3,2)] , list(SI$Species ), mean ) 

body= read.table("../../02_Morpho_Eco/body/PCA_pc_scores_body.txt", h=T)
#head(body)
body_means= aggregate(body[,2:3]  , list(body$sp ), mean ) 

LPJ= read.table( "../../02_Morpho_Eco/LPJ/PCA_pc_scores_LPJ.txt", h=T)
#head(LPJ)
LPJ_means= aggregate(LPJ[,1:2]  , list(LPJ$sp ), mean ) 

OJ= read.table("../../02_Morpho_Eco/oral/PCA_pc_scores_UOJ.txt", h=T)
#head(OJ)
OJ_means= aggregate(OJ[,2:3]  , list(OJ$sp ), mean ) 


######## combine all datasets into one, dicard species info and add Trait classifier

SI_means$Group.1="SI"
body_means$Group.1="Body"
LPJ_means$Group.1="LPJ"
OJ_means$Group.1="OJ"

names(SI_means)= names(body_means)=names(LPJ_means)=names(OJ_means)= c("group","X", "Y")
data_all= rbind(SI_means, body_means , LPJ_means, OJ_means)
data_all$group=as.factor(data_all $group)
#str(data_all)

##### plot
#head(data_all)

quartz(width =12 , height=3, file="../Plots/density_plots_all_traits.pdf", type="pdf") 
ggplot(data_all, aes(x=X, y=Y)) +
  geom_hex(bins=20) +
  facet_wrap(~group, scales="free", ncol=4)+
  scale_fill_gradientn(colours = c("#C8DBCC",  "deepskyblue4",  "#032E3F"), na.value = "#00000000")+
  theme_bw() +
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank()  , axis.line = element_line(colour = "black"))

dev.off()


