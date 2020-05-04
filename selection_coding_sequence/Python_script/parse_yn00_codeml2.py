import csv, re,os

#### Open all yn00 files:

import csv, argparse

parser = argparse.ArgumentParser(description='Retrive dN and dS values from the standrad output file')
# user name in scicore
parser.add_argument("-s", dest='sequence',help="Display the user name in scicore",required=True)
args = parser.parse_args()

output_dN = open('/scicore/home/salzburg/eltaher/cichlidX/result/dNdS/codeml.dN.dS.txt/' + args.sequence + '.dN.txt', 'w')
output_dS = open('/scicore/home/salzburg/eltaher/cichlidX/result/dNdS/codeml.dN.dS.txt/' + args.sequence + '.dS.txt', 'w')


dN_dico = {}
dS_dico = {}

# All specimen that we kept for the analyses:
with open('/scicore/home/salzburg/eltaher/cichlidX/data/dNdS_genomes/speciesList_FinalSelection_RadiationTribe_minGene18000.txt','r') as Sugarbindings:
    file_read = csv.reader(Sugarbindings, delimiter='\t', quotechar='"')
    specimen = []
    for row in file_read:
        specimen += [row]

files = os.listdir('/scicore/home/salzburg/eltaher/cichlidX/result/dNdS/codeml_summaryFile/OmegaEstimate/' + args.sequence)
for i in files:
    #print(i)
    with open('/scicore/home/salzburg/eltaher/cichlidX/result/dNdS/codeml_summaryFile/OmegaEstimate/' + args.sequence + '/' + i,'r') as Sugarbindings:
        #print(i)
        specimenID = i.split('.')[1]
        #print(specimenID)
        file_read = csv.reader(Sugarbindings, delimiter='\t', quotechar='"')
        summary_File = []
        for row in file_read:
            summary_File += [row]

    lastLine = summary_File[len(summary_File)-1]
    Infos = re.split('  |=', lastLine[0])

    if len(Infos) > 1:
        dS = Infos[-1]
        dS = dS.replace(" ", "")

        dN = Infos[-3]
        dN = dN.replace(" ", "")


        dN_dico[specimenID] = dN
        dS_dico[specimenID] = dS


for allSp in specimen:
    sp = allSp[0]
    if sp in dN_dico:
        output_dN.write(sp + '\t' + dN_dico[sp] + '\n')
        output_dS.write(sp + '\t' + dS_dico[sp] + '\n')
    else:
        output_dN.write(sp + '\t' + 'NaN' + '\n')
        output_dS.write(sp + '\t' + 'NaN' + '\n')


