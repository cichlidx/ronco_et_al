# m_matschiner Mon Jul 2 12:40:51 CEST 2018

# Load the ruby module.
module load ruby/2.1.5

# Run a ruby script to determine the per-sample probability of filtering due to low genotype quality.
for filter in strict permissive
do
    ruby compare_missingness.rb ../res/gatk ${filter} ../res/gatk/call_probability.${filter}.txt
done