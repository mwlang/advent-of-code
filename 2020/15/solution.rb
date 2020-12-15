# In this game, the players take turns saying numbers. They begin by taking turns
# reading from a list of starting numbers (your puzzle input). Then, each turn
# consists of considering the most recently spoken number:

# If that was the first time the number has been spoken, the current player says 0.

# Otherwise, the number had been spoken before; the current player announces how
# many turns apart the number is from when it was previously spoken.

# So, after the starting numbers, each turn results in that player speaking aloud
# either 0 (if the last number is new) or an age (if the last number is a
# repeat).

def play starting, turns
  collection = {}
  starting.map.with_index{ |v,t| collection[v] = [t + 1]}
  current_turn = starting.size
  last_spoken = starting[-1]

  (turns - starting.size).times do
    current_turn += 1
    current = collection[last_spoken]

    if current.size == 1
      last_spoken = 0
      collection[0] << current_turn
    else
      last_spoken = current[-1] - current[-2]
      collection[last_spoken] ||= []
      collection[last_spoken] << current_turn
    end
  end
  last_spoken
end

puts play [0,3,6], 10
puts play [2,20,0,4,1,17], 2020
puts play [2,20,0,4,1,17], 30_000_000

