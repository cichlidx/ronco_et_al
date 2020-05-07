# m_matschiner Tue Apr 10 14:18:08 CEST 2018

# Set the sample file name.
sample_table="../data/tables/DNATube_2018-02-13_13-43.tsv"

# Add paup blocks for all nexus files.
for gzvcf in ../data/vcf/{strict,permissive}.c60.thin.vcf.gz ../data/vcf/{strict,permissive}.c60.s[0-9][0-9][0-9].vcf.gz ../data/vcf/{strict,permissive}.c60.sub1.thin.vcf.gz ../data/vcf/{strict,permissive}.c60.sub1.s[0-9][0-9][0-9].vcf.gz
do
    file_id=`basename ${gzvcf%.vcf.gz}`
    nex="../data/nexus/${file_id}.nex"
    new_nex="../data/nexus/${file_id}.paup.nex"
    res="../res/svdquartets/${file_id}.tre"
    log="../log/svdquartets/${file_id}.log"
    out="../log/misc/add_paup.${file_id}.out"
    split_species="Neocan"
    if [[ ${gzvcf} =~ "strict.c60.thin" ]]
    then
        n_quartets="3e+08"
        n_cpus=10
    elif [[ ${gzvcf} =~ "permissive.c60.thin" ]]
    then
        n_quartets="3e+08"
        n_cpus=10
    elif [[ ${gzvcf} =~ "strict.c60.sub1.thin" ]]
    then
        n_quartets="3e+08"
        n_cpus=10
    elif [[ ${gzvcf} =~ "permissive.c60.sub1.thin" ]]
    then
        n_quartets="3e+08"
        n_cpus=10
    elif [[ ${gzvcf} =~ "strict.c60.s" ]]
    then
        n_quartets="1e+09"
        n_cpus=1
    elif [[ ${gzvcf} =~ "permissive.c60.s" ]]
    then
        n_quartets="1e+09"
        n_cpus=10
    else
	echo "ERROR: Unexpected input file name ${gzvcf}!"
	exit 1
    fi
    if [ -f ${nex} ]
    then
        if [ ! -f ${new_nex} ]
        then
	    rm -f ${out}
            sbatch -o ${out} add_paup_block_to_nex.slurm ${gzvcf} ${sample_table} ${nex} ${new_nex} ${res} ${log} ${n_quartets} ${n_cpus} ${split_species}
        fi
    fi
done
