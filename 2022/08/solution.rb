data = File.read('input.txt').split("\n").map{ |line| line.chars.map(&:to_i) }

NEIGHBORS = [[-1,-1], [0,-1], [1,-1],   [-1,0], [1, 0],   [-1, 1], [0, 1], [1, 1]]

class Forest
  attr_reader :trees

  def initialize
    @trees = yield
    trees.flatten.each{ |tree| tree.introduce_neighbors(self) }
  end

  def width
    @trees.size
  end
  alias :height :width

  def cover? index
    (0..width-1).cover? index
  end

  def visible_trees
    trees.flatten.select(&:visible?).count
  end
end

class Tree
  attr_reader :forest, :neighbors
  attr_reader :x, :y
  attr_reader :height

  def initialize height, x, y
    @height = height
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

    line_of_sight = ([a, b].min..[a, b].max).map{ |delta| yield(delta).height }
    return 0 if line_of_sight.empty?

    line_of_sight.reverse! if a > b
    answer = (line_of_sight.index{ |h| h >= height } || (line_of_sight.count - 1)) + 1
    answer
  end

  def scenery_horizontally
    scenery_left * scenery_right
  end

  def scenery_vertically
    scenery_up * scenery_down
  end

  def scenery_left
    check_scenery(x - 1, 0) { |delta| forest.trees[y][delta] }
  end

  def scenery_right
    check_scenery(x + 1, forest.width - 1) { |delta| forest.trees[y][delta] }
  end

  def scenery_up
    check_scenery(y - 1, 0) { |delta| forest.trees[delta][x] }
  end

  def scenery_down
    check_scenery(y + 1, forest.height - 1) { |delta| forest.trees[delta][x] }
  end

  def visible_horizontally?
    visible_left? || visible_right?
  end

  def visible_vertically?
    visible_top? || visible_bottom?
  end

  def check_height(a, b)
    height > ([a, b].min..[a, b].max)
      .map{ |delta| yield(delta).height }
      .max
  end

  def visible_left?
    check_height(0, x - 1) { |delta| forest.trees[y][delta] }
  end

  def visible_right?
    check_height(x + 1, forest.width - 1) { |delta| forest.trees[y][delta] }
  end

  def visible_top?
    check_height(0, y - 1) { |delta| forest.trees[delta][x] }
  end

  def visible_bottom?
    check_height(y + 1, forest.height - 1) { |delta| forest.trees[delta][x] }
  end

  def inspect
    "<T[#{x},#{y}] #{height}/#{visible? ? 't' : 'f'}>"
  end

  def introduce_neighbors forest
    @forest = forest
    NEIGHBORS.each do |xx, yy|
      dx = x + xx
      dy = y + yy
      @neighbors << forest.trees[dy][dx] if forest.cover?(dx) && forest.cover?(dy)
    end
  end
end

forest = Forest.new do
  data.map.with_index do |row, y|
    row.map.with_index do |height, x|
      Tree.new(height, x, y)
    end
  end
end

print "PART 1: "
puts forest.visible_trees

print "PART 2: "
puts forest.trees.flatten.map(&:scenery).max