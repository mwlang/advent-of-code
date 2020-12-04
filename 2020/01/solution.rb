def solve(values, entries)
  sum = Array(values).reduce(0){|sum,v| sum + v}
  return nil if sum >= 2020

  prod = Array(values).reduce(1){|prod, v| prod * v }

  if entry = entries.detect{|d| d + sum == 2020}
    puts "%s and %d => %d" % [Array(values).join(', '), entry, prod * entry]
    return entry
  end
  nil
end

def pair_solution entries
  entries.each do |value|
    return if solve(value, entries - [value])
  end
end

def trifecta_solution entries
  entries.each do |value|
    sub_entries = entries - [value]
    sub_entries.each do |value2|
      return if solve([value, value2], sub_entries - [value2])
    end
  end
end

entries = File.readlines("input.txt").map(&:to_i)

pair_solution entries
trifecta_solution entries