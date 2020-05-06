# m_matschiner Fri Dec 14 11:26:05 CET 2018

# Get the command-line arguments.
intree_file_name = ARGV[0]
outtree_file_name = ARGV[1]

# Read the input tree file.
intree_file = File.open(intree_file_name)
intree = intree_file.readline

# Convert branch lengths in scientific notation to decimal notation.
while intree.match(/:(\d+\.\d+[eE]-*[0-9]+)[,\)]/)
	scientific_float = $1
	decimal_float = '%.8f' % $1
	if $1.to_f < 0.001
		intree.sub!(scientific_float,"0")
	else
		intree.sub!(scientific_float,decimal_float)
	end
end
outtree = intree

# Write the output tree file.
outtree_file = File.open(outtree_file_name, "w")
outtree_file.write(outtree)