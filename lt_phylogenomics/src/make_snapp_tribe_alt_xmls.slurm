#!/bin/bash

# m_matschiner Mon Jul 22 09:03:56 CEST 2019

# Job name:
#SBATCH --job-name=makxml
#
# Wall clock limit:
#SBATCH --time=10:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=4G

## Set up the job environment.
source /cluster/bin/jobsetup

## Feedback.
echo
echo "make_snapp_tribe_xmls.slurm was called with arguments ${@}."
echo

# Load modules.
module load bcftools/1.6
module load ruby/2.1.5

# Get the command-line arguments.
analysis_id=${1}

# Set the vcf file.
gzvcf=`readlink -f ../data/vcf/permissive.phased.vcf.bgzip.gz`

# Set the sample table file.
all_samples=`readlink -f ../data/tables/DNATube_2018-02-13_13-43.tsv`

# Set the completeness table file.
missingness_table=`readlink -f ../data/tables/call_probability.permissive.txt`

# Set the starting tree.
starting_astral=`readlink -f ../data/trees/snapp_${analysis_id}_astral_topology.tre`
starting_raxml=`readlink -f ../data/trees/snapp_${analysis_id}_raxml_topology.tre`

# Set the constraint files.
constraint_astral=`readlink -f ../data/constraints/snapp_${analysis_id}_astral.txt`
constraint_raxml=`readlink -f ../data/constraints/snapp_${analysis_id}_raxml.txt`
constraint_free=`readlink -f ../data/constraints/snapp_${analysis_id}_free.txt`

# Set the name of the results directory.
res_dir=`readlink -f ../res/snapp/${analysis_id}/xml`

# Make the results directory.
mkdir -p ${res_dir}

# Set the name of the snapp xml file.
xml_astral=${res_dir}/${analysis_id}_astral_topology_alt.xml
xml_raxml=${res_dir}/${analysis_id}_raxml_topology_alt.xml
xml_free=${res_dir}/${analysis_id}_free_topology_alt.xml

# Change to temporary directory.
cd ${SCRATCH}

# Prepare the samples file (selecting for each species the specimen with highest call probability).
species_in_analysis=`head -n 1 ${constraint_astral} | cut -f 3 | tr "," "\n"`
rm -f tmp.snapp_samples.txt
for species in ${species_in_analysis}
do
    cat ${all_samples} | cut -f 1,3 | grep ${species} | cut -f 1 > tmp.specimens_of_species_in_analyses.txt
    cat ${missingness_table} | grep -f tmp.specimens_of_species_in_analyses.txt | sort -n -r -k 7 | head -n 1 | cut -f 1 >> tmp.snapp_samples.txt
    rm -f tmp.specimens_of_species_in_analyses.txt
done

# Touch the index file to remove bcftools warnings.
touch ${gzvcf}.tbi

# Make a reduced version of the vcf file, including only data for the selected samples.
for lg_n in `seq 65 87`
do
    if [ ! -f tmp.NC_0319${lg_n}.vcf ]
    then
	echo -n "Extracting NC_0319${lg_n}..."
	bcftools view -S tmp.snapp_samples.txt -m 2 -M 2 --min-ac=1 ${gzvcf} NC_0319${lg_n} | bcftools view -e 'AC==0 || AC==AN || F_MISSING > 0' -o tmp.NC_0319${lg_n}.vcf
	echo " done."
    fi
done

# Combine the reduced vcf files.
cp tmp.NC_031965.vcf tmp.vcf
for lg_n in `seq 66 87`
do
    cat tmp.NC_0319${lg_n}.vcf | grep -v \# >> tmp.vcf
done

# Get the snapp_prep.rb script.
if [ ! -f snapp_prep.rb ]
then
    wget https://raw.githubusercontent.com/mmatschiner/snapp_prep/master/snapp_prep.rb
fi

# Prepare a sample list.
echo -e "species\tsample" > tmp.samples.txt
while read line
do
    sample=`echo ${line}`
    species=`cat ${all_samples} | cut -f 1,3 | grep ${sample} | cut -f 2`
    echo -e "${species}\t${sample}" >> tmp.samples.txt
done < tmp.snapp_samples.txt

# Generate snapp xml files with the script snapp_prep.rb.
ruby snapp_prep.rb -v tmp.vcf -t tmp.samples.txt -c ${constraint_astral} -m 10000 -l 250000 -w 0 -s ${starting_astral} -o ${analysis_id}_astral_topology -x ${xml_astral}
ruby snapp_prep.rb -v tmp.vcf -t tmp.samples.txt -c ${constraint_raxml} -m 10000 -l 250000 -w 0 -s ${starting_raxml} -o ${analysis_id}_raxml_topology -x ${xml_raxml}
ruby snapp_prep.rb -v tmp.vcf -t tmp.samples.txt -c ${constraint_free} -m 10000 -l 250000 -s ${starting_raxml} -o ${analysis_id}_free_topology -x ${xml_free}
