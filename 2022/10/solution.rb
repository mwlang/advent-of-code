data = File.readlines('input.txt', chomp: true)

class Instruction
  attr_reader :args

  def initialize(*args)
    @args = args.flatten
  end

  def execute(cpu)
    cpu.tick!
    self.tap{ perform(cpu) }
  end

  def perform(cpu)
  end
end

class Addx < Instruction
  def value
    args[0].to_i
  end

  def perform cpu
    cpu.tick!
    cpu.x += value
  end
end

class Noop < Instruction
end

class Stop < Instruction
  def perform(cpu)
    cpu.stop!
  end
end

def instruction_class(name)
  Object.const_get(name)
end

instructions = data.map do |line|
  instruction, *args = line.split(" ")
  Object.const_get(instruction.capitalize).new(args)
end

class Cpu
  attr_accessor :x
  attr_reader :instructions, :cycle, :debugger

  def initialize(instructions, debugger=nil)
    @instructions = instructions.dup
    @x = 1
    @cycle = 0
    @stop = false
    @debugger = debugger
  end

  def tick!
    @cycle += 1
    trace
  end

  def stop!
    @stop = true
  end

  def stop?
    @stop
  end

  def fetch
    instructions.shift || Stop.new
  end

  def status
    "#{cycle.to_s.rjust(5)} : #{x}"
  end

  def trace instruction=nil
    debugger&.trace(self, instruction)
  end

  def run
    debugger&.start
    loop do
      break if stop?
      fetch.execute(self)
    end
  end
end

class Debugger
  def start
    @last_status = nil
    @sum = 0
  end

  def trace(cpu, _instruction)
    return if @last_status == cpu.status

    @last_status = cpu.status
    signal_strength = cpu.cycle * cpu.x

    if [20, 60, 100, 140, 180, 220].include?(cpu.cycle)
      @sum += signal_strength
      puts @sum if cpu.cycle == 220
    end
  end
end

print "PART 1: "
Cpu.new(instructions, Debugger.new).run

print "PART 2: "

class Crt
  def start
    @pixels = []
    puts
  end

  def render(cpu)
    sprite = ((cpu.x - 1)..(cpu.x + 1))
    @pixels << (sprite.cover?(@pixels.count) ? '#' : ' ')
  end

  def cr(cpu)
    puts @pixels.join
    @pixels.clear
  end

  def trace(cpu, instruction)
    cpu.cycle % 40 == 0 ? cr(cpu) : render(cpu)
  end
end

Cpu.new(instructions, Crt.new).run
