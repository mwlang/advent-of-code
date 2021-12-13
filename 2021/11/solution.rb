data = File.read('input.txt').split("\n").map{|l| l.chars.map(&:to_i)}

NEIGHBORS = [[-1,-1], [0,-1], [1,-1],   [-1,0], [1, 0],   [-1, 1], [0, 1], [1, 1]]

class Point
  attr_reader :neighbors
  attr_reader :x, :y
  attr_reader :energy
  attr_reader :flashes

  def initialize energy, x, y
    @energy = energy
    @x = x
    @y = y
    @flashes = 0
    @neighbors = []
  end

  def flashed?
    energy == 0
  end

  def boost!
    return if flashed?
    @energy += 1
  end

  def reset!
    return unless energy > 9
    @energy = 0
    @flashes += 1
  end

  def increment!
    @energy += 1
  end

  def flash!
    return unless energy > 9
    neighbors.each(&:boost!)
    reset!
  end

  def inspect
    "<P[#{x},#{y}] #{energy}/#{flashes}>"
  end

  def introduce_neighbors points
    NEIGHBORS.each do |xx, yy|
      dx = x + xx
      dy = y + yy
      @neighbors << points[dx][dy] if (0..9).cover?(dx) && (0..9).cover?(dy)
    end
  end
end

points = data.map.with_index do |row, x|
  row.map.with_index do |col, y|
    Point.new(col, x, y)
  end
end

points.flatten.each{ |point| point.introduce_neighbors(points) }

def draw points
  puts "=" * 40
  points.each do |row|
    row.each do |point|
      print point.energy
    end
    puts
  end
end

def flash points
  flash(points) if points.any?(&:flash!)
end

flattened = points.flatten
cycle = 0

loop do
  cycle += 1
  flattened.each(&:increment!)
  flash(flattened)
  if cycle == 100
    puts "=" * 40, "PART I", ""
    draw points
    puts flattened.reduce(0){ |sum, point| sum + point.flashes }, ""
  end
  if flattened.all?(&:flashed?)
    puts "=" * 40, "PART II", ""
    puts cycle
    break
  end
end
