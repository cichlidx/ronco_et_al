#!/usr/bin/env ruby

# Michael Matschiner, 2018-05-21
#
# This script prepares XML format input files for the software SNAPP (http://beast2.org/snapp/),
# given a phylip format SNP matrix, a table linking species IDs and specimen IDs, and a file
# specifying age constraints. Optionally, a starting tree can be provided (recommended) and the
# number of MCMC iterations used by SNAPP can be specified. Files prepared by this script use
# a particular combination of priors and operators optimized for SNAPP analyses that aim to
# estimate species divergence times (note that all population sizes are linked in these analyses).
# Detailed annotation explaining the choice of priors and operators will be included in the
# XML file (unless turned off with option '-n').
#
# A manuscript on divergence-time estimation with SNAPP is in preparation.
#
# To learn about the available options of this script, run with '-h' (or without any options):
# ruby snapp_prep.rb -h
#
# For questions and bug fixes, email to michaelmatschiner@mac.com

# Load required libraries.
require 'optparse'

# Feedback.
puts ""
puts "snapp_prep.rb"
puts ""
puts "----------------------------------------------------------------------------------------"
puts ""

# Define default options.
options = {}
options[:phylip] = nil
options[:vcf] = nil
options[:table] = "example.spc.txt"
options[:constraints] = "example.con.txt"
options[:tree] = nil
options[:length] = 500000
options[:weight] = 1.0
options[:max_snps] = nil
options[:transversions] = false
options[:transitions] = false
options[:xml] = "snapp.xml"
options[:out] = "snapp"
options[:no_annotation] = false

# Get the command line options.
ARGV << '-h' if ARGV.empty?
opt_parser = OptionParser.new do |opt|
	opt.banner = "Usage: ruby #{$0} [OPTIONS]"
	opt.separator  ""
	opt.separator  "Example:"
	opt.separator  "ruby #{$0} -p example.phy -t #{options[:table]} -c #{options[:constraints]} -x #{options[:xml]}"
	opt.separator  ""
	opt.separator  "Options:"
	opt.on("-p","--phylip FILENAME","File with SNP data in phylip format (default: none).") {|p| options[:phylip] = p}
	opt.on("-v","--vcf FILENAME","File with SNP data in vcf format (default: none).") {|v| options[:vcf] = v}
	opt.on("-t","--table FILENAME","File with table linking species and specimens (default: #{options[:table]}).") {|t| options[:table] = t}
	opt.on("-c","--constraints FILENAME","File with age constraint information (default: #{options[:constraints]}).") {|c| options[:constraints] = c}
	opt.on("-s","--starting-tree FILENAME","File with starting tree in Nexus or Newick format (default: none).") {|s| options[:tree] = s}
	opt.on("-l","--length LENGTH",Integer,"Number of MCMC generations (default: #{options[:length]}).") {|l| options[:length] = l}
	opt.on("-w","--weight WEIGHT",Float,"Relative weight of topology operator (default: #{options[:weight]}).") {|w| options[:weight] = w}
	opt.on("-m","--max-snps NUMBER",Integer,"Maximum number of SNPs to be used (default: no maximum).") {|m| options[:max_snps] = m}
	opt.on("-r","--transversions","Use transversions only (default: #{options[:transversions]}).") {options[:transversions] = true}
	opt.on("-i","--transitions","Use transitions only (default: #{options[:transitions]}).") {options[:transitions] = true}
	opt.on("-x","--xml FILENAME","Output file in XML format (default: #{options[:xml]}).") {|x| options[:xml] = x}
	opt.on("-o","--out PREFIX","Prefix for SNAPP's .log and .trees output files (default: snapp).") {|i| options[:out] = i}
	opt.on("-n","--no-annotation","Do not add explanatory annotation to XML file (default: #{options[:no_annotation]}).") {options[:no_annotation] = true}
	opt.on("-h","--help","Print this help text.") {
		puts opt_parser
		exit(0)
	}
	opt.separator  ""
end
opt_parser.parse!

# Make sure that input is provided in either phylip or vcf format.
if options[:phylip] == nil and options[:vcf] == nil
	puts "ERROR: An input file must be provided, either in phylip format with option '-p' or in vcf format with option '-v'!"
	exit(1)
elsif options[:phylip] != nil and options[:vcf] != nil
	puts "ERROR: Only one of the two options '-p' and '-v' can be used!"
	exit(1)	
end

# Make sure that the -r and -i options are not used jointly.
if options[:transversions] and options[:transitions]
	puts "ERROR: Only one of the two options '-r' and '-i' can be used!"
	exit(1)
end

# Initiate a warn string and counts for excluded sites.
warn_string = ""
number_of_excluded_sites_missing = 0
number_of_excluded_sites_monomorphic = 0
number_of_excluded_sites_triallelic = 0
number_of_excluded_sites_tetraallelic = 0
number_of_excluded_sites_indel = 0
number_of_excluded_sites_transition = 0
number_of_excluded_sites_transversion = 0
number_of_sites_with_half_call = 0

# Initiate arrays for specimen ids and sequences.
specimen_ids = []
seqs = []

# Define various characters.
binary_chars = ["0","1","2"]
nucleotide_chars = ["A","C","G","T","R","Y","S","W","K","M"]
ambiguous_chars = ["R","Y","S","W","K","M"]
missing_chars = ["-","?","N"]

# Read the phylip file.
if options[:phylip] != nil
	phylip_file =  File.open(options[:phylip])
	phylip_lines = phylip_file.readlines
	phylip_lines[1..-1].each do |l|
		unless l.strip == ""
			specimen_ids << l.split[0]
			seqs << l.split[1].upcase
		end
	end
	# Recognize the sequence format (nucleotides or binary).
	unique_seq_chars = []
	seqs.each do |s|
		s.size.times do |pos|
			unless missing_chars.include?(s[pos])
				unique_seq_chars << s[pos] unless unique_seq_chars.include?(s[pos])
			end
		end
	end
	sequence_format_is_nucleotide = true
	sequence_format_is_binary = true
	unique_seq_chars.each do |c|
		sequence_format_is_binary = false unless binary_chars.include?(c)
		sequence_format_is_nucleotide = false unless nucleotide_chars.include?(c)
	end
	if sequence_format_is_binary == false and sequence_format_is_nucleotide == false
		puts "ERROR: Sequence format could not be recognized as either 'nucleotide' or 'binary'!"
		exit(1)
	end
end

# Alternatively, read the vcf file.
tmp_line_count_all = 0
if options[:vcf] != nil
	vcf_file =  File.open(options[:vcf])
	vcf_lines = vcf_file.readlines
	vcf_header_line = ""
	vcf_lines.each do |l|
		if l[0..1] != "##"
			if l[0] == "#" and vcf_header_line == ""
				vcf_header_line = l
				vcf_header_line_ary = vcf_header_line.split
				specimen_ids = vcf_header_line_ary[9..-1]
				specimen_ids.size.times {seqs << ""}
			elsif vcf_header_line != ""
				tmp_line_count_all += 1
				line_ary = l.split
				ref = line_ary[3]
				alt = line_ary[4]
				if ref.size == 1 and alt.size == 1
					format_str = line_ary[8]
					gt_index = format_str.split(":").index("GT")
					if gt_index == nil
						puts "ERROR: Expected 'GT' in FORMAT field but could not find it!"
						exit(1)
					end
					specimen_index = 0
					found_half_called_gt = false
					line_ary[9..-1].each do |rec|
						gt = rec.split(":")[gt_index]
						if gt.include?("/")
							gt1 = gt.split("/")[0]
							gt2 = gt.split("/")[1]
						elsif gt.include?("|")
							gt1 = gt.split("|")[0]
							gt2 = gt.split("|")[1]
						else
							puts "ERROR: Expected alleles to be separated by '/' or '|' but did not found such separators!"
							exit(1)
						end
						if ["0","1","."].include?(gt1) and ["0","1","."].include?(gt2)
							if gt1 == "0"
								base1 = ref
							elsif gt1 == "1"
								base1 = alt
							else
								base1 = "N"
							end
							if gt2 == "0"
								base2 = ref
							elsif gt2 == "1"
								base2 = alt
							else
								base2 = "N"
							end
							if base1 == "N" and base2 == "N"
								seqs[specimen_index] << "N"
							elsif base1 == "N" or base2 == "N"
								seqs[specimen_index] << "N"
								found_half_called_gt = true
							elsif [base1,base2].sort == ["A","A"]
								seqs[specimen_index] << "A"
							elsif [base1,base2].sort == ["A","C"]
								seqs[specimen_index] << "M"
							elsif [base1,base2].sort == ["A","G"]
								seqs[specimen_index] << "R"
							elsif [base1,base2].sort == ["A","T"]
								seqs[specimen_index] << "W"
							elsif [base1,base2].sort == ["C","C"]
								seqs[specimen_index] << "C"
							elsif [base1,base2].sort == ["C","G"]
								seqs[specimen_index] << "S"
							elsif [base1,base2].sort == ["C","T"]
								seqs[specimen_index] << "Y"
							elsif [base1,base2].sort == ["G","G"]
								seqs[specimen_index] << "G"
							elsif [base1,base2].sort == ["G","T"]
								seqs[specimen_index] << "K"
							elsif [base1,base2].sort == ["T","T"]
								seqs[specimen_index] << "T"
							else
								puts "ERROR: Unexpected genotype: #{base1} and #{base2}!"
								exit(1)
							end
						else
							puts "ERROR: Expected genotypes to be bi-allelic and contain only 0s and/or 1s or missing data marked with '.', but found #{gt1} and #{gt2}!"
							exit(1)
						end
						specimen_index += 1
					end
					number_of_sites_with_half_call += 1 if found_half_called_gt
				elsif ref.size > 1 and ref.include?(",") == false
					number_of_excluded_sites_indel += 1
				elsif alt.size > 1 and alt.include?(",") == false
					number_of_excluded_sites_indel += 1
				elsif ref.include?(",") or alt.include?(",")
					number_of_ref_and_alt_alleles = ref.count(",") + alt.count(",") + 2
					if number_of_ref_and_alt_alleles == 3
						number_of_excluded_sites_triallelic += 1
					elsif number_of_ref_and_alt_alleles == 4
						number_of_excluded_sites_tetraallelic += 1
					else
						puts "ERROR: Unexpected combination of REF and ALT alleles (REF: #{ref}; ALT: #{alt})!"
						exit(1)
					end
				end
			else
				puts "ERROR: Expected a vcf header line beginning with '#CHROM' but could not find it!"
				exit(1)
			end
		end
	end

	# Make sure that all sequences have a positive and equal length.
	seqs[1..-1].each do |s|
		if s.size != seqs[0].size
			puts "ERROR: Sequences have different lengths!"
			exit(1)
		end
	end

	# Specify that the sequence format is nucleotide.
	sequence_format_is_binary = false
end

# If necessary, translate the sequences into SNAPP's "0", "1", "2" code, where "1" is heterozygous.
binary_seqs = []
seqs.size.times{binary_seqs << ""}
if sequence_format_is_binary
	seqs[0].size.times do |pos|
		alleles_at_this_pos = []
		seqs.each do |s|
			alleles_at_this_pos << s[pos] if binary_chars.include?(s[pos])
		end
		uniq_alleles_at_this_pos = alleles_at_this_pos.uniq
		if uniq_alleles_at_this_pos.size == 2 or uniq_alleles_at_this_pos.size == 3
			seqs.size.times do |x|
				binary_seqs[x] << seqs[x][pos]
			end
		elsif uniq_alleles_at_this_pos.size == 0
			number_of_excluded_sites_missing += 1
		elsif uniq_alleles_at_this_pos.size == 1
			number_of_excluded_sites_monomorphic += 1
		end
	end

	# Check if the total number of '0' and '2' in the data set are similar.
	total_number_of_0s = 0
	total_number_of_2s = 0
	binary_seqs.each do |b|
		total_number_of_0s += b.count("0")
		total_number_of_2s += b.count("2")
	end
	goal = 0.5
	tolerance = 0.01
	if (total_number_of_0s/(total_number_of_0s+total_number_of_2s).to_f - goal).abs > tolerance
		warn_string << "WARNING: The number of '0' and '2' in the data set is expected to be similar, however,\n"
		warn_string << "    they differ by more than #{tolerance*100.round} percent.\n"
		warn_string << "\n"
	end
else
	seqs[0].size.times do |pos|
		# Collect all bases at this position.
		bases_at_this_pos = []
		seqs.each do |s|
			if s[pos] == "A"
				bases_at_this_pos << "A"
				bases_at_this_pos << "A"
			elsif s[pos] == "C"
				bases_at_this_pos << "C"
				bases_at_this_pos << "C"
			elsif s[pos] == "G"
				bases_at_this_pos << "G"
				bases_at_this_pos << "G"
			elsif s[pos] == "T"
				bases_at_this_pos << "T"
				bases_at_this_pos << "T"
			elsif s[pos] == "R"
				bases_at_this_pos << "A"
				bases_at_this_pos << "G"
			elsif s[pos] == "Y"
				bases_at_this_pos << "C"
				bases_at_this_pos << "T"
			elsif s[pos] == "S"
				bases_at_this_pos << "G"
				bases_at_this_pos << "C"
			elsif s[pos] == "W"
				bases_at_this_pos << "A"
				bases_at_this_pos << "T"
			elsif s[pos] == "K"
				bases_at_this_pos << "G"
				bases_at_this_pos << "T"
			elsif s[pos] == "M"
				bases_at_this_pos << "A"
				bases_at_this_pos << "C"
			else
				unless ["N","?","-"].include?(s[pos])
					puts "ERROR: Found unexpected base at position #{pos+1}: #{s[pos]}!"
					exit(1)
				end
			end
		end
		uniq_bases_at_this_pos = bases_at_this_pos.uniq
		# Issue a warning if non-bi-allelic sites are excluded.
		if uniq_bases_at_this_pos.size == 2
			# Determine if this is a transition or transversion site.
			transversion_site = false
			if uniq_bases_at_this_pos.sort == ["A","C"]
				transversion_site = true
			elsif uniq_bases_at_this_pos.sort == ["A","G"]
				transversion_site = false
			elsif uniq_bases_at_this_pos.sort == ["A","T"]
				transversion_site = true
			elsif uniq_bases_at_this_pos.sort == ["C","G"]
				transversion_site = true
			elsif uniq_bases_at_this_pos.sort == ["C","T"]
				transversion_site = false
			elsif uniq_bases_at_this_pos.sort == ["G","T"]
				transversion_site = true
			else
				puts "ERROR: Unexpected combination of unique bases at position #{pos+1}: #{uniq_bases_at_this_pos[0]}, #{uniq_bases_at_this_pos[1]}"
				exit(1)
			end
			transition_site = true
			transition_site = false if transversion_site == true
			if options[:transversions] == true and transversion_site == false # If the site is a transition and only transversions are allowed.
				number_of_excluded_sites_transition += 1
			elsif options[:transitions] == true and transition_site == false # If the site is a transversion and only transitions are allowed.
				number_of_excluded_sites_transversion += 1
			else
				# Randomly define what's "0" and "2".
				uniq_bases_at_this_pos.shuffle!
				seqs.size.times do |x|
					if seqs[x][pos] == uniq_bases_at_this_pos[0]
						binary_seqs[x] << "0"
					elsif seqs[x][pos] == uniq_bases_at_this_pos[1]
						binary_seqs[x] << "2"
					elsif missing_chars.include?(seqs[x][pos])
						binary_seqs[x] << "-"
					elsif ambiguous_chars.include?(seqs[x][pos])
						binary_seqs[x] << "1"
					else
						puts "ERROR: Found unexpected base at position #{pos+1}: #{seqs[x][pos]}!"
						exit(1)
					end
				end
			end
		elsif uniq_bases_at_this_pos.size == 0
			number_of_excluded_sites_missing += 1
		elsif uniq_bases_at_this_pos.size == 1
			number_of_excluded_sites_monomorphic += 1
		elsif uniq_bases_at_this_pos.size == 3
			number_of_excluded_sites_triallelic += 1
		elsif uniq_bases_at_this_pos.size == 4
			number_of_excluded_sites_tetraallelic += 1
		else
			puts "ERROR: Found unexpected number of alleles at position #{pos+1}!"
			exit(1)
		end
	end
end

# Read the file with a table linking species and specimens.
table_file = File.open(options[:table])
table_lines = table_file.readlines
table_species = []
table_specimens = []
table_lines.each do |l|
	line_ary = l.split
	header_line = false
	header_line = true if line_ary[0].downcase == "species" and line_ary[1].downcase == "specimen"
	header_line = true if line_ary[0].downcase == "species" and line_ary[1].downcase == "specimens"
	header_line = true if line_ary[0].downcase == "species" and line_ary[1].downcase == "sample"
	header_line = true if line_ary[0].downcase == "species" and line_ary[1].downcase == "samples"
	unless header_line
		table_species << line_ary[0]
		table_specimens << line_ary[1]
	end
end

# Make sure that the arrays table_specimens and specimen_ids are identical when sorted.
unless table_specimens.sort == specimen_ids.sort
	puts "ERROR: The specimens listed in file #{options[:table]} and those included in the input file are not identical!"
	exit(1)
end

# Remove sites at which one or more species have only missing data; these could not be used by SNAPP anyway.
binary_seqs_for_snapp = []
binary_seqs.size.times {binary_seqs_for_snapp << ""}
binary_seqs[0].size.times do |pos|
	one_or_more_species_have_only_missing_data_at_this_pos = false
	table_species.uniq.each do |spc|
		specimens_for_this_species = []
		table_specimens.size.times do |x|
			specimens_for_this_species << table_specimens[x] if table_species[x] == spc
		end
		alleles_for_this_species_at_this_pos = []
		specimen_ids.size.times do |x|
			if specimens_for_this_species.include?(specimen_ids[x])
				alleles_for_this_species_at_this_pos << binary_seqs[x][pos]
			end
		end
		if alleles_for_this_species_at_this_pos.uniq == ["-"]
			one_or_more_species_have_only_missing_data_at_this_pos =  true
		end
	end
	# Set all alleles at this position to nil if one species had only missing data.
	if one_or_more_species_have_only_missing_data_at_this_pos
		number_of_excluded_sites_missing += 1
	else
		binary_seqs.size.times do |x|
			binary_seqs_for_snapp[x] << binary_seqs[x][pos]
		end
	end
end
binary_seqs = binary_seqs_for_snapp

# If a maximum number of SNPs has been set, reduce the data set to this number.
number_of_sites_before_excluding_due_to_max = binary_seqs[0].size
number_of_excluded_sites_due_to_max = 0
if options[:max_snps] != nil
	if options[:max_snps] < binary_seqs[0].size
		seq_indices = []
		binary_seqs[0].size.times {|x| seq_indices << x}
		selected_seq_indices = seq_indices.sample(options[:max_snps]).sort
		binary_seqs_red = []
		binary_seqs.each do |s|
			binary_seq_red = ""
			selected_seq_indices.each do |i|
				binary_seq_red << s[i]
			end
			binary_seqs_red << binary_seq_red
		end
		binary_seqs = binary_seqs_red
		number_of_excluded_sites_due_to_max = number_of_sites_before_excluding_due_to_max - options[:max_snps]
	else
		warn_string << "WARNING: The maximum number of SNPs has been set to #{options[:max_snps]}, which is greater\n"
		warn_string << "    than the number of bi-allelic SNPs with sufficient information for SNAPP.\n"
	end
end

# Compose the warn string if necessary.
if number_of_sites_with_half_call > 0
	warn_string << "WARNING: Found #{number_of_sites_with_half_call} site"
	warn_string << "s" if number_of_sites_with_half_call > 1
	warn_string << " with genotypes that were half missing. These genotypes were ignored.\n"
end
if number_of_excluded_sites_missing > 0
	warn_string << "WARNING: Excluded #{number_of_excluded_sites_missing} site"
	warn_string << "s" if number_of_excluded_sites_missing > 1
	warn_string << " with only missing data in one or more species.\n"
end
if number_of_excluded_sites_monomorphic > 0
	warn_string << "WARNING: Excluded #{number_of_excluded_sites_monomorphic} monomorphic site"
	warn_string << "s" if number_of_excluded_sites_monomorphic > 1
	warn_string << ".\n"
end
if number_of_excluded_sites_transition > 0
	warn_string << "WARNING: Excluded #{number_of_excluded_sites_transition} transition site"
	warn_string << "s" if number_of_excluded_sites_transition > 1
	warn_string << ".\n"
end
if number_of_excluded_sites_transversion > 0
	warn_string << "WARNING: Excluded #{number_of_excluded_sites_transversion} transversion site"
	warn_string << "s" if number_of_excluded_sites_transversion > 1
	warn_string << ".\n"
end
if number_of_excluded_sites_triallelic > 0
	warn_string << "WARNING: Excluded #{number_of_excluded_sites_triallelic} tri-allelic site"
	warn_string << "s" if number_of_excluded_sites_triallelic > 1
	warn_string << ".\n"
end
if number_of_excluded_sites_tetraallelic > 0
	warn_string << "WARNING: Excluded #{number_of_excluded_sites_tetraallelic} tetra-allelic site"
	warn_string << "s" if number_of_excluded_sites_tetraallelic > 1
	warn_string << ".\n"
end

# If there were any warning, print them.
unless warn_string == ""
	warn_string << "\n"
	puts warn_string
end

# Print the info string.
if options[:max_snps] != nil
	info_string = "INFO: Removed #{number_of_excluded_sites_due_to_max} bi-allelic sites due to specified maximum number of #{options[:max_snps]} sites.\n"
	info_string << "\n"
	puts info_string
else
	if options[:transversions]
		info_string = "INFO: Retained #{binary_seqs[0].size} bi-allelic transversion sites.\n"
	elsif options[:transitions]
		info_string = "INFO: Retained #{binary_seqs[0].size} bi-allelic transition sites.\n"
	else
		info_string = "INFO: Retained #{binary_seqs[0].size} bi-allelic sites.\n"
	end
	info_string << "\n"
	puts info_string
end

# Read the file with age constraint information.
constraint_file = File.open(options[:constraints])
constraint_lines = constraint_file.readlines
constraint_strings = []
cladeage_constraints_used = false
constraint_lines.each do |l|
	if ["normal","lognor","unifor","cladea","monoph"].include?(l[0..5].downcase)
		cladeage_constraints_used = true if l[0..7].downcase == "cladeage"
		constraint_strings << l
	end
end
if constraint_strings.size == 0
	puts "WARNING: No age constraints could be found in file #{options[:constraints]}. You will have to manually modify the XML file to include age constraints."
end
if cladeage_constraints_used
	info_string = "INFO: CladeAge constraints are specified in file #{options[:constraints]}.\n"
	info_string << "    To use these in SNAPP, make sure that the CladeAge package for BEAST2 is installed.\n"
	info_string << "    Installation instructions can be found at http://evoinformatics.eu/cladeage.pdf.\n"
	info_string << "\n"
	puts info_string
end

# Read the starting tree input file if specified.
if options[:tree]
	tree_file = File.open(options[:tree])
	tree_string = tree_file.readlines[0].strip.chomp(";").gsub(/\[.+?\]/,"")
else
	warn_string = "WARNING: As no starting tree has been specified, a random starting tree will be used by\n"
	warn_string << "    SNAPP. If the random starting tree is in conflict with specified constraints, SNAPP\n"
	warn_string << "    may not be able to find a suitable state to initiate the MCMC chain. This will lead\n"
	warn_string << "    to an error message such as 'Could not find a proper state to initialise'. If such\n"
	warn_string << "    a problem is encountered, it can be solved by providing a starting tree in which\n"
	warn_string << "    the ages of constrained clades agree with the constraints placed on these clades.\n"
	warn_string << "\n"
	puts warn_string
end

# Set run parameters.
store_frequency = options[:length]/2000
screen_frequency = 50
snapp_log_file_name = "#{options[:out]}.log"
snapp_trees_file_name = "#{options[:out]}.trees"

# Prepare SNAPP input string.
snapp_string = ""
snapp_string << "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n"
snapp_string << "<beast beautitemplate='SNAPP' beautistatus='' namespace=\"beast.core:beast.evolution.alignment:beast.evolution.tree.coalescent:beast.core.util:beast.evolution.nuc:beast.evolution.operators:beast.evolution.sitemodel:beast.evolution.substitutionmodel:beast.evolution.likelihood\" version=\"2.0\">\n"
snapp_string << "\n"
snapp_string << "<!-- Data -->\n"
unless options[:no_annotation]
	snapp_string << "<!--\n"
	if sequence_format_is_binary
		snapp_string << "The SNP data matrix, taken from file #{options[:phylip]}.\n"
	else
		snapp_string << "The SNP data matrix, converted to binary format from file #{options[:phylip]}.\n"
	end
	snapp_string << "-->\n"
end
snapp_string << "<data id=\"snps\" dataType=\"integer\" name=\"rawdata\">\n"
specimen_ids.size.times do |x|
	snapp_string << "    <sequence id=\"seq_#{specimen_ids[x]}\" taxon=\"#{specimen_ids[x]}\" totalcount=\"3\" value=\"#{binary_seqs[x]}\"/>\n"
end
snapp_string << "</data>\n"
snapp_string << "\n"
snapp_string << "<!-- Maps -->\n"
snapp_string << "<map name=\"Uniform\" >beast.math.distributions.Uniform</map>\n"
snapp_string << "<map name=\"Exponential\" >beast.math.distributions.Exponential</map>\n"
snapp_string << "<map name=\"LogNormal\" >beast.math.distributions.LogNormalDistributionModel</map>\n"
snapp_string << "<map name=\"Normal\" >beast.math.distributions.Normal</map>\n"
snapp_string << "<map name=\"Gamma\" >beast.math.distributions.Gamma</map>\n"
snapp_string << "<map name=\"OneOnX\" >beast.math.distributions.OneOnX</map>\n"
snapp_string << "<map name=\"prior\" >beast.math.distributions.Prior</map>\n"
snapp_string << "\n"
snapp_string << "<run id=\"mcmc\" spec=\"MCMC\" chainLength=\"#{options[:length]}\" storeEvery=\"#{store_frequency}\">\n"
snapp_string << "\n"
snapp_string << "    <!-- State -->\n"
snapp_string << "    <state id=\"state\" storeEvery=\"#{store_frequency}\">\n"
if options[:tree]
	snapp_string << "        <stateNode id=\"tree\" spec=\"beast.util.TreeParser\" IsLabelledNewick=\"true\" nodetype=\"snap.NodeData\" newick=\"#{tree_string};\">\n"
else
	snapp_string << "        <stateNode id=\"tree\" spec=\"beast.util.ClusterTree\" clusterType=\"upgma\" nodetype=\"snap.NodeData\">\n"
end
snapp_string << "            <taxa id=\"data\" spec=\"snap.Data\" dataType=\"integerdata\">\n"
snapp_string << "                <rawdata idref=\"snps\"/>\n"
table_species.uniq.each do |s|
	snapp_string << "                <taxonset id=\"#{s}\" spec=\"TaxonSet\">\n"
	table_species.size.times do |x|
		if table_species[x] == s
			snapp_string << "                    <taxon id=\"#{table_specimens[x]}\" spec=\"Taxon\"/>\n"
		end
	end
	snapp_string << "                </taxonset>\n"
end
snapp_string << "            </taxa>\n"
snapp_string << "        </stateNode>\n"
snapp_string << "        <!-- Parameter starting values -->\n"
snapp_string << "        <parameter id=\"lambda\" lower=\"0.0\" name=\"stateNode\">0.1</parameter>\n"
snapp_string << "        <parameter id=\"coalescenceRate\" lower=\"0.0\" name=\"stateNode\">200.0</parameter>\n"
snapp_string << "        <parameter id=\"clockRate\" lower=\"0.0\" name=\"stateNode\">0.01</parameter>\n"
snapp_string << "    </state>\n"
snapp_string << "\n"
snapp_string << "    <!-- Posterior -->\n"
snapp_string << "    <distribution id=\"posterior\" spec=\"util.CompoundDistribution\">\n"
snapp_string << "        <distribution id=\"prior\" spec=\"util.CompoundDistribution\">\n"
snapp_string << "\n"
snapp_string << "            <!-- Divergence age priors -->\n"
constraint_count = 0
constraint_strings.each do |c|
	constraint_count += 1
	constraint_ary = c.split
	unless constraint_ary.size == 3
		puts "ERROR: Expected three character strings per line for each constraint specification, but found"
		puts "    '#{c.strip}',"
		exit(1)
	end
	constraint_distribution = constraint_ary[0].downcase
	constraint_placement = constraint_ary[1].downcase
	constraint_clade = constraint_ary[2]
	constraint_clade_ary = constraint_clade.split(",")
	constraint_clade_ary.each do |s|
		unless table_species.include?(s)
			puts "ERROR: A constraint has been specified for a clade that includes species #{s}, however,"
			puts "    this species could not be found in file #{options[:table]}!"
			exit(1)
		end
	end
	unless ["stem","crown","na"].include?(constraint_placement)
		puts "ERROR: Expected 'stem', 'crown', or 'NA' (only for monophyly constraints without calibration)"
		puts "    but found '#{constraint_placement}' as the second character string in '#{c}'!"
		exit(1)
	end
	if constraint_distribution.include?("(") == false and constraint_distribution != "monophyletic"
		puts "ERROR: Expected parameters in parentheses as part of the first character string in "
		puts "    '#{c.strip}',"
		puts "    but found '#{constraint_distribution}'!"
		exit(1)
	end
	if constraint_distribution == "monophyletic"
		constraint_type = "monophyletic"
	else
		constraint_type = constraint_distribution.split("(")[0].strip
	end
	unless ["normal","lognormal","uniform","cladeage","monophyletic"].include?(constraint_type)
		puts "ERROR: Expected 'normal', 'lognormal', 'uniform', 'cladeage', or 'monophyletic' as part"
		puts "    of the first character string in '#{c}' but found '#{constraint_type}'!"
		exit(1)
	end
	unless constraint_type == "monophyletic"
		constraint_parameters = constraint_distribution.split("(")[1].strip.chomp(")").split(",")
	end
	if constraint_type == "normal"
		unless constraint_parameters.size == 3
			puts "ERROR: Expected 3 parameters for normal distribution, but found #{constraint_parameters.size}!"
			exit(1)
		end
	elsif constraint_type == "lognormal"
		unless constraint_parameters.size == 3
			puts "ERROR: Expected 3 parameters for lognormal distribution, but found #{constraint_parameters.size}!"
			exit(1)
		end
	elsif constraint_type == "uniform"
		unless constraint_parameters.size == 2
			puts "ERROR: Expected 2 parameters for lognormal distribution, but found #{constraint_parameters.size}!"
			exit(1)
		end
	elsif constraint_type == "cladeage"
		unless constraint_parameters.size == 8
			puts "ERROR: Expected 8 parameters for lognormal distribution, but found #{constraint_parameters.size}!"
			exit(1)
		end
	else
		unless constraint_type == "monophyletic"
			puts "ERROR: Unexpected constraint type '#{constraint_type}'!"
			exit(1)
		end
	end
	constraint_id = constraint_count.to_s.rjust(4).gsub(" ","0")
	if constraint_type == "cladeage"
		snapp_string << "            <distribution id=\"Clade#{constraint_id}\" spec=\"beast.math.distributions.FossilPrior\" monophyletic=\"true\"  tree=\"@tree\">\n"
	else
		snapp_string << "            <distribution id=\"Clade#{constraint_id}\" spec=\"beast.math.distributions.MRCAPrior\" "
		if constraint_placement == "stem"
			if constraint_clade_ary.size == table_species.uniq.size
				puts "ERROR: It seems that a #{constraint_type} constraint should be placed on the stem of the root of the phylogeny!"
				exit(1)
			else
				snapp_string << "useOriginate=\"true\" "
			end
		else
			snapp_string << "useOriginate=\"false\" "
		end
		snapp_string << "monophyletic=\"true\"  tree=\"@tree\">\n"
	end
	snapp_string << "                <taxonset id=\"Constraint#{constraint_id}\" spec=\"TaxonSet\">\n"
	constraint_clade_ary.each do |s|
		snapp_string << "                    <taxon idref=\"#{s}\"/>\n"
	end
	snapp_string << "                </taxonset>\n"
	if constraint_type == "normal"
		snapp_string << "                <Normal name=\"distr\" offset=\"#{constraint_parameters[0]}\">\n"
		snapp_string << "                    <parameter estimate=\"false\" lower=\"0.0\" name=\"mean\">#{constraint_parameters[1]}</parameter>\n"
		snapp_string << "                    <parameter estimate=\"false\" lower=\"0.0\" name=\"sigma\">#{constraint_parameters[2]}</parameter>\n"
		snapp_string << "                </Normal>\n"
	elsif constraint_type == "lognormal"
		snapp_string << "                <LogNormal meanInRealSpace=\"true\" name=\"distr\" offset=\"#{constraint_parameters[0]}\">\n"
		snapp_string << "                    <parameter estimate=\"false\" lower=\"0.0\" name=\"M\">#{constraint_parameters[1]}</parameter>\n"
		snapp_string << "                    <parameter estimate=\"false\" lower=\"0.0\" name=\"S\">#{constraint_parameters[2]}</parameter>\n"
		snapp_string << "                </LogNormal>\n"
	elsif constraint_type == "uniform"
		snapp_string << "                <Uniform name=\"distr\" lower=\"#{constraint_parameters[0]}\" upper=\"#{constraint_parameters[1]}\"/>\n"
	elsif constraint_type == "cladeage"
		snapp_string << "                <fossilDistr\n"
		snapp_string << "                    id=\"#{constraint_id}\"\n"
		snapp_string << "                    minOccuranceAge=\"#{constraint_parameters[0]}\"\n"
		snapp_string << "                    maxOccuranceAge=\"#{constraint_parameters[1]}\"\n"
		snapp_string << "                    minDivRate=\"#{constraint_parameters[2]}\"\n"
		snapp_string << "                    maxDivRate=\"#{constraint_parameters[3]}\"\n"
		snapp_string << "                    minTurnoverRate=\"#{constraint_parameters[4]}\"\n"
		snapp_string << "                    maxTurnoverRate=\"#{constraint_parameters[5]}\"\n"
		snapp_string << "                    minSamplingRate=\"#{constraint_parameters[6]}\"\n"
		snapp_string << "                    maxSamplingRate=\"#{constraint_parameters[7]}\"\n"
		snapp_string << "                    minSamplingGap=\"0\"\n"
		snapp_string << "                    maxSamplingGap=\"0\"\n"
		snapp_string << "                    spec=\"beast.math.distributions.FossilCalibration\"/>\n"
	end
	snapp_string << "            </distribution>\n"
end
unless options[:no_annotation]
	snapp_string << "            <!--\n"
	snapp_string << "            The clock rate affects the model only by scaling branches before likelihood calculations.\n"
	snapp_string << "            A one-on-x prior distribution is used, which has the advantage that the shape of its\n"
	snapp_string << "            distribution is independent of the time scales used, and can therefore equally be applied\n"
	snapp_string << "            in phylogenetic analyses of very recent or old groups. However, note that the one-on-x\n"
	snapp_string << "            prior distribution is not a proper probability distribution as its total probability mass\n"
	snapp_string << "            does not sum to 1. For this reason, this prior distribution can not be used for Bayes Factor\n"
	snapp_string << "            comparison based on Path Sampling or Stepping Stone analyses. If such analyses are to be\n"
	snapp_string << "            performed, a different type of prior distribution (uniform, lognormal, gamma,...) will need\n"
	snapp_string << "            to be chosen.\n"
	snapp_string << "            -->\n"
end
snapp_string << "            <prior name=\"distribution\" x=\"@clockRate\">\n"
snapp_string << "                <OneOnX name=\"distr\"/>\n"
snapp_string << "            </prior>\n"
unless options[:no_annotation]
	snapp_string << "            <!--\n"
	snapp_string << "            The scaling of branch lengths based on the clock rate does not affect the evaluation of the\n"
	snapp_string << "            likelihood of the species tree given the speciation rate lambda. Thus, lambda is measured in\n"
	snapp_string << "            the same time units as the unscaled species tree. As for the clock rate, a one-on-x prior\n"
	snapp_string << "            distribution is used, and an alternative prior distribution will need to be chosen if Bayes\n"
	snapp_string << "            Factor comparisons are to be performed.\n"
	snapp_string << "            -->\n"
end
snapp_string << "            <prior name=\"distribution\" x=\"@lambda\">\n"
snapp_string << "                <OneOnX name=\"distr\"/>\n"
snapp_string << "            </prior>\n"
unless options[:no_annotation]
	snapp_string << "            <!--\n"
	snapp_string << "            The below distribution defines the prior probability for the population mutation rate Theta.\n"
	snapp_string << "            In standard SNAPP analyses, a gamma distribution is commonly used to define this probability,\n"
	snapp_string << "            with a mean according to expectations based on the assumed mean effective population size\n"
	snapp_string << "            (across all branches) and the assumed mutation rate per site and generation. However, with\n"
	snapp_string << "            SNP matrices, the mutation rate of selected SNPs usually differs strongly from the genome-wide\n"
	snapp_string << "            mutation rate, and the degree of this difference depends on the way in which SNPs were selected\n"
	snapp_string << "            for the analysis. The SNP matrices used for this analysis are assumed to all be bi-allelic,\n"
	snapp_string << "            excluding invariable sites, and are thus subject to ascertainment bias that will affect the\n"
	snapp_string << "            mutation rate estimate. If only a single species would be considered, this ascertainment bias\n"
	snapp_string << "            could be accounted for (Kuhner et al. 2000; Genetics 156: 439–447). However, with multiple\n"
	snapp_string << "            species, the proportion of SNPs that are variable among individuals of the same species,\n"
	snapp_string << "            compared to the overall number of SNPs variable among all species, depends on relationships\n"
	snapp_string << "            between species and the age of the phylogeny, parameters that are to be inferred in the analysis.\n"
	snapp_string << "            Thus, SNP ascertainment bias can not be accounted for before the analysis, and the prior\n"
	snapp_string << "            expectation of Theta is extremely vague. Therefore, a uniform prior probability distribution\n"
	snapp_string << "            is here used for this parameter, instead of the commonly used gamma distribution. By default,\n"
	snapp_string << "            SNAPP uses a lower boundary of 0 and an upper boundary of 10000 when a uniform prior probability\n"
	snapp_string << "            distribution is chosen for Theta, and these lower and upper boundaries can not be changed without\n"
	snapp_string << "            editing the SNAPP source code. Regardless of the wide boundaries, the uniform distribution works\n"
	snapp_string << "            well in practice, at least when the Theta parameter is constrained to be identical on all branches\n"
	snapp_string << "            (see below).\n"
	snapp_string << "            -->\n"
end
snapp_string << "            <distribution spec=\"snap.likelihood.SnAPPrior\" coalescenceRate=\"@coalescenceRate\" lambda=\"@lambda\" rateprior=\"uniform\" tree=\"@tree\">\n"
unless options[:no_annotation]
	snapp_string << "                <!--\n"
	snapp_string << "                SNAPP requires input for parameters alpha and beta regardless of the chosen type of prior,\n"
	snapp_string << "                however, the values of these two parameters are ignored when a uniform prior is selected.\n"
	snapp_string << "                Thus, they are both set arbitrarily to 1.0.\n"
	snapp_string << "                -->\n"
end
snapp_string << "                <parameter estimate=\"false\" lower=\"0.0\" name=\"alpha\">1.0</parameter>\n"
snapp_string << "                <parameter estimate=\"false\" lower=\"0.0\" name=\"beta\">1.0</parameter>\n"
snapp_string << "            </distribution>\n"
snapp_string << "        </distribution>\n"
snapp_string << "        <distribution id=\"likelihood\" spec=\"util.CompoundDistribution\">\n"
snapp_string << "            <distribution spec=\"snap.likelihood.SnAPTreeLikelihood\" data=\"@data\" non-polymorphic=\"false\" pattern=\"coalescenceRate\" tree=\"@tree\">\n"
snapp_string << "                <siteModel spec=\"SiteModel\">\n"
snapp_string << "                    <substModel spec=\"snap.likelihood.SnapSubstitutionModel\" coalescenceRate=\"@coalescenceRate\">\n"
unless options[:no_annotation]
	snapp_string << "                        <!--\n"
	snapp_string << "                        The forward and backward mutation rates are fixed so that the number of expected mutations\n"
	snapp_string << "                        per time unit (after scaling branch lengths with the clock rate) is 1.0. This is done to\n"
	snapp_string << "                        avoid non-identifability of rates, given that the clock rate is estimated. Both parameters\n"
	snapp_string << "                        are fixed at the same values, since it is assumed that alleles were translated to binary\n"
	snapp_string << "                        code by random assignment of '0' and '2' to homozygous alleles, at each site individually.\n"
	snapp_string << "                        Thus, the probabilities for '0' and '2' are identical and the resulting frequencies of '0'\n"
	snapp_string << "                        and '2' in the data matrix should be very similar.\n"
	snapp_string << "                        -->\n"
end
snapp_string << "                        <parameter estimate=\"false\" lower=\"0.0\" name=\"mutationRateU\">1.0</parameter>\n"
snapp_string << "                        <parameter estimate=\"false\" lower=\"0.0\" name=\"mutationRateV\">1.0</parameter>\n"
snapp_string << "                    </substModel>\n"
snapp_string << "                </siteModel>\n"
unless options[:no_annotation]
	snapp_string << "                <!--\n"
	snapp_string << "                A strict clock rate is used, assuming that only closely related species are used in SNAPP\n"
	snapp_string << "                analyses and that branch rate variation among closely related species is negligible.\n"
	snapp_string << "                The use of a relaxed clock is not supported in SNAPP.\n"
	snapp_string << "                -->\n"
end
snapp_string << "                <branchRateModel spec=\"beast.evolution.branchratemodel.StrictClockModel\" clock.rate=\"@clockRate\"/>\n"
snapp_string << "            </distribution>\n"
snapp_string << "        </distribution>\n"
snapp_string << "    </distribution>\n"
snapp_string << "\n"
snapp_string << "    <!-- Operators -->\n"
if options[:weight] > 0
	unless options[:no_annotation]
		snapp_string << "    <!--\n"
		snapp_string << "    The treeNodeSwapper operator is the only operator on the tree topology. Thus if the tree topology\n"
		snapp_string << "    should be fixed, simply remove this operator by deleting the second-next line.\n"
		snapp_string << "    -->\n"
	end
	snapp_string << "    <operator id=\"treeNodeSwapper\" spec=\"snap.operators.NodeSwapper\" tree=\"@tree\" weight=\"#{options[:weight]}\"/>\n"
end
unless options[:no_annotation]
	snapp_string << "    <!--\n"
	snapp_string << "    The treeNodeBudger and treeScaler operators modify node heights of the tree.\n"
	snapp_string << "    -->\n"
end
snapp_string << "    <operator id=\"treeNodeBudger\" spec=\"snap.operators.NodeBudger\" size=\"0.75\" tree=\"@tree\" weight=\"1.0\"/>\n"
snapp_string << "    <operator id=\"treeScaler\" spec=\"snap.operators.ScaleOperator\" scaleFactor=\"0.75\" tree=\"@tree\" weight=\"1.0\"/>\n"
unless options[:no_annotation]
	snapp_string << "    <!--\n"
	snapp_string << "    To constrain the Theta parameter so that all branches always share the same value (and thus\n"
	snapp_string << "    the same population size estimates), a single operator is used to modify Theta values by scaling\n"
	snapp_string << "    the Thetas of all branches up or down by the same factor. Instead, SNAPP's default Theta operator\n"
	snapp_string << "    types 'GammaMover' and 'RateMixer' are not not used.\n"
	snapp_string << "    -->\n"
end
snapp_string << "    <operator id=\"thetaScaler\" spec=\"snap.operators.ScaleOperator\" parameter=\"@coalescenceRate\" scaleFactor=\"0.75\" scaleAll=\"true\" weight=\"1.0\"/>\n"
unless options[:no_annotation]
	snapp_string << "    <!--\n"
	snapp_string << "    The lamdaScaler and clockScaler operators modify the speciation and clock rates.\n"
	snapp_string << "    -->\n"
end
snapp_string << "    <operator id=\"lamdaScaler\" spec=\"snap.operators.ScaleOperator\" parameter=\"@lambda\" scaleFactor=\"0.75\" weight=\"1.0\"/>\n"
snapp_string << "    <operator id=\"clockScaler\" spec=\"snap.operators.ScaleOperator\" parameter=\"@clockRate\" scaleFactor=\"0.75\" weight=\"1.0\"/>\n"
snapp_string << "\n"
snapp_string << "    <!-- Loggers -->\n"
snapp_string << "    <logger fileName=\"#{snapp_log_file_name}\" logEvery=\"#{store_frequency}\">\n"
snapp_string << "        <log idref=\"posterior\"/>\n"
snapp_string << "        <log idref=\"likelihood\"/>\n"
snapp_string << "        <log idref=\"prior\"/>\n"
snapp_string << "        <log idref=\"lambda\"/>\n"
snapp_string << "        <log id=\"treeHeightLogger\" spec=\"beast.evolution.tree.TreeHeightLogger\" tree=\"@tree\"/>\n"
snapp_string << "        <log idref=\"clockRate\"/>\n"
snapp_string << "    </logger>\n"
snapp_string << "    <logger logEvery=\"#{screen_frequency}\">\n"
snapp_string << "        <log idref=\"posterior\"/>\n"
snapp_string << "        <log spec=\"util.ESS\" arg=\"@posterior\"/>\n"
snapp_string << "        <log idref=\"likelihood\"/>\n"
snapp_string << "        <log idref=\"prior\"/>\n"
snapp_string << "        <log idref=\"treeHeightLogger\"/>\n"
snapp_string << "        <log idref=\"clockRate\"/>\n"
snapp_string << "    </logger>\n"
snapp_string << "    <logger fileName=\"#{snapp_trees_file_name}\" logEvery=\"#{store_frequency}\" mode=\"tree\">\n"
snapp_string << "        <log spec=\"beast.evolution.tree.TreeWithMetaDataLogger\" tree=\"@tree\">\n"
snapp_string << "            <metadata id=\"theta\" spec=\"snap.RateToTheta\" coalescenceRate=\"@coalescenceRate\"/>\n"
snapp_string << "        </log>\n"
snapp_string << "    </logger>\n"
snapp_string << "\n"
snapp_string << "</run>\n"
snapp_string << "\n"
snapp_string << "</beast>\n"

# Write the SNAPP input file.
snapp_file = File.open(options[:xml],"w")
snapp_file.write(snapp_string)
puts "Wrote SNAPP input in XML format to file #{options[:xml]}.\n\n"
