# This script reads the table of a reference species' exons from
# Biomart and filters them as follows:
#
# 1. If multiple transcripts are known for a gene, only exons of
#    the transcript with the longest overall length are used.
# 2. Exons shorter than 300 bp are discarded.
# 3. Exons are discarded if their gene has less than three exons
#    that passed filters 1 and 2.
#
# Exons that pass these filters are translated and written to a
# fasta file.

module Enumerable
	def sum
		self.inject(0){|accum, i| accum + i }
	end
end
class String
	def reverse_complement
		reverse_complement = ""
		(self.size-1).downto(0) do |x|
			if self[x].upcase == "A"
				reverse_complement << "T"
			elsif self[x].upcase == "C"
				reverse_complement << "G"
			elsif self[x].upcase == "G"
				reverse_complement << "C"
			elsif self[x].upcase == "T"
				reverse_complement << "A"
			else
				reverse_complement << "N"
			end
		end
		reverse_complement
	end
	def translate
		translation = ""
		(self.size/3).times do |x|
			codon = self[3*x..3*(x+1)-1].upcase
			if codon == "AAA"
				translation << "K"
			elsif codon == "AAC"
				translation << "N"
			elsif codon == "AAG"
				translation << "K"
			elsif codon == "AAT"
				translation << "N"
			elsif codon == "ACA"
				translation << "T"
			elsif codon == "ACC"
				translation << "T"
			elsif codon == "ACG"
				translation << "T"
			elsif codon == "ACT"
				translation << "T"
			elsif codon == "AGA"
				translation << "R"
			elsif codon == "AGC"
				translation << "S"
			elsif codon == "AGG"
				translation << "R"
			elsif codon == "AGT"
				translation << "S"
			elsif codon == "ATA"
				translation << "I"
			elsif codon == "ATC"
				translation << "I"
			elsif codon == "ATG"
				translation << "M"
			elsif codon == "ATT"
				translation << "I"
			elsif codon == "CAA"
				translation << "Q"
			elsif codon == "CAC"
				translation << "H"
			elsif codon == "CAG"
				translation << "Q"
			elsif codon == "CAT"
				translation << "H"
			elsif codon == "CCA"
				translation << "P"
			elsif codon == "CCC"
				translation << "P"
			elsif codon == "CCG"
				translation << "P"
			elsif codon == "CCT"
				translation << "P"
			elsif codon == "CGA"
				translation << "R"
			elsif codon == "CGC"
				translation << "R"
			elsif codon == "CGG"
				translation << "R"
			elsif codon == "CGT"
				translation << "R"
			elsif codon == "CTA"
				translation << "L"
			elsif codon == "CTC"
				translation << "L"
			elsif codon == "CTG"
				translation << "L"
			elsif codon == "CTT"
				translation << "L"
			elsif codon == "GAA"
				translation << "E"
			elsif codon == "GAC"
				translation << "D"
			elsif codon == "GAG"
				translation << "E"
			elsif codon == "GAT"
				translation << "D"
			elsif codon == "GCA"
				translation << "A"
			elsif codon == "GCC"
				translation << "A"
			elsif codon == "GCG"
				translation << "A"
			elsif codon == "GCT"
				translation << "A"
			elsif codon == "GGA"
				translation << "G"
			elsif codon == "GGC"
				translation << "G"
			elsif codon == "GGG"
				translation << "G"
			elsif codon == "GGT"
				translation << "G"
			elsif codon == "GTA"
				translation << "V"
			elsif codon == "GTC"
				translation << "V"
			elsif codon == "GTG"
				translation << "V"
			elsif codon == "GTT"
				translation << "V"
			elsif codon == "TAA"
				translation << "*"
			elsif codon == "TAC"
				translation << "Y"
			elsif codon == "TAG"
				translation << "*"
			elsif codon == "TAT"
				translation << "Y"
			elsif codon == "TCA"
				translation << "S"
			elsif codon == "TCC"
				translation << "S"
			elsif codon == "TCG"
				translation << "S"
			elsif codon == "TCT"
				translation << "S"
			elsif codon == "TGA"
				translation << "*"
			elsif codon == "TGC"
				translation << "C"
			elsif codon == "TGG"
				translation << "W"
			elsif codon == "TGT"
				translation << "C"
			elsif codon == "TTA"
				translation << "L"
			elsif codon == "TTC"
				translation << "F"
			elsif codon == "TTG"
				translation << "L"
			elsif codon == "TTT"
				translation << "F"
			else
				translation << "X"
			end
		end
		translation
	end
end

class Gene
	attr_reader :id, :transcripts, :chromosome, :gene_tree, :ortholog_ids
	def initialize(id)
		@id = id
		@transcripts = []
		@ortholog_ids = []
	end
	def add_chromosome(chromosome)
		@chromosome = chromosome
	end
	def add_transcript(transcript)
		@transcripts << transcript
	end
	def longest_transcript
		longest_transcript = @transcripts[0]
		@transcripts[1..-1].each do |t|
			if t.length > longest_transcript.length
				longest_transcript = t
			end
		end
		longest_transcript
	end
	def selected(minimum_number_of_usable_exons_per_gene)
		@minimum_number_of_usable_exons_per_gene = minimum_number_of_usable_exons_per_gene
		self.longest_transcript.selected(@minimum_number_of_usable_exons_per_gene)
	end
	def add_gene_tree(gene_tree)
		@gene_tree = gene_tree
	end
	def add_ortholog_id(ortholog_id)
		@ortholog_ids << ortholog_id
	end
end

class Transcript
	attr_reader :id, :exons, :selected, :strand
	def initialize(id)
		@id = id
		@exons = []
	end
	def add_start(transcript_start)
		@start = transcript_start
	end
	def add_end(transcript_end)
		@end = transcript_end
	end
	def add_strand(strand)
		@strand = strand
	end
	def add_exon(exon)
		@exons << exon
	end
	def length
		length = 0
		@exons.each do |e|
			length += e.length
		end
		length
	end
	def long_exons(minimum_exon_length_in_nucleotides)
		@minimum_exon_length_in_nucleotides = minimum_exon_length_in_nucleotides
		long_exons = []
		@exons.each do |e|
			long_exons << e if e.length >= @minimum_exon_length_in_nucleotides
		end
		long_exons
	end
	def selected(minimum_number_of_usable_exons_per_gene)
		@minimum_number_of_usable_exons_per_gene = minimum_number_of_usable_exons_per_gene
		number_of_selected_exons = 0
		@exons.each do |e|
			number_of_selected_exons += 1 if e.selected
		end
		if number_of_selected_exons >= minimum_number_of_usable_exons_per_gene
			true
		else
			false
		end
	end
	def sort_exons
		exon_starts = []
		@exons.each do |e|
			exon_starts << e.start
		end
		exon_starts.sort!
		if strand == -1
			exon_starts.reverse!
		end
		tmp_exons = []
		if exon_starts.size != exon_starts.uniq.size
			raise "Some exons seem to have the same start!"
		end
		exon_starts.each do |s|
			@exons.each do |e|
				if e.start == s
					tmp_exons << e
				end
			end
		end
		@exons = tmp_exons
	end
end

class Exon
	attr_reader :id, :selected, :seq, :start, :end, :start_phase, :end_phase, :translation, :correct_bitscores, :correct_seqs, :incorrect_bitscores
	def initialize(id)
		@id = id
		@selected = false
	end
	def add_start(exon_start)
		@start = exon_start
	end
	def add_end(exon_end)
		@end = exon_end
	end
	def add_start_phase(start_phase)
		@start_phase = start_phase
	end
	def add_end_phase(end_phase)
		@end_phase = end_phase
	end
	def length
		(@end - @start).abs + 1
	end
	def select
		@selected = true
	end
	def deselect
		@selected = false
	end
	def add_seq(exon_seq)
		@seq = exon_seq
	end
	def translate
		@translation = @seq.translate
	end
	def add_correct_bitscores(correct_bitscores)
		@correct_bitscores = correct_bitscores
	end
	def add_correct_seqs(correct_seqs)
		@correct_seqs = correct_seqs
	end
	def add_incorrect_bitscores(incorrect_bitscores)
		@incorrect_bitscores = incorrect_bitscores
	end
end

# Define the input file names.
biomart_table_file_name = ARGV[0] # "../data/mart_export.txt"
gene_tree_file_name = ARGV[1] # "../data/Compara.93.protein_default.nhx.emf"
fasta_file_name = ARGV[2] # "../data/orylat.fasta"
database_table_file_name = ARGV[3] # "../data/databases.txt"
taxon_assignment_file_name = ARGV[4]
database_table_file_name_without_path = database_table_file_name.split("/").last
subject_database_path = database_table_file_name.chomp(database_table_file_name_without_path).chomp("/")
n_orthologs_allowed_missing = ARGV[5].to_i

# Define the output file names.
dump_file_name = ARGV[6]
gene_table_file_name = ARGV[7] # "../res/tables/nuclear_queries_genes.txt"
exon_table_file_name = ARGV[8] # "../res/tables/nuclear_queries_exons.txt"
exon_fasta_file_name = ARGV[9] # "../res/queries/orylat_exons.fasta"

# Define the name of the temporary query file.
query_file_name = "tmp_query.fasta"

# The next two parameters specify the factor by which a bitscore must be
# better than the worst incorrect bitscore in order to count as an ortholog,
# and the number of taxa for which orthologs must be identified in this way,
# otherwise, the exon will be removed.
minimum_bitscore_difference_for_orthologs = 20
# ortholog_bitscore_ratio_threshold = 1.5
# The minimum bitscore required for consideration as ortholog.
ortholog_minimum_bitscore = 50
minimum_number_of_usable_exons_per_gene = 3
minimum_exon_length_in_nucleotides = 150

# Read the database table file.
subject_databases = []
database_table_file = File.open(database_table_file_name)
database_table_lines = database_table_file.readlines
database_table_lines.each do |l|
	unless l.strip[0] == "#" or l.strip == ""
		subject_databases << l.strip
	end
end

# Read the taxon assignment table file.
taxon_tags = []
taxon_assignments = []
taxon_counts = []
taxon_assignment_file = File.open(taxon_assignment_file_name)
taxon_assignment_lines = taxon_assignment_file.readlines
taxon_assignment_lines.each do |l|
	unless l[0] == "#"
		line_ary = l.split
		if ["out","ref","in"].include?(line_ary[1])
			taxon_tags << line_ary[0]
			taxon_assignments << line_ary[1]
			taxon_counts << line_ary[2].to_i
		else
			puts "ERROR: Expected the second column of file #{taxon_assignment_file_name} to contain either 'out', 'ref', or 'in' as taxon assignment, but found #{line_ary[1]}!"
			exit(1)
		end
	end
end

# Get the number of ingroup ortholog counts that could maximally be expected.
max_ingroup_n_orthologs = 0
taxon_tags.size.times do |x|
	max_ingroup_n_orthologs += taxon_counts[x] if taxon_assignments[x] == "in"
end

# See if a dump file exists already.
if File.exists?(dump_file_name)

	# Read the dump file.
	print "Reading dump file..."
	STDOUT.flush
	dump_file = File.open(dump_file_name)
	genes = Marshal.load(dump_file.read)
	puts " done."
	STDOUT.flush

else

	# Read the biomart table.
	print "Reading file #{biomart_table_file_name}..."
	STDOUT.flush
	biomart_table_file = File.open(biomart_table_file_name)
	biomart_table = biomart_table_file.readlines
	biomart_table = biomart_table[1..-1].sort!
	puts " done."
	STDOUT.flush

	# Read the genome sequence fasta file.
	print "Reading file #{fasta_file_name}..."
	STDOUT.flush
	fasta_file = File.open(fasta_file_name)
	fasta_lines = fasta_file.readlines
	fasta_ids = []
	fasta_seqs = []
	read_this_seq = false
	fasta_lines.each do |l|
		if l[0] == ">"
			#if l.match(/>(\d+) dna:chromosome/)
			if l.match(/>(.+) dna:/)
				read_this_seq = true
				#fasta_ids << $1.to_i
				fasta_ids << $1
				fasta_seqs << ""
			else
				read_this_seq = false
			end
		elsif l.strip != "" and read_this_seq
			fasta_seqs.last << l.strip
		end
	end
	puts " done."
	STDOUT.flush

	# Analyze the biomart table.
	print "Analyzing the biomart table..."
	STDOUT.flush
	genes = []
	gene_id = ""
	transcript_id = ""
	biomart_table.each do |l|
		last_gene_id = gene_id
		last_transcript_id = transcript_id
		row_ary = l.split
		gene_id = row_ary[0]
		transcript_id = row_ary[1]
		# chromosome = row_ary[2].to_i
		chromosome = row_ary[2]
		# if chromosome > 0
		transcript_start = row_ary[3].to_i
		transcript_end = row_ary[4].to_i
		strand = row_ary[5].to_i
		exon_id = row_ary[6]
		exon_start = row_ary[7].to_i
		exon_end = row_ary[8].to_i
		start_phase = row_ary[9].to_i
		end_phase = row_ary[10].to_i
		exon = Exon.new(exon_id)
		exon.add_start(exon_start)
		exon.add_end(exon_end)
		exon.add_start_phase(start_phase)
		exon.add_end_phase(end_phase)
		if transcript_id != last_transcript_id
			transcript = Transcript.new(transcript_id)
			transcript.add_start(transcript_start)
			transcript.add_end(transcript_end)
			transcript.add_strand(strand)
			transcript.add_exon(exon)
			if gene_id != last_gene_id
				gene = Gene.new(gene_id)
				gene.add_chromosome(chromosome)
				genes << gene
			end
			genes.last.add_transcript(transcript)
		else
			genes.last.transcripts.last.add_exon(exon)
		end
		# end
	end
	puts " done."
	STDOUT.flush

	# Sort all exons per transcript.
	print "Sorting exons for each transcript..."
	STDOUT.flush
	genes.each do |g|
		g.transcripts.each do |t|
			t.sort_exons
		end
	end
	puts " done."
	STDOUT.flush

	# Select exons that pass filters 1, 2, and 3, as well as their transcripts and genes.
	print "Selecting exons of genes with at least #{minimum_number_of_usable_exons_per_gene} exons, with a minimum length of #{minimum_exon_length_in_nucleotides} bp for further analysis..."
	STDOUT.flush
	selected_exons = 0
	genes.each do |g|
		long_exons = g.longest_transcript.long_exons(minimum_exon_length_in_nucleotides)
		if long_exons.size >= minimum_number_of_usable_exons_per_gene
			long_exons.each do |e|
				unless e.start_phase == -1 and e.end_phase == -1 # -1 stands for UTRs.
					e.select
					selected_exons += 1
				end
			end
		end
	end

	# Report number of genes still selected.
	selected_genes = 0
	genes.each do |g|
		selected_genes += 1 if g.selected(minimum_number_of_usable_exons_per_gene)
	end
	puts " done."
	puts "  --> #{selected_exons} exons of #{selected_genes} genes remain after basic filters for exon length and number of exons per gene."
	STDOUT.flush

	# Add the sequence to each exon, trim it by removing partial codons and UTR regions at the beginning and end,
	# and add the translation to each exon. Deselect exons if the translation contains stop codons before the
	# last codon.
	print "Collecting the sequence of each selected exon from the reference genome..."
	STDOUT.flush
	n_exons_deselected_because_stop_codon = 0
	n_exons_deselected_because_too_short = 0
	genes.each do |g|
		# next unless g.id == "ENSORLG00015001833" # XXX Remove again.
		if g.selected(minimum_number_of_usable_exons_per_gene)
			if fasta_ids.include?(g.chromosome)
				chromosome_index = fasta_ids.index(g.chromosome)
			else
				puts "ERROR: Chromosome ID #{g.chromosome} could not be found among the fasta IDs."
				exit(1)
			end
			g.transcripts.each do |t|
				if t.selected(minimum_number_of_usable_exons_per_gene)
					t.exons.each do |e|
						if e.selected
							if t.strand == 1
								exon_seq = fasta_seqs[chromosome_index][e.start-1..e.end-1].upcase
							elsif t.strand == -1
								exon_seq = fasta_seqs[chromosome_index][e.start-1..e.end-1].upcase.reverse_complement
							else
								puts "ERROR: Unexpected transcript strand!"
								exit 1
							end
							n_sites_to_trim_from_start = 0 if e.start_phase == 0
							n_sites_to_trim_from_start = 2 if e.start_phase == 1
							n_sites_to_trim_from_start = 1 if e.start_phase == 2
							n_sites_to_trim_from_start = -1 if e.start_phase == -1
							n_sites_to_trim_from_end = 0 if e.end_phase == 0
							n_sites_to_trim_from_end = 1 if e.end_phase == 1
							n_sites_to_trim_from_end = 2 if e.end_phase == 2
							n_sites_to_trim_from_end = -1 if e.end_phase == -1
							if n_sites_to_trim_from_start != -1 and n_sites_to_trim_from_end != -1
								exon_seq = exon_seq[n_sites_to_trim_from_start..(-1-n_sites_to_trim_from_end)]
							elsif n_sites_to_trim_from_start != -1 and n_sites_to_trim_from_end == -1
								exon_seq = exon_seq[n_sites_to_trim_from_start..-1]
								exon_seq = exon_seq[0..((exon_seq.size/3)*3)-1]
								trimmed_exon_seq = ""
								stop_codon_found = false
								(exon_seq.size/3).times do |z|
									if ["TAA","TAG","TGA"].include?(exon_seq[(3*z)..(3*z)+2])
										stop_codon_found = true
									elsif stop_codon_found == false
										trimmed_exon_seq << exon_seq[(3*z)..(3*z)+2]
									end
								end
								exon_seq = trimmed_exon_seq
							elsif n_sites_to_trim_from_start == -1 and n_sites_to_trim_from_end != -1
								exon_seq = exon_seq[0..(-1-n_sites_to_trim_from_end)]
								exon_seq = exon_seq[exon_seq.size-((exon_seq.size/3)*3)..-1]
								trimmed_exon_seq = ""
								(exon_seq.size/3).times do |z|
									if exon_seq[(3*z)..(3*z)+2] == "ATG"
										trimmed_exon_seq = exon_seq[(3*z)..(3*z)+2]
									else
										trimmed_exon_seq << exon_seq[(3*z)..(3*z)+2]
									end
								end
								exon_seq = trimmed_exon_seq
							else
								puts "ERROR: Unexpectedly found exon sequence with both start and end phase -1!"
								exit 1
							end

							if exon_seq.size != (exon_seq.size/3)*3
								puts "ERROR: After trimming, the exon sequence length is not a multiple of three!"
								puts "Exon sequence: #{exon_seq}"
								exit 1
							end
							e.add_seq(exon_seq)
							e.translate
							if e.translation[0..-2].include?("*") or e.translation.size < minimum_exon_length_in_nucleotides/3
								e.deselect
								if e.translation[0..-2].include?("*")
									n_exons_deselected_because_stop_codon += 1

									# puts
									# puts "======================="
									# puts "Debugging:"
									# puts
									# puts "e.id:"
									# puts e.id
									# puts
									# puts "exon_seq:"
									# puts exon_seq
									# puts
									# puts "n_sites_to_trim_from_start:"
									# puts n_sites_to_trim_from_start
									# puts
									# puts "n_sites_to_trim_from_end:"
									# puts n_sites_to_trim_from_end
									# puts
									# exit
								else
									n_exons_deselected_because_too_short += 1
								end
							end
						end
					end
				end
			end
		end
	end

	# Report number of genes still selected.
	selected_genes = 0
	genes.each do |g|
		# next unless g.id == "ENSORLG00015001833" # XXX Remove again.
		selected_genes += 1 if g.selected(minimum_number_of_usable_exons_per_gene)
	end
	puts " done."
	puts "  --> #{n_exons_deselected_because_stop_codon} exons were removed due to stop codons."
	puts "      #{n_exons_deselected_because_too_short} exons were removed because their translation had less than 50 amino acids."
	puts "      #{selected_exons-n_exons_deselected_because_stop_codon-n_exons_deselected_because_too_short} exons of #{selected_genes} genes remain, these genes will be used for gene tree comparisons."
	STDOUT.flush

	# Read the ENSEMBL gene trees file to memory.
	print "Reading the ENSEMBL gene tree file..."
	STDOUT.flush
	gene_tree_file = File.open(gene_tree_file_name)
	gene_trees = []
	previous_line = ""
	while line = gene_tree_file.gets do
		if previous_line[0..3] == "DATA"
			gene_trees << line
		end
		previous_line = line
	end
	puts " done."
	STDOUT.flush

	# For each selected gene, check the gene tree.
	print "Checking for gene id presence in gene trees..."
	STDOUT.flush
	genes.each do |g|
		# next unless g.id == "ENSORLG00015001833" # XXX Remove again.
		if g.selected(minimum_number_of_usable_exons_per_gene)
			gene_trees.each do |gt|
				if gt.include?(g.id)
					g.add_gene_tree(gt)
				end
			end
		end
	end
	puts " done."
	STDOUT.flush

	# Deselect exons of genes without gene trees.
	print "Deselecting exons of genes without gene trees..."
	STDOUT.flush
	n_selected_genes_before = 0
	genes.each do |g|
		# next unless g.id == "ENSORLG00015001833" # XXX Remove again.
		n_selected_genes_before += 1 if g.selected(minimum_number_of_usable_exons_per_gene)
	end
	n_exons_deselected_because_no_gene_tree = 0
	genes.each do |g|
		# next unless g.id == "ENSORLG00015001833" # XXX Remove again.
		if g.gene_tree == nil
			g.transcripts.each do |t|
				t.exons.each do |e|
					if e.selected
						e.deselect
						n_exons_deselected_because_no_gene_tree += 1
					end
				end
			end
		end
	end
	n_selected_exons_after = 0
	n_selected_genes_after = 0
	genes.each do |g|
		# next unless g.id == "ENSORLG00015001833" # XXX Remove again.
		if g.selected(minimum_number_of_usable_exons_per_gene)
			n_selected_genes_after += 1
			g.transcripts.each do |t|
				if t.selected(minimum_number_of_usable_exons_per_gene)
					t.exons.each do |e|
						n_selected_exons_after += 1 if e.selected
					end
				end
			end
		end
	end
	puts " done. #{n_exons_deselected_because_no_gene_tree} exons and #{n_selected_genes_before-n_selected_genes_after} genes were removed because no gene tree could be found. #{n_selected_exons_after} exons of #{n_selected_genes_after} genes remain for further analysis."
	STDOUT.flush

	# Check whether the gene tree for each gene conforms to expectations.
	print "Checking gene trees and collecting ortholog ids..."
	STDOUT.flush
	count = 1
	n_genes_deselected_because_too_few_orthologs = 0
	n_genes_deselected_because_duplication = 0
	genes.each do |g|
		# next unless g.id == "ENSORLG00015001833" # XXX Remove again.
		print "\rChecking gene trees and collecting ortholog ids (gene #{count}/#{genes.size}; #{g.id})..."
		STDOUT.flush
		count += 1
		use_gene = false
		use_gene = true if g.selected(minimum_number_of_usable_exons_per_gene)
		if use_gene
			gene_id_length = g.id.length
			pos = nil
			g.gene_tree.size.times do |x|
				if g.id == g.gene_tree[x..x+gene_id_length-1]
					pos = x
					break
				end
			end
			if pos == nil
				puts "ERROR: Position of first character of gene id cound not be found in gene tree string!"
				exit
			end
			# Find the largest tree substring that contains only ingroup taxa.
			forwards_pos_addition = pos + gene_id_length - 1
			backwards_pos_addition = pos
			tree_substring = g.gene_tree[backwards_pos_addition..forwards_pos_addition]
			tree_substring_contains_only_refgroup = true
			tree_substring_contains_only_refgroup_and_ingroup = true
			refgroup_tree_substring = nil
			refgroup_and_ingroup_tree_substring = nil
			group_level = 0
			num_closing_parentheses = 0
			num_opening_parentheses = 0
			while tree_substring_contains_only_refgroup_and_ingroup and tree_substring.size < g.gene_tree.size

				# Increase the length of the substring.
				group_level += 1
				# forwards_pos_addition = pos + gene_id_length - 1 # No need to set it back to the initial position.
				until num_closing_parentheses == group_level or forwards_pos_addition > g.gene_tree.size
					forwards_pos_addition += 1
					if g.gene_tree[forwards_pos_addition] == ")"
						num_closing_parentheses += 1
					elsif g.gene_tree[forwards_pos_addition] == "("
						num_closing_parentheses -= 1
					end
				end
				# backwards_pos_addition = pos # No need to set it back to the initial position.
				until num_opening_parentheses == group_level or backwards_pos_addition == 0
					backwards_pos_addition -= 1
					if g.gene_tree[backwards_pos_addition] == "("
						num_opening_parentheses += 1
					elsif g.gene_tree[backwards_pos_addition] == ")"
						num_opening_parentheses -= 1
					end
				end
				proposed_tree_substring = g.gene_tree[backwards_pos_addition..forwards_pos_addition]

				# Check if the new proposed substring still contains only reference taxa or only reference or ingroup taxa, and fix the refgroup and
				# refgroup_and_ingroup tree substrings if that's not the case any more.
				taxon_tags.size.times do |x|
					if ["out","in"].include?(taxon_assignments[x]) and proposed_tree_substring.include?(taxon_tags[x]) and tree_substring_contains_only_refgroup
						tree_substring_contains_only_refgroup = false
						refgroup_tree_substring = tree_substring
					elsif taxon_assignments[x] == "out" and proposed_tree_substring.include?(taxon_tags[x]) and tree_substring_contains_only_refgroup_and_ingroup
						tree_substring_contains_only_refgroup_and_ingroup = false
						refgroup_and_ingroup_tree_substring = tree_substring
					end
				end
				tree_substring = proposed_tree_substring

				# If one or both of refgroup and refgroup_and_ingroup tree substrings are empty when the tree substring reaches the full gene tree size,
				# set them to the tree substring.
				if tree_substring.size == g.gene_tree.size
					refgroup_tree_substring = tree_substring if refgroup_tree_substring == nil
					refgroup_and_ingroup_tree_substring = tree_substring if refgroup_and_ingroup_tree_substring == nil
				end

			end

			# Make sure that the refgroup and refgroup_and_ingroup tree substrings are no longer empty.
			if refgroup_tree_substring == nil
				puts "ERROR: The reference group could not be extracted from the gene tree!"
				exit(1)
			end
			if refgroup_and_ingroup_tree_substring == nil
				puts "ERROR: The reference group and ingroup group could not jointly be extracted from the gene tree!"
				exit(1)
			end

			# Get, for each ingroup taxon, all gene IDs in the tree substrings.
			taxon_ortholog_ids_this_gene = []
			taxon_tags.size.times do |x|
				taxon_ortholog_ids_this_gene << []
			end
			taxon_tags.size.times do |x|
				if taxon_assignments[x] == "in"
					matches = refgroup_and_ingroup_tree_substring.scan(/#{taxon_tags[x]}\d+\:[\d\.]*\[.*?G=[A-Z]+G[0-9]+.+?\]/)
					matches.each do |m|
						if m.match(/G=([A-Z]+G[0-9]+)\:/)
							taxon_ortholog_ids_this_gene[x] << $1
						else
							puts "ERROR: Unexpected match #{m}!"
							exit(1)
						end
					end
				end
			end

			# Reduce the number of gene IDs to that allowed per taxon (according to the third column in the taxon assignment file).
			# Due to duplications, more than the allowed number might be found. If so, those additional gene IDs are arbitrarily deleted. This means that these IDs
			# will not be registered as ortholog, and may therefore cause a high "incorrect bitscore" later on. The result might be that the gene is not used in the
			# end, which is justified if duplications occurred in the focal taxa.
			taxon_tags.size.times do |x|
				if taxon_assignments[x] == "in"
					taxon_ortholog_ids_this_gene[x] = taxon_ortholog_ids_this_gene[x][0..taxon_counts[x]-1]
				end
			end

			# Search for monophyletic single-taxon duplications in the ingroup. If any are found, arbitrarily remove the second occurrence of the taxon. Gene IDs have already
			# been stored (see above).
			check_for_duplications = true
			while check_for_duplications
				check_for_duplications = false
				taxon_tags.size.times do |x|
					if taxon_assignments[x] == "in"
						if refgroup_and_ingroup_tree_substring.match(/\((#{taxon_tags[x]}\d+\:[\d\.]*\[.+?\]),(#{taxon_tags[x]}\d+\:[\d\.]*\[.+?\])\)\:([\d\.]*\[.+?\])/)
							check_for_duplications = true
							taxon1_str = $1
							taxon2_str = $2
							node_annotation = $3
							search_str = "(#{taxon1_str},#{taxon2_str}):#{node_annotation}"
							replace_str = "#{taxon1_str}"
							refgroup_and_ingroup_tree_substring.sub!(search_str,replace_str)
						end
					end
				end
			end

			# Make sure that after removing of monophyletic single-taxon duplications, no taxa are found more than once in the refgroup_and_ingroup tree substring.
			taxon_tags.size.times do |x|
				if taxon_assignments[x] == "in"
					if refgroup_and_ingroup_tree_substring.scan(taxon_tags[x]).size > 1 # Not using taxon_ortholog_ids_this_gene[x] because we need the number of non-monophyletic duplications.
						n_genes_deselected_because_duplication += 1
						use_gene = false
						break
					end
				end
			end
		end

		# Check if no more than the allowed number of orthologs are missing.
		if use_gene
			n_orthologs_missing = 0
			taxon_tags.size.times do |x|
				if taxon_assignments[x] == "in"
					n_orthologs_missing += 1 if taxon_ortholog_ids_this_gene[x] == []
				end
			end
			if n_orthologs_missing > n_orthologs_allowed_missing
				use_gene = false
				n_genes_deselected_because_too_few_orthologs += 1
			end
		end

		# Store ortholog IDs in the gene object if the gene should still be used.
		if use_gene
			taxon_tags.size.times do |x|
				taxon_ortholog_ids_this_gene[x].each { |i| g.add_ortholog_id(i) }
			end
		end

		# Deselect all transcripts of the gene unless it is still used.
		unless use_gene
			g.transcripts.each do |t|
				t.exons.each do |e|
					e.deselect
				end
			end
		end
	end
	n_selected_exons_after = 0
	n_selected_genes_after = 0
	genes.each do |g|
		if g.selected(minimum_number_of_usable_exons_per_gene)
			n_selected_genes_after += 1
			g.transcripts.each do |t|
				if t.selected(minimum_number_of_usable_exons_per_gene)
					t.exons.each do |e|
						n_selected_exons_after += 1 if e.selected
					end
				end
			end
		end
	end
	puts "\rChecking gene trees and collecting ortholog ids... done.                                          "
	puts "  --> #{n_selected_exons_after} exons of #{n_selected_genes_after} genes remain for further analysis."
	puts "      #{n_genes_deselected_because_too_few_orthologs} genes were deselected because too few orthologs were found in tree string."
	puts "      #{n_genes_deselected_because_duplication} genes were deselected because of duplications in tree string."
	STDOUT.flush

	# Get the worst tblastn score for each selected exon.
	print "Running tblastn to determine the worst score for each exon..."
	STDOUT.flush
	count = 0
	genes.each do |g|
		if g.selected(minimum_number_of_usable_exons_per_gene)
			g.transcripts.each do |t|
				if t.selected(minimum_number_of_usable_exons_per_gene)
					t.exons.each do |e|
						if e.selected
							count += 1
							print "\rRunning tblastn to determine the worst score for each exon (exon #{count}/#{n_selected_exons_after}; #{e.id})..."
							# Write a query file with the amino acid sequence of
							# the current exon.
							query_file = File.new(query_file_name,"w")
							# Make sure the exon translation is not empty.
							if e.translation == nil
								puts "ERROR: Exon sequence translation is nil!"
								exit(1)
							elsif e.translation.strip == ""
								puts "ERROR: Exon sequence translation is empty!"
								exit(1)
							end
							query_file.write(">query\n#{e.translation}\n")
							query_file.close
							orthologs = []
							correct_bitscores = []
							correct_seqs = []
							incorrect_bitscores = []
							# For each database, run tblastn searches.
							subject_databases.size.times do |x|
								db = subject_databases[x]
								hits_string = `tblastn -db #{subject_database_path}/#{db} -num_threads 10 -query #{query_file_name} -outfmt '6 stitle sseq bitscore' | head -n 20`

								# Analyze the TBLASTN hits.
								hits = hits_string.split("\n")
								correct_bitscores_for_this_subject = []
								correct_seqs_for_this_subject = []
								incorrect_bitscores_for_this_subject = []
								stitles = []
								subj_scfs = []
								subj_starts = []
								subj_ends = []
								sseqs = []
								bitscores = []
								ortholog_flags = []
								hits.each do |h|
									if h.split("\t").size == 3
										stitle = h.split("\t")[0]
										scoords = stitle.split(" ")[2]
										scoords_ary = scoords.split(":")
										if scoords_ary.size == 6
											subj_scf = scoords_ary[2]
											subj_start = scoords_ary[3].to_i
											subj_end = scoords_ary[4].to_i
											subj_start, subj_end = subj_end, subj_start if subj_start > subj_end
											sseq = h.split("\t")[1]
											bitscore = h.split("\t")[2].to_f
											ortholog_flag = false
											g.ortholog_ids.each do |i|
												ortholog_flag = true if stitle.match(i)
											end
											stitles << stitle
											subj_scfs << subj_scf
											subj_starts << subj_start
											subj_ends << subj_end
											sseqs << sseq
											bitscores << bitscore
											ortholog_flags << ortholog_flag
										else
											puts "WARNING: Unexpected format of TBLASTN result string: #{h}. Element #{scoords} includes #{scoords_ary.size} subelements."
										end
									else
										puts "WARNING: Unexpected format of TBLASTN result string: #{h}. It does not contain three elements separated by tabs."
									end
								end

								# Remove hits overlapping with other hits.
								0.upto(stitles.size-2) do |y|
									(y+1).upto(stitles.size-1) do |z|
										if stitles[y] != nil and stitles[z] != nil
											if subj_scfs[y] == subj_scfs[z]
												overlap = false
												overlap = true if subj_starts[y] >= subj_starts[z] and subj_starts[y] <= subj_ends[z]
												overlap = true if subj_starts[z] >= subj_starts[y] and subj_starts[z] <= subj_ends[y]
												overlap = true if subj_ends[y] >= subj_starts[z] and subj_ends[y] <= subj_ends[z]
												overlap = true if subj_ends[z] >= subj_starts[y] and subj_ends[z] <= subj_ends[y]
												if overlap
													if ortholog_flags[y] == false
														stitles[y] = nil
														subj_scfs[y] = nil
														subj_starts[y] = nil
														subj_ends[y] = nil
														sseqs[y] = nil
														bitscores[y] = nil
														ortholog_flags[y] = nil
													elsif ortholog_flags[z] == false
														stitles[z] = nil
														subj_scfs[z] = nil
														subj_starts[z] = nil
														subj_ends[z] = nil
														sseqs[z] = nil
														bitscores[z] = nil
														ortholog_flags[z] = nil
													end
												end
											end
										end
									end
								end
								stitles.compact!
								subj_scfs.compact!
								subj_starts.compact!
								subj_ends.compact!
								sseqs.compact!
								bitscores.compact!
								ortholog_flags.compact!

								# Store correct and incorrect bitscores, and sequences for correct bitscores.
								stitles.size.times do |y|
									if ortholog_flags[y] == true
										correct_bitscores_for_this_subject << bitscores[y]
										correct_seqs_for_this_subject << sseqs[y]
									else
										incorrect_bitscores_for_this_subject << bitscores[y]
									end
								end
								if correct_bitscores_for_this_subject == []
									correct_bitscores << 0
									correct_seqs << ""
								else
									correct_bitscores_for_this_subject.size.times do |z|
										if correct_bitscores_for_this_subject[z] == correct_bitscores_for_this_subject.max
											correct_bitscores << correct_bitscores_for_this_subject[z]
											correct_seqs << correct_seqs_for_this_subject[z]
											break
										end
									end
								end
								if incorrect_bitscores_for_this_subject == []
									incorrect_bitscores << 0
								else
									incorrect_bitscores << incorrect_bitscores_for_this_subject.max
								end
								orthologs << g.ortholog_ids[x]
							end
							e.add_correct_bitscores(correct_bitscores)
							e.add_correct_seqs(correct_seqs)
							e.add_incorrect_bitscores(incorrect_bitscores)
						end
					end
				end
			end
		end
	end
	puts "\rRunning tblastn to determine the worst score for each exon... done.                                                    "

	# Write the genes to a dump file.
	print "Writing dump file..."
	STDOUT.flush
	dump_file = File.open(dump_file_name,"w")
	dump_file.write(Marshal.dump(genes))
	puts " done."
	STDOUT.flush

end

# Deselect exons according to blast bitscores.
print "Deselecting exons according to blast bitscores..."
STDOUT.flush
n_selected_exons_before = 0
n_selected_genes_before = 0
genes.each do |g|
	if g.selected(minimum_number_of_usable_exons_per_gene)
		n_selected_genes_before += 1
		g.transcripts.each do |t|
			if t.selected(minimum_number_of_usable_exons_per_gene)
				t.exons.each do |e|
					n_selected_exons_before += 1 if e.selected
				end
			end
		end
	end
end
xcount = 0
genes.each do |g|
	if g.selected(minimum_number_of_usable_exons_per_gene)
		g.transcripts.each do |t|
			if t.selected(minimum_number_of_usable_exons_per_gene)
				t.exons.each do |e|
					if e.selected
						n_orthologs = 0
						e.correct_bitscores.each do |bs|
							if bs >= minimum_bitscore_difference_for_orthologs + e.incorrect_bitscores.max # = ortholog_bitscore_ratio_threshold * e.incorrect_bitscores.max
								if bs > ortholog_minimum_bitscore
									n_orthologs += 1
								end
							end
						end
						if n_orthologs < subject_databases.size - n_orthologs_allowed_missing
							e.deselect
						end
					end
				end
			end
		end
	end
end
n_selected_exons_after = 0
n_selected_genes_after = 0
genes.each do |g|
	if g.selected(minimum_number_of_usable_exons_per_gene)
		n_selected_genes_after += 1
		g.transcripts.each do |t|
			if t.selected(minimum_number_of_usable_exons_per_gene)
				t.exons.each do |e|
					n_selected_exons_after += 1 if e.selected
				end
			end
		end
	end
end
puts " done."
puts "  --> Removed #{n_selected_genes_before-n_selected_genes_after} genes and #{n_selected_exons_before-n_selected_exons_after} exons due to low blast bitscores."
puts "      The final dataset contains #{n_selected_exons_after} exons of #{n_selected_genes_after} genes."
STDOUT.flush

# Prepare the output table and fasta string.
print "Preparing output strings..."
STDOUT.flush
gene_count = 0
transcript_count = 0
exon_count = 0
gene_table_string = "gene_id\ttranscript_id\tn_exons\tn_orthologs\tortholog_ids\n"
exon_table_string = "exon_id\tgene_id\ttranscript_id\ttranslation\tlength\tthreshold_bitscore\tcorrect_bitscores\tincorrect_bitscores\tmin(correct_bitscores)-max(incorrect_bitscores)\n"
exon_fasta_string = ""
genes.each do |g|
	if g.selected(minimum_number_of_usable_exons_per_gene)
		exon_count_for_this_gene = 0
		gene_count += 1
		g.transcripts.each do |t|
			if t.selected(minimum_number_of_usable_exons_per_gene)
				transcript_count += 1
				t.exons.each do |e|
					if e.selected
						exon_count_for_this_gene += 1
						ortholog_threshold_bitscore = [(minimum_bitscore_difference_for_orthologs + e.incorrect_bitscores.max),ortholog_minimum_bitscore].max.round(2) # [(ortholog_bitscore_ratio_threshold * e.incorrect_bitscores.max),ortholog_minimum_bitscore].max.round(2)
						exon_table_string << "#{e.id}\t#{g.id}\t#{t.id}\t#{e.translation[0..9]}..#{e.translation[-10..-1]}\t#{e.length}\t#{ortholog_threshold_bitscore}\t["
						e.correct_bitscores.each do |bs|
							exon_table_string << "#{bs},"
						end
						exon_table_string.chomp!(",")
						exon_table_string << "]\t["
						e.incorrect_bitscores.each do |bs|
							exon_table_string << "#{bs},"
						end
						exon_table_string.chomp!(",")
						exon_table_string << "]\t#{(e.correct_bitscores.min-e.incorrect_bitscores.max).round(1)}\n"
						exon_fasta_string << ">#{e.id}[&bitscore=#{ortholog_threshold_bitscore}]\n#{e.translation}\n\n"
						exon_count += 1
					end
				end
			end
		end
		gene_table_string << "#{g.id}\t#{g.transcripts[0].id}\t#{exon_count_for_this_gene}\t#{g.ortholog_ids.size}\t["
		g.ortholog_ids.each do |o|
			gene_table_string << "#{o},"
		end
		gene_table_string.chomp!(",")
		gene_table_string << "]\n"
	end
end
puts " done."
puts "  --> #{gene_count} genes, #{transcript_count} transcripts, and #{exon_count} exons remain after filtering."
STDOUT.flush

# Write the gene output table.
gene_table_file = File.open(gene_table_file_name,"w")
gene_table_file.write(gene_table_string)
puts "Wrote file #{gene_table_file_name}."
STDOUT.flush

# Write the exon output table.
exon_table_file = File.open(exon_table_file_name,"w")
exon_table_file.write(exon_table_string)
puts "Wrote file #{exon_table_file_name}."
STDOUT.flush

# Write the exon output fasta file.
exon_fasta_file = File.open(exon_fasta_file_name,"w")
exon_fasta_file.write(exon_fasta_string)
puts "Wrote file #{exon_fasta_file_name}."
STDOUT.flush

# Clean up.
if File.exists?(query_file_name)
	File.delete(query_file_name)
end
