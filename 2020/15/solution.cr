# In this game, the players take turns saying numbers. They begin by taking turns
# reading from a list of starting numbers (your puzzle input). Then, each turn
# consists of considering the most recently spoken number:

# If that was the first time the number has been spoken, the current player says 0.

# Otherwise, the number had been spoken before; the current player announces how
# many turns apart the number is from when it was previously spoken.

# So, after the starting numbers, each turn results in that player speaking aloud
# either 0 (if the last number is new) or an age (if the last number is a
# repeat).
def play(starting, turns)
  collection = Hash(Int32,Array(Int32)).new
  numbers = starting.map_with_index{ |v,t| collection[v] = [t + 1]}
  numbers = starting.reverse

  (turns - numbers.size).times do |turn|
    current_turn = starting.size + turn + 1
    current = collection[numbers[0]]

    if current.size == 1
      numbers.unshift(0)
      collection[0] << current_turn
    else
      age = current[-1] - current[-2]
      numbers.unshift(age)
      collection[age] ||= Array(Int32).new
      collection[age] << current_turn
    end
  end
  numbers[0]
end

puts play [0,3,6], 10
puts play [2,20,0,4,1,17], 2020
puts play [2,20,0,4,1,17], 30000000
