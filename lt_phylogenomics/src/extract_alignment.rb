# m_matschiner Wed Jul 18 13:51:55 CEST 2018

# Get the command-line arguments.
vcf_file_name = ARGV[0] # The vcf file reduced to the region.
region_string = ARGV[1] # A string such as NC_031965:1000-2000.
masked_reference_file_name = ARGV[2] # The masked reference reduced to the single chromosome of the region.
unmasked_reference_file_name = ARGV[3] # The unmasked reference reduced to the single chromosome of the region.
alleles_option = ARGV[4] # An option to specify whether the first, the second, or both alleles of each sample should be used
alignment_file_name = ARGV[5]

# Read the alleles option.
unless ["1", "2", "both"].include?(alleles_option)
	puts "ERROR: The alleles option (fifth argument) should be either '1', '2', or 'both'!"
	exit 1
end

# Open the vcf file.
vcf_file = File.open(vcf_file_name)
vcf_lines = vcf_file.readlines

# Get the sample IDs from the vcf file.
vcf_header_line = nil
vcf_lines.each do |l|
	if l[0] == "#"
		vcf_header_line = l
	else
		break
	end
end
sample_ids_unphased = vcf_header_line.split[9..-1]
sample_ids_phased = []
sample_ids_unphased.each do |s|
	if alleles_option == "both"
		sample_ids_phased << "#{s}_1"
		sample_ids_phased << "#{s}_2"
	else
		sample_ids_phased << "#{s}"
	end
end

# Analyze the regions string.
if region_string.match(/(.+?):(\d+?)-(\d+?)$/)
	chromsome_id = $1
	from = $2.to_i # 1-based.
	to = $3.to_i # 1-based.
else
	puts "ERROR: Regions string \"#{region_string}\" could not be interpreted!"
	exit 1
end

# Read the masked reference.
masked_reference_file = File.open(masked_reference_file_name)
masked_reference_lines = masked_reference_file.readlines
if masked_reference_lines.size != 2
	puts "ERROR: Expected the masked reference file to contain exactly two lines but found #{masked_reference_lines.size} lines!"
	exit 1
end
if masked_reference_lines[0].strip != ">#{chromsome_id}"
	puts "ERROR: Expected the reference file to contain only the sequence for chromsome #{chromsome_id} but the first sequence ID is #{masked_reference_lines[0].strip[1..-1]}!"
	exit 1
end
masked_reference_seq = masked_reference_lines[1].strip
trimmed_masked_reference_seq = masked_reference_seq[from-1..to-1].upcase

# Read the unmasked reference.
unmasked_reference_file = File.open(unmasked_reference_file_name)
unmasked_reference_lines = unmasked_reference_file.readlines
if unmasked_reference_lines.size != 2
	puts "ERROR: Expected the unmasked reference file to contain exactly two lines but found #{unmasked_reference_lines.size} lines!"
	exit 1
end
if unmasked_reference_lines[0].strip != ">#{chromsome_id}"
	puts "ERROR: Expected the reference file to contain only the sequence for chromsome #{chromsome_id} but the first sequence ID is #{unmasked_reference_lines[0].strip[1..-1]}!"
	exit 1
end
unmasked_reference_seq = unmasked_reference_lines[1].strip
trimmed_unmasked_reference_seq = unmasked_reference_seq[from-1..to-1].upcase

# Prepare an alignment.
seqs = []
sample_ids_phased.size.times do |x|
	seq_as_ary = []
	trimmed_masked_reference_seq.size.times do |pos|
		seq_as_ary << trimmed_masked_reference_seq[pos]
	end
	seqs << seq_as_ary
end

# Add variant information to the alignment.
vcf_lines.each do |l|
	if l[0] != "#"
		line_ary = l.split
		vcf_pos = line_ary[1].to_i
		if line_ary[0] != chromsome_id or vcf_pos < from or vcf_pos > to
			puts "ERROR: Expected the vcf to contain only variants within the specified region \"#{region}\", but found a variant on chromosome #{chromsome_id} at position #{line_ary[1]}!"
			exit 1
		end
		alleles = [line_ary[3]]
		line_ary[4].split(",").each { |i| alleles << i }
		sample_ids_unphased.size.times do |x|
			gts = line_ary[x+9].split("|").map do |i|
				if i == "."
					"N"
				else
					alleles[i.to_i]
				end
			end
			if alleles_option == "both"
				seqs[2*x][vcf_pos-from] = gts[0]
				seqs[(2*x)+1][vcf_pos-from] = gts[1]
			elsif alleles_option == "1"
				seqs[x][vcf_pos-from] = gts[0]
			elsif alleles_option == "2"
				seqs[x][vcf_pos-from] = gts[1]
			else
				puts "ERROR: Unexpected value for variable 'alleles_option'!"
				exit 1
			end
		end
	end
end

# Apply the callability mask.
sample_ids_unphased.size.times do |x|
	sample_id = sample_ids_unphased[x].chomp("_1").chomp("_2") # This works regardless of whether the ID has these suffixes.
	if Dir.entries(".").include?("#{sample_id}.bed")

		# Read the bed file if there is one.
		bed_lines = File.open("#{sample_id}.bed").readlines
		masked_chromosome_ids = []
		masked_froms = []
		masked_tos = []
		bed_lines.each do |l|
			line_ary = l.split
			masked_chromosome_ids << line_ary[0]
			masked_from = line_ary[1].to_i
			if masked_from < from
				masked_froms << from
			else
				masked_froms << masked_from
			end
			masked_to = line_ary[2].to_i
			if masked_to > to
				masked_tos << to
			else
				masked_tos << line_ary[2].to_i
			end
		end

		# Mask sites in the corresponding sequence according to the callability mask.
		masked_froms.size.times do |z|
			masked_froms[z].upto(masked_tos[z]) do |vcf_pos|
				seqs[x][vcf_pos-from] = "N"
			end
		end

	end
end

# Get the longest sample name.
max_sample_id_length = 0
sample_ids_phased.each { |i| max_sample_id_length = i.size if i.size > max_sample_id_length }
max_sample_id_length = region_string.size if region_string.size > max_sample_id_length

# Prepare the alignment string.
alignment_string = "#{sample_ids_phased.size + 1} #{trimmed_masked_reference_seq.size}\n"
alignment_string << "#{region_string.gsub(":","_").gsub("-","_").ljust(max_sample_id_length+2)}"
alignment_string << "#{trimmed_unmasked_reference_seq}\n"
sample_ids_phased.size.times do |x|
	alignment_string << "#{sample_ids_phased[x].ljust(max_sample_id_length+2)}"
	seqs[x].size.times do |pos|
		alignment_string << "#{seqs[x][pos]}"
	end
	alignment_string << "\n"
end

# Write the alignment file.
alignment_file = File.open(alignment_file_name, "w")
alignment_file.write(alignment_string)
