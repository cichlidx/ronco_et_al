# m_matschiner Tue Mar 10 10:48:07 CET 2020

# Generate a newick version of the b1 tree.
unset R_HOME
rscript convert_nexus_tree_to_newick.r ../data/b1.tre tmp.nwk.tre

# Generate a simple version of the species table.
cat ../data/DNATube_2018-02-13_13-43.tsv | tail -n +2 | grep -v "Kabogo" | cut -f 3,4 | grep -v "\." | sort | uniq | grep "\S" > tmp.species_table.txt

# Set the input tree and table.
tree="tmp.nwk.tre"
species_table="tmp.species_table.txt"

# Perform simulations with different settings for within tribe migration.
for within_tribe_migration in Fmatrix_full Fmatrix_full_sample_{1..20} no_mig low_mig high_mig
do
	# Set the vcf output file.
	vcf=../res/simulate.${within_tribe_migration}.vcf

	# Set the name of the alleles table.
	allele_table="../res/simulate_alleles.${within_tribe_migration}.txt"

	# Set the name of the heterozygosity table.
	heterozygosity_table="../res/simulate_heterozygositites.${within_tribe_migration}.txt"

	# Set the name of a plot of heterozygosities per tribe.
	plot=${heterozygosity_table%.txt}.pdf

	# Run simulations with msprime.
	if [ ! -f ${heterozygosity_table} ]
	then	
		if [ ${within_tribe_migration} = "no_mig" ]
		then
			python simulate.py ${tree} ${species_table} 0 ${vcf}
		elif [ ${within_tribe_migration} = "low_mig" ]
		then
			python simulate.py ${tree} ${species_table} 1e-8 ${vcf}
		elif [ ${within_tribe_migration} = "high_mig" ]
		then
			python simulate.py ${tree} ${species_table} 1e-6 ${vcf}
		else
			python simulate.py ${tree} ${species_table} ../data/migration_matrices/${within_tribe_migration}.txt ${vcf}
		fi

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
		Rscript plot_heterozygosities.r ${heterozygosity_table} ${plot} ${within_tribe_migration}
	fi
done

# Clean up.
rm -f tmp.species_table.txt
rm -f tmp.nwk.tre
rm -f tmp.allele_table.txt
