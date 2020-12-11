SEAT_CHART = {"." => nil, "L" => 0, "#" => 1}
NEIGHBORS = [[-1,-1], [0,-1], [1,-1],   [-1,0], [1, 0],   [-1, 1], [0, 1], [1, 1]]

class Lobby
  attr_reader :seats
  attr_reader :width, :height

  def initialize seats, tolerance
    @seats = seats.join.chars.map{|c| SEAT_CHART[c]}
    @tolerance = tolerance
    @width = seats[0].size
    @height = seats.size
  end

  def to_s
    @seats.each_slice(@width).map{|row| row.map{|s| SEAT_CHART.invert[s]}.join}
  end

  def in_range? x, y
    x.between?(0, @width - 1) && y.between?(0, @height - 1)
  end

  def seat x, y, source
    in_range?(x, y) ? source[x + (@width * y)] : nil
  end

  def seat_in_sight x, y, dx, dy, source
    return unless in_range?(x, y)
    source[x + (@width * y)] || seat_in_sight(x + dx, y + dy, dx, dy, source)
  end

  def adjacent_seats source, index
    x, y = index % @width, index / @width
    NEIGHBORS.map{|dx, dy| seat(x + dx, y + dy, source)}.compact
  end

  def line_of_sight_seats source, index
    x, y = [index % @width, index / @width]
    NEIGHBORS.map{|dx, dy| seat_in_sight(x + dx, y + dy, dx, dy, source)}.compact
  end

  def occupied
    @seats.reduce(0){|sum, s| sum + s.to_i}
  end

  def musical_chairs
    ghosts = @seats.dup
    ghosts.each_with_index do |seat, index|
      next unless seat
      occupied = yield(ghosts, index).reduce(0){|sum, v| sum + v}
      @seats[index] = SEAT_CHART["#"] if occupied.zero? && ghosts[index] == SEAT_CHART["L"]
      @seats[index] = SEAT_CHART["L"] if occupied >= @tolerance && ghosts[index] == SEAT_CHART["#"]
    end
    ghosts != @seats
  end

  def flip_adjacents
    musical_chairs { |source, index| adjacent_seats source, index }
  end

  def flip_line_of_sights
    musical_chairs { |source, index| line_of_sight_seats source, index }
  end
end

def solve seats, tolerance
  lobby = Lobby.new(seats, tolerance)
  iteration = 0
  iteration += 1 while yield(lobby)

  puts "Iterations: #{iteration}"
  puts "Occupied: #{lobby.occupied}"
end

def crowded_neighbors data
  solve(data, 4){ |lobby| lobby.flip_adjacents }
end

def look_around data
  solve(data, 5){ |lobby| lobby.flip_line_of_sights }
end

seats = File.read("input.txt").split("\n")

crowded_neighbors seats
look_around seats