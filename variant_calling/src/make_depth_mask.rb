# m_matschiner Mon Feb 26 16:20:32 CET 2018

# Get the command-line arguments.
dump_file_name = ARGV[0]
min_dp = ARGV[1].to_i
max_dp = ARGV[2].to_i
lg_id = dump_file_name.split("/").last.split(".")[-2]

# Make sure the id was recognized correctly.
valid_lg_ids = ["NC_031965"]
valid_lg_ids << "NC_031966"
valid_lg_ids << "NC_031967"
valid_lg_ids << "NC_031968"
valid_lg_ids << "NC_031969"
valid_lg_ids << "NC_031970"
valid_lg_ids << "NC_031971"
valid_lg_ids << "NC_031972"
valid_lg_ids << "NC_031973"
valid_lg_ids << "NC_031974"
valid_lg_ids << "NC_031975"
valid_lg_ids << "NC_031976"
valid_lg_ids << "NC_031977"
valid_lg_ids << "NC_031978"
valid_lg_ids << "NC_031979"
valid_lg_ids << "NC_031980"
valid_lg_ids << "NC_031981"
valid_lg_ids << "NC_031982"
valid_lg_ids << "NC_031983"
valid_lg_ids << "NC_031984"
valid_lg_ids << "NC_031985"
valid_lg_ids << "NC_031986"
valid_lg_ids << "NC_031987"
valid_lg_ids << "UNPLACED"
unless valid_lg_ids.include?(lg_id)
  puts "ERROR: Linkage group #{lg_id} does not seem valid!"
  exit 1
end

# Read the dump file.
print "Reading dump file #{dump_file_name}..."
dump_file = File.open(dump_file_name)
depth_per_site_this_lg = Marshal.load(dump_file.read)
dump_file.close
puts " done."

# Prepare a string in bed format for regions that have a too low or too high depth.
bed_string_this_lg = "chrom\tchromStart\tchromEnd\n"
exclude_switch = false
first_pos_to_exclude = 0
(depth_per_site_this_lg.size-1).times do |x|
    if depth_per_site_this_lg[x] < min_dp or depth_per_site_this_lg[x] > max_dp
        if exclude_switch == false # If the previous site was not excluded but this one is.
            exclude_switch = true
            first_pos_to_exclude = x+1
        end
    else
        if exclude_switch == true # If the previous site was excluded but this one is not.
            exclude_switch = false
            bed_string_this_lg << "#{lg_id}\t#{first_pos_to_exclude}\t#{x}\n"
        end
    end
end
if exclude_switch == true
    bed_string_this_lg << "#{lg_id}\t#{first_pos_to_exclude}\t#{depth_per_site_this_lg.size+1}\n"
end

# Write a new bed file with a mask for regions that have a too low or too high depth.
bed_file_name = "#{dump_file_name.chomp(".dmp")}.depth.bed"
bed_file = File.open(bed_file_name,"w")
bed_file.write(bed_string_this_lg)
puts "Wrote mask to file #{bed_file_name}."
