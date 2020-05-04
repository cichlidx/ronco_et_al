__author__ = 'athimedeltaher'


import csv, argparse

parser = argparse.ArgumentParser(description='replace blank entry by NA')
# user name in scicore
parser.add_argument("-s", dest='sequence',help="Display the user name in scicore",required=True)
args = parser.parse_args()


with open('/scicore/home/salzburg/eltaher/cichlidX/result/dNdS/lnL/' + args.sequence + '.lnL.txt', 'rb') as Sugarbindings:
    file_read = csv.reader(Sugarbindings, delimiter='\t', quotechar='"')
    summary_File = []
    for row in file_read:
        summary_File += [row]



output = open('/scicore/home/salzburg/eltaher/cichlidX/result/dNdS/lnL/' + args.sequence + '.lnL.withNA.txt','w')

for i in summary_File:


    entry = i[0].split(' ')
    if len(entry) == 3:
        output.write(entry[0] + '\t' + entry[1] + '\t' + entry[2] + '\n')
    else:
        output.write(entry[0] + '\t' + 'NA' + '\t' + 'NA' + '\n')


