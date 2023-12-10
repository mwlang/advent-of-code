class Readings
  attr_reader :values, :prediction

  def initialize(values)
    @values = values
    @prediction = Readings.new(values.each_cons(2).map{ |a, b| b - a }) unless final?
    values << next_prediction
    values.unshift(previous_prediction)
  end

  def predicted
    final? ? 0 : values.last
  end

  def extrapolated
    final? ? 0 : values.first
  end

  def predict!
    values << next_prediction
  end

  def final?
    @final ||= values.all?(&:zero?)
  end

  def next_prediction
    return 0 if final?
    values.last + prediction.values.last
  end

  def previous_prediction
    return 0 if final?
    values.first - prediction.values.first
  end

  def inspect
    "#{values.join(" ")} => #{prediction.inspect}} => #{extrapolated.inspect} #{predicted.inspect}}"
  end
end

data = File.read('input.txt').split("\n").map{ |l| l.split(" ").map(&:to_i) }
readings = data.map{ |values| Readings.new(values) }

puts "Part 1: #{readings.map(&:predicted).sum}"
puts "Part 2: #{readings.map(&:extrapolated).sum}"
