class Adapter
  attr_reader :jolt
  attr_reader :compatible

  def initialize jolt
    @jolt = jolt
    @compatible = []
  end

  def compatible? adapter
    (adapter.jolt - jolt).between? 1, 3
  end

  def compute target, track={}
    return 1 if self == target
    track[self] ||= compatible.reduce(0){|sum, a| sum + a.compute(target, track)}
  end

  def to_s
    "#{jolt}: [#{compatible.map(&:jolt).join(',')}]"
  end

  def <=> other
    jolt <=> other.jolt
  end

  def << adapter
    return unless compatible? adapter
    @compatible << adapter
  end 
end

require "benchmark"

Benchmark.bm do |x|
  x.report("Ruby") do
    data = File.readlines("input.txt").map(&:to_i).sort
    data.unshift(0)
    data << (data[-1] + 3)

    adapters = data.sort.map{|jolt| Adapter.new jolt}
    adapters.each_with_index do |adapter, index|
      adapters[[index - 3, 0].max, 3].each{|a| a << adapter}
    end

    adapters.each do |adapter|
      puts adapter.to_s
    end

    diffs = adapters.each_cons(2).map{|a,b| b.jolt - a.jolt}.partition{|p| p == 1}.map(&:size)
    puts diffs.join(",")
    puts diffs[0] * diffs[1]

    puts adapters[0].compute adapters[-1]
  end
end