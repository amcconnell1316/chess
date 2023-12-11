require_relative 'board'
require_relative 'piece'

class Pawn < Piece

  def initialize(player, square, board)
    super(player, square, board, 'pawn')
  end

  def legal_move?(new_square)

    return false unless super
    
    capture = @board.other_player_on_square(new_square, @player) || @board.en_passant_move?(new_square, @player)

    return true if forward_one?(new_square) && !capture
    return true if @first_move && forward_two?(new_square) && !blocked?(new_square) && !capture
    return true if diagonal_one?(new_square) && capture
    false
  end

  def possible_moves
    new_moves = []
    new_moves << forward_one
    new_moves << forward_two
    diag = diagonal_one
    new_moves << diag[0]
    new_moves << diag[1]

    new_moves.select do | square |
      legal_move?(square)
    end
  end

  def king?
    false
  end

  def display_chr
    (@player == 'b' ? "\u2659" : "\u265F").encode('utf-8')
  end

  private

  def blocked?(new_square)
    current_row = @board.row(@current_square)
    current_col = @board.col(@current_square)

    if forward_two?(new_square) 
      if @player == 'w'
        !@board.piece_on_square(@board.to_square(current_row + 1, current_col)).nil?
      else
        !@board.piece_on_square(@board.to_square(current_row - 1, current_col)).nil?
      end
    else
      false
    end
  end

  def forward_one?(new_square)
    new_square == forward_one
  end

  def forward_one
    current_row = @board.row(@current_square)
    current_col = @board.col(@current_square)

    if @player == 'w'
      new_row = current_row + 1
    else
      new_row = current_row - 1
    end

    @board.to_square(new_row, current_col)
  end

  def forward_two?(new_square)
    new_square == forward_two
  end

  def forward_two
    current_row = @board.row(@current_square)
    current_col = @board.col(@current_square)

    if @player == 'w'
      new_row = current_row + 2
    else
      new_row = current_row - 2
    end

    @board.to_square(new_row, current_col)
  end

  def diagonal_one?(new_square)
    !diagonal_one.find_index(new_square).nil?
  end

  def diagonal_one
    current_row = @board.row(@current_square)
    current_col = @board.col(@current_square)

    if @player == 'w'
      new_row = current_row + 1
    else
      new_row = current_row - 1
    end

    [@board.to_square(new_row, current_col + 1), @board.to_square(new_row, current_col - 1)]
  end

end