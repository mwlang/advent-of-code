crab_positions = File.read('input.txt').split(",").map(&:to_i).sort

crabbies = Hash.new
crab_positions.each do |position|
  crabbies[position] ||= 0
  crabbies[position] += 1
end

def alpha(plane, current)
  (plane - current).abs
end

def delta plane, current, step = 1
  return 0 if plane == current

  direction = current > plane ? -1 : 1
  step + delta(plane, current + direction, step + 1)
end

def compute crabbies
  crabbies.keys.min.upto(crabbies.keys.max).map do |plane|
    fuel_used = crabbies.reduce(0){|sum, c| sum + yield(plane, c[0]) * c[1]}
    [plane, fuel_used]
  end.sort_by(&:last)
end

pp compute(crabbies){ |plane, current| alpha(plane, current) }[0]
pp compute(crabbies){ |plane, current| delta(plane, current) }[0]
