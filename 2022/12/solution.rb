require 'set'

data = File.read('input.txt').split("\n").map { |line| line.chars }

NEIGHBORS = [[0, 1], [0, -1], [1, 0], [-1, 0]]

class Hills
  attr_reader :elevations, :paths

  def initialize
    @elevations = yield
    elevations.flatten.each{ |elevation| elevation.introduce_neighbors(self) }
    @paths = Set.new
  end

  def shortest_path
    paths.sort_by{ |path| path.count }.first || []
  end

  def width
    @elevations.count
  end

  def height
    @elevations.first.count
  end

  def cover? y, x
    (0..width-1).include?(y) && (0..height-1).include?(x)
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
    @paths = Set.new
  end

  def start?
    elevation.zero?
  end

  def highest?
    elevation == ELEVATIONS.size - 1
  end

  def inspect
    "[#{x},#{y}]:#{ELEVATIONS[elevation]}"
  end

  def possible_paths
    @possible_paths ||= highest? ? [] : neighbors.select { |n| [elevation, elevation + 1].include? n.elevation }
  end

  def finished!(breadcrumbs)
    hills.paths << (breadcrumbs.dup << self)
  end

  def climb(breadcrumbs)
    return finished!(breadcrumbs) if highest?
    return if breadcrumbs.include?(self) || @paths.include?(breadcrumbs)
    return if !@paths.empty? && @paths.map(&:size).max <= breadcrumbs.size

    @paths << breadcrumbs
    possible_paths.each { |path| path.climb(breadcrumbs.dup << self) }
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
pp hills.elevations

start = hills.elevations.flatten.find{ |e| e.elevation.zero? }
pp start
pp start.possible_paths

breadcrumbs = start.climb(Set.new)

puts "just making sure I get here through the jard of a yard of a bard for lard and marge"
puts [hills.shortest_path.size, hills.shortest_path.map{ |bc| bc.inspect }.join(", ")].join(':')
puts "PART 1: #{hills.shortest_path.size - 1}"