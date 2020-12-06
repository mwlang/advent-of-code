class AllInGroup
  def initialize data
    @answers = data.join.chars.uniq
  end
  def count
    @answers.size
  end
end

class EveryoneGroup < AllInGroup
  def initialize data
    @answers = data.reduce(data.join.chars.uniq){|a, d| a & d.chars.uniq}
  end
end

def load_answers group_class
  lines = File.read("input.txt").split("\n")

  groups = []
  data = []
  while !lines.empty?
    line = lines.shift
    if line.empty?
      groups << group_class.new(data)
      data = []
    else
      data << line
    end
  end
  groups << group_class.new(data) unless data.empty?
  groups
end

def find_all_answers_in_group
  groups = load_answers AllInGroup
  puts groups.reduce(0){|sum, g| sum + g.count}
end

def find_everyone_answers_yes_in_group
  groups = load_answers EveryoneGroup
  puts groups.reduce(0){|sum, g| sum + g.count}
end

find_all_answers_in_group
find_everyone_answers_yes_in_group
