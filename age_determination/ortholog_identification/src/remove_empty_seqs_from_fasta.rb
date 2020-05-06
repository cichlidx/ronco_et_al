# m_matschiner Thu Sep 13 21:05:12 CEST 2018

# Get the command-line arguments.
fasta_in_file_name = ARGV[0]
fasta_out_file_name = ARGV[1]

# Read the input file.
fasta_in_file = File.open(fasta_in_file_name)
fasta_in_lines = fasta_in_file.readlines
ids = []
seqs = []
fasta_in_lines.each do |l|
	if l[0] == ">"
		ids << l.strip[1..-1]
		seqs << ""
	elsif l.strip != ""
		seqs.last << l.strip
	end
end

# Prepare the output string.
fasta_out_string = ""
ids.size.times do |x|
	unless seqs[x] == ""
		fasta_out_string << ">#{ids[x]}\n"
		fasta_out_string << "#{seqs[x]}\n"
	end
end

# Write the output file.
fasta_out_file = File.open(fasta_out_file_name, "w")
fasta_out_file.write(fasta_out_string)