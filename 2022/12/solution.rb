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

  def initialize elevation, x, y
    @elevation = elevation
    @x = x
    @y = y
    @neighbors = []
  end

  def visible?
    return true if neighbors.size < 8

    visible_horizontally? || visible_vertically?
  end

  def scenery
    scenery_horizontally * scenery_vertically
  end

  def check_scenery(a, b)
    return 0 unless forest.cover?(a) && forest.cover?(b)

    line_of_sight = ([a, b].min..[a, b].max).map{ |delta| yield(delta).elevation }
    return 0 if line_of_sight.empty?

    line_of_sight.reverse! if a > b
    answer = (line_of_sight.index{ |h| h >= elevation } || (line_of_sight.count - 1)) + 1
    answer
  end

  def scenery_horizontally
    scenery_left * scenery_right
  end

  def scenery_vertically
    scenery_up * scenery_down
  end

  def scenery_left
    check_scenery(x - 1, 0) { |delta| forest.elevations[y][delta] }
  end

  def scenery_right
    check_scenery(x + 1, forest.width - 1) { |delta| forest.elevations[y][delta] }
  end

  def scenery_up
    check_scenery(y - 1, 0) { |delta| forest.elevations[delta][x] }
  end

  def scenery_down
    check_scenery(y + 1, forest.elevation - 1) { |delta| forest.elevations[delta][x] }
  end

  def visible_horizontally?
    visible_left? || visible_right?
  end

  def visible_vertically?
    visible_top? || visible_bottom?
  end

  def check_elevation(a, b)
    elevation > ([a, b].min..[a, b].max)
      .map{ |delta| yield(delta).elevation }
      .max
  end

  def visible_left?
    check_elevation(0, x - 1) { |delta| forest.elevations[y][delta] }
  end

  def visible_right?
    check_elevation(x + 1, forest.width - 1) { |delta| forest.elevations[y][delta] }
  end

  def visible_top?
    check_elevation(0, y - 1) { |delta| forest.elevations[delta][x] }
  end

  def visible_bottom?
    check_elevation(y + 1, forest.elevation - 1) { |delta| forest.elevations[delta][x] }
  end

  def inspect
    "<T[#{x},#{y}] #{elevation}/#{visible? ? 't' : 'f'}>"
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
puts forest.visible_elevations

print "PART 2: "
puts forest.elevations.flatten.map(&:scenery).max