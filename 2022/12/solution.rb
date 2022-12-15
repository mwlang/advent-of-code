require 'set'

data = File.read('input.txt').split("\n").map { |line| line.chars }

NEIGHBORS = [[0, 1], [0, -1], [1, 0], [-1, 0]]
CLIMBING_ELEVATIONS = ['S', ('a'..'z').to_a, 'E'].flatten.freeze
DESCENDING_ELEVATIONS = CLIMBING_ELEVATIONS.reverse.freeze
class Hills
  attr_reader :elevations

  def initialize
    @elevations = yield
    elevations.flatten.each { |elevation| elevation.introduce_neighbors(self) }
  end

  def climb(trail, distance = 1)
    return if trail.empty?

    trail.each do |hill|
      return distance if hill.possible_paths.detect(&:finish?)
      hill.visited!
      trail += hill.possible_paths
    end

    climb(trail.uniq, distance + 1)
  end

  def width
    @elevations.size
  end

  def height
    @elevations.first.size
  end

  def cover? y, x
    (0..width - 1).include?(y) && (0..height - 1).include?(x)
  end
end

class Elevation
  attr_reader :hills, :neighbors
  attr_reader :x, :y
  attr_reader :elevation
  attr_reader :legend


  def initialize elevation, x, y, legend
    @legend = legend
    @elevation = legend.index(elevation)
    @x = x
    @y = y
    @neighbors = []
    @visited = false
  end

  def visited?
    @visited
  end

  def visited!
    @visited = true
  end

  def start?
    elevation.zero?
  end

  def finish_points
    legend[0] == 'E' ? 2 : 1
  end

  def finish?
    elevation >= legend.size - finish_points
  end

  def inspect
    "[#{x},#{y}]:#{legend[elevation]}"
  end

  def possible_paths
    neighbors.select { |n| (n.elevation - elevation) < 2 }.reject(&:visited?)
  end

  def finished! breadcrumbs
    puts (breadcrumbs << self).size
  end

  def introduce_neighbors hills
    @hills = hills
    NEIGHBORS.each do |yy, xx|
      dy = y + yy
      dx = x + xx
      @neighbors << hills.elevations[dy][dx] if hills.cover?(dy, dx)
    end
  end
end

def read_the_map(data, legend)
  Hills.new do
    data.map.with_index do |row, y|
      row.map.with_index do |elevation, x|
        Elevation.new(elevation, x, y, legend)
      end
    end
  end
end

print "PART 1: "
hills = read_the_map(data, CLIMBING_ELEVATIONS)
start = hills.elevations.flatten.find{ |e| e.elevation.zero? }
puts hills.climb([start])

print "PART 2: "
hills = read_the_map(data, DESCENDING_ELEVATIONS)
start = hills.elevations.flatten.find{ |e| e.elevation.zero? }
puts hills.climb([start])
