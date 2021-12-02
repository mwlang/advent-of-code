readings = File.read('input.txt').split("\n").map(&:to_i)

def increased(values)
  increases = 0
  values.each_cons(2) do |a, b|
    increases += 1 if b > a
  end
  puts increases
end

increased readings

puts "*" * 80, "PART II", ""

summed_readings = []
readings.each_cons(3) do |a, b, c|
  summed_readings << a + b + c
end

increased summed_readings
