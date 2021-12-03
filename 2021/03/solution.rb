input = File.read('input.txt').split("\n").map(&:chars)

class GammaEpisilon
  attr_reader :gamma, :episilon

  def initialize bits
    @zeros = bits.select{ |s| s == "0" }.size
    @ones = bits.size - @zeros
  end

  def gamma_bit
    @ones >= @zeros ? '1' : '0'
  end

  def episilon_bit
    @ones >= @zeros ? '0' : '1'
  end
end

data = input.transpose.map{ |row| GammaEpisilon.new(row) }

gamma = data.map(&:gamma_bit).join.to_i(2)
episilon = data.map(&:episilon_bit).join.to_i(2)

puts "*" * 40, "PART I", ""
puts [gamma, episilon, gamma * episilon].join("\t")

puts "*" * 40, "PART II", ""

def extract_reading(input, indicator)
  subset = input
  0.upto(input.size-1).each do |index|
    break if subset.size == 1
    common_bit = GammaEpisilon.new(subset.map{ |ss| ss[index] }).send(indicator)
    subset = subset.select{ |ss| ss[index] == common_bit }
  end
  subset[0].join.to_i(2)
end

oxygen_generator_rating = extract_reading(input, :gamma_bit)
co2_scrubber_rating = extract_reading(input, :episilon_bit)

puts [oxygen_generator_rating, co2_scrubber_rating, co2_scrubber_rating * oxygen_generator_rating].join("\t")
