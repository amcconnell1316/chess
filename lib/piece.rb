class Piece 
  attr_reader :player, :name, :current_square

  def initialize(player, square, board, name = 'piece')
    @player = player
    @current_square = square
    @name = name
    @board = board
  end

  def move(square)
    @current_square = square
  end

  def legal_move?(new_square)
    current_row = @board.row(@current_square)
    current_col = @board.col(@current_square)
    new_row = @board.row(new_square)
    new_col = @board.col(new_square)

    #have to actually move
    return false if current_row == new_row && current_col == new_col

    #have to stay on the board
    return false unless @board.on_board?(new_row, new_col)

    #are there any pieces that would block this move
    !@board.same_player_on_square(new_square, @player)

  end
  
end