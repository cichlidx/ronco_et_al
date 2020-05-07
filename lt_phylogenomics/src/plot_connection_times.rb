# m_matschiner Mon Mar 30 17:02:40 CEST 2020

# Define a class for lines of the SVG graph.
class Line
	def initialize(x_start,x_end,y_start,y_end,color,stroke,opacity,stroke_dasharray)
		@x_start = x_start
		@x_end = x_end
		@y_start = y_start
		@y_end = y_end
		@color = color
		@stroke = stroke
		@opacity = opacity
		@stroke_dasharray = stroke_dasharray
	end
	def to_svg
		if @stroke_dasharray == "none"
			svg = "<line x1=\"#{@x_start.round(3)}\" y1=\"#{@y_start.round(3)}\" x2=\"#{@x_end.round(3)}\" y2=\"#{@y_end.round(3)}\" stroke=\"#{@color}\" stroke-width=\"#{@stroke}\" stroke-opacity=\"#{@opacity}\" stroke-linecap=\"round\" />"
		else
			svg = "<line x1=\"#{@x_start.round(3)}\" y1=\"#{@y_start.round(3)}\" x2=\"#{@x_end.round(3)}\" y2=\"#{@y_end.round(3)}\" stroke=\"#{@color}\" stroke-width=\"#{@stroke}\" stroke-opacity=\"#{@opacity}\" stroke-linecap=\"round\" stroke-dasharray=\"#{@stroke_dasharray}\" />"
		end
		svg
	end
end

# Get the command line arguments.
log_file_name = ARGV[0]
minimum_age_outer = ARGV[1].to_f
maximum_age_outer = ARGV[2].to_f
minimum_age_inner = ARGV[3].to_f
maximum_age_inner = ARGV[4].to_f
plot_file_name = ARGV[5]

# Read the log file.
log_file = File.open(log_file_name)
log_lines = log_file.readlines
log_lines = log_lines[1..-1]
outer_tree_stem_ages = []
outer_tree_crown_ages = []
inner_tree_root_ages = []
log_lines.each do |l|
	line_ary = l.split
	outer_tree_stem_ages << line_ary[0].to_f
	outer_tree_crown_ages << line_ary[1].to_f
	inner_tree_root_ages << line_ary[2].to_f
end

# Prepare the svg.
lines = []
dim_x = 17.75
dim_y = 22.0
outer_tree_stem_ages.size.times do |x|
	if outer_tree_crown_ages[0] == 0.0
		age_outer = outer_tree_stem_ages[x]
	else
		age_outer = outer_tree_crown_ages[x]
	end
	age_inner = inner_tree_root_ages[x]
	y1_coord = (maximum_age_outer-age_outer)/(maximum_age_outer-minimum_age_outer) * dim_y
	y2_coord = (maximum_age_inner-age_inner)/(maximum_age_inner-minimum_age_inner) * dim_y
	lines << Line.new(0,dim_x,y1_coord,y2_coord,"black",1,1,"none")
end

# add a frame.
lines << Line.new(0,dim_x,0,0,"black",1,1,"none")
lines << Line.new(0,dim_x,dim_y,dim_y,"black",1,1,"none")
# lines << Line.new(0,0,0,dim_y,"black",1,1,"none")
# lines << Line.new(dim_x,dim_x,0,dim_y,"black",1,1,"none")

# Prepare the svg string.
svg_string = ""
svg_string << "<?xml version=\"1.0\" standalone=\"no\"?>\n"
svg_string << "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n"
svg_string << "<svg width=\"#{dim_x}mm\" height=\"#{dim_y}mm\" viewBox=\"0 0 #{dim_x} #{dim_y}\" xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\">\n"
lines.each {|l| svg_string << "    #{l.to_svg}\n"}
svg_string << "</svg>\n"

# Write the svg string to file.
svg_file = File.new(plot_file_name,"w")
svg_file.write(svg_string)

# Feedback.
puts "Wrote file #{plot_file_name}."
