class Seat
  def initialize row, column
    @row = row
    @column = column
    @reserved = false
  end
  def reserve!
    @reserved = true
    self
  end
  def reserved?
    @reserved
  end
  def id
    @row * 8 + @column
  end
end

class Plane
  attr_reader :seats

  def initialize rows, columns
    @seats = rows.times.map do |row|
      columns.times.map{ |column| Seat.new(row, column) }
    end
  end

  def seek location, seats
    head = 0
    tail = seats.size - 1
    size = tail - head + 1
    location.each do |partition|
      if partition =~ /F|L/
        tail -= (size /= 2)
      elsif partition =~ /B|R/
        head += (size /= 2)
      else
        raise "#{partition} not valid!"
      end
    end
    seats[head]
  end

  def reserve location
    rows, columns = location.chars.partition{|p| p =~ /F|B/}
    seek(columns, seek(rows, @seats)).reserve!
  end
end

def find_highest_reservation reservations, plane
  reserved = reservations.map{|r| plane.reserve(r)}
  puts reserved.map(&:id).max
end

def find_my_seat reservations, plane
  reserved = reservations.map{|r| plane.reserve(r)}.map(&:id)
  my_seat = plane.seats.flatten.detect do |seat| 
    !seat.reserved? && reserved.include?(seat.id - 1) && reserved.include?(seat.id + 1)
  end
  puts my_seat.id
end

reservations = File.readlines("input.txt").map(&:chomp)
plane = Plane.new(128, 8)

find_highest_reservation reservations, plane
find_my_seat reservations, plane
