
fishies = 9.times.map{|i| [i, 0]}.to_h

ages = File.read('input.txt').split(",").map(&:to_i)
ages.each{ |age| fishies[age] += 1 }

pp fishies

def generate(fishies, cycles)
  return if cycles.zero?

  zeros = fishies[0]
  fishies.keys.each_cons(2) do |a, b|
    fishies[a] = fishies[b]
  end
  fishies[8] = zeros
  fishies[6] += zeros
  generate(fishies, cycles - 1)
end

puts "=" * 40, "PART I", ""

generate(fishies, 80)
pp fishies
total_fishies = fishies.values.reduce(0){ |sum, age| sum + age }
pp total_fishies

puts "=" * 40, "PART II", ""

generate(fishies, 256 - 80)
pp fishies
total_fishies = fishies.values.reduce(0){ |sum, age| sum + age }
pp total_fishies
