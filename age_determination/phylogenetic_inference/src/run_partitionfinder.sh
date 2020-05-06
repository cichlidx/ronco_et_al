# m_matschiner Mon Nov 26 00:25:58 CET 2018

# Load modules.
module load ruby/2.1.5
module load partitionfinder/2.1.1

# Make the log directory.
mkdir -p ../log/partitionfinder

# Split alignments by codon position.
for mode in strict
do
    mkdir -p ../res/partitionfinder/${mode}/alignments/cp1
    mkdir -p ../res/partitionfinder/${mode}/alignments/cp2
    for nex in ../data/alignments/${mode}/*.nex
    do
        cat ${nex} | grep -v funhet | grep -v tilbre | grep -v pelmar | grep -v tilspa | grep -v stespu > tmp.nex
        gene_id=`basename ${nex%.nex}`
        ruby split_by_cp.rb -i tmp.nex
        rm tmp_3.nex
        mv tmp_1.nex ../res/partitionfinder/${mode}/alignments/cp1/${gene_id}_1.nex
        mv tmp_2.nex ../res/partitionfinder/${mode}/alignments/cp2/${gene_id}_2.nex
        rm tmp.nex
    done
done

# Prepare the partitionfinder analyses.
for mode in strict
do
    min_size=10000
    for weight_scheme in site rate base model alpha
    do
        for codon_pos in cp1 cp2
        do
            # Make the analysis directory.
            mkdir -p ../res/partitionfinder/${mode}/min_${min_size}/${weight_scheme}/${codon_pos}/analysis

            # Write the concatenated alignment file and a partitions file.
            ruby concatenate.rb -i ../res/partitionfinder/${mode}/alignments/${codon_pos}/*.nex -o tmp.align_with_parts.phy -f phylip -p &> /dev/null
            n_tax=`head -n 1 tmp.align_with_parts.phy | cut -d " " -f 1`
            n_lines=$(( ${n_tax} + 1 ))
            head -n ${n_lines} tmp.align_with_parts.phy > ../res/partitionfinder/${mode}/min_${min_size}/${weight_scheme}/${codon_pos}/analysis/${mode}_${codon_pos}.phy
            n_lines=$(( ${n_lines} + 2 ))
            tail -n +${n_lines} tmp.align_with_parts.phy | sed "s/DNA, //g" | sed "s/=/ = /g" | sed 's/$/;/' > tmp.parts.phy

            # Write the partitionfinder configuration file.
            cfg=../res/partitionfinder/${mode}/min_${min_size}/${weight_scheme}/${codon_pos}/analysis/partition_finder.cfg
            echo "# ALIGNMENT FILE #" > ${cfg}
            echo "alignment = ${mode}_${codon_pos}.phy;" >> ${cfg}
            echo "" >> ${cfg}
            echo "# BRANCHLENGTHS #" >> ${cfg}
            echo "branchlengths = linked;" >> ${cfg}
            echo "" >> ${cfg}
            echo "# MODELS OF EVOLUTION #" >> ${cfg}
            echo "models = GTR+G;" >> ${cfg}
            echo "model_selection = aic;" >> ${cfg}
            echo "" >> ${cfg}
            echo "# DATA BLOCKS #" >> ${cfg}
            echo "[data_blocks]" >> ${cfg}
            cat tmp.parts.phy >> ${cfg}
            echo "" >> ${cfg}
            echo "# SCHEMES #" >> ${cfg}
            echo "[schemes]" >> ${cfg}
            echo "search = rcluster;" >> ${cfg}
        done
    done
done

# Run partitionfinder.
for mode in strict
do
    min_size=10000
    for weight_scheme in site rate # base model alpha site
    do
        for codon_pos in cp1 cp2
        do
            out=../log/partitionfinder/${mode}_min_${min_size}_${weight_scheme}_${codon_pos}.out
            rm -f ${out}
            if [ ${weight_scheme} == "rate" ]
            then
                sbatch -o ${out} run_partitionfinder.slurm ../res/partitionfinder/${mode}/min_${min_size}/${weight_scheme}/${codon_pos}/analysis ${min_size} "1,0,0,0"
            elif [ ${weight_scheme} == "base" ]
            then
                sbatch -o ${out} run_partitionfinder.slurm ../res/partitionfinder/${mode}/min_${min_size}/${weight_scheme}/${codon_pos}/analysis ${min_size} "0,1,0,0"
            elif [ ${weight_scheme} == "model" ]
            then
                sbatch -o ${out} run_partitionfinder.slurm ../res/partitionfinder/${mode}/min_${min_size}/${weight_scheme}/${codon_pos}/analysis ${min_size} "0,0,1,0"
            elif [ ${weight_scheme} == "alpha" ]
            then
                sbatch -o ${out} run_partitionfinder.slurm ../res/partitionfinder/${mode}/min_${min_size}/${weight_scheme}/${codon_pos}/analysis ${min_size} "0,0,0,1"
            elif [ ${weight_scheme} == "site" ]
            then
                sbatch -o ${out} run_partitionfinder.slurm ../res/partitionfinder/${mode}/min_${min_size}/${weight_scheme}/${codon_pos}/analysis ${min_size} "0,1,1,1"
            fi
        done
    done
done