# m_matschiner Fri Oct 5 15:44:28 CEST 2018

# Get the command-line arguments.
args <- commandArgs(trailingOnly = TRUE)
table_file_name <- args[1]
output_dir <- args[2]

# Read the stats table.
t <- read.table(table_file_name, header=T)

# Produce plot for the full data set.
outfile_name <- paste(output_dir, "/p_missing_vs_rf_dists.pdf", sep="")
pdf(outfile_name, height=7, width=7)
plot(t$proportion_missing,t$raxml_tree_rf_distance, xlab="Proportion missing", ylab="RF distance", main="All LGs")
dev.off()

# Produce plots for each linkage group.
for (n in c(1965:1987)){

	if (n == 1965) {lg_length = 35256741}
	if (n == 1966) {lg_length = 35256741}
	if (n == 1967) {lg_length = 14041792}
	if (n == 1968) {lg_length = 54508961}
	if (n == 1969) {lg_length = 38038224}
	if (n == 1970) {lg_length = 34628617}
	if (n == 1971) {lg_length = 44571662}
	if (n == 1972) {lg_length = 62059223}
	if (n == 1973) {lg_length = 30802437}
	if (n == 1974) {lg_length = 27519051}
	if (n == 1975) {lg_length = 32426571}
	if (n == 1976) {lg_length = 36466354}
	if (n == 1977) {lg_length = 41232431}
	if (n == 1978) {lg_length = 32337344}
	if (n == 1979) {lg_length = 39264731}
	if (n == 1980) {lg_length = 36154882}
	if (n == 1981) {lg_length = 40919683}
	if (n == 1982) {lg_length = 37007722}
	if (n == 1983) {lg_length = 31245232}
	if (n == 1984) {lg_length = 36767035}
	if (n == 1985) {lg_length = 37011614}
	if (n == 1986) {lg_length = 44097196}
	if (n == 1987) {lg_length = 43860769}

	# Set the linkage group.
	lg <- paste("NC_03", n, sep="")

	# Get a subset of the data for this linkage group only.
	t_sub <- t[ which(t$lg==lg), ]

	# Order the subset by the from column.
	t_sub <- t_sub[order(t_sub$from), ]

	# Plot the proportion of missing data.
	outfile_name <- paste(output_dir, "/p_missing_", lg, ".pdf", sep="")
	pdf(outfile_name, height=7, width=7)
	plot((t_sub$from+t_sub$to)/2, t_sub$proportion_missing, xlim=c(0,lg_length), xlab="Position", ylab="Proportion missing", main=lg)
	dev.off()

	# Plot the RF distances.
	outfile_name <- paste(output_dir, "/rf_dists_", lg, ".pdf", sep="")
	pdf(outfile_name, height=7, width=7)
	plot((t_sub$from+t_sub$to)/2, t_sub$raxml_tree_rf_distance, xlim=c(0,lg_length), xlab="Position", ylab="RF distance", main=lg)
	dev.off()

	# Plot the gsis.
	outfile_name <- paste(output_dir, "/gsis_", lg, ".pdf", sep="")
	pdf(outfile_name, height=7, width=7)
	plot((t_sub$from+t_sub$to)/2, t_sub$gsi_Ectodini, xlim=c(0,lg_length), ylim=c(0,1), col="#9bb8d5", xlab="Position", ylab="Genealogical sorting index", main=lg)
	points((t_sub$from+t_sub$to)/2, t_sub$gsi_Lamprologini, col="#c286b8")
	points((t_sub$from+t_sub$to)/2, t_sub$gsi_Eretmodini, col="#673077")
	points((t_sub$from+t_sub$to)/2, t_sub$gsi_Tropheini, col="#89c275")
	points((t_sub$from+t_sub$to)/2, t_sub$gsi_Cyprichromini, col="#eb4c33")
	points((t_sub$from+t_sub$to)/2, t_sub$gsi_Benthochromini, col="#ac252c")
	points((t_sub$from+t_sub$to)/2, t_sub$gsi_Perissodini, col="#f5ab4f")
	points((t_sub$from+t_sub$to)/2, t_sub$gsi_Limnochromini, col="#555ca3")
	points((t_sub$from+t_sub$to)/2, t_sub$gsi_Bathybatini, col="#1f2322")
	points((t_sub$from+t_sub$to)/2, t_sub$gsi_Trematocarini, col="#939171")
	points((t_sub$from+t_sub$to)/2, t_sub$gsi_Cyphotilapiini, col="#fbdd35")
	dev.off()

	# Get another subset for this linkage group only, using only windows with a low proportion of missing data.
	t_sub2 <- t_sub[ which(t_sub$proportion_missing < 0.6), ]

	# Plot the RF distances.
	outfile_name <- paste(output_dir, "/rf_dists_lt06_", lg, ".pdf", sep="")
	pdf(outfile_name, height=7, width=7)
	plot((t_sub2$from+t_sub2$to)/2, t_sub2$raxml_tree_rf_distance, xlim=c(0,lg_length), xlab="Position", ylab="RF distance", main=lg)
	dev.off()

	# Plot the gsis.
	outfile_name <- paste(output_dir, "/gsis_lt06_", lg, ".pdf", sep="")
	pdf(outfile_name, height=7, width=7)
	plot((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Ectodini, xlim=c(0,lg_length), ylim=c(0,1), col="#9bb8d5", xlab="Position", ylab="Genealogical sorting index", main=lg)
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Lamprologini, col="#c286b8")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Eretmodini, col="#673077")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Tropheini, col="#89c275")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Cyprichromini, col="#eb4c33")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Benthochromini, col="#ac252c")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Perissodini, col="#f5ab4f")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Limnochromini, col="#555ca3")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Bathybatini, col="#1f2322")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Trematocarini, col="#939171")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Cyphotilapiini, col="#fbdd35")
	dev.off()

	# Get another subset for this linkage group only, using only windows with a low proportion of missing data.
	t_sub2 <- t_sub[ which(t_sub$proportion_missing < 0.5), ]

	# Plot the RF distances.
	outfile_name <- paste(output_dir, "/rf_dists_lt05_", lg, ".pdf", sep="")
	pdf(outfile_name, height=7, width=7)
	plot((t_sub2$from+t_sub2$to)/2, t_sub2$raxml_tree_rf_distance, xlim=c(0,lg_length), xlab="Position", ylab="RF distance", main=lg)
	dev.off()

	# Plot the gsis.
	outfile_name <- paste(output_dir, "/gsis_lt05_", lg, ".pdf", sep="")
	pdf(outfile_name, height=7, width=7)
	plot((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Ectodini, xlim=c(0,lg_length), ylim=c(0,1), col="#9bb8d5", xlab="Position", ylab="Genealogical sorting index", main=lg)
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Lamprologini, col="#c286b8")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Eretmodini, col="#673077")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Tropheini, col="#89c275")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Cyprichromini, col="#eb4c33")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Benthochromini, col="#ac252c")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Perissodini, col="#f5ab4f")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Limnochromini, col="#555ca3")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Bathybatini, col="#1f2322")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Trematocarini, col="#939171")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Cyphotilapiini, col="#fbdd35")
	dev.off()

	# Get another subset for this linkage group only, using only windows with a low proportion of missing data.
	t_sub2 <- t_sub[ which(t_sub$proportion_missing < 0.4), ]

	# Plot the RF distances.
	outfile_name <- paste(output_dir, "/rf_dists_lt04_", lg, ".pdf", sep="")
	pdf(outfile_name, height=7, width=7)
	plot((t_sub2$from+t_sub2$to)/2, t_sub2$raxml_tree_rf_distance, xlim=c(0,lg_length), xlab="Position", ylab="RF distance", main=lg)
	dev.off()

	# Plot the gsis.
	outfile_name <- paste(output_dir, "/gsis_lt04_", lg, ".pdf", sep="")
	pdf(outfile_name, height=7, width=7)
	plot((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Ectodini, xlim=c(0,lg_length), ylim=c(0,1), col="#9bb8d5", xlab="Position", ylab="Genealogical sorting index", main=lg)
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Lamprologini, col="#c286b8")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Eretmodini, col="#673077")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Tropheini, col="#89c275")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Cyprichromini, col="#eb4c33")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Benthochromini, col="#ac252c")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Perissodini, col="#f5ab4f")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Limnochromini, col="#555ca3")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Bathybatini, col="#1f2322")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Trematocarini, col="#939171")
	points((t_sub2$from+t_sub2$to)/2, t_sub2$gsi_Cyphotilapiini, col="#fbdd35")
	dev.off()

}