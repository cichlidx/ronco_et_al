# m_matschiner Mon Jul 2 12:35:18 CEST 2018

# Get the command-line arguments.
input_dir = ARGV[0]
filter = ARGV[1]
table_file_name = ARGV[2]

# Get the names of all files with misingness before and after filtering in the input directory.
missingness_before_file_names = []
missingness_after_file_names = []
Dir.entries(input_dir).each do |e|
	if e.match(/#{filter}.missing_before.txt/)
		missingness_before_file_names << e
	elsif e.match(/#{filter}.missing_after.txt/)
		missingness_after_file_names << e
	end
end
missingness_before_file_names.sort!
missingness_after_file_names.sort!

# Read the first file before filtering to get the list of sample IDs.
sample_ids = []
first_file_name = missingness_before_file_names[0]
first_file = File.open("#{input_dir}/#{first_file_name}")
first_file_lines = first_file.readlines
first_file_lines[1..-1].each do |l|
	line_ary = l.split
	sample_ids << line_ary[0]
end

# Prepare arrays for the total number of sites, the number of missing sites before, and the number of missing sites after filtering.
ns_sites_total = []
ns_sites_missing_before = []
ns_sites_missing_after = []
sample_ids.size.times do |x|
	ns_sites_total << 0
	ns_sites_missing_before << 0
	ns_sites_missing_after << 0
end

# Compare all files before and after filtering.
missingness_before_file_names.size.times do |x|

	# Get the names of the current two files.
	missingness_before_file_name = missingness_before_file_names[x]
	missingness_after_file_name = missingness_after_file_names[x]
	unless missingness_before_file_name.chomp("missing_before.txt") == missingness_after_file_name.chomp("missing_after.txt")
		puts "ERROR: The names of the files before and after filtering do not match (#{missingness_before_file_name} and #{missingness_after_file_name})!"
		exit 1
	end

	# Read the file of missing data before filtering.
	missingness_before_file = File.open("#{input_dir}/#{missingness_before_file_name}")
	missingness_after_file = File.open("#{input_dir}/#{missingness_after_file_name}")
	missingness_before_lines = missingness_before_file.readlines
	missingness_after_lines = missingness_after_file.readlines
	sample_ids_this_before_file = []
	ns_sites_total_this_before_file = []
	ns_sites_missing_this_before_file = []	
	missingness_before_lines[1..-1].each do |l|
		line_ary = l.split
		sample_ids_this_before_file << line_ary[0]
		ns_sites_total_this_before_file << line_ary[1].to_i
		ns_sites_missing_this_before_file << line_ary[3].to_i
	end

	# Read the file of missing data after filtering.
	sample_ids_this_after_file = []
	ns_sites_total_this_after_file = []
	ns_sites_missing_this_after_file = []	
	missingness_after_lines[1..-1].each do |l|
		line_ary = l.split
		sample_ids_this_after_file << line_ary[0]
		ns_sites_total_this_after_file << line_ary[1].to_i
		ns_sites_missing_this_after_file << line_ary[3].to_i
	end

	# Make sure that the sample IDs are identical between the two files and with the overall array of sample IDs.
	unless sample_ids_this_before_file == sample_ids_this_after_file
		puts "ERROR: Sample IDs differ between the files before and after filtering (#{missingness_before_file_name} and #{missingness_after_file_name})!"
		exit 1
	end
	unless sample_ids_this_before_file == sample_ids
		puts "ERROR: Sample IDs differ between the file before filtering (#{missingness_before_file_name}) and the overall array of sample IDs!"
		exit 1
	end

	# Make sure that all lines contain the same number of total sites filtering.
	unless ns_sites_total_this_before_file.uniq.size == 1
		puts "ERROR: Found different numbers of sites in one and the same file (#{missingness_before_file_name})!"
		exit 1
	end

	# Make sure that the total number of sites is identical in the files before and after filtering.
	unless ns_sites_total_this_before_file == ns_sites_total_this_after_file
		puts "ERROR: The numbers of total sites differ between the files before and after filtering (#{missingness_before_file_name} and #{missingness_after_file_name})!"
		exit 1
	end

	# Add numbers to overall arrays.
	sample_ids.size.times do |y|
		ns_sites_total[y] += ns_sites_total_this_before_file[y]
		ns_sites_missing_before[y] += ns_sites_missing_this_before_file[y]
		ns_sites_missing_after[y] += ns_sites_missing_this_after_file[y]
	end
end

# Prepare the output table.
table_string = "sample_id\tn_sites\tn_sites_missing_before\tn_sites_missing_after\tn_sites_nonmissing_before\tn_sites_nonmissing_after\tcall_probability\n"
sample_ids.size.times do |x|
	n_sites_nonmissing_before = ns_sites_total[x]-ns_sites_missing_before[x]
	n_sites_nonmissing_after = ns_sites_total[x]-ns_sites_missing_after[x]
	table_string << "#{sample_ids[x]}\t#{ns_sites_total[x]}\t#{ns_sites_missing_before[x]}\t#{ns_sites_missing_after[x]}\t#{n_sites_nonmissing_before}\t#{n_sites_nonmissing_after}\t#{n_sites_nonmissing_after/n_sites_nonmissing_before.to_f}\n"
end

# Write the output table.
table_file = File.open(table_file_name, "w")
table_file.write(table_string)

# Feedback.
puts "Wrote file #{table_file_name}"
