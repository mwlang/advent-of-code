stack_data, movement_data = File.read('input.txt').split("\n\n")

class Stack
  attr_reader :crates

  def initialize
    @crates = []
  end

  def load crates_in_stack
    @crates = crates_in_stack.reverse.compact
  end

  def <<(crate)
    @crates << crate
  end

  def +(new_crates)
    @crates += new_crates.flatten
    @crates
  end

  def top
    crates[-1]
  end

  def pop(count=1)
    crates.pop(count)
  end
end

class Stacks
  include Enumerable
  attr_reader :stacks

  def initialize number_of_stacks
    @stacks = number_of_stacks.times.map { Stack.new }
  end

  def each
    stacks.each{ |stack| yield stack }
  end

  def [](index)
    stacks[index]
  end

  def count
    stacks.count
  end

  def top_crates
    stacks.map(&:top).join
  end
end

# Build the stacks from input data
def build_stacks stack_data
  stack_data = stack_data.split("\n")
  stacks = Stacks.new stack_data.pop.scan(/\d+/).last.to_i

  transposed_stacks = stack_data.map{|s| s.scan(/\s{4}|\[\w\]/).map{|m| m.scan(/\w/)}.map(&:first)}.transpose
  stacks.each{|stack| stack.load transposed_stacks.shift }

  stacks
end

class Move
  attr_reader :count, :from, :to

  def initialize(count, from, to)
    @count = count
    @from = from - 1
    @to = to - 1
  end
end

class Move9000 < Move
  def execute stacks
    count.times { stacks[to] << stacks[from].pop }
  end
end

class Move9001 < Move
  def execute stacks
    stacks[to] + stacks[from].pop(count)
  end
end

moves9000 = movement_data.split("\n").map{ |move| Move9000.new *move.scan(/\d+/).flatten.map(&:to_i) }
moves9001 = movement_data.split("\n").map{ |move| Move9001.new *move.scan(/\d+/).flatten.map(&:to_i) }

print "PART 1: "
stacks = build_stacks(stack_data)
moves9000.each { |move| move.execute stacks }
puts stacks.top_crates

print "PART 2: "
stacks = build_stacks(stack_data)
moves9001.each { |move| move.execute stacks }
puts stacks.top_crates
