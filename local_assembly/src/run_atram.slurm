#!/bin/bash

# m_matschiner Tue Mar 13 16:42:27 CET 2018

# Job name:
#SBATCH --job-name=atram
#
# Wall clock limit:
#SBATCH --time=168:00:00
#
# Processor and memory usage:
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=3G

# Define a function to print the time.
function print_time {
  END=$(date +%s)
  DIFF=$(( $END - $1 ))
  dd=$(echo "$DIFF/86400" | bc)
  dt2=$(echo "$DIFF-86400*$dd" | bc)
  dh=$(echo "$dt2/3600" | bc)
  dt3=$(echo "$dt2-3600*$dh" | bc)
  dm=$(echo "$dt3/60" | bc)
  ds=$(echo "$dt3-60*$dm" | bc)
  if [ $dd -gt 0 ]; then
    echo "done in ${dd} days and ${dh} hours."
  elif [ $dh -gt 0 ]; then
    echo "done in ${dh} hours and ${dm} minutes."
  elif [ $dm -gt 0 ]; then
    echo "done in ${dm} minutes and ${ds} seconds."
  else
    echo "done in ${ds} seconds."
  fi
}

## Set up the job environment.
source /cluster/bin/jobsetup
module load python3/3.5.0
module load trinityrnaseq/2.5.1
module load blast/2.7.1

## Feedback.
echo
echo "run_atram.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
specimen=${1}
query_w_relative_path=${2}
query=`basename ${query_w_relative_path}`
res_dir_w_relative_path=${3}
res_dir_w_absolute_path=`readlink -f ${res_dir_w_relative_path}`
log_w_relative_path=${4}
log=`basename ${log_w_relative_path}`
log_w_absolute_path=`readlink -f ${log_w_relative_path}`
database_dir=${5}

# Copy fastq input files to the temporary directory.
if [ -z ${database_dir} ]
then
    START=$(date +%s)
    echo -n "Copying fastq input files... "
    cp ../data/fastq/${specimen}_*.fastq.gz ${SCRATCH}
    print_time $START
fi

# Copy the query file to the temporary or the database directory.
START=$(date +%s)
if [ -z ${database_dir} ]
then
    echo -n "Copying file ${query} to temporary directory... "
    cp ${query_w_relative_path} ${SCRATCH}
else
    echo -n "Copying file ${query} to database directory... "
    cp ${query_w_relative_path} ${database_dir}
fi
print_time $START

# Copy atram scripts to the temporary or the database directory.
if [ -z ${database_dir} ]
then
    START=$(date +%s)
    echo -n "Copying atram scripts to temporary directory... "
    cp -r ../bin/* ${SCRATCH}
    print_time $START
else
    for i in ../bin/*
    do
	if [ ! -f ${database_dir}/${i} ]
	then
	    START=$(date +%s)
	    echo -n "Copying ${i} to database directory... "
	    cp -r ${i} ${database_dir}
	    print_time $START
	fi
    done
fi

# Change to the temporary or the database directory.
if [ -z ${database_dir} ]
then
    cd ${SCRATCH}
else
    cd ${database_dir}
fi

# Unzip all fastq input files.
if [ -z ${database_dir} ]
then
    START=$(date +%s)
    echo -n "Unzipping fastq.gz files... "
    zcat *R1.fastq.gz > r1.fastq
    zcat *R2.fastq.gz > r2.fastq
    print_time $START
fi

# Run atram's preprocessor to make a database.
if [ -z ${database_dir} ]
then
    START=$(date +%s)
    echo -n "Running atram's preprocessor... "
    python3 atram_preprocessor.py --cpus 10 -b ${specimen} --end-1 r1.fastq --end-2 r2.fastq &> ${log}
    print_time $START
fi

# Determine the original name of the query.
org_query=`echo ${query} | sed "s/tmp.${specimen}_//g"`

# Run atram.
START=$(date +%s)
echo -n "Running atram... "
python3 atram.py --cpus 10 --max-memory 10 -T 1000 -b ${specimen} -Q ${query} -p --exp-coverage 10 -a trinity --bit-score 50 -o ${specimen} &> ${log}
print_time $START

# Rename the atram output files.
for file in ${specimen}.${specimen}_${query%.txt}_*.filtered_contigs.fasta
do
    new_file=`echo ${file} | sed "s/${query%.txt}/${org_query%.txt}/g"`
    mv ${file} ${new_file}
done

# Copy the result files back to the result directory.
START=$(date +%s)
echo -n "Copying the result files back to the result directory... "
mv ${specimen}.${specimen}_${org_query%.txt}*filtered_contigs.fasta ${res_dir_w_absolute_path}
mv ${log} ${log_w_absolute_path}
print_time $START