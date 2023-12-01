class Digitizer
  attr_reader :line

  def initialize(line)
    @line = line
  end

  def digits
    @digits ||= line.scan(/[0-9]/).flatten
  end

  def value
    (digits.first + digits.last).to_i
  end
end

class Despeller
  attr_reader :line

  def initialize(line)
    @line = line
  end

  def scan(...)
    to_s.scan(...)
  end

  def replacements
    [ [/zero/,  'z0o'],
      [/one/,   'o1e'],
      [/two/,   't2o'],
      [/three/, 't3e'],
      [/four/,  'f4r'],
      [/five/,  'f5e'],
      [/six/,   's6x'],
      [/seven/, 's7n'],
      [/eight/, 'e8t'],
      [/nine/,  'n9e'] ]
  end

  def to_s
    replacements.reduce(line) { |line, (name, digit)| line.gsub(name, digit) }
  end
end

lines = File.read('input.txt').split("\n")

data = lines.map { |line| Digitizer.new(line) }
puts data.reduce(0){ |sum, digit| sum + digit.value }

data = lines.map{ |line| Despeller.new(line) }.map{ |line| Digitizer.new(line) }
puts data.reduce(0){ |sum, digit| sum + digit.value }
