ACTIVE = {"." => false, "#" => true}

module Dimension
  extend self

  @@dimensions = 3

  def four!
    @@dimensions = 4
  end

  @@x_min, @@x_max = 0, 0
  @@y_min, @@y_max = 0, 0
  @@z_min, @@z_max = 0, 0
  @@w_min, @@w_max = 0, 0

  def expand
    @@x_min -= 1; @@x_max += 1
    @@y_min -= 1; @@y_max += 1
    @@z_min -= 1; @@z_max += 1
    return unless @@dimensions == 4
    @@w_min -= 1; @@w_max += 1
  end

  def cycle
    expand
    x.each{|x| y.each{|y| z.each{|z| w.each{|w| yield x, y, z, w}}}}
  end

  def coordinate(x, y, z, w, expand = true)
    if expand
      @@x_min, @@x_max = [@@x_min, @@x_max, x].minmax
      @@y_min, @@y_max = [@@y_min, @@y_max, y].minmax
      @@z_min, @@z_max = [@@z_min, @@z_max, z].minmax
      @@w_min, @@w_max = [@@w_min, @@w_max, w].minmax
    end
    [x, y, z, w].join(":")
  end

  def x; (@@x_min..@@x_max) end
  def y; (@@y_min..@@y_max) end
  def z; (@@z_min..@@z_max) end
  def w; (@@w_min..@@w_max) end

  def dx; (-1..1) end
  def dy; (-1..1) end
  def dz; (-1..1) end
  def dw; @@dimensions == 3 ? [0] : (-1..1) end

  # works, but sloooow!
  # def neighbors
  #   [dx.to_a, dy.to_a, dz.to_a, dw.to_a].flatten.combination(4)
  # end

  def neighbor_coordinates(x, y, z, w)
    dx.flat_map do |dx|
      dy.flat_map do |dy|
        dz.flat_map do |dz|
          dw.map do |dw|
            [x + dx, y + dy, z + dz, w + dw]
          end
        end
      end
    end.reject{|coordinate| coordinate == [x,y,z,w]}
  end
end

class Cube
  attr_reader :x, :y, :z, :w
  attr_accessor :active

  def initialize active, x, y, z, w
    @x, @y, @z, @w = x, y, z, w
    @active = active
  end

  def location
    @location ||= Dimension.coordinate(x, y, z, w)
  end

  def neighbor_coordinates
    @neighbor_coordinates ||= Dimension.neighbor_coordinates(x,y,z,w)
  end

  def neighbor_locations space
    neighbor_coordinates.map do |xyzw|
      nlocation = Dimension.coordinate(*xyzw, false)
      if neighbor = space[nlocation]
        neighbor.location
      end
    end
  end

  def cycle space, all_active_locations
    active_neighbors = (neighbor_locations(space) & all_active_locations).size
    if active
      @active = [2, 3].include? active_neighbors
    else
      @active = active_neighbors == 3
    end
  end
end

def show space
  Dimension.z.each do |z|
    puts "z = #{z}"
    Dimension.y.each do |y|
      row = Dimension.x.map do |x|
        location = Dimension.coordinate(x, y, z, 0)
        cell = space[location]
        cell ? ACTIVE.invert[cell.active] : "%"
      end
      puts row.join
    end
    puts
  end
end

def cycle space, active_locations
  Dimension.cycle do |x, y, z, w|
    location = Dimension.coordinate(x, y, z, w)
    cube = space[location] ||= Cube.new(false, x, y, z, w)
    cube.cycle(space, active_locations)
  end
end

def load_space
  space = {}

  cells = File.read("input.txt").split("\n")
  cells.each_with_index do |row, y|
    row.chars.each_with_index do |cell, x|
      space[Dimension.coordinate(x, y,  0, 0)] = Cube.new(ACTIVE[cell], x, y,  0, 0)
    end
  end
  space
end

def process cycles
  yield if block_given?
  space = load_space
  cycles.times do |turn|
    active_locations = space.values.select(&:active).map(&:location)
    cycle space, active_locations
    print "active cells: "
    puts space.values.select(&:active).size
  end
end

def cycle_3d
  process(6)
end

def cycle_4d
  process(6) { Dimension.four! }
end

cycle_3d
cycle_4d