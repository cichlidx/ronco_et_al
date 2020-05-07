#!/bin/bash

# m_matschiner Wed Apr 11 12:08:57 CEST 2018

# Job name:
#SBATCH --job-name=addpaup
#
# Wall clock limit:
#SBATCH --time=10:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=10G

## Set up the job environment.
source /cluster/bin/jobsetup

## Feedback.
echo
echo "add_paup_block_to_nex.slurm called with arguments ${@}."
echo

# Get the command-line arguments.
gzvcf_with_relative_path=${1}
gzvcf_with_absolute_path=`readlink -f ${gzvcf_with_relative_path}`
sample_table_with_relative_path=${2}
sample_table_with_absolute_path=`readlink -f ${sample_table_with_relative_path}`
nex_with_relative_path=${3}
nex_with_absolute_path=`readlink -f ${nex_with_relative_path}`
new_nex_with_relative_path=${4}
new_nex_with_absolute_path=`readlink -f ${new_nex_with_relative_path}`
file_id=`basename ${gzvcf_with_relative_path%.vcf.gz}`
res_with_relative_path=${5}
res_with_absolute_path=`readlink -m ${res_with_relative_path}`
log_with_relative_path=${6}
log_with_absolute_path=`readlink -f ${log_with_relative_path}`
n_quartets=${7} # 1e+09 or 3e+08
n_cpus=${8}
split_species=${9} #"Neocan"

# Feedback.
echo "vcf: ${gzvcf_with_absolute_path}"
echo "table: ${sample_table_with_absolute_path}"
echo "nexus: ${nex_with_absolute_path}"
echo "new nexus: ${new_nex_with_absolute_path}"
echo "result: ${res_with_absolute_path}"
echo "log: ${log_with_absolute_path}"
echo "quartets: ${n_quartets}"
echo "cpus: ${n_cpus}"
echo "species to split: ${split_species}"
echo

# Change to temporary directory.
cd ${SCRATCH}

# Generate a file with a list of species for which alleles should be split.
echo ${split_species} | tr "," "\n" > split_species.txt

# Set the names of temporary files.
tmp_nex="tmp.nex"
tmp_specimen_table="specimens.txt"
tmp_split_specimen_table="split_specimens.txt"
tmp_nosplit_specimen_table="nosplit_specimens.txt"
tmp_split_species_list="split_species.txt"

# Generate a file with a list of species for which alleles should be split.
echo ${split_species} | tr "," "\n" > ${tmp_split_species_list}

# Initiate the taxon set block string.
taxon_set_block_string="begin sets;\n"
taxon_set_block_string="${taxon_set_block_string}\ttaxPartition species =\n"

# Start writing a new nexus file.
cat ${nex_with_absolute_path} | head -n 8 > ${tmp_nex}

# Make a list all specimens and species in the vcf.
for i in `zcat ${gzvcf_with_absolute_path} | head -n 1000 | grep CHROM | cut -f 10-`
do
    cat ${sample_table_with_absolute_path} | grep "^${i}"
done | cut -f 1,3 > ${tmp_specimen_table}
sample_count1=`cat ${tmp_specimen_table} | wc -l`

# Split the table into one that contains the specimens that should be split and one with all others. 
cat ${tmp_specimen_table} | grep -v -f ${tmp_split_species_list} > ${tmp_nosplit_specimen_table}
cat ${tmp_specimen_table} | grep -f ${tmp_split_species_list} > ${tmp_split_specimen_table}

# Compose the taxon block string.
# First, add all species that are not to be split to the taxon block string and to the nexus file.
sample_count2=0
line_count=0
for species in `cat ${tmp_nosplit_specimen_table} | cut -f 2 | sort | uniq`
do
    taxon_set_block_string="${taxon_set_block_string}\t\t${species}:"
    samples=`cat ${tmp_nosplit_specimen_table} | grep ${species} | cut -f 1`
    first_line_index=$((line_count+1))
    for i in ${samples}
    do
	sample_count2=$((sample_count2+1))
	line_count=$((line_count+1))
	cat ${nex_with_absolute_path} | grep "^${i}" >> ${tmp_nex}
    done
    last_line_index=$((line_count))
    taxon_set_block_string="${taxon_set_block_string} ${first_line_index}-${last_line_index},\n"
done
# Second, add all specimens that should be split twice to the taxon block string and to the nexus file.
for specimen in `cat ${tmp_split_specimen_table} | cut -f 1 | sort | uniq`
do
    sample_count2=$((sample_count2+1))
    taxon_set_block_string="${taxon_set_block_string}\t\t${specimen}_1:"
    line_count=$((line_count+1))
    cat ${nex_with_absolute_path} | grep "^${specimen}_1" >> ${tmp_nex}
    taxon_set_block_string="${taxon_set_block_string} ${line_count}-${line_count},\n"
    taxon_set_block_string="${taxon_set_block_string}\t\t${specimen}_2:"
    line_count=$((line_count+1))
    cat ${nex_with_absolute_path} | grep "^${specimen}_2" >> ${tmp_nex}
    taxon_set_block_string="${taxon_set_block_string} ${line_count}-${line_count},\n"
done
echo ";" >> ${tmp_nex}
echo "end;" >> ${tmp_nex}
echo "" >> ${tmp_nex}
taxon_set_block_string=`echo ${taxon_set_block_string} | rev | cut -c 4- | rev`
taxon_set_block_string="${taxon_set_block_string};\nend;\n"

# Make sure the sample count is correct.
if [ ! ${sample_count1} == ${sample_count2} ]
then
    echo "ERROR: The sample counts differ!"
    exit 1
fi
echo -e ${taxon_set_block_string} >> ${tmp_nex}

# Generate the paup block string.
paup_block_string="begin paup;\n"
paup_block_string="${paup_block_string}\tlog file=${log_with_absolute_path};\n"
paup_block_string="${paup_block_string}\toutgroup JWF9 JWE7 JWE3;\n"
paup_block_string="${paup_block_string}\tset outroot=monophyl;\n"
paup_block_string="${paup_block_string}\tSVDQuartets nthreads=${n_cpus} evalQuartets=random nquartets=${n_quartets} taxPartition=species ambigs=distribute;\n"
paup_block_string="${paup_block_string}\tsavetrees file=${res_with_absolute_path};\n"
paup_block_string="${paup_block_string}\tlog stop;\n"
paup_block_string="${paup_block_string}\tquit;\n"
paup_block_string="${paup_block_string}end;\n"

# Write the paup block string to the output file.
echo -e ${paup_block_string} >> ${tmp_nex}

# Replace the old nexus file with the new one.
cp ${tmp_nex} ${new_nex_with_absolute_path}
