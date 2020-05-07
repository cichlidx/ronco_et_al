# m_matschiner Fri Jul 20 22:11:44 CEST 2018

# Get the command-line argument.
fasta_file_name = ARGV[0]
sequentialized_fasta_file_name = ARGV[1]

# Read the fasta file.
fasta_file = File.open(fasta_file_name)
fasta_lines = fasta_file.readlines
ids = []
seqs = []
fasta_lines.each do |l|
	if l.strip[0] == ">"
		ids << l.strip[1..-1]
		seqs << ""
	elsif l.strip != ""
		seqs.last << l.strip
	end
end

# Prepare the output string.
sequentialized_fasta_string = ""
ids.size.times do |x|
	sequentialized_fasta_string << ">#{ids[x]}\n"
	sequentialized_fasta_string << "#{seqs[x]}\n"
end

# Write the output file.
sequentialized_fasta_file = File.open(sequentialized_fasta_file_name, "w")
sequentialized_fasta_file.write(sequentialized_fasta_string)
puts "Wrote file #{sequentialized_fasta_file_name}."