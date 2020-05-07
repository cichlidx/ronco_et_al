# m_matschiner Thu May 10 12:20:01 CEST 2018

# Get the command-line arguments.
vcf_file_name = ARGV[0]
nexus_file_name = ARGV[1]
samples_to_split = ARGV[2].split(",")

# Feedback.
puts
puts "Input vcf file: #{vcf_file_name}."
puts "Output nexus file: #{nexus_file_name}"
print "Samples to split:"
samples_to_split.each do |s|
    print " #{s}"
end
puts
puts
STDOUT.flush

# Open the input vcf file.
print "Opening vcf file #{vcf_file_name}..."
STDOUT.flush
vcf_file = File.open(vcf_file_name)
puts " done."
STDOUT.flush

# Read each line of the input vcf file and add gts to sequences.
ids = []
ids_after_splitting = []
seqs_after_splitting = []
ids_found = false
previous_lg = ""
vcf_file.each do |l|
    if l[0] == "#"
        if l[0..5] == "#CHROM"
            ids = l.split[9..-1]
            ids.each do |i|
                if samples_to_split.include?(i)
                    ids_after_splitting << "#{i}_1"
                    seqs_after_splitting << ""
                    ids_after_splitting << "#{i}_2"
                    seqs_after_splitting << ""
                else
                    ids_after_splitting << i
                    seqs_after_splitting << ""
                end
            end
            ids_found = true
        end
    elsif ids_found
        line_ary = l.split
        lg = line_ary[0]
        if previous_lg == ""
            print "Reading #{lg}..."
            STDOUT.flush
        elsif lg != previous_lg
            puts " done."
            print "Reading #{lg}..."
            STDOUT.flush
        end
        previous_lg = lg
        ref = line_ary[3]
        alt = line_ary[4]
        alleles = [ref]
        alt.split(",").each do |a|
            alleles << a
        end
        ids.size.times do |x|
            gt = line_ary[9+x]
            gt = ".|." if gt == "."
            if gt.match(/([\d\.])\|([\d\.])/)
                if $1 == "." and $2 == "."
                    sample_allele1 = "N"
                    sample_allele2 = "N"
                else
                    sample_allele1 = alleles[$1.to_i]
                    sample_allele2 = alleles[$2.to_i]
                end
                if samples_to_split.include?(ids[x])
                    if ids_after_splitting.include?("#{ids[x]}_1")
                        seqs_after_splitting[ids_after_splitting.index("#{ids[x]}_1")] << sample_allele1
                    else
                        puts "ERROR: ID #{ids[x]}_1 could not be found!"
                        exit 1
                    end
                    if ids_after_splitting.include?("#{ids[x]}_1")
                        seqs_after_splitting[ids_after_splitting.index("#{ids[x]}_2")] << sample_allele2
                    else
                        puts "ERROR: ID #{ids[x]}_2 could not be found!"
                        exit 1
                    end
                else
                    if sample_allele1 == "A" and sample_allele2 == "A"
                        gt_iupac = "A"
                    elsif sample_allele1 == "A" and sample_allele2 == "C"
                        gt_iupac = "M"
                    elsif sample_allele1 == "A" and sample_allele2 == "G"
                        gt_iupac = "R"
                    elsif sample_allele1 == "A" and sample_allele2 == "T"
                        gt_iupac = "W"
                    elsif sample_allele1 == "C" and sample_allele2 == "A"
                        gt_iupac = "M"
                    elsif sample_allele1 == "C" and sample_allele2 == "C"
                        gt_iupac = "C"
                    elsif sample_allele1 == "C" and sample_allele2 == "G"
                        gt_iupac = "S"
                    elsif sample_allele1 == "C" and sample_allele2 == "T"
                        gt_iupac = "Y"
                    elsif sample_allele1 == "G" and sample_allele2 == "A"
                        gt_iupac = "R"
                    elsif sample_allele1 == "G" and sample_allele2 == "C"
                        gt_iupac = "S"
                    elsif sample_allele1 == "G" and sample_allele2 == "G"
                        gt_iupac = "G"
                    elsif sample_allele1 == "G" and sample_allele2 == "T"
                        gt_iupac = "K"
                    elsif sample_allele1 == "T" and sample_allele2 == "A"
                        gt_iupac = "W"
                    elsif sample_allele1 == "T" and sample_allele2 == "C"
                        gt_iupac = "Y"
                    elsif sample_allele1 == "T" and sample_allele2 == "G"
                        gt_iupac = "K"
                    elsif sample_allele1 == "T" and sample_allele2 == "T"
                        gt_iupac = "T"
                    elsif sample_allele1 == "N" and sample_allele2 == "N"
                        gt_iupac = "N"
                    else
                        puts "ERROR: Unexpected genotype: #{gt}, recognized as alleles #{sample_allele1} and #{sample_allele2}!"
                        exit 1
                    end
                    if ids_after_splitting.include?("#{ids[x]}")
                        seqs_after_splitting[ids_after_splitting.index(ids[x])] << gt_iupac
                    else
                        puts "ERROR: ID #{ids[x]} could not be found!"
                        exit 1
                    end
                end
            else
                puts "ERROR: A genotype (#{gt}) could not be read correctly!"
                puts "  This was found on the following line:"
                puts "  #{l}"
                exit 1
            end
        end
    else
        puts "ERROR: The vcf header could not be read correctly!"
        exit 1
    end
end
puts " done."
STDOUT.flush

# Prepare the Nexus string.
print "Preparing the nexus string..."
nexus_str = "#NEXUS\n"
nexus_str << "\n"
nexus_str << "BEGIN DATA;\n"
nexus_str << "        DIMENSIONS NTAX=#{ids_after_splitting.size} NCHAR=#{seqs_after_splitting[0].size};\n"
nexus_str << "        FORMAT DATATYPE=DNA MISSING=N GAP=- ;\n"
nexus_str << "\n"
nexus_str << "MATRIX\n"
nexus_str << "\n"
ids_after_splitting.size.times do |x|
    nexus_str << "#{ids_after_splitting[x].ljust(10)}#{seqs_after_splitting[x]}\n"
end
nexus_str << ";\n"
nexus_str << "END;\n"
puts " done."

# Write the Nexus string to file.
print "Writing the nexus file #{nexus_file_name}..."
nexus_file = File.open(nexus_file_name,"w")
nexus_file.write(nexus_str)
puts " done."

