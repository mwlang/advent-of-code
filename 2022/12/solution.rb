require 'set'

data = File.read('input.txt').split("\n").map { |line| line.chars }

NEIGHBORS = [[0, 1], [0, -1], [1, 0], [-1, 0]]

class Hills
  attr_reader :elevations, :paths

  def initialize
    @elevations = yield
    elevations.flatten.each{ |elevation| elevation.introduce_neighbors(self) }
    @paths = []
  end

  def shortest_path
    paths.sort_by{ |path| path.count }.first || []
  end

  def climb(trail, distance = 1)
    return if trail.empty?

    trail.each do |hill|
      return distance if hill.possible_paths.detect(&:highest?)
      hill.visited!
      trail += hill.possible_paths
    end

    climb(trail.uniq, distance + 1)
  end

  def descend(trail, distance = 1)
    return if trail.empty?

    trail.each do |hill|
      return distance if hill.possible_down_paths.detect(&:lowest?)
      hill.visited!
      trail += hill.possible_down_paths
    end

    descend(trail.uniq, distance + 1)
  end

  def width
    @elevations.count
  end

  def height
    @elevations.first.count
  end

  def cover? y, x
    (0..width - 1).include?(y) && (0..height - 1).include?(x)
  end
end

class Elevation
  attr_reader :hills, :neighbors
  attr_reader :x, :y
  attr_reader :elevation

  ELEVATIONS = ['S', ('a'..'z').to_a, 'E'].flatten.freeze

  def initialize elevation, x, y
    @elevation = ELEVATIONS.index(elevation)
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

  def lowest?
    elevation <= ELEVATIONS.index('a')
  end

  def highest?
    elevation == ELEVATIONS.size - 1
  end

  def inspect
    "[#{x},#{y}]:#{ELEVATIONS[elevation]}"
  end

  def possible_paths
    neighbors.select { |n| (n.elevation - elevation) < 2 }.reject(&:visited?)
  end

  def possible_down_paths
    neighbors.select { |n| (elevation - n.elevation) < 2 }.reject(&:visited?)
  end

  def finished! breadcrumbs
    hills.paths << (breadcrumbs.dup << self)
    puts breadcrumbs.size
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

hills = Hills.new do
  data.map.with_index do |row, y|
    row.map.with_index do |elevation, x|
      Elevation.new(elevation, x, y)
    end
  end
end

print "PART 1: "
start = hills.elevations.flatten.find{ |e| e.elevation.zero? }
puts hills.climb([start])

print "PART 2: "
highest = hills.elevations.flatten.find(&:highest?)
puts hills.descend([highest])
