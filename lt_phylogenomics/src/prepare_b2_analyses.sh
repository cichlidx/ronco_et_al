# m_matschiner Fri Jul 5 00:04:11 CEST 2019

# Copy the b2 xml and slurm script to 10 replicate directories.
for n in `seq -w 1 10`
do
    dir=../res/beast/b2/replicates/r${n}
    mkdir -p ${dir}
    rm -f ${dir}/*
    cp ../res/beast/b2/xml/b2.xml ${dir}
    cp run_b2.slurm ${dir}
done