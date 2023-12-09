class Hand
  include Comparable

  attr_reader :cards, :bid, :jacks_are_wild

  def initialize(cards, bid=1, jacks_are_wild: false)
    @jacks_are_wild = jacks_are_wild
    @bid = bid.to_i
    @cards = cards.chars.map{ |face| Card.new(face, jacks_are_wild: jacks_are_wild) }
  end

  def wild_cards
    @wild_cards ||= cards.select(&:wild_card?)
  end

  def non_wild_cards
    @non_wild_cards ||= cards.reject(&:wild_card?)
  end

  def non_wild_card_groups(length:)
    non_wild_cards.group_by(&:face).select{ |_, cards| cards.length == length }
  end

  def one_pair?
    pair_count = non_wild_card_groups(length: 2).count
    (pair_count == 1) || (pair_count.zero? && wild_cards.count == 1)
  end

  def two_pairs?
    return false if three_of_a_kind?
    pair_count = non_wild_card_groups(length: 2).count
    (pair_count == 2) || (pair_count == 1 && wild_cards.count == 1)
  end

  def full_house?
    pair_count = non_wild_card_groups(length: 2).count
    case wild_cards.count
    when 0 then natural_three_of_a_kind? && pair_count == 1
    when 1 then pair_count == 2
    else false
    end
  end

  def natural_three_of_a_kind?
    return false if four_of_a_kind? || five_of_a_kind?
    non_wild_card_groups(length: 3).any?
  end

  def three_of_a_kind?
    return false if four_of_a_kind? || five_of_a_kind?
    non_wild_card_groups(length: (3 - wild_cards.count)).any?
  end

  def four_of_a_kind?
    non_wild_card_groups(length: (4 - wild_cards.count)).any?
  end

  def five_of_a_kind?
    return true if wild_cards.count >= 5
    non_wild_card_groups(length: (5 - wild_cards.count)).any?
  end

  RANK_BY_KIND = %i(
    high_card
    one_pair
    two_pairs
    three_of_a_kind
    straight
    flush
    full_house
    four_of_a_kind
    straight_flush
    five_of_a_kind
    )

  def kind
    return :five_of_a_kind if five_of_a_kind?
    return :four_of_a_kind if four_of_a_kind?
    return :full_house if full_house?
    return :three_of_a_kind if three_of_a_kind?
    return :two_pairs if two_pairs?
    return :one_pair if one_pair?
    :high_card
  end

  def rank
    RANK_BY_KIND.index(kind)
  end


  def <=>(other)
    [rank, cards] <=> [other.rank, other.cards]
  end

  def inspect
    "#{cards.map(&:face).join} #{cards.sort.map(&:face).join} #{cards.select(&:wild_card?).count} #{bid} (#{kind})"
  end
end
