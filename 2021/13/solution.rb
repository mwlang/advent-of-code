class Dot
  attr_reader :x, :y
  def initialize input
    @x, @y = input.split(",").map(&:to_i)
  end
end

class Fold
  attr_reader :axis
  attr_reader :crease
  def initialize input
    input.split("=").tap do |axis, crease|
      @axis = axis =~ /x/ ? :x : :y
      @crease = crease.to_i
    end
  end
end

class Paper
  attr_reader :lines

  def initialize dots
    max_x = dots.map(&:x).max + 1
    max_y = dots.map(&:y).max + 1
    @lines = Array.new(max_x) { Array.new(max_y, '.') }.transpose
    dots.each{ |dot| lines[dot.y][dot.x] = "#" }
  end

  def fold_at fold
    print "folding #{lines.size}/#{lines[0].size} at #{fold.crease} (#{fold.crease * 2})"
    fold.axis == :x ? fold_across(fold.crease) : fold_up(fold.crease)
  end

  def fold_up crease
    puts " up"
    bottom_half = lines.pop(crease + 1).reverse
    bottom_half.each_with_index do |line, y|
      if lines[y].nil?
        next
        puts "adding a line on #{y}"
        lines << line
      else
        line.each_with_index do |value, x|
          lines[y][x] = value if value == "#"
        end
      end
    end
  end

  def fold_across crease
    puts " across"
    @lines = lines.transpose
    fold_up crease
    @lines = lines.transpose
  end

  def tally
    lines.reduce(0){ |sum, line| sum + line.tally['#'].to_i }
  end
end

dots_instructions, folds_instructions = File.read("input.txt").split("\n\n").map{|part| part.split("\n")}

dots = dots_instructions.map{ |input| Dot.new(input) }
folds = folds_instructions.map{ |input| Fold.new(input) }
paper = Paper.new(dots)

puts "=" * 40, "PART I", ""

paper.fold_at folds.shift
puts paper.tally

puts "=" * 40, "PART II", ""

folds.each{ |fold| paper.fold_at(fold) }

puts paper.lines.map(&:join).join("\n")

# EAMKRECP