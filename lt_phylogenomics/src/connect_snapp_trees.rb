# m_matschiner Mon Aug 5 15:45:11 CEST 2019

# Include the phylsim library.
$libPath = "./phylsim/"
require "./phylsim/main.rb"

# Get the command-line arguments.
backbone_trees_file_name = ARGV[0]
connection_table_file_name = ARGV[1]
connected_trees_file_name = ARGV[2]
log_dir = ARGV[3]

# Read the backbone trees.
backbone_trees_file = File.open(backbone_trees_file_name)
trees = backbone_trees_file.readlines

# Read the connection table.
connection_table_file = File.open(connection_table_file_name)
connection_table = connection_table_file.readlines

# Remove the header of the connection table.
connection_table = connection_table[1..-1]

# Replace parts of the backbone tree iteratively with the more specific trees.
connection_table.each do |l|
	
	# Determine the placeholder species pair and the replacement tree for this table row.
	line_ary = l.split
	placeholder_species = line_ary[0].split(",")
	inner_trees_file_id = line_ary[1]
	inner_trees_file_name = "tmp.#{inner_trees_file_id}.trees"
	log_file_name = "#{log_dir}/#{inner_trees_file_id}.log"

	# Feedback.
	if placeholder_species.size == 2
		puts "Replacing species #{placeholder_species[0]} and #{placeholder_species[1]} with strings from #{inner_trees_file_name}."
	elsif placeholder_species.size == 1
		puts "Replacing species #{placeholder_species[0]} with strings from #{inner_trees_file_name}."
	else
		puts "ERROR: Expected one or two placeholder species but found #{l.strip}!"
		exit 1
	end

	# Make sure that the inner trees file exists.
	if File.file?(inner_trees_file_name)

		# Read the replacement tree.
		inner_trees_file = File.open(inner_trees_file_name)
		inner_tree_strings = inner_trees_file.readlines
		inner_tree_trimmed_strings = []
		inner_tree_strings.each do |t|
			inner_tree_trimmed_strings << t.sub(":0;\n","").sub(";\n","")
		end

		# Get crown and stem ages of the group that is to be replaced in all trees.
		outer_tree_crown_ages = []
		outer_tree_stem_durations = []
		outer_tree_stem_ages = []
		outer_tree_find_strings = []
		trees.each do |t|
			outer_tree_crown_age = nil
			outer_tree_stem_duration = nil
			outer_tree_stem_age = nil
			outer_tree_find_string = nil
			if placeholder_species.size == 2
				if t.match(/\((#{placeholder_species[0]}|#{placeholder_species[1]}):(.+?),(#{placeholder_species[0]}|#{placeholder_species[1]}):(.+?)\):(.+?)[,\)]/)
					if $2.to_f.round(4) != $4.to_f.round(4)
						puts "ERROR: Could not parse tree string #{t} (the species pair #{placeholder_species[0]} and #{placeholder_species[1]} seem to have different ages: #{$2.to_f.round(4)} and #{$4.to_f.round(4)})!"
						exit 1
					else
						outer_tree_crown_age = $2.to_f
						outer_tree_stem_duration = $5.to_f
						outer_tree_stem_age = outer_tree_crown_age + outer_tree_stem_duration
						outer_tree_find_string = "(#{$1}:#{$2},#{$3}:#{$4}):#{$5}"
					end
				else
					puts "ERROR: No match could be found for match string \"\((#{placeholder_species[0]}|#{placeholder_species[1]}):(.+?),(#{placeholder_species[0]}|#{placeholder_species[1]}):(.+?)\):(.+?)[,\)]\" in tree string #{t}!"
					exit 1
				end
			elsif placeholder_species.size == 1
				if t.match(/(#{placeholder_species[0]}):(.+?)[,\)]/)
					outer_tree_crown_age = 0.0
					outer_tree_stem_duration = $2.to_f
					outer_tree_stem_age = $2.to_f
					outer_tree_find_string = "#{$1}:#{$2}"
				else
					puts "ERROR: Could not parse tree string #{t} (no age found for species #{placeholder_species[0]}!"
					exit 1
				end
			end
			if outer_tree_stem_duration == 0
				puts "ERROR: Could not parse tree string #{t} (a stem duration appears to be 0)!"
				exit 1
			end
			outer_tree_crown_ages << outer_tree_crown_age
			outer_tree_stem_durations << outer_tree_stem_duration
			outer_tree_find_strings << outer_tree_find_string
			outer_tree_stem_ages << outer_tree_stem_age
		end

		# Get the root ages of the inner tree.
		inner_tree_root_ages = []
		inner_tree_trimmed_strings.size.times do |x|
			tree = Tree.parse(fileName = inner_trees_file_name, fileType = "newick", diversityFileName = nil, treeNumber = x, verbose = false)
			inner_tree_root_ages << tree.treeOrigin
		end

		# Sort the outer trees according to the crown age of the group (in the case of two placeholder species),
		# or according to the stem age of the group (in the case of one placeholder species).
		sorted = false
		if placeholder_species.size == 2
			until sorted
				sorted = true
				(outer_tree_crown_ages.size-1).times do |x|
					x.upto(outer_tree_crown_ages.size-1) do |y|
						if outer_tree_crown_ages[x] > outer_tree_crown_ages[y]
							outer_tree_crown_ages[x],outer_tree_crown_ages[y] = outer_tree_crown_ages[y],outer_tree_crown_ages[x]
							outer_tree_stem_durations[x],outer_tree_stem_durations[y] = outer_tree_stem_durations[y],outer_tree_stem_durations[x]
							outer_tree_find_strings[x],outer_tree_find_strings[y] = outer_tree_find_strings[y],outer_tree_find_strings[x]
							outer_tree_stem_ages[x],outer_tree_stem_ages[y] = outer_tree_stem_ages[y],outer_tree_stem_ages[x]
							trees[x],trees[y] = trees[y],trees[x]
							sorted = false
						end
					end
				end
			end
		elsif placeholder_species.size == 1
			until sorted
				sorted = true
				(outer_tree_stem_ages.size-1).times do |x|
					x.upto(outer_tree_stem_ages.size-1) do |y|
						if outer_tree_stem_ages[x] > outer_tree_stem_ages[y]
							outer_tree_crown_ages[x],outer_tree_crown_ages[y] = outer_tree_crown_ages[y],outer_tree_crown_ages[x]
							outer_tree_stem_durations[x],outer_tree_stem_durations[y] = outer_tree_stem_durations[y],outer_tree_stem_durations[x]
							outer_tree_find_strings[x],outer_tree_find_strings[y] = outer_tree_find_strings[y],outer_tree_find_strings[x]
							outer_tree_stem_ages[x],outer_tree_stem_ages[y] = outer_tree_stem_ages[y],outer_tree_stem_ages[x]
							trees[x],trees[y] = trees[y],trees[x]
							sorted = false
						end
					end
				end
			end
		end

		# Sort the inner trees according to their root age.
		sorted = false
		until sorted
			sorted = true
			(inner_tree_root_ages.size-1).times do |x|
				x.upto(inner_tree_root_ages.size-1) do |y|
					if inner_tree_root_ages[x] > inner_tree_root_ages[y]
						inner_tree_root_ages[x],inner_tree_root_ages[y] = inner_tree_root_ages[y],inner_tree_root_ages[x]
						inner_tree_trimmed_strings[x],inner_tree_trimmed_strings[y] = inner_tree_trimmed_strings[y],inner_tree_trimmed_strings[x]
						sorted = false
					end
				end
			end
		end

		# Calculate the new stem age and make sure that it is always positive.
		new_stem_durations = []
		outer_tree_stem_ages.size.times do |x|
			new_stem_duration = outer_tree_stem_ages[x] - inner_tree_root_ages[x]
			if new_stem_duration < 0
				puts "WARNING: An outer stem age is younger than the internal root age (by a difference of #{-1*new_stem_duration})!"
			end
			new_stem_durations << new_stem_duration
		end

		# Replace the species pair in each (resorted) outer tree with the corresponding inner tree.
		trees.size.times do |x|
			find = outer_tree_find_strings[x]
			replace = "#{inner_tree_trimmed_strings[x]}:#{new_stem_durations[x]}"
			trees[x].sub!(find,replace)
		end

		# Prepare and write the log string.
		log_string = "outer_tree_stem_age\touter_tree_crown_age\tinner_tree_root_age\n"
		if inner_tree_root_ages.size != outer_tree_stem_ages.size or outer_tree_stem_ages.size != outer_tree_crown_ages.size
			puts "ERROR: Arrays have different lengths!"
		end
		inner_tree_root_ages.size.times do |x|
			log_string << "#{outer_tree_stem_ages[x]}\t#{outer_tree_crown_ages[x]}\t#{inner_tree_root_ages[x]}\n"
		end
		log_file = File.open(log_file_name, "w")
		log_file.write(log_string)

	else
		# Warn if the file for the replacement tree is not found.
		puts "WARNING: Could not find file #{inner_trees_file_name}!"

	end

end

# Prepare and write the output.
outstring = ""
trees.each do |t|
	outstring << "#{t}"
end
outfile = File.open(connected_trees_file_name,"w")
outfile.write(outstring)

# Feedback.
puts "Wrote file #{connected_trees_file_name}."
