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
  def big?
    @big ||= @name =~ /[A-Z]+/
  end
  def small?
    !big?
  end
  def ending?
    @name == "end"
  end
  def starting?
    @name == "start"
  end
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
  def explore!
    trips = 0
    paths = Set.new

    cavern_path = [caverns["start"], Array(caverns["start"])]
    visited = []
    openings = caverns["start"].neighbors.map{ |neighbor| [neighbor, Array(caverns["start"])] }

    while !openings.empty? do

      opening, path = openings.shift

      opening_path = path + [opening]
      paths << opening_path
      # puts opening_path.inspect

      next if opening.ending? || visited.include?([opening, opening_path])
      visited << [opening, opening_path] unless opening.big?
      opening.neighbors.each do |cavern|
        next if visited.include?([cavern, opening_path])
        next if path.include?(cavern) && cavern.small?
        openings << [cavern, opening_path] unless visited.include?([cavern, opening_path])
      end
    end
    start_end_paths = paths
      .select{ |path| path.last.ending? }
      .map{ |path| path.map(&:name).join(",") }

    pp start_end_paths
    puts start_end_paths.size

    puts "*" * 40

    valid_paths = paths
      .select{ |path| path.last.ending? }
      .reject do |openings|
        openings.group_by(&:itself).any?{|cavern, visits| !cavern.big? && visits.size > 1}
      end
      .map{ |path| path.map(&:name).join(",") }
    pp valid_paths.sort
    puts valid_paths.size
  end
end

underground = Underground.new(tunnels)
underground.explore!
# pp underground.caverns