require 'ruby_jard'
require_relative "./tile"
require_relative "./tile_reader"

tiles = TileReader.load("input.txt")

puts "SOLUTION PART 1"
puts "tiles: #{tiles.size}"

0.upto(tiles.size - 2) do |i|
  (i + 1).upto(tiles.size - 1) do |j|
    tiles[i].pair tiles[j]
  end
end

corners = tiles.select(&:corner?)

puts corners.map(&:id).inspect
puts ["ANSWER", corners.reduce(1) { |p, tile| p * tile.id }].join(": ")

puts "=" * 80, ""

puts "SOLUTION PART 2"
edges = tiles.select(&:edge?) - corners

def orient_top_left(tile)
  2.times { tile.rotate } unless tile.top?
  tile.reverse unless tile.left?
  tile
end

def orient_top_left(tile)
  2.times { tile.rotate } unless tile.top?
  tile.reverse unless tile.left?
  tile
end

def orient_middle_left(tile, top_tile)
  while tile.top != top_tile do
    tile.rotate
  end
  tile.reverse unless tile.left?
  tile
end

def build_top_edge(tile, tile_on_left)
  return if tile.nil?
  while !tile.top? do
    tile.rotate
  end
  tile.reverse if tile.left != tile_on_left
  build_top_edge(tile.right, tile)
end

def build_row(tile, tile_on_left, top_tile)
  return if tile.nil?
  while tile.top != top_tile do
    tile.rotate
  end
  tile.reverse if tile.left != tile_on_left
  build_row(tile.right, tile, top_tile.right)
end

def walk_row(tile)
  tiles = [tile]
  while tile do
    tiles << (tile = tile.right)
  end
  tiles.compact
end

tlc = orient_top_left(corners.first)
build_top_edge(tlc, nil)

oriented_tiles = []
oriented_tiles += walk_row(tlc)

left_edge_tile = tlc.bottom
top_tile = tlc
while left_edge_tile do
  orient_middle_left(left_edge_tile, top_tile)

  top_tile = top_tile.right
  build_row(left_edge_tile.right, left_edge_tile, top_tile)

  oriented_tiles += walk_row(left_edge_tile)

  top_tile = left_edge_tile
  left_edge_tile = left_edge_tile.bottom
end

class Puzzle
  attr_reader :canvas, :tiles, :borderless_tiles
  def initialize tiles
    @tiles = tiles
    @borderless_tiles = tiles.map(&:borderless)
    @canvas = tiles_by_row
  end

  def tiles_by_row
    rows = []
    segment = (@tiles.size**0.5).to_i
    borderless_tiles.each_slice(segment) do |row_tiles|
      rows += combine_tile_rows(row_tiles)
    end
    rows
  end

  def combine_tile_rows(row_tiles)
    row_tiles[0].size.times.map do |index|
      row_tiles.map{|tr| tr[index]}.join
    end
  end
end

DRAGON_HEAD_REGX  = /#/
DRAGON_BACK_REGX  = /#.{4}##.{4}##.{4}###/
DRAGON_BELLY_REGX = /.{1}#.{2}#.{2}#.{2}#.{2}#.{2}#/

def double_offsets str, regex, offset
  offsets(str, regex).map{|i| i - offset}.reject(&:negative?)
end

def offsets str, regex
  str.enum_for(:scan, regex).map{ Regexp.last_match.begin(0) }
end

def find_dragons(tile)
  found = 0
  tile.data.each_cons(3) do |head, back, belly|
    positions = []
    double_offsets(head.join, DRAGON_HEAD_REGX, 18).each do |hp|
      if (back_pos = (back.slice(hp, back.size).join =~ DRAGON_BACK_REGX)) && back_pos.zero?
        if (belly_pos = (belly.slice(hp, belly.size).join =~ DRAGON_BELLY_REGX)) && belly_pos.zero?
          found += 1
          positions << hp
        end
      end
    end
    positions.each do |p|
      head[p + 18] = "O"
      [0,5,6,11,12,17,18,19].each{|o| back[p + o] = "O"}
      [1,4,7,10,13,16].each{|o| belly[p + o] = "O"}
    end
  end
  found
end

puts "=" * 40
puzzle = Puzzle.new(oriented_tiles)
puzzle_tile = Tile.new("puzzle", puzzle.canvas)

puts "looking for dragons"
dragons = 0
4.times do
  break if dragons > 0
  puzzle_tile.rotate
  dragons += find_dragons(puzzle_tile)
end
puts "*" * 40
puzzle_tile.reverse
4.times do
  break if dragons > 0
  puzzle_tile.rotate
  dragons += find_dragons(puzzle_tile)
end

# 2532
# 2457 too high

puzzle_tile.data.each{ |d| puts d.join }

puts "Found #{dragons} dragons!"
puts "Total Hashes: #{puzzle_tile.hashes}"
                  #
#    ##    ##    ###
 #  #  #  #  #  #
# NOTE: Code to produce the DRAGON_REGX
# a = "                  # #    ##    ##    ### #  #  #  #  #  #".chars
# while a.size > 0 do
#   s = 0
#   while a.size > 0 && a[0] == " " do
#     s += 1
#     a.shift
#   end
#   print ".{#{s}}"
#   while a.size > 0 && a[0] != " " do
#     print a.shift
#   end
# end
