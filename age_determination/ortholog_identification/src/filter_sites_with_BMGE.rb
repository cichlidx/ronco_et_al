# m_matschiner Sun Mar 19 12:44:05 CET 2017

# Get the command line arguments.
bmge_relative_path = ARGV[0]
alignment_directory_in = ARGV[1].chomp("/")
alignment_directory_out = ARGV[2].chomp("/")
gap_rate_cut_off = ARGV[3].to_f
entropy_like_score_cut_off = ARGV[4].to_f

# Create the output directory if it does not exist yet.
unless Dir.exists?(alignment_directory_out)
	Dir.mkdir(alignment_directory_out)
end

# Collect names of nucleotide fasta files in the input directory.
mitochondrial_marker_ids = ["ATP6","ATP8","COX1","COX2","COX3","CYTB","ND1","ND2","ND3","ND4","ND4L","ND5"]
dir_entries_in = Dir.entries(alignment_directory_in)
filenames_in = []
dir_entries_in.each do |e|
	if e.match(/.*_nucl.fasta/) or mitochondrial_marker_ids.include?(e.chomp(".fasta"))
		filenames_in << e
	end
end

# Do for each fasta file in the input directory.
count = 0
filenames_in.each do |f|

	# Feedback.
	count += 1
	print "\rAnalysing file #{f} (#{count}/#{filenames_in.size})..."

	# Read the fasta file.
	fasta_file = File.open("#{alignment_directory_in}/#{f}")
	fasta_lines = fasta_file.readlines
	fasta_ids = []
	fasta_seqs = []
	fasta_lines.each do |l|
		if l[0] == ">"
			fasta_ids << l[1..-1].strip
			fasta_seqs << ""
		else
			fasta_seqs.last << l.strip
		end
	end

	# Run BMGE.
	system("java -jar #{bmge_relative_path} -i #{alignment_directory_in}/#{f} -t DNA -g 0.99 -oh tmp.html > /dev/null")
	
	# Read the BMGE HTML file, and then delete it.
	html_file = File.open("tmp.html")
	html_lines = html_file.readlines
	File.delete("tmp.html")

	# Parse the HTML file.
	smoothed_entropies = []
	gap_rates = []
	in_table = false
	html_lines.each do |l|
		if l.match(/ch\.\s+entropy\s+smooth\. entr.\s+gap rate/)
			in_table = true
		elsif l.match(/<\/span>/)
			in_table = false
		elsif in_table
			smoothed_entropies << l.split[2].to_f
			gap_rates << l.split[3].to_f
		end
	end

	# Make sure that entropy scores and gap rates are found for each site.
	if fasta_seqs[0].size != smoothed_entropies.size or fasta_seqs[0].size != gap_rates.size
		raise "Alignment scores were not found for all positions!"
	end
	
	# Determine the sites to be discarded.
	discarded_sites = []
	(fasta_seqs[0].size/3).times do |codon_pos|
		keep_codon = true
		if smoothed_entropies[3*codon_pos] > entropy_like_score_cut_off or gap_rates[3*codon_pos] > gap_rate_cut_off
			keep_codon = false
		elsif smoothed_entropies[3*codon_pos+1] > entropy_like_score_cut_off or gap_rates[3*codon_pos+1] > gap_rate_cut_off
			keep_codon = false
		elsif smoothed_entropies[3*codon_pos+2] > entropy_like_score_cut_off or gap_rates[3*codon_pos+2] > gap_rate_cut_off
			keep_codon = false
		end
		if keep_codon == false
			discarded_sites << 3*codon_pos
			discarded_sites << 3*codon_pos+1
			discarded_sites << 3*codon_pos+2
		end
	end
	
	# Prepare the string for a new fasta file.
	new_fasta_string = ""
	fasta_ids.size.times do |x|
		new_fasta_string << ">#{fasta_ids[x]}\n"
		fasta_seqs[x].size.times do |pos|
			unless discarded_sites.include?(pos)
				new_fasta_string << fasta_seqs[x][pos]
			end
		end
		new_fasta_string << "\n"
	end

	# Write the corrected fasta file.
	new_fasta_file = File.open("#{alignment_directory_out}/#{f}","w")
	new_fasta_file.write(new_fasta_string)

end

# Feedback.
puts " done."
