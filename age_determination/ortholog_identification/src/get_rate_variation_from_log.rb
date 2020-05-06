# m_matschiner Tue Jul 24 13:02:25 CEST 2018

module Enumerable
    def sum
        self.inject(0){|accum, i| accum + i }
    end
    def mean
        if self.length == 0
            nil
        else
            self.sum/self.length.to_f
        end
    end
end

# Get the command line arguments.
log_file_name = ARGV[0]

# Read the BEAST log file.
log_file = File.open(log_file_name)
log_lines = log_file.readlines
coefficients_of_variation = []
mutation_rates = []
out_of_comments = false
coefficients_of_variation_index = nil
mutation_rate_index = nil
log_lines.each do |l|
    line_ary = l.split
    if line_ary[0].downcase == "sample"
        out_of_comments = true
        line_ary.size.times do |x|
            coefficients_of_variation_index = x if line_ary[x].match(/ucldStdev/)
            mutation_rate_index = x if line_ary[x].match(/mutationRate/)
        end
    elsif out_of_comments
        unless l[0] == "#"
            if coefficients_of_variation_index == 0
                puts "ERROR: Column for coefficient of variation could not be found!"
                exit 1
            end
            coefficients_of_variation << line_ary[coefficients_of_variation_index].to_f
            if mutation_rate_index == 0
                puts "ERROR: Column for mutation rate could not be found!"
                exit 1
            end
            mutation_rates << line_ary[mutation_rate_index].to_f
        end
    end
end
if coefficients_of_variation.size == 0
    puts "ERROR: Coefficient of variation could not be read!"
    exit 1
end
coefficients_of_variation = coefficients_of_variation[1..-1]
number_of_burnin_samples = (coefficients_of_variation.size)/5
coefficients_of_variation_wo_burnin = coefficients_of_variation[number_of_burnin_samples+1..-1]
coefficients_of_variation_wo_burnin_mean = coefficients_of_variation_wo_burnin.mean
mutation_rates_wo_burnin = mutation_rates[number_of_burnin_samples+1..-1]
mutation_rates_wo_burnin_mean = mutation_rates_wo_burnin.mean

# Report the mean estimates for the coefficient of variation and the mutation rate.
puts "#{mutation_rates_wo_burnin_mean}\t#{coefficients_of_variation_wo_burnin_mean}"
