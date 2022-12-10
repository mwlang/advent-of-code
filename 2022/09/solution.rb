data = File.read('input.txt').split("\n").map{ |line| line.split(" ") }

ORTHOGONAL_DIRECTIONS = [[0, 1], [0, -1], [1, 0], [-1, 0]].freeze
DIAGONAL_DIRECTIONS = [[1, 1], [1, -1], [-1, -1], [-1, 1]].freeze

MOVEMENTS = {
  'R' => {dx:  1,  dy:  0},
  'L' => {dx: -1,  dy:  0},
  'U' => {dx:  0,  dy:  1},
  'D' => {dx:  0,  dy: -1},
}
class Point
  attr_reader :x, :y
  attr_reader :visited

  def initialize
    @x = 0
    @y = 0
  end

  def track_visits!
    @visited = [position]
  end

  def position
    [x, y]
  end

  def track!
    return unless @visited
    return if @visited.include? position

    visited << position
  end

  def move(dx:, dy:)
    @x += dx
    @y += dy
    track!
  end

  def adjacent?(point, x: @x, y: @y)
    (point.x - x).abs <= 1 && (point.y - y).abs <= 1
  end
end

class Head < Point
end

class Tail < Point
  def follow(point)
    return if adjacent?(point)

    (point.x - x).abs + (point.y - y).abs > 2 ? follow_diagonally(point) : follow_othogonally(point);
  end

  def follow_diagonally(point)
    DIAGONAL_DIRECTIONS.each do |dx, dy|
      next unless adjacent?(point, x: @x + dx, y: @y + dy)

      move dx: dx, dy: dy
      break
    end
  end

  def follow_othogonally(point)
    ORTHOGONAL_DIRECTIONS.each do |dx, dy|
      next unless adjacent?(point, x: @x + dx, y: @y + dy)

      move dx: dx, dy: dy
      break
    end
  end
end

class Knot < Tail
  attr_accessor :head

  def follow
    super(@head)
  end
end
class Rope
  attr_reader :head, :tail

  def initialize
    @head = Head.new
    @tail = Tail.new
    tail.track_visits!
  end

  def move(steps:, dx:, dy:)
    steps.times.each do
      head.move(dx: dx, dy: dy)
      follow
    end
  end

  def follow
    tail.follow(head)
  end
end

def waggle rope, data
  data.each{ |direction, steps| rope.move(steps: steps.to_i, **MOVEMENTS[direction]) }
  puts rope.tail.visited.uniq.size
end

print "PART 1: "
waggle Rope.new, data

class BigRope < Rope
  attr_reader :knots

  def initialize
    @head = Head.new
    @knots = []
    build_knots(9)
    tail.track_visits!
  end

  def tail
    @knots[-1]
  end

  def build_knots count
    return if count.zero?

    @knots << Knot.new.tap{ |knot| knot.head = (tail || head) }
    build_knots count - 1
  end

  def follow
    knots.each(&:follow)
  end
end

print "PART 2: "
waggle BigRope.new, data
