# m_matschiner Mon Apr 8 13:50:29 CEST 2019

# Prepare analysis directories.
for pop_size in pop025 pop05 pop1 pop2
do
    for n in `seq -w 20`
    do
	replicate_id="r${n}"
	analysis_dir=../res/beast/strict/min_10000/pop1/replicates/${replicate_id}
	mkdir -p ${analysis_dir}
	cp ../data/xml/strict_${pop_size}.xml ${analysis_dir}/strict.xml
	cat run_beast.slurm | sed "s/QQQQQQ/strict/g" > ${analysis_dir}/run_beast.slurm
    done
done