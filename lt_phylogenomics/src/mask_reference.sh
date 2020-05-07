# m_matschiner Tue Jul 17 15:17:51 CEST 2018

# Specify the reference.
ref=../data/reference/orenil2.fasta

# Specify the script to be used.
script=./mask_reference.rb

# Mask the reference according to uncallable sites in the strict filtering.
out=../log/misc/mask_reference.strict.out
rm -f ${out}
gzmask=../data/masks/strict.uncallable.bed.gz
masked_ref=../data/reference/orenil2.masked.strict.fasta
sbatch -o ${out} mask_reference.slurm ${script} ${ref} ${gzmask} ${masked_ref}

# Mask the reference according to uncallable sites in the permissive filtering.
out=../log/misc/mask_reference.permissive.out
rm -f ${out}
gzmask=../data/masks/permissive.uncallable.bed.gz
masked_ref=../data/reference/orenil2.masked.permissive.fasta
sbatch -o ${out} mask_reference.slurm ${script} ${ref} ${gzmask} ${masked_ref}
