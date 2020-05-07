# Michael Matschiner, 2016-08-05

# This script calcualates the proportion of missing
# data in an alignment in nexus format.
#
# It should be called as
# ruby get_proportion_of_missing_data.rb alignment.nex

input_file_name = ARGV[0]
input_file = File.open(input_file_name)
input_lines = input_file.readlines

# Read the sequences and ids.
ids = []
seqs = []
in_matrix = false
input_lines.each do |l|
	if l.strip.downcase == "matrix"
		in_matrix = true
	elsif l.strip.downcase == "end;"
		in_matrix = false
	elsif in_matrix and l.strip != ";"
		unless l.strip == ""
			line_ary = l.strip.split
			raise "ERROR: File could not be read properly!" if line_ary.size != 2
			ids << line_ary[0]
			seqs << line_ary[1]
		end
	end
end

# Make sure all sequences have the same length.
seqs[1..-1].each do |s|
	raise "ERROR: Sequences have different lengths!" if s.size != seqs[0].size
end

# Get the proportion of missing data.
number_of_missing_bases = 0
length_of_alignment_without_completely_missing_sites = 0
seqs[0].size.times do |pos|
	alleles_at_this_pos = []
	seqs.each do |s|
		alleles_at_this_pos << s[pos]
	end
	# unless alleles_at_this_pos.count("N") + alleles_at_this_pos.count("n") + alleles_at_this_pos.count("-") + alleles_at_this_pos.count("?") == alleles_at_this_pos.size
		number_of_missing_bases += alleles_at_this_pos.count("N")
		number_of_missing_bases += alleles_at_this_pos.count("n")
		number_of_missing_bases += alleles_at_this_pos.count("-")
		number_of_missing_bases += alleles_at_this_pos.count("?")
		length_of_alignment_without_completely_missing_sites += 1
	# end
end

# Output the proportion of missing data.
puts number_of_missing_bases/(seqs.size*length_of_alignment_without_completely_missing_sites).to_f