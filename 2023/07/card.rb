class Card
  include Comparable

  attr_reader :face, :value

  def initialize(face, jacks_are_wild: false)
    @jacks_are_wild = jacks_are_wild
    @face = face
    raise "Invalid face: #{face}" unless face_values.include?(face)
    @value = face_values.index(face)
  end

  NORMAL_FACE_VALUES = %w{2 3 4 5 6 7 8 9 T J Q K A}
  WILD_FACE_VALUES   = %w{J 2 3 4 5 6 7 8 9 T Q K A}

  def face_values
    jacks_are_wild? ? WILD_FACE_VALUES : NORMAL_FACE_VALUES
  end

  def <=>(other)
    value <=> other.value
  end

  def wild_card?
    face == 'J' && jacks_are_wild?
  end

  def jacks_are_wild?
    @jacks_are_wild
  end

  def ==(other)
    (wild_card? || other.wild_card?) || value == other.value
  end

  def inspect
    face
  end
end
