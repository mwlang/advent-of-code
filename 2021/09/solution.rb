require 'set'

data = File.read('input.txt').split("\n").map{|l| l.chars.map(&:to_i)}

class Point
  attr_reader :n, :s, :e, :w
  attr_reader :x, :y
  attr_reader :value, :lowest

  def initialize value, x, y
    @value = value
    @x = x
    @y = y
  end

  def risk
    @value + 1
  end

  def peak?
    value == 9
  end

  def basin(pool=Set.new)
    return if pool.include?(self)
    pool << self
    nearby = Set.new([n, s, e, w].compact.reject(&:peak?))
    nearby.each{ |p| p.basin(pool) }
    pool
  end

  def inspect
    "<P[#{x},#{y}] #{value} (n:#{n&.value} s:#{s&.value} e:#{e&.value} w:#{w&.value})>"
  end

  def introduce_neighbors points
    @n = points[x][y - 1] if y > 0
    @w = points[x - 1][y] if x > 0
    @s = points[x][y + 1] if y < points[x].size - 1
    @e = points[x + 1][y] if x < points.size - 1
    @lowest = [n&.value, s&.value, e&.value, w&.value].compact.min > @value
  end
end

points = data.map.with_index do |row, x|
  row.map.with_index do |col, y|
    Point.new(col, x, y)
  end
end

points.flatten.each{ |point| point.introduce_neighbors(points) }

puts "=" * 40, "PART I", ""

low_points = points.flatten.select(&:lowest)
puts low_points.reduce(0){ |sum, p| sum + p.risk }

puts "=" * 40, "PART II", ""

largest_basins = low_points.map do |low_point|
  low_point.basin.size
end.sort.reverse.take(3)

pp largest_basins.reduce(&:*)