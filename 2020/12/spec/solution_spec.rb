require './solution'

describe Vessel do
  let(:ship) { Vessel.new }

  describe "#rotate" do
    it "faces east initially" do
      expect(ship.facing).to eq 0
    end

    [ [0, 0],
      [90, 90],
      [180, 180],
      [270, 270],
      [360, 0],
      [-90, 270],
      [-180, 180],
      [-270, 90],
    ].each do |degrees, expected|
      it "rotates #{degrees} to #{expected}" do
        ship.rotate(degrees)
        expect(ship.facing).to eq expected
      end
      it "rotates #{degrees} five times to #{expected}" do
        5.times { ship.rotate(degrees) }
        expect(ship.facing).to eq expected
      end
    end
  end

  describe "#move" do
    it "starts at 0, 0 initially" do
      expect(ship.x).to eq 0
      expect(ship.y).to eq 0
    end

    it "moves forward and back" do
      ship.move(1,1)
      expect([ship.x, ship.y]).to eq [1, 1]
      ship.move(-1,-1)
      expect([ship.x, ship.y]).to eq [0, 0]
      ship.move(-2,-2)
      expect([ship.x, ship.y]).to eq [-2, -2]
      ship.move(2,2)
      expect([ship.x, ship.y]).to eq [0, 0]
    end
  end

  describe "#forward" do
    context "facing East" do
      it "moves East" do
        ship.forward(2)
        expect([ship.x, ship.y]).to eq [2, 0]
      end
    end

    context "facing North" do
      let(:ship) { Vessel.new.tap{|v| v.rotate(90)} }
      it "moves North" do
        expect(ship.facing).to eq 90
        ship.forward(2)
        expect([ship.x, ship.y]).to eq [0, 2]
      end
    end

    context "facing West" do
      let(:ship) { Vessel.new.tap{|v| v.rotate(180)} }
      it "moves West" do
        expect(ship.facing).to eq 180
        ship.forward(2)
        expect([ship.x, ship.y]).to eq [-2, 0]
      end
    end

    context "facing South" do
      let(:ship) { Vessel.new.tap{|v| v.rotate(-90)} }
      it "moves South" do
        expect(ship.facing).to eq 270
        ship.forward(2)
        expect([ship.x, ship.y]).to eq [0, -2]
      end
    end
  end

  describe Waypoint do
    let(:waypoint) { Waypoint.new(10, 4) }

    [ [0,    [10,   4]],
      [90,   [-4,  10]],
      [180,  [-10, -4]],
      [270,  [ 4, -10]],
      [360,  [10,   4]],
      [-90,  [ 4, -10]],
      [-180, [-10, -4]],
      [-270, [-4,  10]],
      [-360, [10,   4]],
    ].each do |degrees, expected|
      it "rotates #{degrees} to #{expected}" do
        waypoint.rotate(degrees)
        expect([waypoint.x, waypoint.y]).to eq expected
      end
      it "rotates #{degrees} five times to #{expected}" do
        5.times { waypoint.rotate(degrees) }
        expect([waypoint.x, waypoint.y]).to eq expected
      end
    end
  end
end