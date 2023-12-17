require 'set'

class Galaxy
  include Comparable

  attr_accessor :x, :y

  def initialize(x:, y:)
    super()
    @x = x
    @y = y
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

  def <=>(other)
    [source, destination].sort <=> [other.source, other.destination].sort
  end


  def hash
    [source, destination].sort.hash
  end

  def eql?(other)
    other.is_a?(self.class) && self == other
  end

  def distance
    @distance ||= source.move_cost(destination)
  end

  def inspect
    "[#{source.inspect} <=> #{destination.inspect}]"
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
end

class Universe
  attr_reader :galaxies, :wormholes, :red_shift

  def initialize(data, red_shift:)
    @red_shift = red_shift <= 1 ? 2 : red_shift
    @galaxies = find_galaxies(data)
    @wormholes = find_wormholes
    expand_universe(data)
  end

  def galaxy_pairs
    galaxies.combination(2)
  end

  def find_wormholes
    Set.new galaxy_pairs.map { |a, b| Wormhole.new(self, a, b) }
  end

  def galaxy(n)
    galaxies[n - 1]
  end

  def find_empty_columns(data)
    data[0].size.times.map do |x|
      x if data.map{ |row| row[x] }.all?{ |pixel| pixel == '.' }
    end.compact
  end

  def find_empty_rows(data)
    data.map.with_index do |row, y|
      y if row.all?{ |pixel| pixel == '.' }
    end.compact
  end

  def expand_universe(data)
    empty_columns = find_empty_columns(data)
    empty_rows = find_empty_rows(data)

    galaxies.each do |galaxy|
      shift_x = empty_columns.count{ |x| x < galaxy.x }
      shift_y = empty_rows.count{ |y| y < galaxy.y }

      galaxy.x += shift_x * red_shift - shift_x
      galaxy.y += shift_y * red_shift - shift_y
    end
  end

  def find_galaxies(data)
    data.flat_map.with_index do |row, y|
      row.map.with_index{ |pixel, x| Galaxy.new(x: x, y: y) if pixel == '#' }
    end.compact
  end

  def inspect
    "U: #{galaxies.map(&:inspect).join(", ")}}"
  end
end

def solve(part:, data:, red_shift:)
  universe = Universe.new(data, red_shift: red_shift)

  puts "-" * 40, "Part #{part}: "
  puts "Red Shift: #{red_shift}"
  puts "wormholes: #{universe.wormholes.count}"
  puts "sum: #{universe.wormholes.map(&:distance).sum}"
end

data = File.read('input.txt').split("\n").map(&:chars)

solve(part: 1, data: data, red_shift: 1)
solve(part: 2, data: data, red_shift: 1_000_000)
