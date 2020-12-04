class Elevation
  def initialize pattern
    @pattern = pattern.chomp
  end

  def treed?(checkpoint)
    repeat = (checkpoint / @pattern.size) + 1
    full = @pattern * repeat
    treed = full[checkpoint] == "#"
    full[checkpoint] = treed ? "X" : "O"
    treed
  end

  def to_s
    @pattern
  end
end

mountain = File.readlines("input.txt").map{|row| Elevation.new(row)}

def trees_of_the_slope mountain, x, y
  trees = 0
  mountain.each_with_index do |elevation, index|
    next if index % y != 0
    trees += 1 if elevation.treed? (x * index)
  end
  trees
end

puts trees_of_the_slope(mountain, 3, 1)

# Right 1, down 1.
# Right 3, down 1. (This is the slope you already checked.)
# Right 5, down 1.
# Right 7, down 1.
# Right 1, down 2.

slopes = [
  [1, 1],
  [3, 1],
  [5, 1],
  [7, 1],
  [1, 2]
]
trees = slopes.reduce(1){ |trees, slope| trees * trees_of_the_slope(mountain, *slope) }

puts trees