require 'ruby_jard'
require_relative "tile"

RSpec.describe Tile do
  let(:tile) { Tile.new(1, ["123", "456", "789"]) }
  subject do
    tile.to_s
  end

  it "initial orientation" do
    # 123
    # 456
    # 789
    expect(subject).to eq "123\n456\n789"
  end

  context "#sides" do
    it "has all side permutations" do
      expect(tile.sides.keys).to eq ["123", "321", "741", "147", "987", "789", "369", "963"]
    end
  end

  context "#reverse" do
    it "reverses every row" do
      # 321
      # 654
      # 987
      expect(tile.to_s).to eq "123\n456\n789"
      tile.reverse
      expect(tile.to_s).to eq "321\n654\n987"
    end

    context "after pairing" do
      let(:tile) { Tile.new(1, ["123", "456", "789"]) }
      let(:other_tile) { Tile.new(1, ["111", "422", "733"]) }

      before { tile.pair(other_tile) }

      it "tracks when reversed" do
        expect(tile.left).to eq other_tile
        expect(tile.right).to be_nil

        tile.reverse

        expect(tile.left).to be_nil
        expect(tile.right).to eq other_tile
      end
    end
  end

  context "#rotate" do
    it "rotated back to initial orientation" do
      4.times { tile.rotate }
      expect(subject).to eq "123\n456\n789"
    end

    it "rotated 90" do
      # 741
      # 852
      # 963
      tile.rotate
      expect(subject).to eq "741\n852\n963"
    end

    it "rotated 180" do
      # 987
      # 654
      # 321
      tile.rotate
      tile.rotate
      expect(subject).to eq "987\n654\n321"
    end

    it "rotated 270" do
      # 369
      # 258
      # 147
      tile.rotate
      tile.rotate
      tile.rotate
      expect(subject).to eq "369\n258\n147"
    end
  end

  context "#rotate(track: true)" do
    let(:tile) { Tile.new(1, ["123", "456", "789"]) }
    let(:other_tile) { Tile.new(1, ["111", "222", "789"]) }

    subject { tile }
    before { tile.pair(other_tile) }

    it "paired to bottom" do
      expect(tile.bottom).to eq(other_tile)
      expect(tile.top).to be_nil
      expect(tile.left).to be_nil
      expect(tile.right).to be_nil
    end

    it "paired to left" do
      tile.rotate

      expect(tile.left).to eq(other_tile)
      expect(tile.top).to be_nil
      expect(tile.bottom).to be_nil
      expect(tile.right).to be_nil
    end

    it "paired to top" do
      2.times { tile.rotate }

      expect(tile.top).to eq(other_tile)
      expect(tile.bottom).to be_nil
      expect(tile.left).to be_nil
      expect(tile.right).to be_nil
    end

    it "paired to right" do
      3.times { tile.rotate }

      expect(tile.right).to eq(other_tile)
      expect(tile.top).to be_nil
      expect(tile.bottom).to be_nil
      expect(tile.left).to be_nil
    end

  end
  context "sample" do
    let(:tile_2311) do
      Tile.new(
        2311, [
        "..##.#..#.",
        "##..#.....",
        "#...##..#.",
        "####.#...#",
        "##.##.###.",
        "##...#.###",
        ".#.#.#..##",
        "..#....#..",
        "###...#.#.",
        "..###..###",
        ])
    end


    let(:tile_1951) do
      Tile.new(
        1951, [
        "#.##...##.",
        "#.####...#",
        ".....#..##",
        "#...######",
        ".##.#....#",
        ".###.#####",
        "###.##.##.",
        ".###....#.",
        "..#.#..#.#",
        "#...##.#..",
        ])
    end


    let(:tile_1171) do
      Tile.new(
        1171, [
        "####...##.",
        "#..##.#..#",
        "##.#..#.#.",
        ".###.####.",
        "..###.####",
        ".##....##.",
        ".#...####.",
        "#.##.####.",
        "####..#...",
        ".....##...",
        ])
    end


    let(:tile_1427) do
      Tile.new(
        1427, [
        "###.##.#..",
        ".#..#.##..",
        ".#.##.#..#",
        "#.#.#.##.#",
        "....#...##",
        "...##..##.",
        "...#.#####",
        ".#.####.#.",
        "..#..###.#",
        "..##.#..#.",
        ])
    end


    let(:tile_1489) do
      Tile.new(
        1489, [
        "##.#.#....",
        "..##...#..",
        ".##..##...",
        "..#...#...",
        "#####...#.",
        "#..#.#.#.#",
        "...#.#.#..",
        "##.#...##.",
        "..##.##.##",
        "###.##.#..",
        ])
    end


    let(:tile_2473) do
      Tile.new(
        2473, [
        "#....####.",
        "#..#.##...",
        "#.##..#...",
        "######.#.#",
        ".#...#.#.#",
        ".#########",
        ".###.#..#.",
        "########.#",
        "##...##.#.",
        "..###.#.#.",
        ])
    end


    let(:tile_2971) do
      Tile.new(
        2971, [
        "..#.#....#",
        "#...###...",
        "#.#.###...",
        "##.##..#..",
        ".#####..##",
        ".#..####.#",
        "#..#.#..#.",
        "..####.###",
        "..#.#.###.",
        "...#.#.#.#",
        ])
    end


    let(:tile_2729) do
      Tile.new(
        2729, [
        "...#.#.#.#",
        "####.#....",
        "..#.#.....",
        "....#..#.#",
        ".##..##.#.",
        ".#.####...",
        "####.#.#..",
        "##.####...",
        "##..#.##..",
        "#.##...##.",
        ])
    end


    let(:tile_3079) do
      Tile.new(
        3079, [
        "#.#.#####.",
        ".#..######",
        "..#.......",
        "######....",
        "####.#..#.",
        ".#...#.##.",
        "#.#####.##",
        "..#.###...",
        "..#.......",
        "..#.###...",
        ])
    end
    it "matches 1951 to 2311" do
      tile_1951.pair(tile_2311)
      expect(tile_1951.sides.values).to eq([[], [], [], [], [], [], [tile_2311], [tile_2311]])
      expect(tile_2311.sides.values).to eq([[], [], [tile_1951], [tile_1951], [], [], [], []])
      expect(tile_1951.top).to be_nil
      expect(tile_1951.left).to be_nil
      expect(tile_1951.right).to eq tile_2311
      expect(tile_2311.left).to eq tile_1951
      expect(tile_1951.top?).to be_truthy
      expect(tile_1951.left?).to be_truthy
      expect(tile_1951.corner?).to be_truthy
    end

    it "matches 2311 to 1951, 1427, and 3079" do
      tile_2311.pair(tile_3079)
      tile_2311.pair(tile_1951)
      tile_2311.pair(tile_1427)
      expect(tile_2311.sides.values).to eq([[tile_1427], [tile_1427], [tile_1951], [tile_1951], [], [], [tile_3079], [tile_3079]])
      expect(tile_3079.sides.values).to eq([[], [], [tile_2311], [tile_2311], [], [], [], []])
      expect(tile_1951.sides.values).to eq([[], [], [], [], [], [], [tile_2311], [tile_2311]])
      expect(tile_2311.left).to eq tile_1951
      expect(tile_2311.top).to eq tile_1427
      expect(tile_2311.right).to eq tile_3079
      expect(tile_2311.bottom?).to be_truthy
      expect(tile_2311.top?).to be_falsey
      expect(tile_2311.corner?).to be_falsey
    end

    it "matches 2729 to 1951, 1427, 2971" do
      tile_2729.pair(tile_1951)
      tile_2729.pair(tile_1427)
      tile_2729.pair(tile_2971)
      expect(tile_2729.sides.values).to eq([[tile_2971], [tile_2971], [], [], [tile_1951], [tile_1951], [tile_1427], [tile_1427]])
      expect(tile_2729.bottom).to eq tile_1951
      expect(tile_2729.right).to eq tile_1427
      expect(tile_2729.top).to eq tile_2971
    end

    context "all paired" do
      let(:all_tiles) do
        [ tile_2311, tile_1951, tile_1171,
          tile_1427, tile_1489, tile_2473,
          tile_2971, tile_2729, tile_3079,
        ]
      end
      before do
        0.upto(7) do |i|
          (i + 1).upto(8) do |j|
            all_tiles[i].pair(all_tiles[j])
          end
        end
      end

      subject { all_tiles.select(&:corner?) }

      it "finds the corners" do
        expect(subject.map(&:id)).to eq([1951, 1171, 2971, 3079])
        expect(subject.reduce(1){ |prod, tile| prod * tile.id }).to eq 20899048083289
      end
    end
  end
end
