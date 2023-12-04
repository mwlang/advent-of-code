class Number
  attr_reader :x, :y, :number

  def initialize(number:, x:, y:)
    @number = number
    @x = x
    @y = y
    @part = false
  end

  def length
    number.size
  end

  def is_part=(value)
    @part = value unless part?
  end

  def part?
    @part
  end

  def inspect
    "[#{@x},#{@y}]: #{@number}#{'p' if part?}"
  end
end

class PartSymbol
  attr_reader :x, :y, :symbol

  def initialize(symbol:, x:, y:)
    @symbol = symbol
    @x = x
    @y = y
    @parts = []
  end

  def gear?
    @symbol == '*' && @parts.count == 2
  end

  def gear_ratio
    return 0 unless gear?
    @parts.map(&:number).map(&:to_i).reduce(:*)
  end

  def inspect
    "[#{@x},#{@y}]: #{@symbol}"
  end

  def cover?(number:, grid:)
    from_x = [number.x - 1, 0].max
    from_y = [number.y - 1, 0].max

    to_x = [number.x + number.length, grid.max_width - 1].min
    to_y = [number.y + 1, grid.max_height - 1].min

    if (from_x..to_x).cover?(x) && (from_y..to_y).cover?(y)
      number.is_part = true
      @parts << number
    end
  end
end

# 467..114.. 0
# ...*...... 1
# ..35..633. 2
# ......#... 3
# 617*...... 4
# .....+.58. 5
# ..592..... 6
# ......755. 7
# ...$.*.... 8
# .664.598.. 9

class Grid
  attr_reader :symbols, :max_width, :max_height

  def initialize(data)
    @max_width = data.first.chars.size - 1
    @max_height = data.size - 1
    @numbers = []
    @symbols = []
    find_parts_and_symbols(data)
    mark_part_numbers
  end

  def part_numbers
    @numbers.select(&:part?)
  end

  private

  def scan_symbols(row:, y:)
    row.chars.each.with_index do |symbol, x|
      next if symbol.match(/[0-9.]/)
      @symbols << PartSymbol.new(symbol:, x:, y:)
    end
  end

  def scan_part_numbers(row:, y:)
    positions = row.enum_for(:scan, /\d+/).map { Regexp.last_match.begin(0) }
    row.scan(/\d+/).each_with_index do |number, index|
      x = positions[index]
      @numbers << Number.new(number:, x:, y:)
    end
  end

  def find_parts_and_symbols(data)
    data.each.with_index do |row, y|
      scan_part_numbers(row:, y:)
      scan_symbols(row:, y:)
    end
  end

  def mark_part_numbers
    @numbers.each do |number|
      @symbols.any?{ |symbol| symbol.cover?(number:, grid: self) }
    end
  end
end

data = File.read('input.txt').split("\n")
grid = Grid.new(data)

print "Part 1: "
puts grid.part_numbers.reduce(0){ |sum, number| sum + number.number.to_i }

print "Part 2: "
puts grid.symbols.map(&:gear_ratio).sum
