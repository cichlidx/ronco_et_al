# m_matschiner Fri Jul 5 00:04:11 CEST 2019

# Copy the b3 xml and slurm script to 10 replicate directories.
for n in `seq -w 1 10`
do
    dir=../res/beast/b3/replicates/r${n}
    mkdir -p ${dir}
    rm -f ${dir}/*
    cp ../res/beast/b3/xml/b3.xml ${dir}
    cp run_b3.slurm ${dir}
done
