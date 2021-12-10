lines = File.read('input.txt').split("\n").map(&:chars)

OPENINGS = {
  "(" => ")",
  "[" => "]",
  "{" => "}",
  "<" => ">"
}.freeze

CLOSINGS = OPENINGS.invert

ILLEGAL_POINTS = {
  ")" => 3,
  "]" => 57,
  "}" => 1197,
  ">" => 25137,
}.freeze

MISSING_POINTS = {
  ")" => 1,
  "]" => 2,
  "}" => 3,
  ">" => 4,
}.freeze

def parse line
  openings = []
  line.each do |symbol|
    if OPENINGS[symbol]
      openings << symbol
    elsif CLOSINGS[symbol] == openings[-1]
      openings.pop
    else
      raise symbol
    end
  end
  openings.map{|o| OPENINGS[o]}.reverse
end

illegals = []
missings = []

lines.each do |line|
  missings << parse(line)
rescue => e
  illegals << e.message
end

puts "=" * 40, "PART I", ""
score = illegals.tally.reduce(0) do |sum, (symbol, value)|
  sum + ILLEGAL_POINTS[symbol] * value
end

puts score

puts "=" * 40, "PART II", ""

scores = missings.map do |symbols|
  symbols.reduce(0) do |score, symbol|
    score *= 5
    score += MISSING_POINTS[symbol]
  end
end.sort

puts scores[scores.size / 2]