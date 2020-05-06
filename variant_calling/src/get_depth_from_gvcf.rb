# m_matschiner Tue Mar 6 16:16:42 CET 2018

# Specify the lgs.
all_lg_ids = ["NC_031965","NC_031966","NC_031967","NC_031968","NC_031969","NC_031970","NC_031971","NC_031972","NC_031973","NC_031974","NC_031975","NC_031976","NC_031977","NC_031978","NC_031979","NC_031980","NC_031981","NC_031982","NC_031983","NC_031984","NC_031985","NC_031986","NC_031987","UNPLACED"]
all_lg_lengths = [38372991,35256741,14041792,54508961,38038224,34628617,44571662,62059223,30802437,27519051,32426571,36466354,41232431,32337344,39264731,36154882,40919683,37007722,31245232,36767035,37011614,44097196,43860769,141274046]

# Get the command-line arguments.
gvcf_file_name = ARGV[0]
dump_file_name = ARGV[1]

# Read the coverage file.
print "Reading file #{gvcf_file_name}..."
gvcf_file = File.open(gvcf_file_name)
gvcf_lines = gvcf_file.readlines

# Get the lg id.
lg_id = nil
gvcf_lines.each do |l|
  unless l[0] == "#"
    line_ary = l.split
    lg_id = line_ary[0]
    break
  end
end

# Make sure the lg is included in the lgs defined above
unless all_lg_ids.include?(lg_id)
  puts "ERROR: Linkage group #{lg_id} is not known."
  exit 1
end
lg_length = all_lg_lengths[all_lg_ids.index(lg_id)]

# Get the per-site depth from the gvcf file.  
depths = []
n_unparsed_lines = 0
gvcf_lines.size.times do |z|
  line = gvcf_lines[z]
  unless line[0] == "#"
    line_ary = line.split
    first_pos = line_ary[1].to_i
    if line_ary[7][0..2] == "END"
      last_pos = line_ary[7].split("=")[1].to_i
      depth_index_str = line_ary[8].split(":").index("MIN_DP")
      if depth_index_str == nil
        puts "ERROR: Block line could not be parsed:"
        puts line
        exit 1
      else
        depth_index = depth_index_str.to_i
      end
      depth = line_ary[9].split(":")[depth_index].to_i
    elsif line_ary[7][0..1] == "DP" or line_ary[7][0..11] == "BaseQRankSum"
      gt_length=line_ary[3].size
      last_pos = first_pos-1+gt_length
      if line_ary[7].include?("DP=")
        depth = line_ary[7].split("DP=")[1].split(";")[0].to_i
      else
        depth_index_str = line_ary[8].split(":").index("DP")
        if depth_index_str == nil
          n_unparsed_lines += 1 
          depth_index = 0
        else
          depth_index = depth_index_str.to_i
        end
        depth = line_ary[9].split(":")[depth_index].to_i
      end
    else
      puts "ERROR: Unexpected line:"
      puts line
      exit 1
    end
    (first_pos-1).upto(last_pos-1) do |x|
      depths[x] = depth
    end
  end
end
puts " done."

# Make sure the length of the depth array matches the lg length
unless depths.size == lg_length
  puts "ERROR: The length of the depth array (#{depths.size}) does not match the length of lg #{lg_id} (#{lg_length})!"
  exit 1
end

# Report how many sites could no be parsed.
if n_unparsed_lines > 0
  puts "WARNING: #{n_unparsed_lines} sites contained no depth information. Assuming that the depth at these sites is 0."
end

# Write the array of per-site coverages to a dump file.
dump_file = File.open(dump_file_name,"w")
dump_file.write(Marshal.dump(depths))

# Feedback.
puts "Wrote dump file #{dump_file_name}"
