require 'rspec'
require_relative 'solution'

RSpec.describe Universe do
  let(:data) { File.read('test_input.txt').split("\n").map(&:chars) }
  let(:universe) { Universe.new(data, red_shift: 1) }

  it { expect(universe.wormholes.size).to eq 36 }
end

RSpec.describe Galaxy do
  let(:a) { Galaxy.new(x: 1, y: 1) }
  let(:b) { Galaxy.new(x: 1, y: 2) }
  let(:c) { Galaxy.new(x: 1, y: 2) }

  it 'is comparable' do
    expect(a).to be < b
    expect(b).to be == c
  end

  it 'is sortable' do
    expect([b, a, c].sort).to eq([a, b, c])
  end
end

RSpec.describe Wormhole do
  let(:data) { File.read('test_input.txt').split("\n").map(&:chars) }
  let(:universe) { Universe.new(data, red_shift: 1) }

  let(:a) { universe.galaxy(5) }
  let(:b) { universe.galaxy(9) }

  it { expect(a).to be_a(Galaxy) }
  it { expect(b).to be_a(Galaxy) }

  describe 'comparable' do
    let(:wormhole_ab) { Wormhole.new(universe, a, b) }
    let(:wormhole_ba) { Wormhole.new(universe, b, a) }

    it "(a, b) == (b, a)" do
      expect(wormhole_ab).to eq wormhole_ba
      expect(wormhole_ab).to eql wormhole_ba
      set = Set.new
      set << wormhole_ab
      set << wormhole_ba
      expect(set.size).to eq 1
    end
  end

  describe '#distance' do
    subject { Wormhole.new(universe, source, destination) }

    context 'when #5 => #9' do
      let(:source) { universe.galaxy(5) }
      let(:destination) { universe.galaxy(9) }
      it { expect(subject.distance). to eq 9 }

      context 'when redshift is 10' do
        let(:universe) { Universe.new(data, red_shift: 10) }
        it { expect(subject.distance). to eq 25 }
      end

      context 'when redshift is 100' do
        let(:universe) { Universe.new(data, red_shift: 100) }
        it { expect(subject.distance). to eq 205 }
      end
    end

    context 'when #1 => #7' do
      let(:source) { universe.galaxy(1) }
      let(:destination) { universe.galaxy(7) }

      it { expect(subject.distance). to eq 15 }
      it { expect(source.inspect).to eq "G:4,0" }

      context 'when redshift is 10' do
        let(:universe) { Universe.new(data, red_shift: 10) }
        it { expect(subject.distance). to eq 39 }
      end

      context 'when redshift is 100' do
        let(:universe) { Universe.new(data, red_shift: 100) }
        it { expect(subject.distance). to eq 309 }
      end
    end

    context 'when #3 => #6' do
      let(:source) { universe.galaxy(3) }
      let(:destination) { universe.galaxy(6) }
      it { expect(subject.distance). to eq 17 }

      context 'when redshift is 10' do
        let(:universe) { Universe.new(data, red_shift: 10) }
        it { expect(subject.distance). to eq 49 }
      end

      context 'when redshift is 100' do
        let(:universe) { Universe.new(data, red_shift: 100) }
        it { expect(subject.distance). to eq 409 }
      end
    end

    context 'when #8 => #9' do
      let(:source) { universe.galaxy(8) }
      let(:destination) { universe.galaxy(9) }
      it { expect(subject.distance). to eq 5 }

      context 'when redshift is 10' do
        let(:universe) { Universe.new(data, red_shift: 10) }
        it { expect(subject.distance). to eq 13 }
      end

      context 'when redshift is 100' do
        let(:universe) { Universe.new(data, red_shift: 100) }
        it { expect(subject.distance). to eq 103 }
      end
    end
  end
end
