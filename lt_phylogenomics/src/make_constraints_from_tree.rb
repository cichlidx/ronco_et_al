# m_matschiner Wed Oct 17 17:54:04 CEST 2018

# $libPath = "/Users/m_matschiner/Software/Ruby/phylsim/"
$libPath = "./phylsim/"
require "./phylsim/main.rb"

# Get the command-line arguments.
tree_file_name = ARGV[0]
tree_file_format = ARGV[1]
constraint_file_name = ARGV[2]
root_age_mean = ARGV[3]
root_age_sigma = ARGV[4]
if ARGV[5] == nil
	outgroup_species_ids = []
else	
	outgroup_species_ids = ARGV[4].split(",")
end

# Parse the input tree.
tree = Tree.parse(fileName = ARGV[0], fileType = tree_file_format, diversityFileName = nil, treeNumber = 0, verbose = false)

# Get arrays of branch IDs and corresponding sets of progeny IDs.
branch_ids = []
branch_progeny_ids = []
tree.branch.each do |b|
	progeny_ids_this_branch = []
	direct_descendants = []
	if b.speciesId == "unknown"
		direct_descendants << b.daughterId[0]
		direct_descendants << b.daughterId[1]
	else
		progeny_ids_this_branch << b.speciesId
	end
	while direct_descendants.size > 0
		new_direct_descendants = []
		direct_descendants.each do |d|
			tree.branch.each do |bb|
				if bb.id == d
					if bb.speciesId == "unknown"
						new_direct_descendants << bb.daughterId[0]
						new_direct_descendants << bb.daughterId[1]
					else
						progeny_ids_this_branch << bb.speciesId
					end
					break
				end
			end
		end
		direct_descendants = new_direct_descendants
	end

	branch_ids << b.id
	branch_progeny_ids << progeny_ids_this_branch
end

# Write the constraint on the root age.
constraint_string = ""
constraint_string << "\t\t\t\t<distribution id=\"all.prior\" spec=\"beast.math.distributions.MRCAPrior\" tree=\"@tree.t:Species\" monophyletic=\"true\">\n"
constraint_string << "\t\t\t\t\t<taxonset id=\"all\" spec=\"TaxonSet\">\n"
branch_progeny_ids[0].each do |b|
	constraint_string << "\t\t\t\t\t\t<taxon idref=\"#{b}\"/>\n" unless outgroup_species_ids.include?(b)
end
branch_progeny_ids[1].each do |b|
	constraint_string << "\t\t\t\t\t\t<taxon idref=\"#{b}\"/>\n" unless outgroup_species_ids.include?(b)
end
constraint_string << "\t\t\t\t\t</taxonset>\n"
constraint_string << "\t\t\t\t\t<Normal name=\"distr\" mean=\"#{root_age_mean}\" sigma=\"#{root_age_sigma}\"/>\n" unless root_age_mean == nil
constraint_string << "\t\t\t\t</distribution>\n"

# Write constraints for all branches.
branch_ids.size.times do |x|
	if branch_progeny_ids[x].size > 1
		constraint_string << "\t\t\t\t<distribution id=\"#{branch_ids[x]}.prior\" spec=\"beast.math.distributions.MRCAPrior\" tree=\"@tree.t:Species\" monophyletic=\"true\">\n"
		constraint_string << "\t\t\t\t\t<taxonset id=\"#{branch_ids[x]}\" spec=\"TaxonSet\">\n"
		branch_progeny_ids[x].each do |b|
			constraint_string << "\t\t\t\t\t\t<taxon idref=\"#{b}\"/>\n"
		end
		constraint_string << "\t\t\t\t\t</taxonset>\n"
		constraint_string << "\t\t\t\t</distribution>\n"
	end
end

# Write the constraints string to a file.
constraint_file = File.open(constraint_file_name, "w")
constraint_file.write(constraint_string)
