require 'set'

data = File.read('input.txt').split("\n").map{ |line| line.split(",") }

class Assignments
  def initialize assignments
    @polly, @noelle = assignments.map{ |assignment| build assignment }
  end

  def piss_poor_management
    polly.subset?(noelle) || noelle.subset?(polly)
  end

  def just_plain_inefficient
    !(polly & noelle).empty?
  end

  private

  attr_reader :polly, :noelle

  def build assignment
    Set.new eval "(#{assignment.gsub('-','..')}).to_a"
  end
end

assignments = data.map{ |assignments| Assignments.new assignments }

print "PART 1: "
puts assignments.select(&:piss_poor_management).count

print "PART 2: "
puts assignments.select(&:just_plain_inefficient).count