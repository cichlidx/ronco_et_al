# m_matschiner Wed Oct 3 12:37:54 CEST 2018

# Set the subject directory.
dir=../data/subjects/remote

# Make the subject directory.
mkdir -p ${dir}

# Set the links table.
links=../data/tables/subject_links.txt

# Download or copy all assemblies.
tail -n +2 ${links} > tmp.links.txt
while read line
do
    species=`echo ${line} | tr -s " " | cut -d " " -f 1`
    fasta=${dir}/${species}.fasta
    rm -f ${fasta}
    touch ${fasta}
    links=`echo ${line} | tr -s " " | cut -d " "  -f 2-`
    for link in ${links}
    do
	# If this is an internet link, then use wget to download.
	if [[ "${link:0:3}" == "ftp" || "${link:0:3}" == "htt" ]]
	then
	    if [[ "${link:(-7)}" == ".tar.gz" ]]
	    then
		wget -O - "${link}" > tmp.tar.gz; tar -xzOf tmp.tar.gz >> ${fasta}
		rm -f tmp.tar.gz
	    elif [[ "${link:(-3)}" == ".gz" ]]
	    then
		wget -O - "${link}" | gunzip >> ${fasta}
	    else
		wget -O- "${link}" >> ${fasta}
	    fi
	# If this is a path then use gunzip or cat.
	else
	    if [[ "${link:(-3)}" == ".gz" ]]
	    then
		gunzip -c ${link} >> ${fasta}
	    else
		cat ${link} >> ${fasta}
	    fi
	fi 
    done
    echo "Wrote file ${fasta}."
done < tmp.links.txt

# Clean up.
rm -f tmp.links.txt