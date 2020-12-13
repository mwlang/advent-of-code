class Bus
  attr_reader :id, :track

  def initialize id, track
    @id = id
    @track = track
  end

  def line
    id - track
  end

  def stop?(start)
    ((start + track) % id).zero?
  end
end

def shuttle_search data
  buses = data.reject(&:zero?)
  start = data.shift # <= side effect: Part Two doesn't need first line.

  schedule = buses.map{|bus| [bus - (start % bus), bus]}.sort_by{|sb| sb[0]}
  puts schedule[0][0] * schedule[0][1]
end

# Full credit to David for explaining the mathematical solution:
# https://github.com/davidolivefarga/advent-of-code-2020/tree/master/day13
# Chinese Remainder System is the Fortune Cookie you're looking for.
def solution_matrix(buses)
  buses.map do |bus|
    mod = bus.id
    remainder = bus.line
    remainder += mod while (remainder < 0)
    [mod, remainder]
  end
end

def busitary_alignment_horiscope data
  # Gimme an array of Buses with their line in the rotation noted.
  schedule = data.map
    .with_index{ |bus, i| bus.zero? ? [0, i] : [bus, i] }
    .reject{|r| r[0].zero?}
    .map{|id, line| Bus.new(id, line)}

  # The possible solutions out of infinitely many!
  solutions = solution_matrix schedule

  mod, remainder = solutions.shift

  solution = remainder
  increment = mod

  # Solve each bus line to arrive at final solution
  solutions.each do |mod, remainder|
    solution += increment while (solution % mod != remainder)
    increment *= mod
  end
  puts solution
end

buses = File.read("input.txt").split(/\n|,/).map(&:to_i)

shuttle_search buses
busitary_alignment_horiscope buses