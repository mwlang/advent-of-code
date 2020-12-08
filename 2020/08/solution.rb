class Instruction
  attr_reader :code, :arg, :mark

  def initialize line
    @code, @arg = line.split(/\s+/)
    @arg = @arg.to_i
    @mark = false
  end

  def to_s
    [@code.rjust(8), "#{arg}".rjust(8), @mark].join(" ")
  end

  def repair
    @code = {"jmp" => "nop", "nop" => "jmp"}[@code]
  end

  def reset
    @mark = false
  end

  def mark!
    @mark = true
  end
end

class Cpu
  def initialize program
    @program = program
    @accumulator = 0
    @p = 0
  end

  def fetch
    @i = @program[@p]
  end

  def execute
    case @i.code
    when "jmp" then
      @p += (@i.arg - 1)
    when "acc" then
      @accumulator += @i.arg
    end
    @i.mark!
  end

  def interpret
    raise "infinite loop" if @i.mark
    @p += 1
  end

  def boot
    @p = 0
    @accumulator = 0
    @program.each(&:reset)
  end

  def finished?
    @p > @program.size - 1
  end

  def process
    loop do
      fetch
      interpret
      execute
      break if finished?
    end
  end

  def debug
    candidates = @program.select{|i| i.code == "nop" || i.code == "jmp"}
    candidates.each do |c|
      begin
        c.repair
        boot
        process
        puts "FINISHED: #{@accumulator}"
        break
      rescue
        c.repair
      end
    end
  end

  def run
    boot
    process
  rescue
    puts "STOPPED: #{@accumulator}"
  end
end

program = File.read("input.txt").split("\n").map{|l| Instruction.new(l)}

cpu = Cpu.new(program)
cpu.run
cpu.debug