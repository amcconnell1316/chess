class Piece 
  attr_reader :player, :name, :current_square, :first_move

  def initialize(player, square, board, name = 'piece')
    @player = player
    @current_square = square
    @name = name
    @board = board
    @first_move = true
  end

  def move(square)
    @current_square = square
    @first_move = false
  end

  def legal_move?(new_square)
    current_row = @board.row(@current_square)
    current_col = @board.col(@current_square)
    new_row = @board.row(new_square)
    new_col = @board.col(new_square)

    #have to actually move
    return false if current_row == new_row && current_col == new_col

    @board.on_board?(new_square) && !@board.same_player_on_square(new_square, @player)
  end

  def to_json(options = {})
    JSON.dump ({
      :player => @player,
      :name => @name,
      :current_square => @current_square,
      :first_move => @first_move
    })
  end
  
end