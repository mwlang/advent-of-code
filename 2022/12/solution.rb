data = File.read('input.txt').split("\n").map { |line| line.chars }

NEIGHBORS = [[-1,-1], [0,-1], [1,-1],   [-1,0], [1, 0],   [-1, 1], [0, 1], [1, 1]]

class Forest
  attr_reader :elevations

  def initialize
    @elevations = yield
    elevations.flatten.each{ |elevation| elevation.introduce_neighbors(self) }
  end

  def width
    @elevations.size
  end
  alias :height :width

  def cover? index
    (0..width-1).cover? index
  end
end

class Elevation
  attr_reader :forest, :neighbors
  attr_reader :x, :y
  attr_reader :elevation

  ELEVATIONS = ['S', ('a'..'z').to_a, 'E'].flatten.freeze

  def initialize elevation, x, y
    @elevation = ELEVATIONS.index(elevation)
    @x = x
    @y = y
    @neighbors = []
    @paths = []
  end

  def start?
    elevation.zero?
  end

  def finish?
    elevation == ELEVATIONS[-1]
  end

  def inspect
    "<E[#{x},#{y}] #{elevation} #{start? ? 's' : finish? ? 'E' : ''}>"
  end

  def introduce_neighbors forest
    @forest = forest
    NEIGHBORS.each do |xx, yy|
      dx = x + xx
      dy = y + yy
      @neighbors << forest.elevations[dy][dx] if forest.cover?(dx) && forest.cover?(dy)
    end
  end
end

forest = Forest.new do
  data.map.with_index do |row, y|
    row.map.with_index do |elevation, x|
      Elevation.new(elevation, x, y)
    end
  end
end

print "PART 1: "
pp forest.elevations
