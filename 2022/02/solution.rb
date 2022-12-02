data = File.read('input.txt').split("\n").map{ |l| l.split(' ') }

class Answer
  def self.beats?(other); new.beats?(other) end
  def self.ties?(other); other.is_a?(self) end
  def should_win?; false end
  def should_draw?; false end
end

class Rock < Answer
  def self.symbols; %w(A X) end
  def score; 1 end
  def beats?(other); other.is_a?(Scissors) end
end

class Paper < Answer
  def self.symbols; %w(B Y) end
  def score; 2 end
  def beats?(other); other.is_a?(Rock) end
  def should_draw?; true end
end

class Scissors < Answer
  def self.symbols; %w(C Z) end
  def score; 3 end
  def beats?(other); other.is_a?(Paper) end
  def should_win?; true end
end

class AnswerFactory
  def self.choice value
    [Rock, Paper, Scissors].find{ |answer| answer.symbols.include? value }.new
  end

  def beats! answer
    [Rock, Paper, Scissors].find{ |choice| choice.beats?(answer) }.new
  end
end

class Game
  attr_reader :you, :me

  def initialize you, me
    @you = AnswerFactory.choice(you)
    @me = AnswerFactory.choice(me)
  end

  def won?
    me.beats? you
  end

  def draw?
    me.is_a?(you.class)
  end

  def choice_score
    me.score
  end

  def draw_score
    draw? ? 3 : 0
  end

  def win_or_draw_score
    won? ? 6 : draw? ? 3 : 0
  end

  def score
    choice_score + win_or_draw_score
  end

  def round
    print [
      me.class.to_s.downcase.ljust(8),
      you.class.to_s.downcase.ljust(8),
      choice_score, win_or_draw_score, won? ? 'W' : draw? ? 'D' : 'L'
    ].join(' ')
  end
end

class SneakyGame < Game
  def won?
    me.should_win?
  end

  def draw?
    me.should_draw?
  end

  def what_beats_you?
    [Rock, Paper, Scissors].find { |answer| answer.beats?(you) }.new
  end

  def what_loses_to_you?
    [Rock, Paper, Scissors].find { |answer| !answer.beats?(you) && !answer.ties?(you) }.new
  end

  def cheat
    return you if me.should_draw?

    me.should_win? ? what_beats_you? : what_loses_to_you?
  end

  def choice_score
    cheat.score
  end
end

print "PART 1: "
game_answers = data.map { |you, me| Game.new you, me }
pp game_answers.reduce(0) { |sum, g| sum + g.score }

print "PART 2: "
game_answers = data.map { |you, me| SneakyGame.new you, me }
pp game_answers.reduce(0) { |sum, g| sum + g.score }
