class Command
  attr_reader :direction, :distance

  def initialize(direction, distance)
    @direction = direction.to_sym
    @distance = distance.to_i
  end
end

class Position
  attr_reader :horizontal, :vertical
  def initialize
    @horizontal = 0
    @vertical = 0
  end

  def execute command
    case command.direction
    when :up then move_up(command)
    when :down then move_down(command)
    when :forward then move_forward(command)
    end
  end

  def move_forward command
    @horizontal += command.distance
  end

  def move_down command
    @vertical += command.distance
  end

  def move_up command
    @vertical -= command.distance
  end

  def location
    @horizontal * @vertical
  end
end

class SmartPosition < Position
  attr_reader :aim

  def initialize
    super
    @aim = 0
  end

  def move_forward command
    super(command)
    @vertical += (@aim * command.distance)
  end

  def move_down command
    @aim += command.distance
  end

  def move_up command
    @aim -= command.distance
  end
end

commands = File.read('input.txt').split("\n").map { |line| Command.new(*line.split(/\s+/)) }

position = Position.new
commands.each { |command| position.execute command }

pp [position.horizontal, position.vertical, position.location]


position = SmartPosition.new
commands.each { |command| position.execute command }

pp [position.horizontal, position.vertical, position.location]
