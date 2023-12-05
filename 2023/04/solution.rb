class Card
  def initialize(data)
    all_numbers = data.scan(/Card\s+(\d+):\s+([\d\s]+)\|([\d\s]+)/).flatten
    @card_number = all_numbers.shift.to_i
    @winning_numbers = all_numbers.shift.split(" ").map(&:to_i)
    @picked_numbers = all_numbers.shift.split(" ").map(&:to_i)
    @copies = 1
  end

  attr_reader :card_number, :winning_numbers, :picked_numbers, :copies

  def copy!(count)
    @copies += count
  end

  def matches
    winning_numbers & picked_numbers
  end

  def points
    matches.empty? ? 0 : 2**(matches.size - 1)
  end

  def inspect
    w = winning_numbers.map{ |n| n.to_s.rjust(2) }.join(" ")
    p = picked_numbers.map{ |n| n.to_s.rjust(2) }.join(" ")
    m = matches.map{ |n| n.to_s.rjust(2) }.join(" ")
    "Card #{card_number}: w: #{w} p: #{p} => #{points} c: #{copies} => #{copies}"
  end
end

cards = File.read('input.txt').split("\n").map{ |data| Card.new(data) }
cards.each.with_index do |card, index|
  cards.slice(index + 1, card.matches.count).each do |card_to_copy|
    card_to_copy.copy!(card.copies)
  end
end

# 1 instance of card 1,
# 2 instances of card 2,
# 4 instances of card 3,
# 8 instances of card 4,
# 14 instances of card 5,
# 1 instance of card 6.
# you to ultimately have 30 scratchcards!
cards.each.with_index do |card, index|
  puts card.inspect
end

puts cards.reduce(0) { |sum, card| sum + card.points }
puts cards.reduce(0) { |sum, card| sum + card.copies }
