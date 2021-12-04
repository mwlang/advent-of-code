input = File.read('input.txt').split("\n")
draws = input.shift.split(",").map(&:to_i)
input.shift

class Board
  attr_reader :rows, :cols
  attr_reader :placed
  attr_reader :turns_taken

  def initialize rows
    @rows = rows.map{ |row| row.split.map(&:to_i) }
    @cols = @rows.transpose
    @placed = []
    @turns_taken = 0
  end

  def << value
    return if winner?
    @turns_taken += 1
    @placed << value
  end

  def winner?
    @rows.any?{ |row| (row - placed).empty? } || @cols.any?{ |col| (col - placed).empty? }
  end

  def unplaced
    @rows.flat_map(&:itself) - @placed
  end

  def score
    unplaced.reduce(0){ |sum, value| sum + value } * @placed[-1]
  end
end

boards = []
rows = []

until input.empty? do
  if input[0] == ""
    input.shift
    boards << Board.new(rows)
    rows = []
  else
    rows << input.shift
  end
end
boards << Board.new(rows)

def play_bingo! boards, draws
  previous_board_won = nil
  draws.each_with_index do |draw, index|
    boards.each do |board|
      board << draw
      if board.winner? && board.turns_taken == (index + 1)
        puts "Board ##{board.object_id} won on #{board.turns_taken} turns with a score of #{board.score}"
        previous_board_won = board
      end
    end
  end
  puts "total turns: #{draws.size}"
  return previous_board_won
end

play_bingo! boards, draws
