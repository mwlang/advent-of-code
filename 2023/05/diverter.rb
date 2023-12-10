class Diverter
  attr_reader :source_range, :offset

  def initialize(source_range, offset)
    @source_range = source_range
    @offset = offset
  end

  def diverted(diverted: [], undiverted: [])
    { diverted: [diverted].flatten, undiverted: [undiverted].flatten }
  end

  def divert(range)
    range = as_range(range)
    return diverted(diverted: adjust(range)) if covers?(range)
    return diverted(undiverted: range) unless overlaps?(range)
    return split(range)
  end

  def overlaps?(range)
    range.bsearch{ |seed| source_range.include?(seed) } ||
    source_range.bsearch{ |seed| range.include?(seed) }
  end

  def covers?(range)
    source_range.cover?(range)
  end

  def split(range)
    starts_before_and_ends_within(range) ||
    starts_within_and_ends_after(range) ||
    starts_before_and_ends_after(range)
  end

  def adjust(range)
    (range.min + offset)..(range.max + offset)
  end

  def starts_before_and_ends_within(range)
    return unless starts_before_and_ends_within?(range)

    diverted_range = adjust(source_range.min..range.max)
    undiverted_range = (range.min..source_range.min - 1)
    diverted(diverted: diverted_range, undiverted: undiverted_range)
  end

  def starts_within_and_ends_after(range)
    return unless starts_within_and_ends_after?(range)

    diverted_range = adjust(range.min..source_range.max)
    undiverted_range = (source_range.max + 1..range.max)
    diverted(diverted: diverted_range, undiverted: undiverted_range)
  end

  def starts_before_and_ends_after(range)
    diverted_range = adjust(source_range)
    undiverted_range = [(range.min..source_range.min - 1)]
    undiverted_range << (source_range.max + 1..range.max)
    diverted(diverted: diverted_range, undiverted: undiverted_range)
  end

  def starts_before_and_ends_within?(range)
    range.min < source_range.min && range.max <= source_range.max
  end

  def starts_within_and_ends_after?(range)
    range.min >= source_range.min && range.max > source_range.max
  end

  def as_range(range)
    return range if range.is_a?(Range)
    return (range..range) if range.is_a?(Integer)
    raise "Invalid range: #{range}"
  end
end
