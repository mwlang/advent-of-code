class RaceStats
  attr_reader :time, :distance
  def initialize(time, distance)
    @time = time
    @distance = distance
  end

  # travel = rate * time
  def record_breakers
    @record_breakers ||= Array.new.tap do |record_times|
      (1...time).map do |energizer_time|
        travel_time = time - energizer_time
        speed = energizer_time
        performance = speed * travel_time
        break if performance <= record_times[-1].to_i
        record_times << performance if performance > distance
      end
    end
  end

  def records
    print "(#{record_breakers.size}) "
    if record_breakers.size.odd?
      ((record_breakers.size - 1) * 2) + 1
    else
      record_breakers.size * 2
    end
  end
end

print "Part 1: "

data = File.read('input.txt').split("\n")

times = data.shift.scan(/\d+/).map(&:to_i)
distances = data.shift.scan(/\d+/).map(&:to_i)

race_stats = times.zip(distances).map do |time, distance|
  RaceStats.new(time, distance)
end

puts race_stats.reduce(1){|product, rs| product * rs.records}


print "Part 2: "

data = File.read('test_input.txt').split("\n")

time = data.shift.scan(/\d+/).flatten.join('').to_i
distance = data.shift.scan(/\d+/).flatten.join('').to_i

puts RaceStats.new(time, distance).records
