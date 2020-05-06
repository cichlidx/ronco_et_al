# m_matschiner Wed Nov 7 16:19:59 CET 2018

# Get the command-line arguments.
infasta_file_name = ARGV[0]
id_prefix = ARGV[1]
outfasta_file_name = ARGV[2]

# Read the input fasta file.
infasta_file = File.open(infasta_file_name)
infasta_lines = infasta_file.readlines

# Get the total number of sequences in the fasta file.
n_seqs = 0
infasta_lines.each do |l|
	n_seqs += 1 if l[0] == ">"
end
n_digits = n_seqs.to_s.size

# Rename fasta ids.
count = 0
outfasta_string = ""
infasta_lines.each do |l|
	if l[0] == ">"
		count += 1
		outfasta_string << ">#{id_prefix}_#{count.to_s.rjust(n_digits).gsub(" ","0")}\n"
	else
		outfasta_string << "#{l.strip}\n"
	end
end

# Write the fasta file with renamed ids.
outfasta_file = File.open(outfasta_file_name, "w")
outfasta_file.write(outfasta_string)