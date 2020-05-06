# m_matschiner Fri Jan 5 12:59:12 CET 2018

# Get the command-line arguments.
indel_list_file_name = ARGV[0]
indel_mask_file_name = ARGV[1]
if ARGV.size == 4
	min_pos = ARGV[2].to_i
	max_pos = ARGV[3].to_i
end

# Read the indel-list file.
indel_list_file = File.open(indel_list_file_name)
indel_list_lines = indel_list_file.readlines

# Analyze the indel list.
chrs = []
masked_pos = []
indel_list_lines.each do |l|
	line_ary = l.split
	chr = line_ary[0]
	chrs << chr
	pos = line_ary[1].to_i
	ref_allele = line_ary[2]
	alt_alleles = line_ary[3].split(",")
	ref_allele_length = ref_allele.size
	alt_alleles_max_length = 0
	alt_alleles.each {|a| alt_alleles_max_length = a.size if a.size > alt_alleles_max_length}
	any_alleles_max_length = [ref_allele_length,alt_alleles_max_length].max
	if ref_allele_length == 1
		# Mask the position itself.
		masked_pos << pos
		# Mask positions +/- 2 bp for insertions of 1 bp and larger.
		if alt_alleles_max_length >= 2
			masked_pos << pos - 1
			masked_pos << pos + 1
			masked_pos << pos + 2
		end
		# Mask positions +/- 3 bp for insertions of 2 bp and larger.
		if alt_alleles_max_length >= 3
			masked_pos << pos - 2
			masked_pos << pos + 3
		end
                # Mask positions +/- 5 bp for insertions of 3 bp and larger.
                if alt_alleles_max_length >= 4
                        masked_pos << pos - 4
                        masked_pos << pos - 3
                        masked_pos << pos + 4
                        masked_pos << pos + 5
                end
		# Mask positions +/- 10 bp for insertions of 5 bp and larger.
		if alt_alleles_max_length >= 6
			masked_pos << pos - 9
			masked_pos << pos - 8
			masked_pos << pos - 7
			masked_pos << pos - 6
			masked_pos << pos - 5
			masked_pos << pos + 6
			masked_pos << pos + 7
			masked_pos << pos + 8
			masked_pos << pos + 9
			masked_pos << pos + 10
		end
	elsif ref_allele_length > 1
		# Mask the position itself.
		ref_allele_length.times do |x|
			masked_pos << pos + x
		end
		# Mask positions +/- 2 bp for indels of 1 bp and larger.
		if any_alleles_max_length >= 2
			masked_pos << pos - 1
			masked_pos << pos + ref_allele_length
			masked_pos << pos + ref_allele_length + 1
		end
		# Mask positions +/- 3 bp for indels of 2 bp and larger.
		if any_alleles_max_length >= 3
			masked_pos << pos - 2
			masked_pos << pos + ref_allele_length + 2
		end
                # Mask positions +/- 5 bp for indels of 3 bp and larger.
                if any_alleles_max_length >= 4
                        masked_pos << pos - 4
                        masked_pos << pos - 3
                        masked_pos << pos + ref_allele_length + 3
                        masked_pos << pos + ref_allele_length + 4
                end
		# Mask positions +/- 10 bp for indels of 5 bp and larger.
		if any_alleles_max_length >= 6
			masked_pos << pos - 9
			masked_pos << pos - 8
			masked_pos << pos - 7
			masked_pos << pos - 6
			masked_pos << pos - 5
 			masked_pos << pos + ref_allele_length + 5
			masked_pos << pos + ref_allele_length + 6
			masked_pos << pos + ref_allele_length + 7
			masked_pos << pos + ref_allele_length + 8
			masked_pos << pos + ref_allele_length + 9
		end
	end
end

# Make sure that only a single chromosome is used.
if chrs.uniq.size > 1
	puts "ERROR: More than one chromosome ids were found: "
	chrs.each do |c|
		puts "ERROR: #{c}"
	end
	puts "ERROR: This script assumes that all sites are on the same chromosome."
	exit 1
end
chr = chrs[0]

# Make an array of unique masked positions.
uniq_masked_pos = masked_pos.sort.uniq

# Remove positions that are outside the minimum and maximum positions.
if ARGV.size == 4 and min_pos > 0
	uniq_masked_pos_tmp = []
	uniq_masked_pos.each do |i|
		uniq_masked_pos_tmp << i if i >= min_pos and i <= max_pos
	end
	uniq_masked_pos = uniq_masked_pos_tmp
end

# Generate a list in bed format.
from = 0
to = 0
array_pos = 0
bed_string = "chrom\tchromStart\tchromEnd\n"
unless uniq_masked_pos == []
	until to == uniq_masked_pos.last
		from = uniq_masked_pos[array_pos]
		until uniq_masked_pos[array_pos+1] > uniq_masked_pos[array_pos] + 1
			array_pos += 1
			break if array_pos + 1 > uniq_masked_pos.size - 1
		end
		to = uniq_masked_pos[array_pos]
		array_pos += 1
		bed_string << "#{chr}\t#{from}\t#{to}\n"
	end
end

# Write the mask in bed format to file.
indel_mask_file = File.open(indel_mask_file_name,"w")
indel_mask_file.write(bed_string)
indel_mask_file.close

# Feedback.
puts "Masked #{uniq_masked_pos.size} sites due to proximity to indels."
