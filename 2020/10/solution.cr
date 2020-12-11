class Adapter
  getter jolt : Int32
  getter compatible : Array(Adapter) = Array(Adapter).new
  getter visited : Bool = false
  getter count : Int64 = 0

  def initialize(@jolt)
  end

  def compatible?(adapter)
    [1,2,3].includes? (adapter.jolt - jolt)
  end

  def increment
    print "." if @count % 1_000_001 == 0
    @count += 1
    self
  end

  def check(target)
    return target.increment if self == target
    compatible.each{|adapter| adapter.check target}
  end

  def to_s
    "#{jolt}: [#{compatible.map(&.jolt).join(',')}]"
  end

  def next_smallest_jolt
    compatible.min?
  end

  def <=>(other)
    jolt <=> other.jolt
  end

  def <<(adapter)
    return unless compatible? adapter
    @compatible << adapter
  end 
end

data = File.read_lines("input.txt").map(&.to_i).sort
data.unshift(0)
data << (data[-1] + 3)
puts data.join(",")
adapters = data.sort.map{|jolt| Adapter.new jolt}
adapters.each_with_index do |adapter, index|
  adapters[[index - 3, 0].max, 3].each{|a| a << adapter}
end

daisy_chain = Array(Adapter).new
adapter = adapters[0]
while adapter
  daisy_chain << adapter
  adapter = adapter.next_smallest_jolt
end

diffs = daisy_chain.each_cons(2).map{|(a,b)| b.jolt - a.jolt}.partition{|p| p == 1}.map(&.size)
puts diffs.join(",")
puts diffs[0] * diffs[1]

daisy_chain.each do |adapter|
  puts adapter.to_s
end

adapters[0].check adapters[-1]
puts adapters[-1].count
