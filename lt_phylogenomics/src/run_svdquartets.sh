# m_matschiner Wed Apr 11 16:49:45 CEST 2018

# Make the output and log directories if they don't exist yet.
mkdir -p ../res/svdquartets
mkdir -p ../log/svdquartets

# Run svdquartets for the main strict and permissive vcfs.
nex=../data/nexus/strict.c60.thin.paup.nex
file_id=`basename ${nex%.paup.nex}`
out="../log/svdquartets/${file_id}.out"
sbatch -o ${out} --cpus-per-task=10 --mem-per-cpu=6G run_svdquartets.slurm ${nex}
nex=../data/nexus/permissive.c60.thin.paup.nex
file_id=`basename ${nex%.paup.nex}`
out="../log/svdquartets/${file_id}.out"
sbatch -o ${out} --cpus-per-task=15 --mem-per-cpu=4G --partition=long --time=300:00:00 run_svdquartets.slurm ${nex}

nex=../data/nexus/strict.c60.sub1.thin.paup.nex
file_id=`basename ${nex%.paup.nex}`
out="../log/svdquartets/${file_id}.out"
sbatch -o ${out} --cpus-per-task=10 --mem-per-cpu=6G run_svdquartets.slurm ${nex}
nex=../data/nexus/permissive.c60.sub1.thin.paup.nex
file_id=`basename ${nex%.paup.nex}`
out="../log/svdquartets/${file_id}.out"
sbatch -o ${out} --cpus-per-task=15 --mem-per-cpu=4G --partition=long --time=300:00:00 run_svdquartets.slurm ${nex}


# Run svdquartets for the vcf files with distributed snps.
for nex in ../data/nexus/strict.c60.s[0-9][0-9][0-9].paup.nex
do
    file_id=`basename ${nex%.paup.nex}`
    out="../log/svdquartets/${file_id}.out"
    sbatch -o ${out} run_svdquartets.slurm ${nex}
done
for nex in ../data/nexus/permissive.c60.s[0-9][0-9][0-9].paup.nex
do
    file_id=`basename ${nex%.paup.nex}`
    out="../log/svdquartets/${file_id}.out"
    sbatch -o ${out} --cpus-per-task=10 --mem-per-cpu=6G run_svdquartets.slurm ${nex}
done

for nex in ../data/nexus/strict.c60.sub1.s[0-9][0-9][0-9].paup.nex
do
    file_id=`basename ${nex%.paup.nex}`
    out="../log/svdquartets/${file_id}.out"
    sbatch -o ${out} run_svdquartets.slurm ${nex}
done
for nex in ../data/nexus/permissive.c60.sub1.s[0-9][0-9][0-9].paup.nex
do
    file_id=`basename ${nex%.paup.nex}`
    out="../log/svdquartets/${file_id}.out"
    sbatch -o ${out} --cpus-per-task=10 --mem-per-cpu=6G run_svdquartets.slurm ${nex}
done
