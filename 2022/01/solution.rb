data = File.read('input.txt').split("\n\n").map{ |a| a.split("\n").map(&:to_i) }

class Elf
  def initialize items
    @items = items
  end

  def total_weight
    @items.reduce(&:+)
  end

  def <=> other
    total_weight <=> other.total_weight
  end

  def + lhs
    lhs + total_weight
  end

  def coerce num
    [self, num]
  end
end

elves = data.map { |items| Elf.new(items) }

puts "PART 1: #{elves.max.total_weight}"
puts "PART 2: #{elves.max(3).reduce(&:+)}"
