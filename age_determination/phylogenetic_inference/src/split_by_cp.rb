# Define the help string.
help_string = ""
help_string << "\n"
help_string << "-----------------------------------------------------------------------------------------------\n"
help_string << "split_by_cp.rb\n"
help_string << "This script splits alignments in NEXUS format according to codon position.\n"
help_string << "11-02-2014, michaelmatschiner@mac.com\n"
help_string << "\n"
help_string << "Available options:\n"
help_string << "  Option   Value                    Comment\n"
help_string << "  -i       input file name        | Full or relative path plus file name\n"
help_string << "  -c       1,2,3                  | Specify with which codon position to start (default == 1)\n"
help_string << "-----------------------------------------------------------------------------------------------\n"
help_string << "\n"

# Read the arguments.
if ARGV == [] or ["-h","--help","-help"].include?(ARGV[0].downcase)
  puts help_string
  exit
end

# Read the specified input file names.
if ARGV.include?("-i")
  input_file_name = ARGV[ARGV.index("-i")+1]
else
  raise "Please specify an input file name with option \"-i\"!"
end

# Read the specified start codon position.
start_cp = 1
if ARGV.include?("-c")
	start_cp = ARGV[ARGV.index("-c")+1].to_i
end

# Open and read the input file.
input_file = File.open(input_file_name)
lines = input_file.readlines
input_file.close
raise "Not a nexus file" unless lines[0].strip.downcase == "#nexus"
ids = []
seqs = []
matrix = false
lines.each do |l|
	unless l.strip == ""

		if l.strip.downcase == "matrix"
			matrix = true
		elsif l.strip == ";"
			matrix = false
		elsif matrix == true
			l_ary = l.strip.split(" ")
			raise "Line has wrong format" if l_ary.size != 2
			ids << l_ary[0]
			seqs << l_ary[1]
		end
	end
end

# Make sure that all sequences have the same length.
seq_length = seqs[0].length
1.upto(seqs.size-1) {|x| raise "Unequal sequence lengths" if seqs[x].length != seq_length}

# Split all sequences by codon position.
seqs_cp1 = []
seqs_cp2 = []
seqs_cp3 = []
seqs.size.times do |s|
	seqs_cp1[s] = ""
	seqs_cp2[s] = ""
	seqs_cp3[s] = ""
	seqs[s].length.times do |pos|
		seqs_cp1[s] << seqs[s][pos] if (pos-1+start_cp).modulo(3) == 0
		seqs_cp2[s] << seqs[s][pos] if (pos-1+start_cp).modulo(3) == 1
		seqs_cp3[s] << seqs[s][pos] if (pos-1+start_cp).modulo(3) == 2
	end
end

# Get the length of the longest id.
max_id_length = 0
ids.each do |i|
	max_id_length = i.size if i.size > max_id_length
end

# Write three output files in nexus format for the three different codon position.
output_file_names = []
3.times do |x|
	out = "#nexus\n"
	out << "begin data;\n"
	out << "  dimensions ntax = #{ids.size} nchar = #{seqs_cp1[0].length};\n" if x == 0
	out << "  dimensions ntax = #{ids.size} nchar = #{seqs_cp2[0].length};\n" if x == 1
	out << "  dimensions ntax = #{ids.size} nchar = #{seqs_cp3[0].length};\n" if x == 2
	out << "  format datatype=dna missing=? gap=-;\n"
	out << "  matrix\n"
	ids.size.times do |i|
		out << "  #{ids[i].ljust(max_id_length)}  #{seqs_cp1[i]}\n" if x == 0
		out << "  #{ids[i].ljust(max_id_length)}  #{seqs_cp2[i]}\n" if x == 1
		out << "  #{ids[i].ljust(max_id_length)}  #{seqs_cp3[i]}\n" if x == 2
	end
	out << ";\n"
	out << "end;\n"
	out_file_name = input_file_name.chomp(".nex") + "_" + (x+1).to_s + ".nex"
	out_file = File.new(out_file_name,"w")
	out_file.write(out)
	out_file.close
	output_file_names << out_file_name
end

# Feedback.
puts "Wrote files #{output_file_names[0]}, #{output_file_names[1]}, and #{output_file_names[2]}."

