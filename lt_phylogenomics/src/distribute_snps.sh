# m_matschiner Wed Apr 4 17:07:05 CEST 2018

# Distribute snps from the strict and permissive vcfs into 100 different vcf files.
for filter in strict permissive
do
    if [ ! -f ../data/vcf/${filter}.c60.s001.vcf.gz ]
    then
        out="../log/misc/distr.${filter}.c60.out"
        sbatch -o ${out} distribute_snps.slurm ../data/vcf/${filter}.c60.vcf.gz
    fi
    if [ ! -f ../data/vcf/${filter}.c60.sub1.s001.vcf.gz ]
    then
        out="../log/misc/distr.${filter}.c60.sub1.out"
        sbatch -o ${out} distribute_snps.slurm ../data/vcf/${filter}.c60.sub1.vcf.gz
    fi
done