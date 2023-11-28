require_relative 'board'
require_relative 'piece'

class Rook < Piece

  def initialize(player, square, board)
    super(player, square, board, 'rook')
    #@MOVES = [[0, -1], [0, -1], [0, -1], [0, -3], [0, -4], [0, -5], [-1, 0], [-1, 1]]
  end

  def legal_move?(new_square)
    current_row = @board.row(@current_square)
    current_col = @board.col(@current_square)
    new_row = @board.row(new_square)
    new_col = @board.col(new_square)

    return false unless super

    #has to be the same row or column but not both
    return false unless (current_row != new_row) ^ (current_col != new_col)

    #are there any pieces that would block this move
    !blocked?(new_square)

  end

  def possible_moves
    new_moves = []
    current_row = @board.row(@current_square)
    current_col = @board.col(@current_square)
    for move_col in 0..7
      next if move_col == current_col
      next if !@board.on_board?(current_row, move_col)
      move_square = @board.to_square(current_row, move_col)
      next if blocked?(move_square)  || @board.same_player_on_square(move_square, @player)
      new_moves << move_square
    end
    for move_row in 0..7
      next if move_row == current_row
      next if !@board.on_board?(move_row, current_col)
      move_square = @board.to_square(move_row, current_col)
      next if blocked?(move_square) || @board.same_player_on_square(move_square, @player)
      new_moves << move_square
    end
    new_moves
  end

  def display_chr
    (@player == 'b' ? "\u2656" : "\u265C").encode('utf-8')
  end

  def king?
    false
  end

  private  

  def blocked?(new_square)
    current_row = @board.row(@current_square)
    current_col = @board.col(@current_square)
    new_row = @board.row(new_square)
    new_col = @board.col(new_square)
    blocking_squares = []
    if current_row == new_row
      lower_col = current_col > new_col ? new_col : current_col
      higher_col = current_col > new_col ? current_col : new_col
      for col in (lower_col + 1)..(higher_col - 1)
        blocking_squares << @board.to_square(current_row, col)
      end
    else
      lower_row = current_row > new_row ? new_row : current_row
      higher_row = current_row > new_row ? current_row : new_row
      for row in (lower_row + 1)..(higher_row - 1)
        blocking_squares << @board.to_square(row, current_col)
      end
    end

    blocking_squares.any? { |square| !@board.piece_on_square(square).nil? }

  end
end