require 'awesome_print'
require 'musique'
require 'optparse'

@options= {
	:open_strings		=> %w[E A D G B E],
	:strings_to_use		=> 0..5,
	:number_of_frets	=> 20,
	:position_size		=> 6,
	:starting_fret		=> 0,
	:chord_progression	=> "C,E,G-F,A,C-G,B,D".split("-").map{|chord| chord.split(",").map{|note_name| Music::Note.new(note_name)}}
}

OptionParser.new do |opts|

	opts.on("-o", "--open_strings STRINGS", "Open strings") do |o|
		@options[:open_strings]= o.split(",")
	end
	opts.on("-t", "--strings_to_use STRING", "Strings to use") do |t|
		@options[:strings_to_use] = t.split(",").map{|string_num| string_num.include?("-") ? ((string_num.split("-")[0].to_i)..(string_num.split("-")[1].to_i)).to_a : string_num}.flatten
	end
	opts.on("-n", "--number_of_frets NUM", "Number of frets") do |n|
		@options[:number_of_frets]= n.to_i
	end
	opts.on("-s", "--position_size SIZE", "Position size") do |s|
		@options[:position_size]= s.to_i
	end
	opts.on("-f", "--starting_fret FRET", "Position fret") do |f|
		@options[:starting_fret]= f.to_i
	end
	opts.on("-c", "--chord_progression PROG", "Chord Progression") do |c|
		@options[:chord_progression]= c.split("-").map{|chord| chord.split(",").map{|note_name| Music::Note.new(note_name)}}
	end

end.parse!

required_options = @options.select{|opt,val| val.nil?}
if !required_options.empty?
	ap "Please enter the following options:"
	ap required_options
	exit
end
ap @options
puts
puts

LETTER_MAP = {
	'A'=> 1.0,
	'B'=> 2.0,
	'C'=> 3.0,
	'D'=> 4.0,
	'E'=> 5.0,
	'F'=> 6.0,
	'G'=> 7.0

}
MINOR_SECOND = Music::Interval.new(2, :minor)
# ap MINOR_SECOND

def note_to_number(note)
	# ap note
	base = LETTER_MAP[note.letter]
	accidental = note.accidental
	case accidental
	when "#"
		base+= 0.5
	when "♭"
		base-= 0.5
	end
	# ap base

	return base
end

# def transpose(matrix)
#   new_matrix = []

#   i = 0
#   while i < matrix.size
#     new_matrix[i] = []
#     j = 0  # move this here
#     while j < matrix.size
#       new_matrix[i] << matrix[j][i]
#       j += 1
#     end
#     i += 1
#   end

#   return new_matrix
# end

@fretboard = []
@options[:open_strings].each do |open_string_note|
	note = Music::Note.new(open_string_note)

	this_string = []
	@options[:number_of_frets].times do |fret_number|
		current_note_num = note_to_number(note)
		this_string<<current_note_num
		# ap note
		note = note.name[1]=="♭" ? Music::Note.new(note.name[0]) :  note.transpose_up(MINOR_SECOND)
		# ap note
	end

	@fretboard<<this_string

end

# ap @fretboard

chord_shapes = {}
@options[:chord_progression].each do |chord|
	fret_region = []
	notes_in_chord = chord#.notes#.map(&:name)

	chord_to_num_translator = {}
	note_names_in_chord = notes_in_chord.map(&:name)
	note_nums_in_chord = notes_in_chord.map{|note| note_to_number(note)}
	chord_to_num_translator = Hash[note_nums_in_chord.zip(note_names_in_chord)]

	@fretboard.each_with_index do |string, string_num|
		string_region = string[@options[:starting_fret], @options[:position_size]]
		string_region.map!{|fret| (@options[:strings_to_use].include?(string_num) && note_nums_in_chord.include?(fret)) ? chord_to_num_translator[fret] : "x"}
		fret_region<<string_region
	end
	# notes_in_chord.each do |note|
	# 	note_num = note_to_number(note)

	# 	@fretboard.each_with_index do |string, string_num|
	# 		string_region = string[@options[:starting_fret], @options[:position_size]]
	# 		string_region.map!{|fret| (@options[:strings_to_use].include?(string_num) && fret==note_num) ? note.name : "x"}
	# 		fret_region<<string_region
	# 	end
	# end

	chord_shapes[note_names_in_chord.join(",")] = fret_region
end

chord_shapes.each do |name, chord_shape|
	ap name
	# chord_shape = transpose(chord_shape)
	chord_shape.reverse!
	chord_shape.each do |string|
		string.each do |fret|
			print fret
		end
		puts
	end
	puts
end




























