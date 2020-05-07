# m_matschiner Mon Sep 17 18:58:36 CEST 2018

# Load the ruby and python3 modules.
module load ruby/2.1.5
module load python3/3.5.0

# Get the command-line argument.
nex=${1}

# Get the number of variable sites in the alignment.
n_variable_sites=`ruby get_number_of_variable_sites.rb ${nex}`

# Get the parsimony score of the alignment.
parsimony_score=`bash get_parsimony_score.sh ${nex}`

# Calculate the number of hemiplasies as the difference of the number of variable sites and the parsimony score.
n_hemiplasies=$((${parsimony_score}-${n_variable_sites}))

# Report the number of hemiplasies.
echo ${n_hemiplasies}