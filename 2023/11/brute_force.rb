require 'ruby_jard'
require 'rspec'
require 'set'

# This solution was next solution after the astar search solution was abandoned.
# the expansion of the universe logic was corrected and it was used to give
# me the numbers I plugged into my specs.rb file.
# It'll work correctly for small test scenarios, but certainly not for 1,000,000
# before the computer melts.
class Point
  include Comparable

  attr_reader :x, :y
  attr_reader :neighbors

  def initialize(x:, y:)
    super()
    @x = x
    @y = y
    @neighbors = []
  end

  def heuristic(other)
    dx = x - other.x
    dy = y - other.y
    (dx**2 + dy**2)**0.5
  end

  def move_cost(other)
    dx = x - other.x
    dy = y - other.y
    (dx.abs + dy.abs)
  end

  def point
    [x, y]
  end

  def <=>(other)
    [y, x] <=> [other.y, other.x]
  end

  def ==(other)
    [y, x] == [other.y, other.x]
  end

  def eql?(other)
    other.is_a?(self.class) && self == other
  end

  def galaxy?
    self.is_a?(Galaxy)
  end

  def introduce_neighbors(universe)
    @neighbors = [
      universe.at(x - 1, y),
      universe.at(x, y - 1),
      universe.at(x + 1, y),
      universe.at(x, y + 1),
    ].compact
  end

  def inspect
    "-:#{x},#{y}"
  end
end

class Space < Point
  def inspect
    "S:#{x},#{y}"
  end
end

class Galaxy < Point
  attr_reader :wormholes

  def inspect
    "G:#{x},#{y}"
  end
end

class Wormhole
  include Comparable

  attr_reader :universe, :source, :destination

  def initialize(universe, a, b)
    @universe = universe
    @source, @destination = [a, b].sort
  end

  def path
    @path ||= a_star(source, destination)
  end

  def <=>(other)
    [source, destination].sort <=> [other.source, other.destination].sort
  end

  def ==(other)
    [source, destination].sort == [other.source, other.destination].sort
  end

  def hash
    [source, destination].sort.hash
  end

  def eql?(other)
    other.is_a?(self.class) && self == other
  end

  def distance
    @distance ||= source.move_cost(destination) # (path.size - 2) #.tap{ |d| puts " => #{d}" }
  end

  def inspect
    a = universe.galaxies.index(source) + 1
    b = universe.galaxies.index(destination) + 1
    "(#{a},#{b})[#{source.inspect} <=> #{destination.inspect}] => #{distance}"
  end

  private

  def reconstruct_path(came_from, current)
    total_path = [current]
    came_from.keys.each do |current|
      current = came_from[current]
      total_path.unshift(current)
    end
    total_path
  end


  # // A* finds a path from start to goal.
  # // h is the heuristic function. h(n) estimates the cost to reach goal from node n.
  # function A_Star(start, goal, h)
  #   // The set of discovered nodes that may need to be (re-)expanded.
  #   // Initially, only the start node is known.
  #   // This is usually implemented as a min-heap or priority queue rather than a hash-set.
  #   openSet := {start}

  #   // For node n, cameFrom[n] is the node immediately preceding it on the cheapest path from the start
  #   // to n currently known.
  #   cameFrom := an empty map

  #   // For node n, gScore[n] is the cost of the cheapest path from start to n currently known.
  #   gScore := map with default value of Infinity
  #   gScore[start] := 0

  #   // For node n, fScore[n] := gScore[n] + h(n). fScore[n] represents our current best guess as to
  #   // how cheap a path could be from start to finish if it goes through n.
  #   fScore := map with default value of Infinity
  #   fScore[start] := h(start)

  #   while openSet is not empty
  #       // This operation can occur in O(Log(N)) time if openSet is a min-heap or a priority queue
  #       current := the node in openSet having the lowest fScore[] value
  #       if current = goal
  #           return reconstruct_path(cameFrom, current)

  #       openSet.Remove(current)
  #       for each neighbor of current
  #           // d(current,neighbor) is the weight of the edge from current to neighbor
  #           // tentative_gScore is the distance from start to the neighbor through current
  #           tentative_gScore := gScore[current] + d(current, neighbor)
  #           if tentative_gScore < gScore[neighbor]
  #               // This path to neighbor is better than any previous one. Record it!
  #               cameFrom[neighbor] := current
  #               gScore[neighbor] := tentative_gScore
  #               fScore[neighbor] := tentative_gScore + h(neighbor)
  #               if neighbor not in openSet
  #                   openSet.add(neighbor)

  #   // Open set is empty but goal was never reached
  #   return failure
  def a_star(start, goal)
    g_scores = Hash.new(Float::INFINITY)
    f_scores = Hash.new(Float::INFINITY)

    # The set of discovered nodes that may need to be (re-)expanded.
    # Initially, only the start node is known.
    # This is usually implemented as a min-heap or priority queue rather than a hash-set.
    open_set = [start]

    # For node n, came_from[n] is the node immediately preceding it on the cheapest path from the start
    # to n currently known.
    came_from = {}

    # For node n, g_score[n] is the cost of the cheapest path from start to n currently known.
    g_scores[start] = 0

    # For node n, f_score[n] := g_score[n] + h(n). f_score[n] represents our current best guess as to
    # how cheap a path could be from start to finish if it goes through n.
    f_scores[start] = start.heuristic(start)

    while not open_set.empty?
      # This operation can occur in O(Log(N)) time if open_set is a min-heap or a priority queue
      current = open_set.min_by{ |node| f_scores[node] }

      return reconstruct_path(came_from, current) if current == goal

      open_set.delete(current)

      current.neighbors.each do |neighbor|
        # d(current,neighbor) is the weight of the edge from current to neighbor
        # tentative_g_score is the distance from start to the neighbor through current
        tentative_g_score = g_scores[current] + current.move_cost(neighbor)

        if tentative_g_score <= g_scores[neighbor]
          # This path to neighbor is better than any previous one. Record it!
          came_from[current] = neighbor
          g_scores[neighbor] = tentative_g_score
          f_scores[neighbor] = neighbor.heuristic(goal)
          open_set << neighbor unless open_set.include?(neighbor)
        end
      end
    end
  end
end

class Universe
  attr_reader :universe, :points, :galaxies, :space, :nodes

  def initialize(data)
    @universe = to_points expand_universe(data)
    @points = universe.flatten
    points.each{ |point| point.introduce_neighbors(self) }
    @nodes = Hash[points.map{|p| [p, p.neighbors]}]
    @galaxies, @space = points.partition(&:galaxy?)
  end

  def wormholes
    @wormholes ||= Set.new(galaxies.combination(2).map{ |a, b| Wormhole.new(self, a, b) })
  end

  def width
    universe.first.size
  end

  def height
    universe.size
  end

  def galaxy(n)
    galaxies[n - 1]
  end

  def at(x, y)
    return if x < 0 || y < 0
    return if x >= width || y >= height
    universe[y][x]
  end

  def expand_universe(data)
    expand(data)
  end

  def expand(rows)
    columns = rows[0].size.times.map do |x|
      x if rows.map{ |row| row[x] }.all?{ |pixel| pixel == '.' }
    end.compact.reverse

    rows.each{ |row| columns.each{ |x| 99.times{row.insert(x, '.')} } }

    expanded = []
    rows.each do |row|
      if row.all?{ |pixel| pixel == '.' }
        100.times{ expanded << row }
      else
        expanded << row
      end
    end
    expanded
  end

  def to_points(data)
    data.map.with_index do |row, y|
      row.map.with_index do |pixel, x|
        pixel == '#' ? Galaxy.new(x: x, y: y) : Space.new(x: x, y: y)
      end
    end
  end

  def inspect
    "U: #{galaxies.map(&:inspect).join(", ")}\nS: #{space.map(&:inspect).join(", ")}"
  end
end

RSpec.describe Universe do
  let(:data) { File.read('test_input.txt').split("\n").map(&:chars) }
  let(:universe) { Universe.new(data) }

  it { expect(universe.width).to eq 13 }
  it { expect(universe.height).to eq 12 }
  it { expect(universe.wormholes.size).to eq 36 }

  context '#neighbors' do
    it { expect(universe.galaxy(1).neighbors.map(&:inspect).sort).to eq ["S:3,0", "S:4,1", "S:5,0"].sort }
    it { expect(universe.galaxy(2).neighbors.map(&:inspect).sort).to eq ["S:10,0", "S:9,1", "S:10,2", "S:11,1"].sort }
    it { expect(universe.galaxy(3).neighbors.map(&:inspect).sort).to eq ["S:0,1", "S:0,3", "S:1,2"].sort }
  end
end

RSpec.describe Galaxy do
  let(:a) { Galaxy.new(x: 1, y: 1) }
  let(:b) { Galaxy.new(x: 1, y: 2) }
  let(:c) { Galaxy.new(x: 1, y: 2) }

  it 'is comparable' do
    expect(a).to be < b
    expect(b).to be == c
  end

  it 'is sortable' do
    expect([b, a, c].sort).to eq([a, b, c])
  end
end

RSpec.describe Wormhole do
  let(:data) { File.read('test_input.txt').split("\n").map(&:chars) }
  let(:universe) { Universe.new(data) }

  let(:a) { universe.at(1, 6) }
  let(:b) { universe.at(6, 11) }

  it { expect(a).to be_a(Galaxy) }
  it { expect(b).to be_a(Galaxy) }

  describe 'comparable' do
    let(:wormhole_ab) { Wormhole.new(universe, a, b) }
    let(:wormhole_ba) { Wormhole.new(universe, b, a) }

    it "(a, b) == (b, a)" do
      expect(wormhole_ab).to eq wormhole_ba
      expect(wormhole_ab).to eql wormhole_ba
      set = Set.new
      set << wormhole_ab
      set << wormhole_ba
      expect(set.size).to eq 1
    end
  end

  describe '#path' do
    subject { Wormhole.new(universe, a, b).path }
    it { expect(subject).to be_a(Array) }
  end

  describe '#distance' do
    subject { Wormhole.new(universe, source, destination) }

    context 'when #5 => #9' do
      let(:source) { universe.at(1, 6) }
      let(:destination) { universe.at(6, 11) }
      it { expect(subject.distance). to eq 9 }
    end

    context 'when #1 => #7' do
      let(:source) { universe.galaxy(1) }
      let(:destination) { universe.galaxy(7) }
      it { expect(subject.distance). to eq 15 }
      it { expect(source.inspect).to eq "G:4,0" }
    end

    context 'when #3 => #6' do
      let(:source) { universe.galaxy(3) }
      let(:destination) { universe.galaxy(6) }
      it { expect(subject.distance). to eq 17 }
    end

    context 'when #8 => #9' do
      let(:source) { universe.galaxy(8) }
      let(:destination) { universe.galaxy(9) }
      it { expect(subject.distance). to eq 5 }
    end
  end
end

data = File.read('test_input.txt').split("\n").map(&:chars)

universe = Universe.new(data)
# universe.wormholes.each do |wormhole|
#   puts '=' * 40
#   puts wormhole.inspect
#   puts wormhole.path.map(&:inspect).join(", ")
#   puts wormhole.distance
#   universe.universe.each do |row|
#     row.each do |point|
#       if wormhole.source == point
#         print 'S'
#       elsif wormhole.destination == point
#         print 'D'
#       elsif wormhole.path.include?(point)
#         print '#'
#       else
#         print point.galaxy? ? '*' : '.'
#       end
#     end
#     puts
#   end
# end
puts '=' * 40
puts "wormholes: #{universe.wormholes.count}"
puts "distances: #{universe.wormholes.map(&:inspect).join("\n")}"
puts "sum: #{universe.wormholes.map(&:distance).sum}"
puts "galaxies: #{universe.galaxies.map(&:inspect).join(", ")}"
puts '=' * 40
universe.universe.each do |row|
  row.each do |point|
    if point.galaxy?
      print universe.galaxies.index(point) + 1
    else
      print '.'
    end
  end
  puts
end

# 9697650 too low

# puts universe.inspect
# puts universe.at(1, 6).inspect
# puts universe.at(6, 11).inspect
# puts universe.galaxy(5).inspect
# puts universe.galaxy(9).inspect

# wormhole = Wormhole.new(universe, universe.galaxy(5), universe.galaxy(9))
# puts wormhole.path.map(&:inspect).join(", ")
# puts wormhole.distance

# data.dup.each.with_index do |row, y|
#   if row.all?{ |char| char == '.' }
#     data.insert(y, row.dup)
#   end
# end
# transposed = data.transpose
# transposed.dup.each.with_index do |row, y|
#   if row.all?{ |char| char == '.' }
#     transposed.insert(y, row.dup)
#   end
# end

# data = transposed.transpose
# puts data.map(&:join).join("\n")
# pp data.first.size
# pp data.count
