require 'set'
require_relative 'hopper'
require_relative 'diverter'
require_relative  'seed_map'

data = File.read('input.txt').split("\n\n")
seeds_to_plant = data.shift.split("seeds: ")[1].split(" ").map(&:to_i)
seed_maps = data.map{ |mapping| SeedMap.new(mapping) }

def find_lowest_location(seeds_to_plant, seed_maps)
  hopper = Hopper.new(seeds_to_plant)
  seed_maps.each do |seed_map|
    seed_map.divert(hopper)
  end
  pp hopper.lowest_location
end

print "Part 1: "

find_lowest_location(seeds_to_plant, seed_maps)

print "Part 2: "

seed_ranges_to_plant = seeds_to_plant
  .each_slice(2)
  .map(&:itself).map{ |a, b| (a..(a + b - 1)) }

find_lowest_location(seed_ranges_to_plant, seed_maps)
