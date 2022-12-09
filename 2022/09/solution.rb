data = File.read('input.txt').split("\n").map{ |line| line.split(" ") }

pp data

class Point
  attr_reader :x, :y
  attr_reader :visited

  def initialize(x, y)
    @x = x
    @y = y
    @visited = [position]
  end

  def position
    [x, y]
  end

  def track!
    return if visited.include? position

    visited << position
  end

  def move(dx:, dy:)
    @x += dx
    @y += dy
    track!
  end

  def follow(point)
    return if adjacent?(point)
    return follow_horizontally(point) if would_be_adjacent?(point, dy: point.y <=> y)
    return follow_vertically(point) if would_be_adjacent?(point, dx: point.x <=> x)
  end

  def would_be_adjacent?(point, dx: 0, dy: 0)
    require 'ruby_jard'; jard
    adjacent?(point, x: @x + dx, y: @y + dy)
  end

  def adjacent?(point, x: @x, y: @y)
    (point.x - x).abs <= 1 && (point.y - y).abs <= 1
  end

  def follow_horizontally(point)
    dx = point.x <=> @x
    @x += dx
    track!
  end

  def follow_vertically(point)
    dy = point.y <=> @y
    @y += dy
    track!
  end
end

class Head < Point
end

class Tail < Point
end

class Rope
  attr_reader :head, :tail

  def initialize(x:, y:)
    @head = Head.new(x, y)
    @tail = Tail.new(x, y)
    tail.track!
  end

  def move(steps:, dx:, dy:)
    steps.times.each do
      head.move(dx: dx, dy: dy)
      tail.follow(head)
    end
  end
end

require 'rspec'

RSpec.describe Point do
  let(:head_x) { 0 }
  let(:head_y) { 0 }
  let(:tail_x) { 0 }
  let(:tail_y) { 0 }

  let(:head) { Head.new(head_x, head_y) }
  let(:tail) { Tail.new(tail_x, tail_y) }

  subject { head }

  context "#would_be_adjacent?" do
    [
      [0, 2, 1, 0, true],
      [2, 0, 0, 1, true],
    ].each do |x, y, dx, dy, expected|
      it "head at [#{x}, #{y}] and moving by [#{dx}, #{dy}]" do
        head = Head.new(x, y)
        expect(tail.would_be_adjacent?(head, dx: dx, dy: dy)).to eq expected
      end
    end
  end

  context "#would_be_adjacent" do
  end
end

# rope = Rope.new(x: 0, y: 0)

# rope.move(steps: 4, dx: 1, dy: 0)
# rope.move(steps: 1, dx: 0, dy: 1)
# rope.move(steps: 4, dx: -1, dy: 0)
# pp rope.tail.visited.uniq

