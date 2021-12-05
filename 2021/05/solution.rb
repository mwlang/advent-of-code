class Point
  attr_reader :x, :y

  def initialize xy
    @x, @y = xy.split(',').map(&:to_i)
  end

  def inspect
    "<Point x: #{x}, y:#{y}>"
  end
end

class Vent
  attr_reader :a, :b

  def initialize a, b
    @a = Point.new(a)
    @b = Point.new(b)
  end

  def horizontal?; a.x == b.x end
  def vertical?; a.y == b.y end
  def orthogonal?; horizontal? || vertical? end
  def max_x; [a.x, b.x].max end
  def max_y; [a.y, b.y].max end
  def min_x; [a.x, b.x].min end
  def min_y; [a.y, b.y].min end

  def points
    dx = (px = a.x) > b.x ? -1 : a.x == b.x ? 0 : 1
    dy = (py = a.y) > b.y ? -1 : a.y == b.y ? 0 : 1

    [[px, py]].tap{ |points| points << [px += dx, py += dy] while [px, py] != [b.x, b.y] }
  end
end

class Ocean
  attr_reader :vents
  attr_reader :floor

  def initialize vents
    @vents = vents
    @floor = (max_y + 1).times.map{ |y| Array.new(max_x + 1, 0) }
  end

  def draw_vent_lines vent_lines
    vent_lines.each do |vent|
      vent.points.each do |x, y|
        @floor[x][y] += 1
      end
    end
  end

  def max_x
    @max_x ||= vents.map(&:max_x).max
  end

  def max_y
    @max_y ||= vents.map(&:max_y).max
  end

  def danger_zones
    @floor.flat_map{ |line| line.select{ |s| s > 1 } }
  end
end

vents = File.read('input.txt').split("\n").map{|l| Vent.new(*l.split(" -> "))}
orthogonal_vents = vents.select(&:orthogonal?)
diagonal_vents = vents.reject(&:orthogonal?)

ocean = Ocean.new(vents)

ocean.draw_vent_lines(orthogonal_vents)
puts ["Part I", ocean.danger_zones.size].join("\t")

ocean.draw_vent_lines(diagonal_vents)
puts ["Part II", ocean.danger_zones.size].join("\t")
