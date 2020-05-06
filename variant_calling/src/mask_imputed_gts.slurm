#!/bin/bash

# m_matschiner Sat Jan 6 16:28:54 CET 2018

# Job name:
#SBATCH --job-name=mskimp
#
# Wall clock limit:
#SBATCH --time=24:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=60G

## Set up the job environment.
source /cluster/bin/jobsetup
module load ruby/2.1.5
module load bcftools/1.6

## Feedback.
echo
echo "mask_imputed_gts.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
unimputed_gzvcf_with_relative_path=${1}
unimputed_gzvcf_with_absolute_path=`readlink -f ${unimputed_gzvcf_with_relative_path}`
imputed_gzvcf_with_relative_path=${2}
imputed_gzvcf_with_absolute_path=`readlink -f ${imputed_gzvcf_with_relative_path}`
masked_vcf_with_relative_path=${3}
masked_vcf_with_absolute_path=`readlink -f ${masked_vcf_with_relative_path}`

# Make sure the samples line in the header is identical between the unimputed and the imputed vcf.
unimputed_gzvcf_sample_line=`zcat ${unimputed_gzvcf_with_absolute_path} | head -n 1000 | grep CHROM`
imputed_gzvcf_sample_line=`zcat ${imputed_gzvcf_with_absolute_path} | head -n 1000 | grep CHROM`
if [ ! "${unimputed_gzvcf_sample_line}" == "${imputed_gzvcf_sample_line}" ]
then
    echo "ERROR: The samples lines seem to differ between the unimputed and the imputed vcf."
fi

# Index the imputed vcf.
if [ ! -f ${imputed_gzvcf_with_absolute_path}.tbi ]
then
    tabix ${imputed_gzvcf_with_absolute_path}
else
    touch ${imputed_gzvcf_with_absolute_path}.tbi
fi
touch ${unimputed_gzvcf_with_absolute_path}.tbi

# Copy the input files without their headers to the temporary directory.
echo -n "Copying the body of the unimputed vcf file to the temporary directory..."
bcftools view -H -o ${SCRATCH}/unimputed.body.vcf ${unimputed_gzvcf_with_absolute_path}
echo " done."
echo -n "Copying the body of the imputed vcf file to the temporary directory..."
bcftools view -H -o ${SCRATCH}/imputed.body.vcf ${imputed_gzvcf_with_absolute_path}
echo " done."

# Copy the ruby script to the temporary directory.
cp mask_imputed_gts.rb ${SCRATCH}

# Move to the temporary directory.
cd ${SCRATCH}

# Prepare a header for the masked file.
echo "##fileformat=VCFv4.2" > masked.header.vcf
echo "##FILTER=<ID=PASS,Description=\"All filters passed\">" >> masked.header.vcf
echo "##filedate=`date +'%Y%m%d'`" >> masked.header.vcf
echo "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">" >> masked.header.vcf
echo "##contig=<ID=NC_031965,length=38372991>" >> masked.header.vcf
echo "##contig=<ID=NC_031966,length=35256741>" >> masked.header.vcf
echo "##contig=<ID=NC_031967,length=14041792>" >> masked.header.vcf
echo "##contig=<ID=NC_031968,length=54508961>" >> masked.header.vcf
echo "##contig=<ID=NC_031969,length=38038224>" >> masked.header.vcf
echo "##contig=<ID=NC_031970,length=34628617>" >> masked.header.vcf
echo "##contig=<ID=NC_031971,length=44571662>" >> masked.header.vcf
echo "##contig=<ID=NC_031972,length=62059223>" >> masked.header.vcf
echo "##contig=<ID=NC_031973,length=30802437>" >> masked.header.vcf
echo "##contig=<ID=NC_031974,length=27519051>" >> masked.header.vcf
echo "##contig=<ID=NC_031975,length=32426571>" >> masked.header.vcf
echo "##contig=<ID=NC_031976,length=36466354>" >> masked.header.vcf
echo "##contig=<ID=NC_031977,length=41232431>" >> masked.header.vcf
echo "##contig=<ID=NC_031978,length=32337344>" >> masked.header.vcf
echo "##contig=<ID=NC_031979,length=39264731>" >> masked.header.vcf
echo "##contig=<ID=NC_031980,length=36154882>" >> masked.header.vcf
echo "##contig=<ID=NC_031981,length=40919683>" >> masked.header.vcf
echo "##contig=<ID=NC_031982,length=37007722>" >> masked.header.vcf
echo "##contig=<ID=NC_031983,length=31245232>" >> masked.header.vcf
echo "##contig=<ID=NC_031984,length=36767035>" >> masked.header.vcf
echo "##contig=<ID=NC_031985,length=37011614>" >> masked.header.vcf
echo "##contig=<ID=NC_031986,length=44097196>" >> masked.header.vcf
echo "##contig=<ID=NC_031987,length=43860769>" >> masked.header.vcf
echo "##contig=<ID=UNPLACED,length=141274046>" >> masked.header.vcf
echo "##reference=file:orenil2.fasta" >> masked.header.vcf
echo "${imputed_gzvcf_sample_line}" >> masked.header.vcf

# Mask the imputed sites.
echo -n "Masking imputed sites with ruby script..."
ruby mask_imputed_gts.rb unimputed.body.vcf imputed.body.vcf masked.body.vcf
echo " done."

# Combine the header of the imputed vcf and the body of the masked vcf to the full masked vcf.
echo -n "Concatenating header and body of the masked vcf to ${masked_vcf_with_absolute_path}..."
cat masked.header.vcf masked.body.vcf | gzip > ${masked_vcf_with_absolute_path} 
echo " done."