# michaelm Fri Feb 24 23:19:58 CET 2017

# Convert the orenil2 reference.
bash convert_ref.sh

# Split the reference into linkage groups.
bash split_ref.sh

# Prepare the reference for mapping.
bash prepare.sh

# Map most (excluding outgroups) fastq files against the reference.
bash map_all.sh

# Merge bam files for the same individual.
bash merge.sh

# Get the unfiltered distribution of coverage in bam files, as determined by bedtools.
bash get_coverage_distribution.sh

# Get coverage statistics for all merged bam files.
bash get_coverage_stats.sh

# Run gatk's HaplotypeCaller with all bam files.
bash run_gatk1_all.sh

# Run gatks's GenotypeGVCFs with all gvcf files. This must be executed repeatedly until the output confirms "All done.".
bash run_gatk2_all.sh

# Prepare lists with ids of specimens per tribe so that separate vcf files can be produced.
bash make_lists_for_tribes.sh

# Filter snps according to strict criteria.
bash apply_strict_filter.sh

# Filter snps according to more permissive criteria.
bash apply_permissive_filter.sh

# Concatenate all filtered vcf files per linkage group.
bash concatenate_vcfs_per_lg.sh

# Concatenate the filtered vcf files of all linkage groups.
bash concatenate_all_vcfs.sh

# Concatenate all indel masks in bed format per linkage group.
bash concatenate_indel_masks_per_lg.sh

# Concatenate the indel masks in bed format of all linkage groups.
bash concatenate_all_indel_masks.sh

# Get stats for the filtered and concatenated vcf files.
bash get_vcf_stats.sh

# Get the allele frequencies for the filtered and concatenated vcf files.
bash get_vcf_freqs.sh

# Get the depth per site for each g.vcf file and store it as a ruby dump file.
bash get_depth_from_gvcf.sh

# Sum the the overall per-site depth across for all individuals, per lg.
bash sum_depths.sh

# Make a mask per lg of those regions in which the overall depth is too high or not high enough.
bash make_depth_masks.sh

# Combine the depth masks of all lgs.
bash concatenate_all_depth_masks.sh

# Combine all masks without regarding sample-specific depth.
bash merge_all_masks_all_samples.sh

# Combine all masks with regarding sample-specific depth.
bash merge_all_masks_per_sample.sh

# Calculate the call probability (per-sample probability that a genotype is not set to missing due to low genotype quality).
bash compare_missingness.sh

# Run imputation with beagle.
bash run_beagle1.sh

# Run phasing with beagle.
bash run_beagle2.sh

# Mask imputated genotypes.
bash mask_imputed_gts.sh

# Fix the phasing of hybrid individuals based on the alleles of the known parents.
bash fix_hybrid_phasing.sh

# Merge the masked phased vcfs.
bash concatenate_phased_vcfs.sh
