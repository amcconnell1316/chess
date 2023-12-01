require_relative 'board'
require_relative 'piece'
require_relative 'rook'
require_relative 'bishop'

class Queen < Piece

  def initialize(player, square, board)
    super(player, square, board, 'queen')
    @rook = Rook.new(player, square, board)
    @bishop = Bishop.new(player, square, board)
  end

  def move(square)
    @current_square = square
    @rook.move(square)
    @bishop.move(square)
  end

  def legal_move?(new_square)
    @bishop.legal_move?(new_square) || @rook.legal_move?(new_square)
  end

  def possible_moves
    @rook.possible_moves + @bishop.possible_moves
  end

  def display_chr
    (@player == 'b' ? "\u2655" : "\u265B").encode('utf-8')
  end

  def king?
    false
  end
end