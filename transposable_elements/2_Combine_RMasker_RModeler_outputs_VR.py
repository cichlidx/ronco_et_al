import os, sys
import pandas as pd
import numpy as np
from collections import OrderedDict


def parse_RM_tbl(tbl_file, path_file, path_out, RM_type):

	if RM_type == 'RMasker':
		genome=tbl_file.split('.', 1)[0] # RepeatMasker outputs

		out_count='Summary_count_RMasker.txt'
		out_masked_bp='Summary_masked_bp_RMasker.txt'
		out_percent='Summary_percent_RMasker.txt'

	if RM_type == 'RMasker_RModeler':
		genome=tbl_file.split('.', 1)[0] + '_lib' # custom of RepeatMasker and RepeatModeler outputs

		out_count='Summary_count_RMasker_RModeler.txt'
		out_masked_bp='Summary_masked_bp_RMasker_RModeler.txt'
		out_percent='Summary_percent_RMasker_RModeler.txt'



	os.chdir(path_out)

	os.system('touch ' + out_count)
	os.system('touch ' + out_masked_bp)
	os.system('touch ' + out_percent)


	os.chdir(path_file)

	count=0
	count_line=0
	list_elements=[] # identified repeat elements >> in .out.detailed file
	list_count=OrderedDict() # elements as keys and count as values
	list_bp=OrderedDict() # elements as keys and masked bp as values
	list_percent=OrderedDict() # elements as keys and percent as values

	file_f=open(tbl_file, 'r') # .out.detailed file
	for line in file_f:
		count_line+=1

		if count_line > 8:
			lline = line.split()

			if len(lline) > 1:
				if lline[0] == 'Total' and lline[1].isdigit() == True and lline[2].isdigit() == True:
					list_elements.append(lline[0])
					list_count[lline[0]] = int(lline[1])
					list_bp[lline[0]] = int(lline[2])
					list_percent[lline[0]] = round(float(lline[3].replace('%', '')), 2) # remove '%' from the value
					break

				if lline[1].isdigit() == True and lline[0] != 'LINE':
					list_elements.append(lline[0])
					list_count[lline[0]] = int(lline[1])
					list_bp[lline[0]] = int(lline[2])
					list_percent[lline[0]] = round(float(lline[3].replace('%', '')), 2) # remove '%' from the value

				if lline[0] == 'LINE':
					list_elements.append(lline[0])
					if lline[1].isdigit() == False:
						list_count[lline[0]] = int('0') # if '--'

					else:
						list_count[lline[0]] = int(lline[1])

					if lline[2].isdigit() == False:
						list_bp[lline[0]] = int('0') # if '--'

					else:
						list_bp[lline[0]] = int(lline[2])

					if lline[3].isdigit() == False:
						list_percent[lline[0]] = round(float('0'), 2) # if '--'

					else:
						list_percent[lline[0]] = round(float(lline[3].replace('%', '')), 2) # remove '%' from the value

				if lline[1].isdigit() == False and lline[0] == 'total':
					list_elements.append('_'.join([lline[0], lline[1]])) # 'total' 'interspersed' >> 'total_interspersed'

					list_count['_'.join([lline[0], lline[1]])] = int(lline[2])
					list_bp['_'.join([lline[0], lline[1]])] = int(lline[3])
					list_percent['_'.join([lline[0], lline[1]])] = round(float(lline[4].replace('%', '')), 2) # remove '%' from the value

	if len(list_elements) == len(list_count) and len(list_count) == len(list_bp) and len(list_bp) == len(list_percent):
		print('%s : Numbers of elements, count, bp and percent values are equal: %s Code okay.'%(genome, len(list_elements)))


	os.chdir(path_out)

	header=False
	line_count=0
	for x in [out_count, out_masked_bp, out_percent]:
		header=False
		line_count=0
		out_f=open(x, 'r')
		for line in out_f:
			lline = line.split()
			line_count+=1

			if line_count == 1 and lline[0] == 'Genome':
				header=True
				break
		out_f.close()

		if header == False:
			out_f=open(x, 'a')

			out_f.write('Genome\t')
			# all elements except the last one
			# if last element >> '\n' at the end of the line
			for el in list_elements[:-1]:
				out_f.write('%s\t'%el)

			out_f.write('%s\n'%list_elements[-1])

		out_f.close()




	for x in [out_count, out_masked_bp, out_percent]:
		if x == out_count:
			liste_df = list_count
		if x == out_masked_bp:
			liste_df = list_bp
		if x == out_percent:
			liste_df = list_percent

		df = pd.read_csv(x, sep='\t')
		new_row = df.shape[0] # new row will be the value of the number of row since python starts with 0
		colnames = df.columns.values.tolist()[1:] # all column names except the first one 'Genome'
		nb_col = df.shape[1]
		zeros= ['0'] * nb_col



		if df.empty == True:
			df.append(pd.Series(zeros, index=df.columns), ignore_index=True)
			

		# same repeat elements present in the .out.detailed file and in the Summary_*_RMasker_RModeler.txt (header)
		df.loc[new_row, 'Genome'] = genome
		for val in liste_df.items():
			if val[0] in colnames:
				df.loc[new_row, val[0]] = val[1] # elements as val[0] and count/bp/percent as val[1]
			else:
				df[val[0]] = 0 # create new column with 0 as value for every rows
				df.loc[new_row, val[0]] = val[1]

		df.to_csv(x, columns = df.columns, sep='\t', index=False)



tbl_file = sys.argv[1]
path_file = sys.argv[2]
path_out = sys.argv[3]
RM_type = sys.argv[4]
parse_RM_tbl(tbl_file, path_file, path_out, RM_type)
