# m_matschiner Sat May 6 01:18:00 CEST 2017

# Get command line arguments.
input_file_name = ARGV[0]
translation_file_name = ARGV[1]
output_file_name = ARGV[2]

# Read the input tree file.
tree = File.open(input_file_name).read

# Read the translation file.
translation_lines = File.open(translation_file_name).readlines

# Translate the tree ids.
translation_lines.each do |l|
  id = l.split[0]
  spc = l.split[1]
  tree.sub!("#{id}:","#{id}__#{spc}:")
  tree.sub!("#{id}_1:","#{id}_1__#{spc}:")
  tree.sub!("#{id}_2:","#{id}_2__#{spc}:")
end

# Write the output file.
output_file = File.open(output_file_name,"w")
output_file.write(tree)
