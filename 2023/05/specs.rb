require 'ruby_jard'
require 'set'
require_relative 'hopper'
require_relative 'diverter'
require_relative 'seed_map'

RSpec.configure do |config|
  config.filter_run_including focus: true
  config.run_all_when_everything_filtered = true
end

RSpec.describe Hopper do
  describe '#collect_seeds' do
    it 'collects and removes seeds when single seed' do
      hopper = Hopper.new(50)
      expect(hopper.collect_seeds).to eq([50..50])
      expect(hopper.seeds).to be_empty
    end

    it 'collects and removes seeds' do
      hopper = Hopper.new(50..52)
      expect(hopper.collect_seeds).to eq([50..52])
      expect(hopper.seeds).to be_empty
    end

    it 'collects and removes multiples of seeds' do
      hopper = Hopper.new([50..52, 96..102])
      expect(hopper.collect_seeds).to eq([50..52, 96..102])
      expect(hopper.seeds).to be_empty
    end
  end
end

RSpec.describe Diverter do
  let(:offset) { 100 }
  let(:diverter) { Diverter.new(source_range, offset) }
  let(:source_range) { 5..10 }

  subject { diverter }

  describe "#divert" do
    context 'scenario' do
      let(:source_begin) { source_range.begin }
      let(:destination_begin) { destination_range.begin }
      let(:offset) { destination_begin - source_begin }

      context 'when 52 50 48' do
        let(:source_range) { 98..100 }
        let(:destination_range) { 50..52 }

        it { expect(subject.divert(97)).to eq({ diverted: [], undiverted: [97..97] }) }
        it { expect(subject.divert(98)).to eq({ diverted: [50..50], undiverted: [] }) }
        it { expect(subject.divert(99)).to eq({ diverted: [51..51], undiverted: [] }) }
        it { expect(subject.divert(98..99)).to eq({ diverted: [50..51], undiverted: [] }) }
        it { expect(subject.divert(96..99)).to eq({ diverted: [50..51], undiverted: [96..97] }) }
      end

      context 'when 50 98 2' do
        let(:source_range) { 50..98 }
        let(:destination_range) { 52..100 }

        it { expect(subject.divert(97)).to eq({ diverted: [99..99], undiverted: [] }) }
        it { expect(subject.divert(50)).to eq({ diverted: [52..52], undiverted: [] }) }
        it { expect(subject.divert(50..52)).to eq({ diverted: [52..54], undiverted: [] }) }
        it { expect(subject.divert(40..52)).to eq({ diverted: [52..54], undiverted: [40..49] }) }
      end
    end

    context "given a range that does not overlap" do
      it { expect(subject.overlaps?(1..3)).to be_falsey }
      it { expect(subject.divert(1..3)).to eq({ diverted: [], undiverted: [1..3] }) }
    end

    context "given a range that overlaps" do
      context 'starts before destination and ends within destination' do
        let(:range) { 1..6 }
        it { expect(subject.overlaps?(range)).to be_truthy }
        it { expect(subject.divert(range)).to eq({ diverted: [105..106], undiverted: [1..4] }) }
      end

      context 'starts within destination and ends after destination' do
        let(:range) { 7..12 }
        it { expect(subject.overlaps?(range)).to be_truthy }
        it { expect(subject.divert(range)).to eq({ diverted: [107..110], undiverted: [11..12] }) }
      end

      context 'starts before destination and ends after destination' do
        let(:range) { 1..12 }
        it { expect(subject.overlaps?(range)).to be_truthy }
        it { expect(subject.divert(range)).to eq({ diverted: [105..110], undiverted: [1..4, 11..12] }) }
      end
    end

    context "given a range that is covered" do
      let(:range) { 6..8 }
      it { expect(subject.covers?(range)).to be_truthy }
      it { expect(subject.overlaps?(range)).to be_truthy }
      it { expect(subject.divert(range)).to eq({diverted: [106..108], undiverted: [] }) }
    end

    context "given a single number" do
      it { expect(subject.divert(6)).to eq({ diverted: [106..106], undiverted: [] }) }
      it { expect(subject.divert(3)).to eq({ diverted: [], undiverted: [3..3] }) }
      it { expect(subject.divert(10)).to eq({ diverted: [110..110], undiverted: [] }) }
      it { expect(subject.divert(12)).to eq({ diverted: [], undiverted: [12..12] }) }
    end
  end
end

RSpec.describe SeedMap do
  let(:seed_to_soil_mappings) { "seed-to-soil map:\n50 98 2\n52 50 48" }
  let(:soil_to_fertilizer_mappings) { "soil-to-fertilizer map:\n0 15 37\n37 52 2\n39 0 15" }
  let(:fertilizer_to_water_mappings) { "fertilizer-to-water map:\n49 53 8\n0 11 42\n42 0 7\n57 7 4" }
  let(:water_to_light_mappings) { "water-to-light map:\n88 18 7\n18 25 70" }
  let(:light_to_temperature_mappings) { "light-to-temperature map:\n45 77 23\n81 45 19\n68 64 13" }
  let(:temperature_to_humidity_mappings) { "temperature-to-humidity map:\n0 69 1\n1 0 69" }
  let(:humidity_to_location_mappings) { "humidity-to-location map:\n60 56 37\n56 93 4" }

  let(:seed_map) { SeedMap.new(mappings) }

  subject(:hopper) { Hopper.new(seeds) }

  def assert_changes(seed_map, hopper, from:, to:)
    if from == to
      expect { seed_map.divert(hopper) }.not_to change{ hopper.seeds }
    else
      expect { seed_map.divert(hopper) }.to change{ hopper.seeds }.from([from..from]).to([to..to])
    end
  end

  # Seed 79, soil 81, fertilizer 81, water 81, light 74, temperature 78, humidity 78, location 82.
  # Seed 14, soil 14, fertilizer 53, water 49, light 42, temperature 42, humidity 43, location 43.
  # Seed 55, soil 57, fertilizer 57, water 53, light 46, temperature 82, humidity 82, location 86.
  # Seed 13, soil 13, fertilizer 52, water 41, light 34, temperature 34, humidity 35, location 35.
  context 'seed-to-soil' do
    let(:mappings) { seed_to_soil_mappings }

    [[82, 84], [79, 81], [14, 14], [55, 57], [13, 13]].each do |seed, soil|
      it "maps #{seed} to #{soil}" do
        hopper = Hopper.new(seed)
        assert_changes(seed_map, hopper, from: seed, to: soil)
      end
    end
  end

  context 'soil-to-fertilizer' do
    let(:mappings) { soil_to_fertilizer_mappings }
    [[84, 84], [81, 81], [14, 53], [57, 57], [13, 52]].each do |soil, fertilizer|
      it "maps #{soil} to #{fertilizer}" do
        hopper = Hopper.new(soil)
        assert_changes(seed_map, hopper, from: soil, to: fertilizer)
      end
    end
  end

  # context 'focused', focus: true do
  #   let(:mappings) { fertilizer_to_water_mappings }
  #   it 'maps 82 to 84' do
  #     hopper = Hopper.new(53)
  #     assert_changes(seed_map, hopper, from: 53, to: 49)
  #   end
  # end

  context 'fertilizer-to-water' do
    let(:mappings) { fertilizer_to_water_mappings }
    [[84, 84], [81, 81], [53, 49], [57, 53], [52, 41]].each do |fertilizer, water|
      it "maps #{fertilizer} to #{water}" do
        hopper = Hopper.new(fertilizer)
        assert_changes(seed_map, hopper, from: fertilizer, to: water)
      end
    end
  end

  context 'water-to-light' do
    let(:mappings) { water_to_light_mappings }
    [[84, 77], [81, 74], [49, 42], [53, 46], [41, 34]].each do |water, light|
      it "maps #{water} to #{light}" do
        hopper = Hopper.new(water)
        assert_changes(seed_map, hopper, from: water, to: light)
      end
    end
  end

  context 'light-to-temperature' do
    let(:mappings) { light_to_temperature_mappings }
    [[77, 45], [74, 78], [42, 42], [46, 82], [34, 34]].each do |light, temperature|
      it "maps #{light} to #{temperature}" do
        hopper = Hopper.new(light)
        assert_changes(seed_map, hopper, from: light, to: temperature)
      end
    end
  end

  context 'temperature-to-humidity' do
    let(:mappings) { temperature_to_humidity_mappings }
    [[45, 46], [78, 78], [42, 43], [82, 82], [34, 35]].each do |temperature, humidity|
      it "maps #{temperature} to #{humidity}" do
        hopper = Hopper.new(temperature)
        assert_changes(seed_map, hopper, from: temperature, to: humidity)
      end
    end
  end

  context 'humidity-to-location' do
    let(:mappings) { humidity_to_location_mappings }
    [[46, 46], [78, 82], [43, 43], [82, 86], [35, 35]].each do |humidity, location|
      it "maps #{humidity} to #{location}" do
        hopper = Hopper.new(humidity)
        assert_changes(seed_map, hopper, from: humidity, to: location)
      end
    end
  end
end
