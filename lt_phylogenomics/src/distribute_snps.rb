# m_matschiner Wed Apr 4 16:26:53 CEST 2018

# Load the zlib library.
require "zlib"

# Get the input file name.
gzvcf_in_file_name = ARGV[0]

# Set the output file names.
gzvcf_out_file_names = []
100.times do |x|
	gzvcf_out_file_names << "#{gzvcf_in_file_name.chomp(".vcf.gz")}.s#{(x+1).to_s.rjust(3).gsub(" ","0")}.vcf.gz"
end

# Open the output file names.
gzvcf_out_files = []
gzvcf_out_file_names.each do |f|
	gzvcf_out_files << Zlib::GzipWriter.open(f)
end

# Write 100 output files, each with a different set of sites.
count = 0
Zlib::GzipReader.open(gzvcf_in_file_name).each do |l|
	if l[0] == "#"
		gzvcf_out_files.each do |f|
			f.write(l)
		end
	else
		gzvcf_out_files[count].write(l)
		count += 1
		count = 0 if count == 100
	end
end
gzvcf_out_files.each {|f| f.close}