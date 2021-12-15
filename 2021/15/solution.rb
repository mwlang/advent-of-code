require 'gastar' # gem install 'gastar'

data = File.read("input.txt").split("\n").map{|l| l.chars.map(&:to_i)}

class Point < AStarNode
  attr_reader :neighbors
  attr_reader :x, :y
  attr_reader :risk

  def initialize risk, x, y
    super()
    @risk = risk
    @x = x
    @y = y
    @neighbors = []
  end

  def move_cost(other)
    raise [self, other].inspect unless @neighbors.include?(other)
    other.risk
  end

  def inspect
    "<P[#{x},#{y}] #{risk}#{@final ? "!" : ""}>"
  end

  def introduce_neighbors points
    @neighbors << points[x][y - 1] if y > 0
    @neighbors << points[x - 1][y] if x > 0
    @neighbors << points[x][y + 1] if y < points[x].size - 1
    @neighbors << points[x + 1][y] if x < points.size - 1
  end
end

class Space < AStar
  def heuristic(node, start, goal)
    Math.sqrt( (goal.x - node.x)**2 + (goal.y - node.y)**2 )
  end
end

def answer(data)
  points = data.map.with_index do |row, x|
    row.map.with_index do |col, y|
      Point.new(col, x, y)
    end
  end

  points.flatten.each{ |point| point.introduce_neighbors(points) }

  nodes = Hash[points.flatten.map{|p| [p, p.neighbors]}]

  path = Space.new(nodes).search(points.flatten.first, points.flatten.last)
  puts path[1..-1].map(&:risk).sum
end

puts "*" * 40, "PART I", ""

answer data

puts "*" * 40, "PART II", ""

data5 = 0.upto(4).flat_map do |delta|
  data.map{ |line| line.map{ |i| i + delta } }
end

data55 = data5.map do |line|
  0.upto(4).flat_map do |delta|
    line.map{|i| i + delta}
  end
end

data55 = data55.map{ |l| l.map{ |ll| ll > 9 ? ll - 9 : ll } }

answer data55
