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
  collection = starting.map.with_index{|spoken, index| [spoken, [index + 1]]}.to_h
  current_turn = starting.size
  last_spoken = starting[-1]

  (starting.size + 1..turns).each do |current_turn|
    current = collection[last_spoken]

    if current.one?
      collection[last_spoken = 0] << current_turn
    else
      last_spoken = current[-1] - current[-2]
      collection[last_spoken] ||= []
      collection[last_spoken] << current_turn
    end
  end
  last_spoken
end

require "benchmark"

results = []
Benchmark.bm do |x|
  x.report("Ruby") do
    results << play([0,3,6], 10)
    results << play([2,20,0,4,1,17], 2020)
    results << play([2,20,0,4,1,17], 30_000_000)
  end
end
puts results

#               user     system      total        real
# Crystal   5.237146   0.157783   5.394929 (  5.162842)
# Ruby     29.513222   0.304294  29.817516 ( 29.821905)