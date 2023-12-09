require 'rspec'
require 'ruby_jard'
require_relative 'card'
require_relative 'hand'

data = File.read('input.txt').split("\n")

def play_hands(hands)
  total = 0
  hands.sort.each.with_index do |hand, index|
    total += hand.bid * (index + 1)
  end

  # pp hands.sort
  puts total
end

puts "\nPart 1:"

hands = data.map{ |row| Hand.new(*row.split(" ")) }
play_hands(hands)

puts "\nPart 2:"
wild_hands = data.map{ |row| Hand.new(*row.split(" "), jacks_are_wild: true) }
play_hands(wild_hands)
