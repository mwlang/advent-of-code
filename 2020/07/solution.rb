BAG_RULES = {}

class BagRule
  attr_accessor :name, :contains
  def initialize name
    @name = name.strip
    @contains = {}
  end

  def contains bag, quantity
    @contains[bag] = quantity
  end

  def contains? bag
    @contains.keys.detect{|held| held.name == bag.name || BAG_RULES[held.name].contains?(bag)}
  end

  def bag_count
    @contains.map{|bag, qty| qty * (1 + bag.bag_count)}.reduce(0){|sum, qty| sum + qty}
  end

  def to_s
    "#{name} => #{contains.map{|k,v| "#{k} #{v}"}.join(", ")}"
  end
end

def load_bag_rules
  data = File.read("input.txt").split("\n").map{|l| l.gsub(/\sbags?|\./,'')}
  data.each do |line|
    contains, contained = line.split(" contain ")
    BAG_RULES[contains] ||= BagRule.new(contains)
    contained.split(/,\s?/).each do |held|
      next if held =~ /no other/
      _, qty, held_name = held.match(/^(\d+)(.*)$/).to_a
      held_name = held_name.strip
      BAG_RULES[held_name] ||= BagRule.new(held_name)
      BAG_RULES[contains].contains BAG_RULES[held_name], qty.to_i
    end
  end
end

def contains_shiny_gold_bag
  puts BAG_RULES.values.select{|bag| bag.contains?(BAG_RULES["shiny gold"])}.size
end

def bags_in_shiny_gold_bag
  puts BAG_RULES["shiny gold"].bag_count
end

load_bag_rules
contains_shiny_gold_bag
bags_in_shiny_gold_bag