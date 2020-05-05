# m_matschiner Sat May 6 01:21:21 CEST 2017

# Load the ruby module.
module load ruby/2.1.5

# Translate tree ids.
ruby translate_tree_ids.rb ../res/raxml/assemblies/NC_013663.assembled.tre ../data/tables/translation.txt ../res/raxml/assemblies/NC_013663.assembled.translated.tre

ruby translate_tree_ids.rb ../res/raxml/mapped/NC_013663.mapped.tre ../data/tables/translation.txt ../res/raxml/mapped/NC_013663.mapped.translated.tre