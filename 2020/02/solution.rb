class DownTheStreetPolicy
  def initialize policy
    range, @letter = policy.split(" ")
    @low, @high = range.split("-").map(&:to_i)
  end
  def valid?(password)
    letters = password.chars.group_by(&:itself).map{|k,v| [k, v.size]}.to_h
    letters[@letter].to_i.between?(@low, @high)
  end
end

class CorporatePolicy
  def initialize policy
    range, @letter = policy.split(" ")
    @low, @high = range.split("-").map(&:to_i)
  end
  def valid?(password)
    letters = password.chars
    a = letters[@low - 1]
    b = letters[@high - 1]
    (a == @letter || b == @letter) && (a != b)
  end
end

class Entry
  def initialize entry, policy_class
    parts = entry.split(": ")
    @policy = policy_class.new(parts.shift)
    @password = parts.shift
  end

  def valid?
    @policy.valid?(@password)
  end
end

def load_em_and_count_em policy_class
  entries = File.readlines("input.txt").map{|entry| Entry.new(entry, policy_class)}
  puts entries.select(&:valid?).size
end

load_em_and_count_em DownTheStreetPolicy
load_em_and_count_em CorporatePolicy
