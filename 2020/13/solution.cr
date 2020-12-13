# 939
# 7,13,x,x,59,x,31,19

class Bus
  property id : Int32
  property track : Int32
  def initialize(@id, @track)
  end
  def line
    id - track
  end
  def stop?(start)
    ((start + track) % id).zero?
  end
end

buses = File.read("input.txt").split(",").map(&.to_i64).reject(&.zero?)
start : Int64 = buses.shift.to_i64
puts buses.inspect

schedule = buses.map{|bus| [bus - (start % bus), bus]}.sort_by{|sb| sb[0]}
puts schedule[0][0] * schedule[0][1]

buses = File.read("input.txt").split(/\n|,/).map{|i| i == "x" ? 0 : i.to_i}
buses.shift

schedule = buses.map_with_index { |bus, i| Bus.new(bus, i) }
track = schedule.reject{|r| r.id.zero?}.sort_by{|sb| -sb.id}
start = track[0].line.to_i64

# When you can't math it away, brute force it.... 9.5 hours to derive answer
# answer: 408_270_049_879_073
loop do
  if track.all?{|t| t.stop?(start)}
    puts "start: #{start}"
    break
  end
  start += track[0].id
end
