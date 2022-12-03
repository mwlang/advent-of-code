data = File.read('input.txt').split("\n")

module Priorities
  def lower_priority item
    ('a'..'z').to_a.unshift(nil).index item
  end

  def upper_priority item
    p = ('A'..'Z').to_a.unshift(nil).index(item) and p + 26
  end

  def priority item
    lower_priority(item) || upper_priority(item)
  end
end

class Rucksack
  include Priorities
  attr_reader :front, :back

  def initialize item_list
    @front, @back = item_list.chars.each_slice(item_list.size / 2).map(&:itself)
  end

  def shared_priorities
    (front & back).map{ |item| priority(item) }
  end

  def items
    @front + @back
  end
end

rucksacks = data.map { |item_list| Rucksack.new(item_list) }

print "PART 1: "
puts rucksacks.map(&:shared_priorities).flatten.reduce(&:+)

class Group
  include Priorities
  attr_reader :rucksacks

  def initialize rucksacks
    @rucksacks = rucksacks
  end

  def badge
    rucksacks.map(&:items).reduce(&:&)
  end

  def badge_priority
    badge.map{ |item| priority(item) }.reduce(&:+)
  end
end

groups = rucksacks.each_slice(3).map{ |rucksacks| Group.new(rucksacks) }

print "PART 2: "
puts groups.map(&:badge_priority).reduce(&:+)
