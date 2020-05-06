# m_matschiner Mon Jul 23 11:22:49 CEST 2018

# Get the command line arguments.
alignment_directory_in = ARGV[0].chomp("/")
alignment_directory_out = ARGV[1].chomp("/")
regions_info_file_name = ARGV[2]
exons_info_file_name = ARGV[3]
minimum_number_of_exons_per_gene = ARGV[4].to_i

# Collect names of nucleotide fasta files in the input directory.
dir_entries_in = Dir.entries(alignment_directory_in)
filenames_in = []
dir_entries_in.each {|e| filenames_in << e if e.match(/.*_nucl.fasta/)}

# Get exon names of alignments from the filenames.
exon_alignment_names = []
filenames_in.each do |f|
	exon_alignment_names << f.chomp("_nucl.fasta")
end

# Read the exons info file.
exons_info_file = File.open(exons_info_file_name)
exons_info_lines = exons_info_file.readlines
exon_ids = []
gene_ids = []
exon_chromosome_ids = []
exon_froms = []
exon_tos = []
exons_info_lines[1..-1].each do |l|
	exon_ids << l.split[0]
	gene_ids << l.split[1]
end
unique_gene_ids = gene_ids.uniq

# Read the regions info file.
regions_info_file = File.open(regions_info_file_name)
regions_info_lines = regions_info_file.readlines
regions_info_file_exon_ids = []
regions_info_file_exon_chromosome_ids = []
regions_info_file_exon_froms = []
regions_info_file_exon_tos = []
regions_info_lines.each do |l|
	line_ary = l.split
	regions_info_file_exon_ids << line_ary[0]
	regions_info_file_exon_chromosome_ids << line_ary[1]
	regions_info_file_exon_froms << line_ary[3]
	regions_info_file_exon_tos << line_ary[4]
end

# Merge information from both files.
exon_ids.size.times do |x|
	if regions_info_file_exon_ids.include?(exon_ids[x])
		regions_info_file_index = regions_info_file_exon_ids.index(exon_ids[x])
		exon_chromosome_ids << regions_info_file_exon_chromosome_ids[regions_info_file_index]
		exon_froms << regions_info_file_exon_froms[regions_info_file_index].to_i
		exon_tos << regions_info_file_exon_tos[regions_info_file_index].to_i
	else
		exon_chromosome_ids << nil
		exon_froms << nil
		exon_tos << nil
	end
end

# For each gene, test whether at least three exons alignments are still present.
count = 0
n_dirs_generated = 0
unique_gene_ids.each do |g|
	# Feedback.
	count += 1
	print "Analysing gene #{g}..."
	exon_ids_for_this_gene = []
	exon_chromosome_ids_for_this_gene = []
	exon_centers_for_this_gene = []
	gene_ids.size.times do |x|
		if gene_ids[x] == g and exon_alignment_names.include?(exon_ids[x])
			exon_ids_for_this_gene << exon_ids[x]
			exon_chromosome_ids_for_this_gene << exon_chromosome_ids[x]
			exon_centers_for_this_gene << (exon_froms[x] + exon_tos[x])/2
		end
	end
	# If the minimum number of exon alignments is still present, convert the fasta
	# alignment files to nexus format and save these in a directory inside the
	# alignments output directory.
	if exon_ids_for_this_gene.size >= minimum_number_of_exons_per_gene
		exon_span = exon_centers_for_this_gene.max - exon_centers_for_this_gene.min
		if exon_chromosome_ids_for_this_gene.uniq.size == 1 and exon_span < 100000
			Dir.mkdir("#{alignment_directory_out}/#{g}")
			n_dirs_generated += 1
			exon_ids_for_this_gene.each do |e|
				fasta_file_name = "#{e}_nucl.fasta"
				fasta_file = File.open("#{alignment_directory_in}/#{fasta_file_name}")
				fasta_lines = fasta_file.readlines
				fasta_ids = []
				fasta_seqs = []
				fasta_lines.each do |l|
					if l[0] == ">"
						fasta_ids << l[1..-1].strip[0..5]
						fasta_seqs << ""
					elsif l.strip != ""
						fasta_seqs.last << l.strip
					end
				end
				nexus_string = "#nexus\n"
				nexus_string << "\n"
				nexus_string << "begin data;\n"
				nexus_string << "dimensions  ntax=#{fasta_ids.size} nchar=#{fasta_seqs[0].size};\n"
				nexus_string << "format datatype=DNA gap=- missing=?;\n"
				nexus_string << "matrix\n"
				fasta_ids.size.times do |x|
					nexus_string << "#{fasta_ids[x].ljust(12)}#{fasta_seqs[x]}\n"
				end
				nexus_string << ";\n"
				nexus_string << "end;\n"
				nexus_file_name = "#{e}.seq"
				nexus_file = File.open("#{alignment_directory_out}/#{g}/#{nexus_file_name}","w")
				nexus_file.write(nexus_string)
			end
			puts " done."
		else
			if exon_chromosome_ids_for_this_gene.uniq.size == 1
				puts " done. Found exons for the gene #{g} separated by #{exon_span} bp."
			else
				puts " done. Found exons for the gene #{g} on #{exon_chromosome_ids_for_this_gene.uniq.size} different chromosomes."
			end
		end
	else
		puts " done. Too few exons for this gene."
	end
end

# Feedback.
puts "#{n_dirs_generated} out of #{unique_gene_ids.size} genes remain after filtering."
