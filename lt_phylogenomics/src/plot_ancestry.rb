# Michael Matschiner, 2016-03-09

# This script reads the output of script 
# determine_alleles_for_sites_fixed_in_parents.rb
# and produces plots for the ancestry of hybrid
# individuals.

# Read the input file.
infile_name = ARGV[0]
infile = File.open(infile_name)
lines = infile.readlines
outfile_name = ARGV[1]
required_completeness = ARGV[2].to_f
thinning_distance = ARGV[3].to_i

# Define the ids of all specimens.
specimen_ids = lines[0].split[4..-1]
n_specimens = specimen_ids.size

# Prepare an empty matrix as the basis for the plots.
specimen_allele1 = []
specimen_allele2 = []
n_specimens.times do |x|
	specimen_allele1[x] = []
	specimen_allele2[x] = []
end

# Analyse the presence of parent alleles in all specimens.
scaffolds_for_all_selected_sites = []
positions_for_all_selected_sites = []
new_scaffold = []
previous_scaffold = nil
previous_position = nil
lines[1..-1].each do |l|
	line_ary = l.split
	scaffold = line_ary[0]
	position = line_ary[1].to_i
	parent1_allele = line_ary[2]
	parent2_allele = line_ary[3]
	alleles_this_pos = line_ary[4..-1]
	# Make sure the number of alleles at this position is identical to that of specimen ids.
	unless alleles_this_pos.size == n_specimens
		puts "ERROR: The number of alleles found at position #{position} does not match the number of specimens #{specimens}!"
		exit
	end
	# Check if the completeness at this position is sufficient.
	if alleles_this_pos.count("./.") + alleles_this_pos.count(".|.") <= alleles_this_pos.size*(1-required_completeness)
		# Check if this position is sufficiently distant to the previous position.
		if previous_position == nil or position < previous_position or position > previous_position + thinning_distance
			alleles_this_pos.size.times do |x|
				if alleles_this_pos[x].include?("/")
					alleles_this_pos_this_specimen = alleles_this_pos[x].split("/")
				elsif alleles_this_pos[x].include?("|")
					alleles_this_pos_this_specimen = alleles_this_pos[x].split("|")
				else
					puts "ERROR: Expected alleles to be separated eiter by '/' or '|' but found #{alleles_this_pos_this_specimen}!"
					exit
				end
				if alleles_this_pos_this_specimen[0] == parent1_allele
					specimen_allele1[x] << "p1"
				elsif alleles_this_pos_this_specimen[0] == parent2_allele
					specimen_allele1[x] << "p2"
				elsif alleles_this_pos_this_specimen[0] == "."
					specimen_allele1[x] << "m"
				else
					puts "WARNING: Expected either one of the parental alleles #{parent1_allele} and #{parent2_allele} or missing data coded with '.' but found #{alleles_this_pos_this_specimen[0]}."
					specimen_allele1[x] << "m"
				end
				if alleles_this_pos_this_specimen[1] == parent1_allele
					specimen_allele2[x] << "p1"
				elsif alleles_this_pos_this_specimen[1] == parent2_allele
					specimen_allele2[x] << "p2"
				elsif alleles_this_pos_this_specimen[1] == "."
					specimen_allele2[x] << "m"
				else
					puts "WARNING: Expected either one of the parental alleles #{parent1_allele} and #{parent2_allele} or missing data coded with '.' but found #{alleles_this_pos_this_specimen[1]}."
					specimen_allele2[x] << "m"
				end
			end
			if previous_scaffold == nil
				new_scaffold << false
			else
				if scaffold == previous_scaffold
					new_scaffold << false
				else
					new_scaffold << true
				end
			end
			previous_scaffold = scaffold
			previous_position = position
			scaffolds_for_all_selected_sites << scaffold
			positions_for_all_selected_sites << position
		end
	end
end

# Get the number of sites included in the plot.
n_sites = specimen_allele1[0].size

# Feedback.
puts "Found #{n_sites} positions with the required completeness."

# Some specifications for the SVG string.
top_margin = 10
bottom_margin = 10
left_margin = 10
left_text_block_width = 40
right_margin = 10
dim_x = 800
dim_y = 600
line_color = "5b5b5b"
color1 = "ef2746"
color2 = "27abd0"
font_size = 12
font_correction_y = 7
height = ((dim_y - top_margin - bottom_margin) / n_specimens.to_f) / 2.0
width = (dim_x - left_margin - left_text_block_width - right_margin) / n_sites.to_f

# Build the SVG header.
svgstring = "<?xml version=\"1.0\" standalone=\"no\"?>\n"
svgstring << "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.0//EN\" \"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd\">\n"
svgstring << "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"#{dim_x}\" height=\"#{dim_y}\" viewBox=\"0 0 #{dim_x} #{dim_y}\" xmlns:xlink=\"htttp://www.w3.org/1999/xlink\">\n\n"
svgstring << "\n"

# Draw each individual block.
n_specimens.times do |y|
	top_left_y = top_margin + y * (2 * height)
	# Draw blocks for the first alleles of this specimen.
	prev_allele = "m"
	prev_allele_first_site = 0
	n_sites.times do |x|
		top_left_x = left_margin + left_text_block_width + prev_allele_first_site * width
		this_allele = specimen_allele1[y][x]
		unless this_allele == prev_allele
			prev_allele_last_site = x-1
			top_right_x = left_margin + left_text_block_width + prev_allele_last_site * width
			if prev_allele == "p1"
				svgstring << "<rect fill=\"##{color1}\" x=\"#{top_left_x.round(3)}\" y=\"#{top_left_y.round(4)}\" width=\"#{(top_right_x-top_left_x+width).round(4)}\" height=\"#{height.round(3)}\" />\n"
			elsif prev_allele == "p2"
				svgstring << "<rect fill=\"##{color2}\" x=\"#{top_left_x.round(3)}\" y=\"#{top_left_y.round(4)}\" width=\"#{(top_right_x-top_left_x+width).round(4)}\" height=\"#{height.round(3)}\" />\n"
			end
		end
		if new_scaffold[x]
			prev_allele_last_site = x-1
			top_right_x = left_margin + left_text_block_width + prev_allele_last_site * width
			if prev_allele == "p1"
				svgstring << "<rect fill=\"##{color1}\" x=\"#{top_left_x.round(3)}\" y=\"#{top_left_y.round(4)}\" width=\"#{(top_right_x-top_left_x+width).round(4)}\" height=\"#{height.round(3)}\" />\n"
			elsif prev_allele == "p2"
				svgstring << "<rect fill=\"##{color2}\" x=\"#{top_left_x.round(3)}\" y=\"#{top_left_y.round(4)}\" width=\"#{(top_right_x-top_left_x+width).round(4)}\" height=\"#{height.round(3)}\" />\n"
			end
			prev_allele = "m"
			prev_allele_first_site = 0
		elsif x == n_sites-1
			top_right_x = dim_x-right_margin
			if this_allele == "p1"
				svgstring << "<rect fill=\"##{color1}\" x=\"#{top_left_x.round(3)}\" y=\"#{top_left_y.round(4)}\" width=\"#{(top_right_x-top_left_x+width).round(4)}\" height=\"#{height.round(3)}\" />\n"
			elsif this_allele == "p2"
				svgstring << "<rect fill=\"##{color2}\" x=\"#{top_left_x.round(3)}\" y=\"#{top_left_y.round(4)}\" width=\"#{(top_right_x-top_left_x+width).round(4)}\" height=\"#{height.round(3)}\" />\n"
			end

		else
			prev_allele_first_site = x unless this_allele == prev_allele
			prev_allele = this_allele
		end
	end
	# Draw blocks for the second alleles of this specimen.
	prev_allele = "m"
	prev_allele_first_site = 0

	n_sites.times do |x|
		top_left_x = left_margin + left_text_block_width + prev_allele_first_site * width
		this_allele = specimen_allele2[y][x]
		unless this_allele == prev_allele
			prev_allele_last_site = x-1
			top_right_x = left_margin + left_text_block_width + prev_allele_last_site * width
			if prev_allele == "p1"
				svgstring << "<rect fill=\"##{color1}\" x=\"#{top_left_x.round(3)}\" y=\"#{(top_left_y+height).round(4)}\" width=\"#{(top_right_x-top_left_x+width).round(4)}\" height=\"#{height.round(3)}\" />\n"
			elsif prev_allele == "p2"
				svgstring << "<rect fill=\"##{color2}\" x=\"#{top_left_x.round(3)}\" y=\"#{(top_left_y+height).round(4)}\" width=\"#{(top_right_x-top_left_x+width).round(4)}\" height=\"#{height.round(3)}\" />\n"
			end
		end
		if new_scaffold[x]
			prev_allele_last_site = x-1
			top_right_x = left_margin + left_text_block_width + prev_allele_last_site * width
			if prev_allele == "p1"
				svgstring << "<rect fill=\"##{color1}\" x=\"#{top_left_x.round(3)}\" y=\"#{(top_left_y+height).round(4)}\" width=\"#{(top_right_x-top_left_x+width).round(4)}\" height=\"#{height.round(3)}\" />\n"
			elsif prev_allele == "p2"
				svgstring << "<rect fill=\"##{color2}\" x=\"#{top_left_x.round(3)}\" y=\"#{(top_left_y+height).round(4)}\" width=\"#{(top_right_x-top_left_x+width).round(4)}\" height=\"#{height.round(3)}\" />\n"
			end
			prev_allele = "m"
			prev_allele_first_site = 0
		elsif x == n_sites-1
			top_right_x = dim_x-right_margin
			if this_allele == "p1"
				svgstring << "<rect fill=\"##{color1}\" x=\"#{top_left_x.round(3)}\" y=\"#{(top_left_y+height).round(4)}\" width=\"#{(top_right_x-top_left_x+width).round(4)}\" height=\"#{height.round(3)}\" />\n"
			elsif this_allele == "p2"
				svgstring << "<rect fill=\"##{color2}\" x=\"#{top_left_x.round(3)}\" y=\"#{(top_left_y+height).round(4)}\" width=\"#{(top_right_x-top_left_x+width).round(4)}\" height=\"#{height.round(3)}\" />\n"
			end

		else
			prev_allele_first_site = x unless this_allele == prev_allele
			prev_allele = this_allele
		end
	end
end

# Draw a horizontal line above the blocks for this specimen.
n_specimens.times do |y|
	top_left_y = top_margin + y * (2 * height)
	unless y == 0
		svgstring << "<line stroke=\"##{line_color}\" x1=\"#{left_margin + left_text_block_width}\" y1=\"#{top_left_y}\" x2=\"#{dim_x - right_margin}\" y2=\"#{top_left_y}\" />\n"
	end
end

# Add the specimen name at the left of the plot.
n_specimens.times do |y|
	top_left_y = top_margin + y * (2 * height)
	svgstring << "<text x=\"#{left_margin}\" y=\"#{top_left_y+height+font_correction_y}\" fill=\"black\" font-family=\"Helvetica\" font-size=\"#{font_size}\">#{specimen_ids[y]}</text>\n"
end

# Draw the scaffold boundaries.
height = (dim_y - top_margin - bottom_margin)
n_sites.times do |x|
	if new_scaffold[x]
		top_left_x = left_margin + left_text_block_width + x * width
		top_left_y = top_margin
		svgstring << "<line stroke=\"##{line_color}\" x1=\"#{top_left_x}\" y1=\"#{top_left_y}\" x2=\"#{top_left_x}\" y2=\"#{top_left_y+height}\" />\n"
	end
end

# Draw the frame.
svgstring << "<rect stroke=\"##{line_color}\" fill=\"none\" x=\"#{left_margin+left_text_block_width}\" y=\"#{top_margin}\" width=\"#{dim_x-left_margin-left_text_block_width-right_margin}\" height=\"#{dim_y-top_margin-bottom_margin}\" />\n"

# Finalize the svg string.
svgstring << "\n"
svgstring << "</svg>\n"

# Write the svg string to file.
outfile = File.open(outfile_name,"w")
outfile.write(svgstring)
outfile.close

# Feedback.
puts "Wrote file #{outfile_name}."
