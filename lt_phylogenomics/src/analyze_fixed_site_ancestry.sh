# m_matschiner Thu Apr 12 17:07:12 CEST 2018

# Make the results and log directories if they don't exist yet.
mkdir -p ../res/tables/fixed_site_ancestry
mkdir -p ../res/plots/fixed_site_ancestry
mkdir -p ../log/misc

# Set the sample table.
sample_table="../data/tables/DNATube_2018-02-13_13-43.tsv"

# Analyze alleles at sites that are fixed between parental species for various sets of species.
gzvcf="../data/vcf/strict.phased.vcf.gz"
file_id=`basename ${gzvcf%.vcf.gz}`
for species in "Altfas,Neocan,TelteS,Astbur" "Altfas,Neocan,Telvit,Astbur" "Neopul,Neokom,Neosav,Astbur"
do
    spc_o=`echo ${species} | cut -d "," -f 4`
    spc_p3=`echo ${species} | cut -d "," -f 3`
    spc_p2=`echo ${species} | cut -d "," -f 2`
    spc_p1=`echo ${species} | cut -d "," -f 1`
    out=../log/misc/fixed_sites.${file_id}.${spc_p1}_${spc_p2}_${spc_p3}_${spc_o}.out
    out_table=../res/tables/fixed_site_ancestry/${file_id}.${spc_p1}_${spc_p2}_${spc_p3}_${spc_o}.fixed_sites.txt
    out_plot=../res/plots/fixed_site_ancestry/${file_id}.${spc_p1}_${spc_p2}_${spc_p3}_${spc_o}.fixed_sites.svg
    if [ ! -f ${out_table} ]
    then
        rm -f ${out}
        sbatch -o ${out} analyze_fixed_site_ancestry.slurm ${gzvcf} ${sample_table} ${species} ${out_table} ${out_plot}
    fi
done
