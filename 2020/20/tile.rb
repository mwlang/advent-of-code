require_relative "./tile"

class Tile
  attr_reader :id, :sides, :data
  attr_reader :top, :left, :right, :bottom

  def initialize(tile_id, data)
    @id = tile_id
    @data = data.map(&:chars)
    @sides = generate_sides.map{|s| [s, []]}.to_h
    @top, @left, @right, @bottom = nil
  end

  def [](index)
    borderless[index]
  end

  def hashes
    @data.flat_map{ |row| row.select { |d| d == "#" } }.size
  end

  def borderless
    data[1...-1].map{ |row| row[1...-1] }
  end

  def size
    @data.size
  end

  def inspect
    "#<Tile:#{@id} @top=#{@top&.id.inspect} @right=#{@right&.id.inspect} @bottom=#{@bottom&.id.inspect} @left=#{@left&.id.inspect}>"
  end

  def rotate track: true
    @data = @data.transpose.map(&:reverse)
    return unless track
    @top, @right, @bottom, @left = [@left, @top, @right, @bottom]
  end

  def reverse
    @data = @data.map(&:reverse)
    @left, @right = [@right, @left]
  end

  def to_s
    @data.map(&:join).join("\n")
  end

  def pair(other)
    (sides.keys & other.sides.keys).each do |side|
      sides[side] << other
      update!
      other.sides[side] << self
      other.update!
    end
  end

  def update!
    @top, @left, @right, @bottom = [fetch_top, fetch_left, fetch_right, fetch_bottom]
  end

  def to_fixture
    puts "let(:tile_#{@id}) do"
    puts "   Tile.new("
    puts "    #{@id}, ["
    @data.each { |d| puts "    \"#{d.join}\"," }
    puts "    ])"
    puts "end"
  end

  def matches
    {
      t: top&.id    || "    ",
      l: left&.id   || "    ",
      r: right&.id  || "    ",
      b: bottom&.id || "    "
    }.to_a.join(" ")
  end

  def top?; top.nil? end
  def left?; left.nil? end
  def right?; right.nil? end
  def bottom?; bottom.nil? end

  def fetch_top; @sides.values[0][0] end
  def fetch_left; @sides.values[2][0] end
  def fetch_right; @sides.values[6][0] end
  def fetch_bottom; @sides.values[4][0] end

  def neighbors
    [top, left, right, bottom].compact.size
  end

  def corner?
    neighbors == 2
  end

  def edge?
    neighbors == 3
  end

  def top_left?
    top? && left?
  end

  def top_right?
    top? && right?
  end

  def bottom_left?
    bottom? && left?
  end

  def bottom_right?
    bottom? && right?
  end

  private

  def generate_sides
    4.times.flat_map do
      [@data[0].join, @data[0].join.reverse].tap { rotate(track: false) }
    end
  end
end
