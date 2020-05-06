# CichlidX script repository

**Repository for scripts used in Ronco et al. (resubmitted).**

Directories correspond to different types of analyses as described below.

## local_assembly

Scripts and data files in this directory perform local assembly of candidate phylogenetic markers, using the programs aTRAM and Kollector. Scripts are written to run on an SGE queuing system; however, aTRAM databases were mostly prepared on a laptop computer with a solid-state drive because the hard disk drives of the SGE were found to write these databases orders of magnitudes slower. File [`run_all.sh`](local_assembly/src/run_all.sh) specifies in which sequence scripts should be run (but `run_all.sh` itself should not be executed as it would trigger scripts before upstream scripts have completed). Required preparatory steps are listed in the [`README`](local_assembly/README) file in directory [`mitochondrial_phylogenetics`](local_assembly).

## age_determination

XXX TODO (cichlid_phylogenetics)

## variant_calling

XXX TODO (sequencing)

## mitochondrial_phylogenetics

Scripts and data files in this directory perform mitochondrial assembly and phylogenetic inference from these assemblies. Scripts are written to be run on an SGE queuing system. File [`run_all.sh`](mitochondrial_phylogenetics/src/run_all.sh) in directory [`mitochondrial_phylogenetics/src`](mitochondrial_phylogenetics/src) specifies in which sequence scripts should be run (but `run_all.sh` itself should not be executed as it would trigger scripts before upstream scripts have completed). Required preparatory steps are listed in the [`README`](mitochondrial_phylogenetics/README) file in directory [`mitochondrial_phylogenetics`](mitochondrial_phylogenetics).

## lt_phylogenomics

XXX TODO (ear_phylogenomics)

## f4-ratio_analyses

The included R script [`f4-ratio_downstreamAnalyses.R`](f4-ratio_analyses/f4-ratio_downstreamAnalyses.R) can be used for analysing introgression on the basis of f4-ratio results produced by Dsuite ([Malinsky et al., 2020](https://doi.org/10.1101/634477)). The Dsuite output is included in the same folder. 

## heterozygosity_simulations

Coalescent simulations on the basis of the Lake Tanganyika species tree allowing various levels of within-tribe migration. The complete analysis can be run by executing the script [`run_all.sh`](heterozygosity_simulations/src/run_all.sh) in directory [`heterozygosity_simulations/src`](heterozygosity_simulations/src).

## trait_evolution 

Phenotypic analyses and phylogenetic comparative analyses of trait evolution.
* The directory [`trait_evolution/02_Morpho_Eco/scripts`](trait_evolution/02_Morpho_Eco/scripts) contains scripts for the geometric morphometric analyses and phenotype environment correlations. The complete analysis can be run by executing the script [`00_run_all.sh`](trait_evolution/02_Morpho_Eco/scripts/00_run_all.sh).
* The directory [`trait_evolution/03_TraitEvolution/scripts`](trait_evolution/03_TraitEvolution/scripts) contains scripts for the phylogenetic comparative analyses of trait evolution. The complete analysis can be run by executing the script [`00_run_all.sh`](trait_evolution/03_TraitEvolution/scripts/00_run_all.sh).

## transposable_elements

The directory includes the scripts to perform RepeatMasker and RepeatModeler, and to combine results for every genomes.
* [`1_RepeatMasker_RepeatModeler_VR.sh`](transposable_elements/1_RepeatMasker_RepeatModeler_VR.sh) script
* [`2_Combine_RMasker_RModeler_outputs_VR.py`](transposable_elements/2_Combine_RMasker_RModeler_outputs_VR.py) script that can be run using [`2_Combine_RMasker_RModeler_outputs_VR.sh`](transposable_elements/2_Combine_RMasker_RModeler_outputs_VR.sh) script

## correlations_species_richness

This directory contains scripts and data to test for an association between species-richness and different genome-wide statistics across the tribes in Lake Tanganyika and 
includes data on per genome repeat content (see [`transposable_elements`](transposable_elements)), gene duplication estimates, heterozygosity, genome-wide dN/dS ratios (see [`selection_coding_sequence`](selection_coding_sequence)), and with-tribe f4-ratio calculations (see [`f4-ratio_analyses`](f4-ratio_analyses)).

## Selection_coding_sequence 

This directory includes all scripts and data to measure substitution rates in coding sequences. Details of the pipeline are mentioned in [`selection_coding_sequence/Readme.md`](selection_coding_sequence/Readme.md). Scripts and data are grouped into six sub-directories:
* [`selection_coding_sequence/Bash_script`](selection_coding_sequence/Bash_script)
* [`selection_coding_sequence/Input_file`](selection_coding_sequence/Input_file)
* [`selection_coding_sequence/Perl_script`](selection_coding_sequence/Perl_script)
* [`selection_coding_sequence/Python_script`](selection_coding_sequence/Python_script)
* [`selection_coding_sequence/R_script`](selection_coding_sequence/R_script)
* [`selection_coding_sequence/Template_codeml`](selection_coding_sequence/Template_codeml)
