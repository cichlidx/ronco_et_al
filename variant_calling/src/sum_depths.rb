# m_matschiner Mon Feb 26 16:20:32 CET 2018

# Get the linkage group id.
lg_id = ARGV[0]

# Get the names of all dump files for this lg.
dmp_file_names = []
Dir.entries("../res/gatk").each do |e|
  if e.include?(lg_id) and e.match(".dmp")
    dmp_file_names << e
  end
end

# Get the linkage group length.
all_lg_ids = ["NC_031965","NC_031966","NC_031967","NC_031968","NC_031969","NC_031970","NC_031971","NC_031972","NC_031973","NC_031974","NC_031975","NC_031976","NC_031977","NC_031978","NC_031979","NC_031980","NC_031981","NC_031982","NC_031983","NC_031984","NC_031985","NC_031986","NC_031987","UNPLACED"]
all_lg_lengths = [38372991,35256741,14041792,54508961,38038224,34628617,44571662,62059223,30802437,27519051,32426571,36466354,41232431,32337344,39264731,36154882,40919683,37007722,31245232,36767035,37011614,44097196,43860769,141274046]
unless all_lg_ids.include?(lg_id)
  puts "ERROR: linkage group #{lg_id} is unknown!"
  exit 1
end
lg_length = all_lg_lengths[all_lg_ids.index(lg_id)]

# Prepare an array for the summed depths of this linkage group.
sum_dmp_file_name = "../res/gatk/#{lg_id}.dmp"
depth_per_site_this_lg = []
lg_length.times {depth_per_site_this_lg << 0}

# Fill the array with depths from each individual.
dmp_file_names.each do |f|
  print "Reading dump file #{f}..."
  STDOUT.flush
  dump_file = File.open("../res/gatk/#{f}")
  depth_per_site_this_lg_this_individual = Marshal.load(dump_file.read)
  if depth_per_site_this_lg.size == depth_per_site_this_lg_this_individual.size
    depth_per_site_this_lg.size.times do |x|
      unless depth_per_site_this_lg_this_individual[x] == nil
        depth_per_site_this_lg[x] = depth_per_site_this_lg[x] + depth_per_site_this_lg_this_individual[x]
      end
    end
  else
    puts "ERROR: The size of the array in file #{f} does not match the size of the overall array!"
    exit 1
  end
  dump_file.close
  puts " done."
  STDOUT.flush
end

# Write a new dmp file with the sum of depth arrays.
new_dmp_file = File.open(sum_dmp_file_name,"w")
new_dmp_file.write(Marshal.dump(depth_per_site_this_lg))
