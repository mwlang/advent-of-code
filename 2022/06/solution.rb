data = File.readlines('input.txt', chomp: true)

class Packet
  attr_reader :packet

  MARKERS = {
    start: 4,
    message: 14,
  }

  def initialize packet
    @packet = packet
  end

  def marker marker
    packet.chars.each_cons(MARKERS[marker]) do |bytes|
      return bytes.join if bytes.uniq.size == MARKERS[marker]
    end
  end

  def marker_position marker
    (packet =~ Regexp.new(marker(marker))) + MARKERS[marker]
  end
end

packets = data.map{ |packet| Packet.new packet }

print "PART 1: "
packets.each do |packet|
  puts "#{packet.marker(:start)}: #{packet.marker_position(:start)}"
end

print "PART 2: "
packets.each do |packet|
  puts "#{packet.marker(:message)}: #{packet.marker_position(:message)}"
end