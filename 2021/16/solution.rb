bit_stream = File.read('input.txt').chomp.chars.flat_map{ |c| ("%0.4d" % c.to_i(16).to_s(2)).chars }

class Decoder
  attr_reader :bit_stream, :output, :versions, :packet_types, :literals, :stack
  def initialize bit_stream
    @bit_stream = bit_stream
    @output = []
    @versions = []
    @packet_types = []
    @stack = []
    @literals = []
  end

  def read(bits)
    bit_stream.shift(bits)
  end

  def peek(bits)
    bit_stream[0...bits]
  end

  def read_version
    read(3).join.to_i(2)
  end

  def read_packet_type
    read(3).join.to_i(2)
  end

  def decode!
    decode_version while bit_stream.any?
  end

  # The three bits labeled V (110) are the packet version, 6.
  def decode_version
    versions << (version = read_version)
    decode_packet_type(version)
  end

  # The three bits labeled T (100) are the packet type ID, 4, which means the packet is a literal value.
  def decode_packet_type(version)
    packet_type = read_packet_type
    if packet_type == 4
      decode_literals(version, packet_type)
    else
      decode_operator(version, packet_type)
    end
  end

  def clear_nulls
    read(1) while peek(1) == ["0"]
  end

  def read_sub_packets(count)
    count.times.map { read(11) }
  end

  # If the length type ID is 1, then the next 11 bits are a number that represents the number of sub-packets immediately contained by this packet.
  def decode_fixed_sub_packets(version, packet_type)

    sub_packet_count = read(11).join.to_i(2)
    answer = read_sub_packets(sub_packet_count).tap { clear_nulls }
    require 'ruby_jard'; jard
    answer
  end

  # If the length type ID is 0, then the next 15 bits are a number that represents the total length in bits of the sub-packets contained by this packet.
  def decode_dynamic_sub_packets(version, packet_type)
    total_sub_packet_bits = read(15).join.to_i(2)
    # Right now, the specific operations aren't important
    [read(total_sub_packet_bits).tap{ clear_nulls }]
  end

  def decode_operator(version, packet_type)
    sub_packets = read_boolean ? decode_fixed_sub_packets(version, packet_type) : decode_dynamic_sub_packets(version, packet_type)
    return if sub_packets.empty?
    sub_packets.each do |sub_packet|
      raise "oops!" unless @bit_stream.empty?
      require 'ruby_jard'; jard
      @bit_stream = sub_packet
      decode!
    end
  end

  def read_boolean
    read(1).first == "0" ? false : true
  end

  def read_literal
    read(4).join
  end

  # The five bits labeled A (10111) start with a 1 (not the last group, keep reading) and contain the first four bits of the number, 0111.
  # The five bits labeled B (11110) start with a 1 (not the last group, keep reading) and contain four more bits of the number, 1110.
  # The five bits labeled C (00101) start with a 0 (last group, end of packet) and contain the last four bits of the number, 0101.
  # The three unlabeled 0 bits at the end are extra due to the hexadecimal representation and should be ignored.
  def decode_literals(version, packet_type)
    last_group = !read_boolean
    stack << read_literal
    decode_literals(version, packet_type) unless last_group
    clear_nulls
    literals << stack.pop(stack.size).join.to_i(2) if stack.any?
  end
end

decoder = Decoder.new(bit_stream)
decoder.decode!
pp decoder
