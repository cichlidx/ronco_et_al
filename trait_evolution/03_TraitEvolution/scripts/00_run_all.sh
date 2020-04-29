#!/bin/bash


############################################################################################################
### Fabrizia Ronco
### April 2020
############################################################################################################

###  this is an exemplary workflow script how to run each of the scripts in what order they need to be executed
###  to run this on a sample of posterior trees the script must be adjusted accordingly 
###  also parallelisation is recommended



##  define working directory
HOME="/DIRECTORY/03_TraitEvolution/"
cd $HOME



## define on which tree to run the analyses
TREE="b1"
#TREE="b2"
#TREE="b3"


###  define on what set of traits to run the analyses
allAXES="body oral LPJ color"
for AXES in $allAXES; do
	if [ $AXES = color ]; then
		TRAIT="singletrait"
    else
    	TRAIT="PLS"
	fi


####################################################################################
	## prepare input files for the downstream analyses

	mkdir -p input

	if [ $TRAIT = PLS ]; then
		Rscript scripts/01a_prepare_input_files_PLS.R \
		../02_Morpho_Eco/${AXES}/${TRAIT}_${AXES}_SI.txt \
		../01_Data/${TREE}.tre \
		input/${TRAIT}_${AXES}.txt \
		input/${TREE}_pruned_to_${TRAIT}_${AXES}_data_nexus.tre
	else
		Rscript scripts/01b_prepare_input_files_color.R \
		../01_Data/${TREE}.tre \
		input/${TREE}_pruned_to_${TRAIT}_${AXES}_data_nexus.tre
	fi



####################################################################################
	## prepare output folder and fit singel process models
	mkdir -p output
	mkdir -p output/output_${TREE}_${TRAIT}_${AXES}
	MYPATH="output/output_${TREE}_${TRAIT}_${AXES}"

	Rscript scripts/02_fitContinous.R \
	input/${TREE}_pruned_to_${TRAIT}_${AXES}_data_nexus.tre \
	input/${TRAIT}_${AXES}.txt \
	> ${MYPATH}/out_fitCont.txt

	## extract parameters
	grep AICc_SE ${MYPATH}/out_fitCont.txt > ${MYPATH}/AICs_fitCont.txt 
	grep sigsq ${MYPATH}/out_fitCont.txt > ${MYPATH}/sigsq_fitCont.txt
	grep z0 ${MYPATH}/out_fitCont.txt > ${MYPATH}/z0_fitCont.txt 
	grep log-likelihood ${MYPATH}/out_fitCont.txt >> ${MYPATH}/log_likelihoods_fitCont.txt 



####################################################################################################################
####  based on the BM model parameters for the Bayes Traits runs need to be adjusted in the parfile*.txt files
####################################################################################################################

####################################################################################
	###  run variable rates model in Bayes Traits; model settings and priors are given in the parfile_*.txt file


	if [ $AXES = color ]; then
		PARFILE="color"
    else
		PARFILE="PLS"
	fi

	cp scripts/parfile_${PARFILE}.txt ${MYPATH}/parfile_${PARFILE}.txt
	cd ${MYPATH}
	BayesTraitsV3 ${HOME}/input/${TREE}_pruned_to_${TRAIT}_${AXES}_data_nexus.tre ${HOME}/input/${TRAIT}_${AXES}.txt < parfile_${PARFILE}.txt >> tmpout
	mv run.VarRates.txt out_${TRAIT}_${AXES}.VarRates.txt
	mv run.Log.txt out_${TRAIT}_${AXES}.Log.txt
	mv run.Schedule.txt out_${TRAIT}_${AXES}.Schedule.txt
	mv run.Output.trees out_${TRAIT}_${AXES}.Output.trees
	cd $HOME
	

####################################################################################
	###  test chains for convergence and define posterior sampel
	
	Rscript scripts/03_testConvergence.R \
	output/output_${TREE}_${TRAIT}_${AXES}/ \
	out_${TRAIT}_${AXES} \
	${TREE} \
	${TRAIT} \
	${AXES} 


####################################################################################
	###  processing the posterior sample of the Bayes Traits chain

	Rscript scripts/04_processingBT.R \
	output/output_${TREE}_${TRAIT}_${AXES}/ \
	out_${TRAIT}_${AXES} \
	input/${TREE}_pruned_to_${TRAIT}_${AXES}_data_nexus.tre \
	${TRAIT} \
	${AXES}


####################################################################################
	###  Ancestral stae reconstruction accounting for variable rates of evolution along the tree

	Rscript scripts/05_AncRec.R \
 	output/output_${TREE}_${TRAIT}_${AXES}/ \
	${TRAIT} \
	${AXES} \
	input/${TRAIT}_${AXES}.txt


####################################################################################
	###  Do the same for 500 Brownian motion simulations

	Rscript scripts/06_NullModel.R \
	output/output_${TREE}_${TRAIT}_${AXES}/ \
	${TRAIT} \
	${AXES} 


####################################################################################
	###  Summarise the evolutionary rates through time estimated by the variable rates model

	Rscript scripts/07_evoRates_TT.R \
	output/output_${TREE}_${TRAIT}_${AXES}/ \
	${TRAIT} \
	${AXES} \
	input/${TREE}_pruned_to_${TRAIT}_${AXES}_data_nexus.tre

####################################################################################
	###  Calculate morphospace expansion (filling) through time for the empirical data and the simulated data and compare the slopes

	Rscript scripts/08_morphoExp_TT.R \
	output/output_${TREE}_${TRAIT}_${AXES}/ \
	${TRAIT} \
	${AXES} 




done
