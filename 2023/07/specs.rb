require 'rspec'
require_relative 'card'
require_relative 'hand'

RSpec.describe Card do
  describe "#value" do
    let(:jack) { Card.new('J') }
    let(:two) { Card.new('2') }
    let(:ace) { Card.new('A') }
    let(:another_ace) { Card.new('A') }

    it { expect(jack.value).to eq(9) }
    it { expect(two.value).to eq(0) }
    it { expect(ace.value).to eq(12) }
    it { expect(ace).to eq another_ace }
    it { expect(ace).not_to eq jack }
    it { expect(ace).to be > jack }
    it { expect(two).to be < jack }
    it { expect(two).not_to eq jack }
    it { expect(ace).to be > two }
    it { expect(jack).not_to be_wild_card }

    context 'when jacks are wild' do
      let(:jack) { Card.new('J', jacks_are_wild: true) }
      let(:two) { Card.new('2', jacks_are_wild: true) }
      let(:ace) { Card.new('A', jacks_are_wild: true) }

      it { expect(jack.value).to eq(0) }
      it { expect(two.value).to eq(1) }
      it { expect(ace.value).to eq(12) }
      it { expect(ace).to eq jack }
      it { expect(ace).to be > jack }
      it { expect(two).to be > jack }
      it { expect(two).to eq jack }
      it { expect(jack).to be_wild_card }
    end
  end
end

RSpec.describe Hand do
  let(:two) { Card.new('2') }
  let(:three) { Card.new('3') }
  let(:four) { Card.new('4') }
  let(:five) { Card.new('5') }
  let(:six) { Card.new('6') }
  let(:seven) { Card.new('7') }
  let(:eight) { Card.new('8') }
  let(:nine) { Card.new('9') }
  let(:ten) { Card.new('T') }
  let(:jack) { Card.new('J') }
  let(:queen) { Card.new('Q') }
  let(:king) { Card.new('K') }
  let(:ace) { Card.new('A') }

  describe "#one_pair" do
    it { expect(Hand.new('23456')).not_to be_one_pair }
  end

  describe "#two_pairs" do
    it { expect(Hand.new('22334')).to be_two_pairs }
    it { expect(Hand.new('2233J', jacks_are_wild: true)).to be_full_house }
    it { expect(Hand.new('AKTJ8')).not_to be_two_pairs }
    it { expect(Hand.new('AKTJ8', jacks_are_wild: true)).to be_one_pair }
    it { expect(Hand.new('AKTJ8', jacks_are_wild: true)).not_to be_two_pair }
  end

  describe "#full_house?" do
    it { expect(Hand.new('22355')).not_to be_full_house }
    it { expect(Hand.new('22555')).to be_full_house }

    context 'no wild cards' do
      it { expect(Hand.new('22333')).to be_full_house }
      it { expect(Hand.new('22334')).not_to be_full_house }
    end
    context 'one wild card' do
      it { expect(Hand.new('2233J', jacks_are_wild: true)).to be_full_house }
      it { expect(Hand.new('2255J', jacks_are_wild: true)).to be_full_house }
      it { expect(Hand.new('2225J', jacks_are_wild: true)).not_to be_full_house } # four of a kind
      it { expect(Hand.new('J242Q', jacks_are_wild: true)).not_to be_full_house }
    end
    context 'two wild cards' do
      it { expect(Hand.new('223JJ', jacks_are_wild: true)).to be_four_of_a_kind }
    end
    context 'three wild cards' do
      it { expect(Hand.new('22JJJ', jacks_are_wild: true)).not_to be_full_house }
    end
  end

  describe "#three_of_a_kind?" do
    it { expect(Hand.new('22355')).not_to be_three_of_a_kind }
    it { expect(Hand.new('22223')).not_to be_three_of_a_kind }
    it { expect(Hand.new('22243')).to be_three_of_a_kind }
    it { expect(Hand.new('J242Q')).not_to be_three_of_a_kind }

    it { expect(Hand.new('22243', jacks_are_wild: true)).to be_three_of_a_kind }
    it { expect(Hand.new('22J33', jacks_are_wild: true)).to be_three_of_a_kind }
    it { expect(Hand.new('2JJ34', jacks_are_wild: true)).to be_three_of_a_kind }
    it { expect(Hand.new('2JJ33', jacks_are_wild: true)).not_to be_three_of_a_kind }
    it { expect(Hand.new('222J3', jacks_are_wild: true)).not_to be_three_of_a_kind }
    it { expect(Hand.new('J242Q', jacks_are_wild: true)).to be_three_of_a_kind }
  end

  describe "#four_of_a_kind?" do
    it { expect(Hand.new('22255')).not_to be_four_of_a_kind }
    it { expect(Hand.new('22223')).to be_four_of_a_kind }
    it { expect(Hand.new('2225J', jacks_are_wild: true)).to be_four_of_a_kind }
    it { expect(Hand.new('2222J', jacks_are_wild: true)).not_to be_four_of_a_kind }
  end

  describe '#five_of_a_kind?' do
    it { expect(Hand.new('JJJJJ')).to be_five_of_a_kind }
    it { expect(Hand.new('JJJJJ', jacks_are_wild: true)).to be_five_of_a_kind }
    it { expect(Hand.new('JJJJA')).to be_four_of_a_kind }
    it { expect(Hand.new('JJJJA', jacks_are_wild: true)).to be_five_of_a_kind }
    it { expect(Hand.new('JJJAA')).to be_full_house }
    it { expect(Hand.new('JJJAA', jacks_are_wild: true)).to be_five_of_a_kind }
    it { expect(Hand.new('JJAAA')).to be_full_house }
    it { expect(Hand.new('JJAAA', jacks_are_wild: true)).to be_five_of_a_kind }
    it { expect(Hand.new('22223')).not_to be_five_of_a_kind }
    it { expect(Hand.new('22222')).to be_five_of_a_kind }
    it { expect(Hand.new('2222J')).not_to be_five_of_a_kind }
    it { expect(Hand.new('2222J', jacks_are_wild: true)).to be_five_of_a_kind }
    it { expect(Hand.new('2JJJJ', jacks_are_wild: true)).to be_five_of_a_kind }
  end
end
