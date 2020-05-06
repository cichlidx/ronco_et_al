# m_matschiner Tue Feb 27 14:51:12 CET 2018

# Get the input and output file names.
input_file_name = ARGV[0]
output_file_name = ARGV[1]

# Open the input and output files.
input_file = File.open(input_file_name)
output_file = File.open(output_file_name,"w")

# Write a new file in which spanning deletions are replaced with missing data.
input_file.each_line do |l|
	if l[0] == "#"
		output_file.write(l)
	elsif l.include?("*") == false
		output_file.write(l)
	else
		line_ary = l.split
		alternate_alleles = line_ary[4].split(",")
		if alternate_alleles.include?("*")
			asterisk_index = alternate_alleles.index("*")
			n_alternates = alternate_alleles.size
			line = l
			n_alternates.size.times do |x|
				line.gsub!("\t#{asterisk_index+1}/","\t./")
				line.gsub!("/#{asterisk_index+1}:","/.:")
			end
			output_file.write(line)
		else
			puts "ERROR: Asterisk found in unexpected position in the following line:"
			puts l
			exit 1
		end
	end
end