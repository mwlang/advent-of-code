class TileReader
  def self.load(filename)
    lines = File.read(filename).split("\n")
    tiles = []
    while !lines.empty?
      tile_id = lines.shift.scan(/\d+/).join.to_i
      data = []
      while !(line = lines.shift).empty?
        data << line
        break if lines.empty?
      end
      tiles << Tile.new(tile_id, data)
    end
    tiles
  end
end
