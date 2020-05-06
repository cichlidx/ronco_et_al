# m_matschiner Tue Mar 13 00:48:18 CET 2018

# Run local assembly with kollector.
bash run_kollector.sh

# Split the amino-acid format query file.
bash split_query_file.sh

# Run local assembly with atram for those specimens that had poor results with kollector.
bash run_atram.sh

# Combine atram results and clean up.
bash combine_atram_results.sh