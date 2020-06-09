# m_matschiner Tue Mar 10 10:48:07 CET 2020

# Generate a newick version of the b1 tree.
unset R_HOME
rscript convert_nexus_tree_to_newick.r ../data/b1.tre tmp.nwk.tre

# Generate a simple version of the species table.
cat ../data/DNATube_2018-02-13_13-43.tsv | tail -n +2 | grep -v "Kabogo" | cut -f 3,4 | grep -v "\." | sort | uniq | grep "\S" > tmp.species_table.txt

# Set the input tree and table.
tree="tmp.nwk.tre"
species_table="tmp.species_table.txt"

# Perform simulations with different settings for migration.
for migration_setting in within_only within_and_between
do
	# Make the results directory.
	mkdir -p ../res/msprime/${migration_setting}

	# Perform simulations with different rate matrices.
	for migration_matrix in F4matrix_sample{1..20}
	do
		# Set the vcf output file.
		vcf=../res/msprime/${migration_setting}/simulate.${migration_matrix}.vcf

		# Set the name of the alleles table.
		allele_table="../res/msprime/${migration_setting}/simulate_alleles.${migration_matrix}.txt"

		# Set the name of the heterozygosity table.
		heterozygosity_table="../res/msprime/${migration_setting}/simulate_heterozygositites.${migration_matrix}.txt"

		# Set the name of a plot of heterozygosities per tribe.
		plot=${heterozygosity_table%.txt}.pdf

		# Run simulations with msprime.
		if [ ! -f ${heterozygosity_table} ]
		then
			python simulate.py ${tree} ${species_table} ../data/F4matrix_20samples/${migration_matrix}.txt ${vcf} ${migration_setting}

			# Calculate the numbers of homozygous and heterozygous sites per sample.
			echo -e "Species\tnRefHom\tnNonRefHom\tnHets" > ${allele_table}
			bcftools stats -s - ${vcf} | grep PSC | grep -v "#" | cut -f 3-6 >> ${allele_table}

			# Make a new table that also includes the tribes and heterozygosities.
			echo -e "Species\tTribe\tHeterozygosity" > ${heterozygosity_table}
			cat ${allele_table} | tail -n +2 > tmp.allele_table.txt
			while read line
			do
				species=`echo ${line} | cut -d " " -f 1`
				tribe=`cat tmp.species_table.txt | grep ${species} | head -n 1 | cut -f 2`
				n_ref_hom=`echo ${line} | cut -d " " -f 2`
				n_alt_hom=`echo ${line} | cut -d " " -f 3`
				n_het=`echo ${line} | cut -d " " -f 4`
				p_het=`echo "${n_het} / (${n_ref_hom} + ${n_alt_hom} + ${n_het})" | bc -l`
				echo -e "${species}\t${tribe}\t${p_het}" | grep -v Gobiocichlini | grep -v Heterotilapini | grep -v Serranochromini | grep -v Steatocranini | grep -v Tilapiini | grep -v Haplochromini >> ${heterozygosity_table}
			done < tmp.allele_table.txt
		fi

		# Plot the heterozygosities per tribe.
		if [ ! -f ${plot} ]
		then
			Rscript plot_heterozygosities.r ${heterozygosity_table} ${plot} ${migration_matrix}
		fi
	done
done

# Clean up.
rm -f tmp.species_table.txt
rm -f tmp.nwk.tre
rm -f tmp.allele_table.txt
