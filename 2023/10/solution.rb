require 'set'

class Pipe
  attr_reader :pipes, :kind, :x, :y, :neighbors, :surroundings, :status

  def initialize(pipes, kind, x, y)
    raise "wrong kind #{kind}"  unless KINDS.keys.include?(kind)
    @status = :unmarked
    @pipes = pipes
    @kind = kind
    @x = x
    @y = y
    @surroundings = []
  end

  def set_status(new_status)
    return if on_path? || new_status == status
    raise "already marked as #{@status} before setting to #{new_status}" unless unmarked?
    @status = new_status
  end

  def mark_inside!; set_status(:inside_path) end
  def mark_outside!; set_status(:outside_path) end
  def mark_path!; set_status(:on_path) end

  def unmarked?; status == :unmarked end
  def on_path?; status == :on_path end
  def inside_path?; status == :inside_path end
  def outside_path?; status == :outside_path end

  def flip_orientation!
    return unless inside_path? || outside_path?
    @status = inside_path? ? :outside_path : :inside_path
  end

  def start?
    kind == "S"
  end

  def next_neighbor(came_from)
    neighbors.reject{ |neighbor| neighbor == came_from }.first
  end

  def discover_neighbors
    @neighbors = surroundings.map do |direction, neighbor|
      connect_from(direction, neighbor)
    end.compact
  end

  def discover_surroundings
    @surroundings = Hash.new(nil)
    @surroundings[:west] = pipes.at(x - 1, y) if x > 0
    @surroundings[:east] = pipes.at(x + 1, y) if x < pipes.width - 1
    @surroundings[:north] = pipes.at(x, y - 1) if y > 0
    @surroundings[:south] = pipes.at(x, y + 1) if y < pipes.height - 1
    @surroundings
    discover_neighbors
  end

  KINDS = {
    "|" => { to: %i(north south), from: %i(north south), ascii: "│" },
    "-" => { to: %i(east west), from: %i(east west), ascii: "─" },
    "L" => { to: %i(north east), from: %i(south west), ascii: "└" },
    "J" => { to: %i(north west), from: %i(south east), ascii: "┘" },
    "7" => { to: %i(south west), from: %i(north east), ascii: "┐" },
    "F" => { to: %i(south east), from: %i(north west), ascii: "┌" },
    "S" => { to: %i(north south east west), from: %i(north south east west), ascii: "▓" },
    "." => { to: [], from: [], ascii: " " },
  }

  STATUSES = {
    unmarked: ".",
    on_path: nil,
    inside_path: "I",
    outside_path: "O",
  }

  def ascii
    STATUSES[status] || KINDS[kind][:ascii]
  end

  def connects_to
    KINDS[kind][:to]
  end

  def connects_from
    KINDS[kind][:from]
  end

  def connects_from?(direction)
    connects_from.include?(direction)
  end

  def can_connect?(direction, other)
    connects_to.include?(direction) && other.connects_from?(direction)
  end

  def connect_from(direction, pipe)
    pipe if can_connect?(direction, pipe)
  end

  def from(visited_from)
    delta_x = x - visited_from.x
    delta_y = y - visited_from.y

    case
    when delta_x > 0 then :west
    when delta_x < 0 then :east
    when delta_y > 0 then :north
    when delta_y < 0 then :south
    end
  end

  # Right hand thumb up rule for flow direction
  OUTSIDE_MAPPINGS = {
    north: {
      south: %i(west),
      east: %i(west south),
      west: %i(north),
    },
    south: {
      north: %i(east),
      east: %i(south),
      west: %i(east north),
    },
    east: {
      west: %i(north),
      north: %i(east),
      south: %i(north west),
    },
    west: {
      east: %i(south),
      north: %i(south east),
      south: %i(west),
    },
  }

  INSIDE_MAPPINGS = {
    north: {
      south: %i(east),
      east: %i(north),
      west: %i(south east),
    },
    south: {
      north: %i(west),
      east: %i(north),
      west: %i(south),
    },
    east: {
      west: %i(south),
      north: %i(south west),
      south: %i(east),
    },
    west: {
      east: %i(north),
      north: %i(west),
      south: %i(north east),
    },
  }

  def follow_the_path(mappings, visited_from)
    from_direction = from(visited_from)
    to_direction = (connects_to - Array(from_direction)).first
    mappings[from_direction][to_direction].map{ |direction| surroundings[direction] }
  end

  def whats_outside(visited_from)
    follow_the_path(OUTSIDE_MAPPINGS, visited_from)
  end

  def whats_inside(visited_from)
    follow_the_path(INSIDE_MAPPINGS, visited_from)
  end

  def inspect
    "#{kind}:#{x},#{y}"
  end
end

class Pipes
  attr_reader :start, :pipes

  def initialize(data)
    @start = nil
    @pipes = build_pipes(data)
    discover_surroundings
  end

  def build_pipes(data)
    data.map.with_index do |row, y|
      row.map.with_index do |pipe, x|
        Pipe.new(self, pipe, x, y)
          .tap{ |pipe| @start = pipe if pipe.start? }
      end
    end
  end

  def all_pipes
    @all_pipes ||= pipes.flatten
  end

  def width
    pipes.first.size
  end

  def height
    pipes.size
  end

  def fill_outliers(side, outliers = nil)
    outliers ||= all_pipes.select(&:"#{side}_path?")
    outliers_count = outliers.count

    while outlier = outliers.pop
      outlier.surroundings.values.select(&:unmarked?).each do |neighbor|
        neighbor.send("mark_#{side}!")
        outliers += neighbor.surroundings.values.select(&:unmarked?).compact
      end
    end
    outliers = all_pipes.select(&:"#{side}_path?")
    fill_outliers(side, outliers) if outliers.count != outliers_count
  end

  def mark_path!(path)
    path.each(&:mark_path!)
    counter = 0
    path.each_cons(2) do |visited_from, current|
      counter += 1
      Array(current.whats_outside(visited_from)).compact.each(&:mark_outside!)
      Array(current.whats_inside(visited_from)).compact.each(&:mark_inside!)
    end
    fill_outliers(:outside)
    fill_outliers(:inside)
    all_pipes.each(&:flip_orientation!) if pipes[0].any?(&:inside_path?)
  end

  def total_inside
    all_pipes.count(&:inside_path?)
  end

  def total_outside
    all_pipes.count(&:outside_path?)
  end

  def total_on_path
    all_pipes.count(&:on_path?)
  end

  def total_visits
    all_pipes.map(&:visited).reject(&:empty?).count
  end

  def total
    all_pipes.count
  end

  def discover_surroundings
    all_pipes.each(&:discover_surroundings)
  end

  def at(x, y)
    pipes[y][x] # x and y are transposed because of loading
  end

  def paths
    @paths ||= explore!
  end

  def explore!
    completed_paths = Set.new
    paths = start.neighbors.map { |neighbor| [start, neighbor] }

    while path = paths.pop
      previous_neighbor = path[-2]
      next_neighbor = path[-1].next_neighbor(previous_neighbor)

      new_path = path + [next_neighbor]
      completed_paths << new_path and next if next_neighbor.start?
      paths << new_path
    end

    completed_paths.to_a
  end

  def draw
    pipes.map{ |row| row.map(&:ascii).join }.join("\n")
  end
end

data = File.read("input.txt").split("\n").map{ |line| line.chars }
pipes = Pipes.new(data)
longest_path = pipes.paths.sort_by(&:count).last

print "Part 1: "
puts longest_path.size / 2

print "Part 2: "

pipes.mark_path! longest_path

puts pipes.total_inside
puts pipes.draw

puts "O: #{pipes.total_outside}"
puts "I: #{pipes.total_inside}"
puts "P: #{pipes.total_on_path}"
puts "T: #{pipes.total}"
