require_relative 'diverter'

# The hopper contains the seeds we are distributing
# We pass the source and destination ranges, compute the offset, then
# diverts all seeds in the hopper accordingly
class Hopper
  attr_reader :seed_ranges

  def initialize(seeds)
    @seed_ranges = Set.new
    add_seeds(seeds)
  end

  def collect_seeds
    seed_ranges.to_a.tap{ seed_ranges.clear }
  end

  def add_seeds(seeds)
    return seed_ranges << seeds if seeds.is_a?(Range)
    Array(seeds).each{ |new_seeds| seed_ranges << as_range(new_seeds) }
  end

  def remove_ranges(seeds)
    return seed_ranges.delete(seeds) if seeds.is_a?(Range)
    Array(seeds).each{ |new_seeds| seed_ranges.delete(as_range(new_seeds)) }
  end

  def as_range(seeds)
    return seeds if seeds.is_a?(Range)
    return (seeds..seeds) if seeds.is_a?(Integer)
    raise "Invalid seeds: #{seeds}"
  end

  def replace(old_seed_ranges, new_seed_ranges)
    remove_ranges(old_seed_ranges)
    add_seeds(new_seed_ranges)
  end

  def seeds
    seed_ranges.to_a.sort_by{ |range| range.begin }
  end

  def lowest_location
    seeds.map(&:begin).min
  end
end
