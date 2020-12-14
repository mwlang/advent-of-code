MEM_REGEX = /^mem\[(\d+)\]\s*\=\s*(\d+)$/
MASK_REGEX = /^mask\s*\=\s*(\w+)$/

class Mask
  attr_reader :mask

  # X's become nil so they're easily ignored
  def initialize mask
    @mask = mask.chars.map{|c| c == "X" ? nil : c}
  end

  # skip X's, replace input bits with 1's or 0's to match mask
  def output value
    bits = value.to_i.to_s(2).rjust(36, "0").chars
    bits.map.with_index{|bit, i| @mask[i] || bit}.join.to_i(2)
  end
end

class RouletteMask
  attr_reader :mask

  # 0's become nil so they're easily ignored
  def initialize mask
    @mask = mask.chars.map{|c| c == "0" ? nil : c}
  end

  # X's become wildcard bits, so we count X's and generate every
  # permutation of 1's and 0's and then generate an address for
  # each permutation and poke the instruction value into that address
  def output address, memory
    bits = address.slot.to_i.to_s(2).rjust(36, "0").chars
    roulette_address = bits.map.with_index{|bit, i| @mask[i] || bit}
    xes = roulette_address.count("X")
    roulette_address = roulette_address.map{|c| c == "X" ? "%s" : c}.join
    (2**xes).times.each do |x|
      slot = roulette_address % x.to_s(2).rjust(xes, "0").chars
      memory[slot.to_i(2)] = address.value
    end
  end
end

class Memory
  attr_reader :slot, :input, :value
  def initialize slot, input
    @slot = slot
    @input = input
    @value = @input.to_i
  end

  def output mask
    mask.output(input)
  end
end

def write_masked_values data
  instructions = data.map do |line|
    _, mask = line.match(MASK_REGEX).to_a
    _, slot, mem = line.match(MEM_REGEX).to_a
    mask ? Mask.new(mask) : Memory.new(slot, mem)
  end

  mask = Mask.new("X" * 36)
  memory = {}
  instructions.each do |instruction|
    if instruction.is_a?(Mask)
      mask = instruction
    else
      memory[instruction.slot] = instruction.output(mask)
    end
  end
  pp memory.values.reduce(0){|sum, v| sum + v}
end

def write_masked_addresses data
  instructions = data.map do |line|
    _, mask = line.match(MASK_REGEX).to_a
    _, slot, mem = line.match(MEM_REGEX).to_a
    mask ? RouletteMask.new(mask) : Memory.new(slot, mem)
  end

  mask = Mask.new("0" * 36)
  memory = {}
  instructions.each do |instruction|
    if instruction.is_a?(RouletteMask)
      mask = instruction
    else
      mask.output(instruction, memory)
    end
  end
  pp memory.values.reduce(0){|sum, v| sum + v}
end

data = File.read("input.txt").split("\n")
write_masked_values data
write_masked_addresses data