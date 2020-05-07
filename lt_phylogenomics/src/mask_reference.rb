# m_matschiner Tue Jul 17 15:25:05 CEST 2018

# Get the command-line arguments.
reference_file_name = ARGV[0]
mask_file_name = ARGV[1]
masked_reference_file_name = ARGV[2]

# Read the reference file.
print "Reading the reference file #{reference_file_name}..."
STDOUT.flush
reference_file = File.open(reference_file_name)
reference_lines = reference_file.readlines
reference_ids = []
reference_seqs = []
reference_lines.each do |l|
	stripped_line = l.strip
	if stripped_line[0] == ">"
		reference_ids << stripped_line[1..-1]
		reference_seqs << []
	elsif stripped_line != ""
		stripped_line.size.times do |pos|
			reference_seqs.last << stripped_line[pos]
		end
	end
end
puts " done."
STDOUT.flush

# Read the mask file.
mask_file = File.open(mask_file_name)
mask_lines = mask_file.readlines

# Feedback.
puts "The mask file #{mask_file_name} has #{mask_lines.size} entries."
STDOUT.flush

# Mask the reference sequence.
line_count = 1
mask_lines.each do |l|
	line_ary = l.split
	chromosome_id = line_ary[0]
	from = line_ary[1].to_i - 1
	to = line_ary[2].to_i - 1
	unless reference_ids.include?(chromosome_id)
		puts "ERROR: The chromosome ID #{chromosome_id} is not among the IDs of the reference sequence!"
		puts reference_ids
		exit 1
	end
	reference_seq_index = reference_ids.index(chromosome_id)
	puts "Replacing nucleotides from #{from} to #{to} on chromosome #{chromosome_id}."
	STDOUT.flush

	# This could have worked faster:
	#  tmp = reference_seq.map.with_index do | nucleotide, index |
	#    if index >= from and index <= to
	#      "N"
	#    else
	#      nucleotide
	#    end
	#  end
	#  reference_seq = tmp

	from.upto(to) do |pos|
		reference_seqs[reference_seq_index][pos] = "N"
	end
	line_count += 1
end

# Prepare the output string.
print "Preparing the output string..."
STDOUT.flush
masked_reference_string = ""
reference_ids.size.times do |x|
	masked_reference_string << ">#{reference_ids[x]}\n"
	masked_reference_seq = ""
	reference_seqs[x].size.times do |pos|
		masked_reference_seq << reference_seqs[x][pos]
	end
	masked_reference_string << "#{masked_reference_seq}\n"
end
puts " done."
STDOUT.flush

# Write the output string.
masked_reference_file = File.open(masked_reference_file_name, "w")
masked_reference_file.write(masked_reference_string)

# Feedback.
puts "Wrote masked reference to file #{masked_reference_file_name}."
