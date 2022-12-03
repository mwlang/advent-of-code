require 'set'

rules = {}

while (l = STDIN.readline.chomp) != ''
  base, rest = l.split ':'
  case rest
  when /"/ then rules[base.to_i] = rest.gsub(/[" ]/, '')
  else rules[base.to_i] = rest.split('|').collect{|xpn| xpn.split.collect(&:to_i)}
  end
end

def each_match_s(rules, l, pos, seq, idx = 0)
  if idx == seq.size
    yield pos
  else
    each_match(rules, l, pos, seq[idx]) do |npos|
      each_match_s(rules, l, npos, seq, idx + 1) do |nnpos|
        yield nnpos
      end
    end
  end
end

def each_match(rules, l, pos, tok)
  if rules[tok].is_a?(String)
    if l[pos] == rules[tok]
      yield pos + 1
    end
    return
  else
    rules[tok].each do |seq|
      each_match_s(rules, l, pos, seq) do |npos|
        yield npos
      end
    end
  end
end

def try_match(rules, l, matches)
  each_match(rules, l, 0, 0) do |npos|
    matches << l if npos == l.size
  end
  return false
end

samples = STDIN.each_line.collect(&:chomp)

# Part 1

matches = Set.new

samples.each do |l|
  try_match(rules, l, matches)
end

puts matches.size

# Part 2

rules[8] = [[42], [42, 8]]
rules[11] = [[42, 31], [42, 11, 31]]

matches = Set.new

samples.each do |l|
  try_match(rules, l, matches)
end

puts matches.size

