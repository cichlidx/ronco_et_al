# m_matschiner Wed Oct 17 20:25:42 CEST 2018

# Copy the b1 xml and slurm script to 10 replicate directories.
for n in `seq -w 1 10`
do
    dir=../res/beast/b1/replicates/r${n}
    mkdir -p ${dir}
    rm -f ${dir}/*
    cp ../res/beast/b1/xml/b1.xml ${dir}
    cp run_b1.slurm ${dir}
done