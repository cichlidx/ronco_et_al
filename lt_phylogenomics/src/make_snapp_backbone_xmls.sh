# m_matschiner Fri Jul 5 00:15:42 CEST 2019

# Load modules.
module load bcftools/1.6
module load ruby/2.1.5

# Make the result directory.
mkdir -p ../res/snapp/backbone/xml


## Fixed input.
# Set the vcf file.
gzvcf=../data/vcf/strict.phased.vcf.gz

# Set the sample table files.
all_samples=../data/tables/DNATube_2018-02-13_13-43.tsv

## Variable input.
snapp_samples=../data/tables/snapp_backbone_samples.txt

# Set the starting tree.
starting_astral=../data/trees/snapp_backbone_astral_topology.tre
starting_raxml=../data/trees/snapp_backbone_raxml_topology.tre

# Set the constraint files.
constraint_astral=../data/constraints/snapp_backbone_astral.txt
constraint_raxml=../data/constraints/snapp_backbone_raxml.txt
constraint_free=../data/constraints/snapp_backbone_free.txt


## Variable output.
# Set the name of the snapp xml file.
xml_astral=../res/snapp/backbone/xml/backbone_astral_topology.xml
xml_raxml=../res/snapp/backbone/xml/backbone_raxml_topology.xml
xml_free=../res/snapp/backbone/xml/backbone_free_topology.xml


# Make a copy of the samples table without tribe names.
cat ${snapp_samples} | grep -v ini > tmp.snapp_samples.txt

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
ruby snapp_prep.rb -v tmp.vcf -t tmp.samples.txt -c ${constraint_astral} -m 10000 -l 250000 -w 0 -s ${starting_astral} -o backbone_astral_topology -x ${xml_astral}
ruby snapp_prep.rb -v tmp.vcf -t tmp.samples.txt -c ${constraint_raxml} -m 10000 -l 250000 -w 0 -s ${starting_raxml} -o backbone_raxml_topology -x ${xml_raxml}
ruby snapp_prep.rb -v tmp.vcf -t tmp.samples.txt -c ${constraint_free} -m 10000 -l 250000 -s ${starting_raxml} -o backbone_free_topology -x ${xml_free}