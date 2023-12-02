class Cube
  attr_reader :id, :color

  def initialize(cube)
    @id, @color = cube.split(' ')
  end

  def count
    @id.to_i
  end

  def inspect
    "#{id} #{color}"
  end
end

class Game
  attr_reader :id, :cubes

  def initialize(input_data)
    game, cube_set = input_data.split(':')
    @id = game.split(' ')[-1].to_i
    @cubes = cube_set.split(';').map{ |draw| draw.split(', ').map{ |cube| Cube.new(cube) } }
  end

  def most_seen
    cubes.reduce(Hash.new(0)) do |hash, draw|
      draw.each{ |cube| hash[cube.color] = [hash[cube.color], cube.count].max }
      hash
    end
  end

  def power
    most_seen.values.reduce(:*)
  end

  def inspect
    "game #{id}: #{cubes.map(&:inspect).join('; ')}: #{power}"
  end
end

def possible?(game, at_most)
  game.most_seen.all?{ |color, count| count <= at_most[color] }
end

input_data = File.read('input.txt').split("\n")
games = input_data.map{ |data| Game.new(data) }

print "PART 1: "
at_most = {'red' => 12, 'green' => 13, 'blue' => 14}
possible_games = games.select{ |game| possible?(game, at_most) }
puts possible_games.reduce(0){ |sum, game| sum + game.id }

print "PART 2: "
puts games.reduce(0){ |sum, game| sum + game.power }
