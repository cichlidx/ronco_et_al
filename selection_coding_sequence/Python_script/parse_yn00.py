import csv, re,os

sequences = os.listdir('/Users/athimed/sc_eltaher/cichlidX/result/dNdS/yn00_summaryFile')

sequences_present = os.listdir('/Users/athimed/sc_eltaher/cichlidX/result/dNdS/dN.dS.txt')



# Do only the missing sequences:
sequenceFinal = []
for seq in sequences:

    if seq + '.dN.txt' not in sequences_present:

        sequenceFinal += [seq]



for sequence in sequenceFinal:

    print(sequence)

    output_dN = open('/Users/athimed/sc_eltaher/cichlidX/result/dNdS/dN.dS.txt/' + sequence + '.dN.txt','w')
    output_dS = open('/Users/athimed/sc_eltaher/cichlidX/result/dNdS/dN.dS.txt/' + sequence + '.dS.txt','w')


    with open('/Users/athimed/sc_eltaher/cichlidX/data/dNdS_genomes/speciesList.txt','r') as Sugarbindings:
        file_read = csv.reader(Sugarbindings, delimiter='\t', quotechar='"')
        specimen = []
        for row in file_read:
            specimen += [row]



    dN_dico = {}
    dS_dico = {}

    files = os.listdir('/Users/athimed/sc_eltaher/cichlidX/result/dNdS/yn00_summaryFile/' + sequence)

    for i in files:

        sp = i.split('.')[1]

        with open('/Users/athimed/sc_eltaher/cichlidX/result/dNdS/yn00_summaryFile/' + sequence + '/' + i,'r') as Sugarbindings:
            file_read = csv.reader(Sugarbindings, delimiter='\t', quotechar='"')
            File = []
            for row in file_read:
                File += [row]

        for a in range(0,len(File)):

            line = File[a]

            if 'seq. seq.     S       N        t   kappa   omega     dN +- SE    dS +- SE' in line:
                target = a + 2
                values = File[target][0]
                values_split = values.split()
                dS = values_split[-3]
                dN = values_split[-6]
                dN_dico[sp] = dN
                dS_dico[sp] = dS



    for allSp in specimen:

        sp = allSp[0]

        if sp in dN_dico:
            output_dN.write(sp + '\t' + dN_dico[sp] + '\n')
            output_dS.write(sp + '\t' + dS_dico[sp] + '\n')


        else:
            output_dN.write(sp + '\t' + 'NaN' + '\n')
            output_dS.write(sp + '\t' + 'NaN' + '\n')

