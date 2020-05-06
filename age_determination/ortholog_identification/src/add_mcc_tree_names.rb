# m_matschiner Mon Nov 19 17:06:55 CET 2018

# Get the command-line arguments.
mcc_numbered_tree_file_name = ARGV[0]
mcc_name_list_file_name = ARGV[1]
mcc_named_tree_file_name = ARGV[2]

# Read the mcc-tree file.
mcc_tree_file = File.open(mcc_numbered_tree_file_name)
mcc_tree_string = mcc_tree_file.read

# Read the mcc-name list.
mcc_name_list_file = File.open(mcc_name_list_file_name)
mcc_names = []
mcc_name_list_file.readlines.each { |l| mcc_names << l.strip unless l.strip == "" }

# Replace numbers with names.
mcc_names.size.times do |x|
	mcc_tree_string.sub!("tree #{x} = ", "tree #{mcc_names[x]} = ")
end

# Write a new mcc tree file with tree names instead of numbers.
mcc_named_tree_file = File.open(mcc_named_tree_file_name, "w")
mcc_named_tree_file.write(mcc_tree_string)
