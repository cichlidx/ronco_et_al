# m_matschiner Thu Nov 15 09:57:44 CET 2018

# Get the command-line argument.
alignment_file_name = ARGV[0]
alignment_file = File.open(alignment_file_name)
table_file_name = ARGV[1]

# Read the alignment, which is expected to be in fasta format.
fasta_ids = []
fasta_seqs = []
alignment_lines = alignment_file.readlines
alignment_lines.each do |l|
	if l[0] == ">"
		fasta_ids << l[1..-1].strip
		fasta_seqs << ""
	elsif l.strip != ""
		fasta_seqs.last << l.strip
	end
end

# Report the completeness of each sequence.
outstring = "ID\tn_total\tn_present\tn_missing\tp_missing\tn_a\tn_c\tn_g\tn_t\tp_a\tp_c\tp_g\tp_t\n"
fasta_ids.size.times do |x|
	n_missing = fasta_seqs[x].count("N") + fasta_seqs[x].count("n") + fasta_seqs[x].count("-") + fasta_seqs[x].count("?")
	n_non_missing = fasta_seqs[x].size - n_missing
	outstring << "#{fasta_ids[x]}\t#{fasta_seqs[x].size}\t#{n_non_missing}\t#{n_missing}\t#{format("%.4f", n_missing/fasta_seqs[x].size.to_f)}\t"
	n_a = fasta_seqs[x].count("A") + fasta_seqs[x].count("a")
	n_c = fasta_seqs[x].count("C") + fasta_seqs[x].count("c")
	n_g = fasta_seqs[x].count("G") + fasta_seqs[x].count("g")
	n_t = fasta_seqs[x].count("T") + fasta_seqs[x].count("t")
	outstring << "#{n_a}\t#{n_c}\t#{n_g}\t#{n_t}\t"
	p_a = n_a/n_non_missing.to_f
	p_c = n_c/n_non_missing.to_f
	p_g = n_g/n_non_missing.to_f
	p_t = n_t/n_non_missing.to_f
	outstring << "#{format("%.3f", p_a)}\t#{format("%.3f", p_c)}\t#{format("%.3f", p_g)}\t#{format("%.3f", p_t)}\n"
end

# Write the output table.
table_file = File.open(table_file_name, "w")
table_file.write(outstring)

# Feedback.
puts "Wrote output table to file #{table_file_name}."