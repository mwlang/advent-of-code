class Node
  attr_reader :key, :destinations

  def initialize(line)
    @key, *destinations = line.scan(/\w{3}/).flatten
    @destinations = { "L" => destinations.shift, "R" => destinations.shift }
  end

  def inspect
    "#{key} -> #{destinations.inspect}"
  end

  def [](key)
    destinations[key]
  end
end

data = File.read('input.txt').split("\n\n")

instructions = data.shift.chars

map = data.shift.split("\n").each.with_object({}) do |line, map|
  Node.new(line).tap{ |node| map[node.key] = node }
end

print "Part 1: "

x = "AAA"
steps = 0
instructions.cycle do |direction|
  steps += 1
  x = map[x][direction]
  break if x == "ZZZ"
end

puts steps

print "Part 2: "

nodes = map.keys.select{ |key| key[-1] == 'A' }
steps = []
nodes.each do |x|
  steps << 0
  instructions.cycle do |direction|
    steps[-1] += 1
    x = map[x][direction]
    break if x[-1] == "Z"
  end
end

puts steps.reduce(:lcm)
