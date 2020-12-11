SEAT_CHART = {"." => nil, "L" => 0, "#" => 1}

class Lobby
  attr_reader :seats
  attr_reader :width, :height

  def initialize data, tolerance
    @seats = data.join.chars.map{|c| SEAT_CHART[c]}
    @tolerance = tolerance
    @width = data[0].size
    @height = data.size
  end

  def to_s
    @seats.each_slice(@width).map{|row| row.map{|s| SEAT_CHART.invert[s]}.join}
  end

  def seat x, y, source
    x.between?(0, @width - 1) && y.between?(0, @height - 1) ? source[x + (@width * y)] : nil
  end

  VECTOR = [[-1,-1], [0,-1], [1,-1], [-1,0], [1, 0],  [-1, 1], [0, 1], [1, 1]]

  def get_neighbors source, index
    x = (index % @width)
    y = (index / @width)
    VECTOR.map{|dx, dy| seat(x + dx, y + dy, source)}.compact
  end

  def seat_in_sight x, y, dx, dy, source
    if x.between?(0, @width - 1) && y.between?(0, @height - 1)
      n = x + (@width * y)
      source[n] ? source[n] : seat_in_sight(x + dx, y + dy, dx, dy, source)
    end
  end

  def get_line_of_sight source, index
    x = (index % @width)
    y = (index / @width)
    VECTOR.map{|dx, dy| seat_in_sight(x + dx, y + dy, dx, dy, source)}.compact
  end

  def occupied
    @seats.reduce(0){|sum, s| sum + s.to_i}
  end

  def musical_chairs
    ghosts = @seats.dup
    ghosts.each_with_index do |seat, index|
      next unless seat
      neighbors = yield ghosts, index
      occupied = neighbors.reduce(0){|sum, v| sum + v}
      @seats[index] = SEAT_CHART["#"] if occupied.zero? && ghosts[index] == SEAT_CHART["L"]
      @seats[index] = SEAT_CHART["L"] if occupied >= @tolerance && ghosts[index] == SEAT_CHART["#"]
    end
    ghosts != @seats
  end

  def tick
    musical_chairs { |source, index| get_neighbors source, index }
  end

  def kick
    musical_chairs { |source, index| get_line_of_sight source, index }
  end
end

def crowded_neighbors data
  lobby = Lobby.new(data, 4)
  iteration = 0
  iteration += 1 while lobby.tick

  puts "Iterations: #{iteration}"
  puts "Occupied: #{lobby.occupied}"
end

def look_around data
  lobby = Lobby.new(data, 5)
  iteration = 0
  iteration += 1 while lobby.kick

  puts "Iterations: #{iteration}"
  puts "Occupied: #{lobby.occupied}"
end

data = File.read("input.txt").split("\n")

crowded_neighbors data
look_around data