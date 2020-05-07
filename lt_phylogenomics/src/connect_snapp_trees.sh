# m_matschiner Mon Aug 5 15:14:07 CEST 2019

# Define function to allow fixing the random number seed.
get_seeded_random()
{
  seed="$1"
  openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt \
    </dev/zero 2>/dev/null
}

# Load modules.
module load R/3.6.0-foss-2019a
module load Ruby/2.6.3-GCCcore-8.2.0

# Set the connection table.
connection_table=../data/tables/snapp_tree_connections.txt

# Connect trees across layers of snapp analyses.
for seed in 27650 24535 28850 20632
do
    for method in astral free raxml
    do
        # Make the results directory.
        res_dir=../res/snapp/connected/${seed}
        mkdir -p ${res_dir}

        # Sample 1000 trees from each posterior tree distribution.
        for group in backbone ectodinibb lamprologinibb tropheinibb astatotilapini bathybatini benthochromini cyphotilapiini cyprichromini ectodini1 ectodini2 eretmodini lamprologini1 lamprologini2 lamprologini3 lamprologini4 lamprologini5 limnochromini orthochromini perissodini pseudocrenilabrini serranochromini tropheini1 tropheini2 trematocarini
        do
            simple_tree=../res/snapp/${group}/${method}_topology/combined/*.nwk
            if [ -f ${simple_tree} ]
            then
                cat ${simple_tree} | shuf -n 1000 --random-source=<(get_seeded_random ${seed}) > tmp.${group}.trees
            fi
        done

        # Use a ruby script to connect the trees across layers of snapp analyses.
        connected_trees=${res_dir}/snapp_${method}_topology.trees
        log_dir=${res_dir}
        ruby connect_snapp_trees.rb tmp.backbone.trees ${connection_table} ${connected_trees} ${log_dir}
    done
done
