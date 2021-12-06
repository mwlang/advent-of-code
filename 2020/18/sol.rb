data = File.read("input.txt").split("\n")

class Term
  attr_reader :value
  def initialize value
    @value = value
  end
  def inspect
    "<#{value}>"
  end
end

PRECIDENCE = { "*" => 2, "+" => 1 }

class Operand
  attr_reader :precedence

  def self.parse operand
    case operand
    when "*" then Multipler.new(PRECIDENCE[operand])
    when "+" then Addition.new
    else raise "oops"
    end
  end
  def initialize precedence
    @precedence = precedence
  end
  def <=> other
    precedence <=> other.precedence
  end
  def > other
    precedence > other.precedence
  end
  def <= other
    precedence <= other.precedence
  end
end

class Addition < Operand
end

class Multipler < Operand
end

def parse equation

  output = []
  stack = []

  equation.scan(/(\d+|\(|\)|\+|\*)/).flatten.each do | char |

    if char =~ /\d+/
      output << Term.new(char)
      next
    end

    operand = Operand.new(char)
    stack << operand if stack.empty? || stack[-1] <= operand

    output << stack.pop while !stack.empty? && stack[-1] > operand
    stack << operand
  end

  output << stack.pop until stack.empty?

  output
end

data[0..0].each do |line|
  puts line.inspect
  # puts line.scan(/(\d+|\(|\)|\+|\*)/).to_a.inspect
  puts parse(line).map(&:inspect)
end