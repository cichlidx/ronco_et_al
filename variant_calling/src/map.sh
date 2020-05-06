# michaelm Fri Dec 2 17:54:19 CET 2016

# Make the output directory.
mkdir -p ../res/mapping

# Make the log directory.
mkdir -p ../log/mapping

# Set the data directory.
data_dir="../data/fastq/mapping"

# Reading the list of fastq files in the data directory.
fastqs_with_relative_path=`ls ${data_dir}/*.fastq.gz`

# Produce a list of unique combinations of sample and library identifiers.
truncated_fastqs_with_relative_path=()
for fastq_with_relative_path in ${fastqs_with_relative_path[@]}
do
    split_ary=(${fastq_with_relative_path//_/ })
    split_ary_size=(${#split_ary[@]})
    trim_part=${split_ary[$split_ary_size-1]}
    truncated_fastq_with_relative_path=${fastq_with_relative_path%_$trim_part}
    truncated_fastqs_with_relative_path+=($truncated_fastq_with_relative_path)
done
unique_truncated_fastqs_with_relative_path=$(echo "${truncated_fastqs_with_relative_path[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

# For each item in that list, start mapping with all fastq.gz files that match that item.
for unique_truncated_fastq_with_relative_path in ${unique_truncated_fastqs_with_relative_path}
do
    unique_truncated_fastq=`basename ${unique_truncated_fastq_with_relative_path}`
    out=../log/mapping.${unique_truncated_fastq}.out
    sbatch -o ${out} map.slurm ../data/reference/orenil2.fasta ../data/adapters/TruSeq_PE_Primer_Multiplex.fasta ../res/mapping $unique_truncated_fastq_with_relative_path*.fastq.gz
done
