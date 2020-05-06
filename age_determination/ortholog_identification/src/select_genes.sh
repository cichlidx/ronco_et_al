# m_matschiner Thu Nov 15 21:16:33 CET 2018

# Load modules.
module load python3/3.5.0 

# Make results directories.
mkdir -p ../res/trees/nuclear/strict
mkdir -p ../res/trees/nuclear/permissive
mkdir -p ../res/alignments/nuclear/strict
mkdir -p ../res/alignments/nuclear/permissive

# Set strict and permissive thresholds.
min_min_ess_strict=200
min_min_ess_permissive=100
max_mut_rate_strict=0.0015
max_mut_rate_permissive=0.0020
max_rate_var_strict=0.4
max_rate_var_permissive=0.6

# Get the content of the stats table without the header line.
tail -n +2 ../res/tables/gene_stats.txt | grep -v -f ../res/manual/tables/unreliable_gene_ids.txt > tmp.table.txt

# Read the stats table.
while read line
do
    # Get values from the line.
    align_id=`echo ${line} | tr -s " " | cut -d " " -f 1`
    mut_rate=`echo ${line} | tr -s " " | cut -d " " -f 6`
    rate_var=`echo ${line} | tr -s " " | cut -d " "  -f 7`
    min_ess=`echo ${line} | tr -s " " | cut -d " " -f 8`

    if (( $(echo "${min_ess} > ${min_min_ess_strict}" | bc -l) ))
    then
	if (( $(echo "${mut_rate} < ${max_mut_rate_strict}" | bc -l) ))
	then
	    if (( $(echo "${rate_var} < ${max_rate_var_strict}" | bc -l) ))
	    then
		if [ ! -f ../res/alignments/nuclear/strict/${align_id}.nex ]
		then
		    cp -f ../res/alignments/nuclear/09/${align_id}/${align_id}.nex ../res/alignments/nuclear/strict
		fi
		if [ ! -f ../res/trees/nuclear/strict/${align_id}.trees ]
		then
		    python3 logcombiner.py -b 10 -n 100 ../res/alignments/nuclear/09/${align_id}/${align_id}.trees ../res/trees/nuclear/strict/${align_id}.trees
		fi
		if [ ! -f ../res/trees/nuclear/strict/${align_id}.tre ]
		then
		    cp -f ../res/alignments/nuclear/09/${align_id}/${align_id}.tre ../res/trees/nuclear/strict
		fi
	    fi
	fi
    fi
    if (( $(echo "${min_ess} > ${min_min_ess_permissive}" | bc -l) ))
    then
        if (( $(echo "${mut_rate} < ${max_mut_rate_permissive}" | bc -l) ))
        then
            if (( $(echo "${rate_var} < ${max_rate_var_permissive}" | bc -l) ))
            then
		if [ ! -f ../res/alignments/nuclear/permissive/${align_id}.nex ]
		then
                    cp -f ../res/alignments/nuclear/09/${align_id}/${align_id}.nex ../res/alignments/nuclear/permissive
		fi
		if [ ! -f ../res/trees/nuclear/permissive/${align_id}.trees ]
		then
		    python3 logcombiner.py -b 10 -n 100 ../res/alignments/nuclear/09/${align_id}/${align_id}.trees ../res/trees/nuclear/permissive/${align_id}.trees
		fi
		if [ ! -f ../res/trees/nuclear/permissive/${align_id}.tre ]
		then
                    cp -f ../res/alignments/nuclear/09/${align_id}/${align_id}.tre ../res/trees/nuclear/permissive
		fi
            fi
        fi
    fi
done < tmp.table.txt

# Clean up.
rm -f tmp.table.txt