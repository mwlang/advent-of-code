class Command
  ACTIONS = {
    "N" => ->(c,v){ v.move(0,  c.value) }, # Action N means to move north by the given value.
    "S" => ->(c,v){ v.move(0, -c.value) }, # Action S means to move south by the given value.
    "E" => ->(c,v){ v.move( c.value, 0) }, # Action E means to move east by the given value.
    "W" => ->(c,v){ v.move(-c.value, 0) }, # Action W means to move west by the given value.
    "L" => ->(c,v){ v.rotate( c.value) },  # Action L means to turn left the given number of degrees.
    "R" => ->(c,v){ v.rotate(-c.value) },  # Action R means to turn right the given number of degrees.
    "F" => ->(c,v){ v.forward(c.value) },  # Action F means to move forward by the given value in the direction the
  }
  attr_reader :command, :value, :action

  def initialize action_and_value
    _, @command, @value = action_and_value.match(/^([A-Z])(\d+)$/).to_a
    @action = ACTIONS[@command]
    @value = @value.to_i
  end

  def forward?
    @command == "F"
  end
end

module Coordinates
  attr_reader :x, :y

  def initialize x, y
    @x = x
    @y = y
  end

  def navigate command
    command.action.call command, self
  end

  def manhattan_distance
    @x.abs + @y.abs
  end

  def move x, y
    @x += x
    @y += y
  end

  def rotate degrees
    (degrees.abs / 90).times{ degrees < 0 ? clockwise : counter_clockwise }
  end

  def clockwise
    @x, @y = y, -x
  end

  def counter_clockwise
    @x, @y = -y, x
  end
end

class Vessel
  include Coordinates

  attr_reader :facing

  def initialize
    super(0, 0)
    @facing = 0
  end

  def forward distance
    case facing
    when 0   then move distance, 0
    when 180 then move -distance, 0
    when 90  then move 0, distance
    when 270 then move 0, -distance
    else raise "wrong direction #{@facing}"
    end
  end

  def rotate degrees
    @facing += degrees
    @facing -= 360 while @facing >= 360
    @facing += 360 while @facing < 0
  end
end

class Waypoint
  include Coordinates
end

class WaypointVessel < Vessel
  attr_reader :waypoint

  def initialize waypoint
    super()
    @waypoint = waypoint
  end

  def forward distance
    @x += (distance * @waypoint.x)
    @y += (distance * @waypoint.y)
  end

  def navigate command
    command.forward? ? forward(command.value) : waypoint.navigate(command)
  end
end

if __FILE__ == $0
  commands = File.read("input.txt").split("\n").map{|line| Command.new(line)}

  ship = Vessel.new
  commands.each{|c| ship.navigate(c)}
  puts ship.manhattan_distance

  ship = WaypointVessel.new(Waypoint.new(10, 1))
  commands.each{|c| ship.navigate(c)}
  puts ship.manhattan_distance
end