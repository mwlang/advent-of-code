require 'set'

class Tunnel
  attr_reader :name, :neighbor
  def initialize segment
    @name, @neighbor = segment.split("-")
  end
  def inspect
    "<Tunnel: #{@name}-#{@neighbor}>"
  end
  def to_s
    [@name, @neighbor].join("-")
  end
end

tunnels = File.read("input.txt").split("\n").map{|line| Tunnel.new(line)}
puts tunnels

class Cavern
  attr_reader :name
  attr_reader :neighbors

  def initialize name
    @name = name
    @neighbors = []
  end

  def big?; @big ||= !!(@name =~ /[A-Z]+/) end
  def small?; !big? end
  def ending?; @name == "end" end
  def starting?; @name == "start" end

  def <<(neighbor)
    @neighbors << neighbor unless @neighbors.include?(neighbor)
  end

  def inspect
    "#{@name}#{big? ? '!' : ''} (#{@neighbors.map(&:name).join(",")})"
  end
end
class Underground
  attr_reader :tunnels
  attr_reader :caverns

  def initialize tunnels
    @tunnels = tunnels
    @caverns = {}
    build_caverns
  end

  def build_caverns
    tunnels.each do |tunnel|
      cavern = @caverns[tunnel.name] ||= Cavern.new(tunnel.name)
      neighbor = @caverns[tunnel.neighbor] ||= Cavern.new(tunnel.neighbor)
      cavern << neighbor
      neighbor << cavern
    end
  end

  def can_visit?(cavern, path, max_visits)
    return true if cavern.big?
    small_caverns = path.select(&:small?).tally
    small_caverns.values.max < max_visits || !small_caverns.include?(cavern)
  end

  def explore! max_small_visits: 1
    paths = caverns["start"].neighbors.map{|neighbor| [caverns["start"], neighbor]}
    completed_paths = Set.new

    while path = paths.pop
      completed_paths << path and next if path.last.ending?

      path.last.neighbors.reject(&:starting?).each do |next_cavern|
        next unless can_visit?(next_cavern, path, max_small_visits)
        paths << path + [next_cavern]
      end
    end

    completed_paths
  end
end

underground = Underground.new(tunnels)

puts "*" * 40, "PART I", ""
completed_paths = underground.explore!
puts completed_paths.size

puts "*" * 40, "PART II", ""
completed_paths = underground.explore! max_small_visits: 2
puts completed_paths.size