class SeedMap
  attr_reader :name, :diverters

  def initialize(row)
    name, *mappings = row.split("\n")
    @name = name.split(" map:")[0]
    @diverters = mappings.map { |mapping| new_diverter(*mapping.split(" ").map(&:to_i)) }
  end

  def new_diverter(destination_start, source_start, range_length)
    source_range = new_range(source_start, range_length)
    offset = destination_start - source_start
    Diverter.new(source_range, offset)
  end

  def new_range(range_start, range_length)
    range_end = range_start + range_length - 1
    (range_start..range_end)
  end

  def divert(hopper)
    seeds_to_divert = hopper.collect_seeds
    diverters.each do |diverter|
      undiverted_seeds = []
      seeds_to_divert.each do |seeds|
        diverted_seeds = diverter.divert(seeds)
        hopper.add_seeds(diverted_seeds[:diverted])
        undiverted_seeds += diverted_seeds[:undiverted]
      end
      seeds_to_divert = undiverted_seeds
    end
    hopper.add_seeds(seeds_to_divert)
  end

  def inspect
    "#{name}: m: #{mappings.inspect}"
  end
end
