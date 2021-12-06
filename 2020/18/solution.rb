lines = File.readlines("input.txt")

# part the first
class Integer
  def >>(x)
    self + x
  end

  def <<(x)
    self * x
  end
end

results = lines.map do |line|
  eval(line.gsub("*","<<").gsub("+",">>"))
end

puts results.sum

# part the second
class Integer
  def -(x)
    self * x
  end

  def /(x)
    self + x
  end
end

results = lines.map do |line|
  eval(line.gsub("*","-").gsub("+","/"))
end

puts results.sum