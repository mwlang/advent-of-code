#   0:      1:      2:      3:      4:
#  aaaa    ....    aaaa    aaaa    ....
# b    c  .    c  .    c  .    c  b    c
# b    c  .    c  .    c  .    c  b    c
#  ....    ....    dddd    dddd    dddd
# e    f  .    f  e    .  .    f  .    f
# e    f  .    f  e    .  .    f  .    f
#  gggg    ....    gggg    gggg    ....

#   5:      6:      7:      8:      9:
#  aaaa    aaaa    aaaa    aaaa    aaaa
# b    .  b    .  .    c  b    c  b    c
# b    .  b    .  .    c  b    c  b    c
#  dddd    dddd    ....    dddd    dddd
# .    f  e    f  .    f  e    f  .    f
# .    f  e    f  .    f  e    f  .    f
#  gggg    gggg    ....    gggg    gggg

require 'set'

SEGMENTS = %i(a b c d e f g).freeze
SEGMENT_MAP = {
  1 => %i(c f),
  7 => %i(a c f),
  4 => %i(b c d f),
  8 => %i(a b c d e f g),

  2 => %i(a c d e g),
  3 => %i(a c d f g),
  5 => %i(a b d f g),

  0 => %i(a b c e f g),
  6 => %i(a b d e f g),
  9 => %i(a b c d f g),
}.freeze
VALUE_MAP = SEGMENT_MAP.invert.freeze

class Digit
  attr_reader :value
  attr_reader :wires
  attr_reader :segments

  def initialize wires
    @value = nil
    @wires = Set.new wires.chars.map(&:to_sym)
  end

  def length
    @wires.size
  end

  def inspect
    "<Digit: wires=#{@wires.inspect} value=#{value.inspect}>"
  end

  def assign(value, decoder)
    @value = value
    decrypt(decoder)
  end

  def decrypt(decoder)
    SEGMENT_MAP[value].each{|k| decoder[k] = decoder[k] & wires}
    (SEGMENTS - SEGMENT_MAP[value]).each{|k| decoder[k] -= wires}
  end

  def decode(decoder)
    segments = wires.map{ |w| decoder[w] }.sort
    @value = VALUE_MAP[segments]
  end

  def encrypted?
    @value.nil?
  end

  def to_s
    @value ? @value.to_i : "-"
  end
end

class Display
  attr_reader :signals
  attr_reader :output
  attr_reader :decoder

  def initialize signals, output
    @signals = signals.split(" ").map{ |datum| Digit.new(datum) }
    @output = output.split(" ").map{ |datum| Digit.new(datum) }
    decrypt
  end

  def deduce(segment, values, decoder)
    stuff = values.map{|v| SEGMENT_MAP[v].flat_map{|m| decoder[m]}}.reduce(&:-)
    decoder[segment] = stuff
  end

  def earmark(value, decoder)
    require 'ruby_jard'; jard
    signals.select{|s| s.value.nil? && s.length == SEGMENT_MAP[value].size}

    segments = decoder.select{ |segment| SEGMENT_MAP[value].include? segment }
    signals.select{|sig| sig.length == segments.size}.each do |signal|
      puts signal
    end
  end

  def spot(value, containing, decoder)
    containing = Array(containing)
    decoded = Set.new(containing.flat_map{|c| decoder[c].to_a})
    (signals + output)
      .select{ |s| s.value.nil? && s.length == SEGMENT_MAP[value].size }
      .select{ |s| containing.all?{ |c| s.wires & decoder[c] == decoder[c] } }
      .each{ |s| s.assign(value, decoder) }
  end

  def decrypt
    @decoder = SEGMENTS.map{|i| [i, Set.new(SEGMENTS)]}.to_h
    (signals + output).select{ |d| d.length == 2 }.each{ |d| d.assign 1, decoder }
    (signals + output).select{ |d| d.length == 3 }.each{ |d| d.assign 7, decoder }
    (signals + output).select{ |d| d.length == 4 }.each{ |d| d.assign 4, decoder }
    (signals + output).select{ |d| d.length == 7 }.each{ |d| d.assign 8, decoder }
    spot(3, :c, decoder)
    spot(5, :b, decoder)
    spot(2, :e, decoder)
    spot(9, SEGMENT_MAP[9], decoder)
    spot(0, SEGMENT_MAP[0], decoder)
    spot(6, SEGMENT_MAP[6], decoder)
  end

  def value
    output.map(&:to_s).join.to_i
  end
end

displays = File.read('input.txt').split("\n").map{ |line| Display.new(*line.split(" | ")) }

puts "=" * 40, "PART I", ""
pp displays.flat_map{|display| display.output.select{|s| s.value}}.size

puts "=" * 40, "PART II", ""
displays.each do |display|
  puts display.value
end

puts displays.reduce(0){ |sum, display| sum + display.value }

