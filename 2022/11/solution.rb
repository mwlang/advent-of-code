class Monkey
  attr_reader :items, :operation, :modulus, :positive_target, :negative_target
  attr_reader :inspections, :clan

  def initialize(items, operation, modulus, positive_target, negative_target)
    @items = items.map(&:to_i)
    @operation = operation
    @modulus = modulus
    @positive_target = positive_target
    @negative_target = negative_target
    @inspections = 0
  end

  def greet clan
    @clan = clan
  end

  def << item
    @items << item
  end

  def bananas
    clan.bananas
  end

  def play worry_o_meter
    return if items.empty?

    items.each do |item|
      @inspections += 1
      item = worry_o_meter.worry!(item: item, operation: operation)
      item = worry_o_meter.relax!(item: item, monkeys: self)

      catcher = (item % modulus).zero? ? clan[positive_target] : clan[negative_target]
      catcher << item
    end
    items.clear
  end
end

class Monkeys
  attr_reader :monkeys

  def initialize
    @monkeys = yield
    clan.each { |monkey| monkey.greet(self) }
  end

  def bananas
    @bananas ||= clan.map(&:modulus).reduce(:lcm)
  end

  def [](index)
    monkeys[index]
  end

  def clan
    monkeys.values
  end
end

class WorryoMeter
  def self.worry! item:, operation:
    old = item.to_s
    eval operation.gsub('old', old)
  end
end

class AgitatedWorryoMeter < WorryoMeter
  def self.relax! item:, monkeys: nil
    item / 3
  end
end

class RidiculousWorryoMeter < WorryoMeter
  def self.relax! item:, monkeys:
    item % monkeys.bananas
  end
end

def load_monkeys
  data = File.read('input.txt').split("\n\n").map{ |line| line.split("\n") }

  Monkeys.new do
    data.map do |entry|
      monkey_id = entry.shift.scan(/\d+/).first.to_i

      items = entry.shift.split(": ").last.split(", ").map(&:to_i)
      operation = entry.shift.split(": ").last.gsub('new = ', '')
      modulus = entry.shift.scan(/\d+/).first.to_i

      positive_target = entry.shift.scan(/\d+/).first.to_i
      negative_target = entry.shift.scan(/\d+/).first.to_i

      [monkey_id, Monkey.new(items, operation, modulus, positive_target, negative_target)]
    end.to_h
  end
end

def play_keepaway(part:, count:, worry_o_meter:)
  print "PART #{part} "

  monkeys = load_monkeys
  count.times { monkeys.clan.each { |monkey| monkey.play worry_o_meter } }

  a, b = monkeys.clan.sort_by{ |monkey| monkey.inspections }.pop(2)
  puts a.inspections * b.inspections
end

play_keepaway part: 1, count: 20, worry_o_meter: AgitatedWorryoMeter
play_keepaway part: 2, count: 10_000, worry_o_meter: RidiculousWorryoMeter
