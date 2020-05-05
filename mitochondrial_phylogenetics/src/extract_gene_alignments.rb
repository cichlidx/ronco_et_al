# m_matschiner Fri May 5 16:16:35 CEST 2017

# Get command line arguments.
alignment_file_name = ARGV[0]
gene_alignment_dir = ARGV[1].chomp("/")
gene_table_file_name = ARGV[2]

# Read the alignment.
alignment_ids = []
alignment_seqs = []
alignment_file = File.open(alignment_file_name)
alignment_lines = alignment_file.readlines
alignment_lines.each do |l|
	if l[0] == ">"
		alignment_ids << l[1..-1].strip
		alignment_seqs << ""
	elsif l.strip != ""
		alignment_seqs.last << l.strip
	end
end

# Read the gene table file.
gene_table_file = File.open(gene_table_file_name)
gene_table_lines = gene_table_file.readlines

# Make alignments for each gene.
gene_table_lines.each do |l|
	line_ary = l.split
	gene_id = line_ary[0]
	gene_from_in_orenil2 = line_ary[1].to_i
	gene_to_in_orenil2 = line_ary[2].to_i

	# Make sure that the first sequence is orenil2
	unless alignment_ids[0] == "orenil2"
		puts "ERROR: The first sequence is not orenil2!"
		exit 1
	end

	# Translate the gene positions in orenil2 to gene positions in the alignment.
	pos_in_orenil2 = 0
	pos_in_alignment = 0
	until pos_in_orenil2 == gene_from_in_orenil2
		pos_in_alignment += 1
		pos_in_orenil2 += 1 unless alignment_seqs[0][pos_in_alignment-1] == "-"
	end
	gene_from_in_alignment = pos_in_alignment
	pos_in_orenil2 = 0
	pos_in_alignment = 0
	until pos_in_orenil2 == gene_to_in_orenil2
		pos_in_alignment += 1
		pos_in_orenil2 += 1 unless alignment_seqs[0][pos_in_alignment-1] == "-"
	end
	gene_to_in_alignment = pos_in_alignment

	gene_length_in_alignment = gene_to_in_alignment-gene_from_in_alignment+1
	n_codons = gene_length_in_alignment/3
	# Prepare a new file for the gene alignment.
	gene_alignment_string = ""
	alignment_ids.size.times do |x|
		gene_alignment_string << ">#{alignment_ids[x]}\n"
		gene_alignment_string << "#{alignment_seqs[x][(gene_from_in_alignment-1)..((gene_from_in_alignment-2)+(3*n_codons))]}\n"
	end
	gene_alignment_file_name = "#{gene_alignment_dir}/#{gene_id}.fasta"
	gene_alignment_file = File.open(gene_alignment_file_name,"w")
	gene_alignment_file.write(gene_alignment_string)
end
