# CichlidX script repository

**Repository for scripts used in Ronco et al. (in revision).**

Directories correspond to different types of analyses as described below.


## f4-ratio_analyses

The included R script [`f4-ratio_downstreamAnalyses.R`](f4-ratio_analyses/f4-ratio_downstreamAnalyses.R) can be used for analysing introgression on the basis of f4-ratio results produced by Dsuite ([Malinsky et al., 2020](https://doi.org/10.1101/634477)). The Dsuite output is included in the same folder. 

## heterozygosity_simulations

Coalescent simulations on the basis of the Lake Tanganyika species tree allowing various levels of within-tribe migration. The complete analysis can be run by executing the script [`run_all.sh`](heterozygosity_simulations/src/run_all.sh) in directory [`heterozygosity_simulations/src`](heterozygosity_simulations/src).

## trait_evolution 

Phenotypic analyses and phylogenetic comparative analyses of trait evolution.
The directory [`trait_evolution/02_Morpho_Eco/scripts`](trait_evolution/02_Morpho_Eco/scripts) contains scripts for the geometric morphometric analyses and phenotype environment correlations. The complete analysis can be run by executing the script [`00_run_all.sh`](trait_evolution/02_Morpho_Eco/scripts/run_all.sh).
The directory [`trait_evolution/03_TraitEvolution/scripts`](trait_evolution/03_TraitEvolution/scripts) contains scripts for the analyses of trait evolution. The complete analysis can be run by executing the script [`00_run_all.sh`](trait_evolution/03_TraitEvolution/scripts/run_all.sh).


