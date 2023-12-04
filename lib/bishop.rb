require_relative 'board'
require_relative 'piece'

class Bishop < Piece

  def initialize(player, square, board)
    super(player, square, board, 'bishop')
  end

  def legal_move?(new_square)
    current_row = @board.row(@current_square)
    current_col = @board.col(@current_square)
    new_row = @board.row(new_square)
    new_col = @board.col(new_square)

    return false unless super

    #has to be the same diffence for row and column
    return false unless (current_row - new_row).abs == (current_col - new_col).abs

    #are there any pieces that would block this move
    !blocked?(new_square)

  end

  def possible_moves
    new_moves = []
    current_row = @board.row(@current_square)
    current_col = @board.col(@current_square)
    for move in 0..7
      move_row = current_row + move
      move_col = current_col + move
      new_moves << @board.to_square(move_row, move_col)

      move_row = current_row - move
      move_col = current_col - move
      new_moves << @board.to_square(move_row, move_col)

      move_row = current_row - move
      move_col = current_col + move
      new_moves << @board.to_square(move_row, move_col)

      move_row = current_row + move
      move_col = current_col - move
      new_moves << @board.to_square(move_row, move_col)
    end
    
    new_moves.select do | square |
      legal_move?(square)
    end
  end

  def display_chr
    (@player == 'b' ? "\u2657" : "\u265D").encode('utf-8')
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
    total_diff = (current_row - new_row).abs
    #upper right direction
    if current_row < new_row && current_col < new_col
      for diff in 1..(total_diff - 1)
        blocking_squares << @board.to_square(current_row + diff, current_col + diff)
      end
    #upper left direction
    elsif current_row < new_row && current_col > new_col
      for diff in 1..(total_diff - 1)
        blocking_squares << @board.to_square(current_row + diff, current_col - diff)
      end
    #lower right direction
    elsif current_row > new_row && current_col > new_col
      for diff in 1..(total_diff - 1)
        blocking_squares << @board.to_square(current_row - diff, current_col - diff)
      end
    else
      for diff in 1..(total_diff - 1)
        blocking_squares << @board.to_square(current_row - diff, current_col + diff)
      end
    end

    blocking_squares.any? { |square| !@board.piece_on_square(square).nil? }

  end
end