# m_matschiner Tue Mar 27 14:36:46 CEST 2018

# Make the nexus data directory unless it exists already.
mkdir -p ../data/nexus

# Convert the vcf file to nexus format.
for gzvcf_with_relative_path in ../data/vcf/{strict,permissive}.c60.thin.vcf.gz ../data/vcf/{strict,permissive}.c60.s[0-9][0-9][0-9].vcf.gz ../data/vcf/{strict,permissive}.c60.sub1.thin.vcf.gz ../data/vcf/{strict,permissive}.c60.sub1.s[0-9][0-9][0-9].vcf.gz
do
    if [ -f ${gzvcf_with_relative_path} ]
    then
        file_id=`basename ${gzvcf_with_relative_path%.vcf.gz}`
        nexus_with_relative_path="../data/nexus/${file_id}.nex"
        if [ ! -f ${nexus_with_relative_path} ]
        then
            out="../log/misc/convert_vcf_to_nexus.${file_id}.out"
            rm -f ${out}
            sbatch -o ${out} convert_vcf_to_unphased_nexus.slurm ${gzvcf_with_relative_path} ${nexus_with_relative_path} "LJC9,LJD1"
        fi
    fi
done
