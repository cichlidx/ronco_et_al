# m_matschiner Thu Mar 12 10:51:25 CET 2020

# Load libraries.
library(ggplot2)
library(grid)

# Get the command line arguments.
args <- commandArgs(trailingOnly = TRUE)
heterozygosity_table_file_name <- args[1]
plot_file_name <- args[2]
title <- args[3]

# Read the heterozygosity table.
heterozygosity_table <- read.table(heterozygosity_table_file_name, header=T)

# Set the order of tribes in plot.
levels=c("Boulengerochromini","Benthochromini","Cyphotilapiini","Eretmodini","Bathybatini","Perissodini","Trematocarini","Limnochromini","Cyprichromini","Tropheini","Ectodini","Lamprologini")
heterozygosity_table$Tribe <- factor(heterozygosity_table$Tribe, levels = levels)

# Save the plot.
a <- ggplot(heterozygosity_table, aes(x=Tribe, y=Heterozygosity)) +
	geom_jitter(size=4, alpha = I(1 / 1.5), aes(color=Tribe)) +
	ggtitle(title) +
	scale_color_manual(values=c("#5A595C", "#AE2529", "#FDDF08", "#692D79", "#242626", "#FAAB42", "#949070", "#535DA9", "#F04E27", "#86C774", "#9BB9D8", "#C388BB"))
grid.newpage()
pushViewport(viewport(layout = grid.layout(2, 2)))
ggsave(plot_file_name)
