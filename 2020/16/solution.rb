class Rule
  attr_reader :field

  def initialize line
    @field, ranges = line.split(": ")
    @ranges = ranges.split(" or ").map do |range|
      a, b = range.split("-").map(&:to_i)
      (a..b).to_a
    end
  end

  def range
    @range ||= @ranges.map(&:to_a).flatten
  end

  def errors values
    values - range
  end
end

class Ticket
  attr_reader :fields

  def initialize line
    @fields = line.split(",").map(&:to_i)
  end

  def to_s
    @fields.join(",")
  end

  def error_rate rules
    rules.reduce(@fields.dup) do |fields, rule|
      fields & rule.errors(fields)
    end
  end

  def valid? rules
    error_rate(rules).empty?
  end
end

def find_invalid_tickets tickets, rules
  error_rates = tickets.map{|ticket| ticket.error_rate(rules)}
  puts error_rates.flatten.reduce(0){|sum,a| sum + a}
end

class Pair
  attr_reader :rules
  attr_reader :position

  def initialize position, rules
    @position = position
    @rules = rules
  end

  def remove rule
    @rules.delete rule
  end

  def field
    @rules[0].field
  end
end

def find_departure_fields my_ticket, tickets, rules
  valid_tickets = tickets.select{|ticket| ticket.valid?(rules)}
  grouped_fields = valid_tickets[0].fields.size.times.map do |index|
    valid_tickets.map{ |ticket| ticket.fields[index] }.uniq
  end
  grouped_rules = valid_tickets[0].fields.size.times.map do |index|
    Pair.new index, rules.select{|r| r.errors(grouped_fields[index]).empty?}
  end.sort_by{|pair| pair.rules.size}

  grouped_rules.each_with_index do |pair, index|
    raise "oops #{pair.rules.size}/#{index}" unless pair.rules.size == 1
    rule = pair.rules[0]
    grouped_rules[index+1..-1].each{|r| r.remove rule}
  end
  departure_token = grouped_rules.sort_by{|p| p.position}.reduce(1) do |acc, pair|
    puts [pair.position, pair.rules[0].field].join(": ")
    pair.field =~ /^departure/i ? acc * my_ticket.fields[pair.position] : acc
  end
  puts departure_token
end

_rules, _my_ticket, _nearby_tickets = File.read("input.txt").split("\n\n")
rules = _rules.split("\n").map{|rule| Rule.new rule}
my_ticket = Ticket.new(_my_ticket.split("\n")[-1])
nearby_tickets = _nearby_tickets.split("\n")[1..-1].map{|ticket| Ticket.new ticket}

find_invalid_tickets(nearby_tickets, rules)
find_departure_fields(my_ticket, nearby_tickets, rules)
