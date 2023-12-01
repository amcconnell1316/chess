require_relative 'board'
require_relative 'piece'

class King < Piece
  def initialize(player, square, board)
    super(player, square, board, 'king')
    @MOVES = [[1, -1], [1, 0], [1, 1], [0, 1], [0, -1], [-1, -1], [-1, 0], [-1, 1]]
  end

  def legal_move?(new_square)
    current_row = @board.row(@current_square)
    current_col = @board.col(@current_square)
    new_row = @board.row(new_square)
    new_col = @board.col(new_square)

    return false unless super

    #is the move legal
    @MOVES.any? do | move |
      move_row = current_row + move[0]
      move_col = current_col + move[1]
      move_row == new_row && move_col == new_col
    end
  end

  def possible_moves
    new_moves = []
    current_row = @board.row(@current_square)
    current_col = @board.col(@current_square)

    @MOVES.each do | move |
      move_row = current_row + move[0]
      move_col = current_col + move[1]
      square = @board.to_square(move_row, move_col)
      next unless legal_move?(square)
      new_moves << square
    end
    new_moves
  end

  def king?
    true
  end

  def display_chr
    (@player == 'b' ? "\u2654" : "\u265A").encode('utf-8')
  end


end