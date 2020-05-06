# m_matschiner Wed Dec 7 13:18:45 CET 2016

# Define file names.
original_ref_file_name = "../data/reference/GCF_001858045.1_ASM185804v2_genomic.fna"
new_ref_file_name = "../data/reference/GCF_001858045.1_ASM185804v2_genomic_edit.fna"
translation_file_name = "../data/reference/GCF_001858045.1_ASM185804v2_genomic_edit.txt"

# Read the original reference file.
original_ref_file = File.open(original_ref_file_name)
original_ref_lines = original_ref_file.readlines
original_ids = []
original_seqs = []
original_ref_lines.each do |l|
	if l[0] == ">"
		original_ids << l[1..-1].strip
		original_seqs << ""
	elsif l != ""
		original_seqs.last << l
	end
end

# Define variables for the output.
new_ids = []
new_seqs = []
translation_string = "original id\tnew id (with location)\n"

# Convert the headers of chromosome scaffolds and the mitochondrial scaffold.
original_ids.size.times do |x|
	if original_ids[x][0..2] == "NC_"
		new_id = original_ids[x].split[0].chomp(".1")
		new_ids << new_id
		new_seqs << original_seqs[x]
		translation_string << "#{original_ids[x]}\t#{new_id}\n"
	end
end

# Combine the unplaced scaffolds.
new_seq = ""
original_ids.size.times do |x|
	if original_ids[x][0..2] == "NW_"
		clean_seq = original_seqs[x].gsub("\n","")
		new_seq_length_before = new_seq.size
		new_seq << clean_seq
		new_seq_length_after = new_seq.size
		translation_string << "#{original_ids[x]}\tUNPLACED (#{new_seq_length_before+1} - #{new_seq_length_after})\n"
		new_seq << "NNNNNNNNNN"
	end
end
new_seq.chomp!("NNNNNNNNNN")
new_seq_folded = ""
new_seq_size = new_seq.size
from = 0
to = 79
while to < new_seq_size-1
	new_seq_folded << "#{new_seq[from..to]}\n"
	from += 80
	to += 80
end
new_seq_folded << "#{new_seq[from..-1]}\n"
new_ids << "UNPLACED"
new_seqs << new_seq_folded

# Prepare the new reference string.
new_ref_string = ""
new_ids.size.times do |x|
	new_ref_string << ">#{new_ids[x]}\n"
	new_ref_string << new_seqs[x]
end

# Write translation string.
translation_file = File.open(translation_file_name,"w")
translation_file.write(translation_string)
translation_file.close

# Write the edited reference.
new_ref_file = File.open(new_ref_file_name,"w")
new_ref_file.write(new_ref_string)
new_ref_file.close
