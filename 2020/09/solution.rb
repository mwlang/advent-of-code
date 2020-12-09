class Validator
  attr_reader :value
  attr_reader :sums

  def initialize value
    @value = value
    @sums = []
  end

  def << new_value
    @sums << (@value + new_value.value)
  end
  
  def allows? candidate
    @sums.include? candidate
  end
end

class Protocol
  attr_reader :validators
  attr_reader :lookback

  def initialize lookback=25
    @values = []
    @validators = []
    @lookback = lookback
  end
  
  def preamble?
    @validators.size < lookback
  end

  def weakness_set sentinel
    subset = @values.reject{|h| h > sentinel}
    run_size = 2
    while run_size < @values.size do
      subset.each_cons(run_size) do |set|
        return set if set.reduce{|sum,i| sum + i} == sentinel
      end
      run_size += 1
    end
    nil
  end

  def weakness_score sentinel
    run = weakness_set sentinel
    run.min + run.max
  end

  def << value
    if preamble? || @validators.any?{|v| v.allows?(value)}
      @values << value
      Validator.new(value).tap do |new_value|
        @validators.each{|validator| validator << new_value}
        @validators << new_value
        @validators.shift if @validators.size > lookback
      end
    end
  end
end

def find_invalid_value data
  protocol = Protocol.new(25)
  data.each do |datum|
    unless protocol << datum
      puts "Invalid: #{datum}"
      yield protocol, datum if block_given?
      return datum
    end
  end
end

def find_weakness_score data
  find_invalid_value(data) do |protocol, sentinel|
    puts "Weakness score: " << protocol.weakness_score(sentinel).to_s
  end
end

data = File.read("input.txt").split("\n").map(&:to_i)

find_weakness_score data