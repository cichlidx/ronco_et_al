#
# Module import
#
# Module for command line in python
import argparse
import csv



parser = argparse.ArgumentParser(description='DenovoGenes pipeline to infert new transcripts from Trinity denovo assemblies')

# General parameters ------------------------------------------------------------------------------------------
# Gff3 input
parser.add_argument("-i", dest='input',help = "full path to gff3",required=True)

# Table output
parser.add_argument('-o', dest='output', help='Full path to output',required=True)

args = parser.parse_args()



with open(args.input, 'r') as Sugarbindings:
    file_read = csv.reader(Sugarbindings, delimiter='\t', quotechar='"')
    gff3 = []
    for row in file_read:
        gff3 += [row]


output = open(args.output,'w')
output.write('ExonId'+ '\t' + 'type' + '\t'	+ 'codingseqId' + '\t' +	'start'	+ '\t' + 'stop' + '\t' + 'strand' + '\t' +	'chromOnil' + '\t' +	'startOnil' + '\t' + 'stopOnil' +  '\n')

for i in gff3:
    if '#' not in i[0]:

        type = i[2]

        if type == 'CDS':

            query_info = i[8]

            query_informations = query_info.split(' ')
            identification = query_informations[0]

            exonId1 = identification.split(';')[0]
            exonId = exonId1.split('ID=')[1]

            geneName1 = identification.split(';')[1]
            geneName = geneName1.split('Name=')[1]

            start = query_informations[1]
            stop = query_informations[2]
            strand = query_informations[3]
            chrom_onil = i[0]
            start_onil = i[3]
            stop_onil = i[4]

            output.write(exonId + '\t' + type + '\t' + geneName + '\t' + start + '\t' + stop + '\t' + strand + '\t' + chrom_onil + '\t' + start_onil + '\t' + stop_onil + '\n')








