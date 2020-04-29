#!/bin/bash


##############################
### Fabrizia Ronco, April 2020


######################## 
###  prepare output folders

mkdir -p ../body
mkdir -p ../oral
mkdir -p ../LPJ
mkdir -p ../SI
mkdir -p ../Plots


######################## 
###  Processing of the Landmark coordinates and perform PCA: 


## runs a procrustes superimposition of landmarks used for body shape characterisation
##(landmark description can be found in Extended Data Fig.4a) 
Rscript 01_body_procAling_PCA.R

## runs a procrustes superimposition of landmarks used for upper oral jaw morphology characterisation 
##(landmark description can be found in Extended Data Fig.4a) 
Rscript 02_UOJ_procAling_and_PCA.R

## runs a procrustes superimposition of landmarks used for lower pharyngeal jaw shape characterisation
##(landmark description can be found in Extended Data Fig.4b) 
Rscript 03_LPJ_mir_procAlign_sym_and_PCA.R


########################
#### stabel isotopes: analyses of baseline data, including plots

Rscript 04_SI_baseline.R > ../SI/results_baseline.txt


########################
###  PLOTS morphospace and ecospace - once as density plots and once as panel plot for each trait including species names

Rscript 05_all_data_density_plots.R

###  plot for each trait and stable isotope data an overview panel plot per tribe
Rscript 06a_Panelplots_MorphoSpace_per_tribe.R body
Rscript 06a_Panelplots_MorphoSpace_per_tribe.R UOJ
Rscript 06a_Panelplots_MorphoSpace_per_tribe.R LPJ
Rscript 06b_Panel_plot_SI.R


########################
#### PLS anaylses

### calculate species means in all data sets as input data for the PLS analyses
Rscript 07_calculate_sp_measn_all_data.R

### perforem PLS fit for each trait with the stable isotope data and save statistical output to file
Rscript 08a_PLS_body_SI.R > ../body/out_pls_stats_body.txt
Rscript 08b_PLS_UOJ_SI.R > ../oral/out_pls_stats_UOJ.txt
Rscript 08c_LPJ_SI_PLS.R > ../LPJ/out_pls_stats_LPJ.txt


###  clean up
rm Rplots.pdf







