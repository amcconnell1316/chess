# frozen_string_literal: true

# This is a class for a chess board
class Board
  def initialize
    @spots = Array.new(8) { Array.new(8, nil) }
    @current_player = 'b' # this is switched to white before the first turn
    setup_board
  end

  def play_move(move)
    if valid_command?(move)
      execute_command(move)
      return
    end

    #break move into from square and to square
    move_arr = move.split(' ')
    #remove piece from that square
    moving_piece = piece_on_square(move_arr[0])
    remove_piece(move_arr[0])
    #check opponent piece in new square
    piece_to_capture = piece_on_square(move_arr[1])
    #capture opponent piece
    if !piece_to_capture.nil?
      puts "#{piece_to_capture.name} has been captured"
      remove_piece(move_arr[1])
    end
    #move piece to new square
    move_piece(move_arr[1], moving_piece)
  end

  def valid_move?(move)
    return true if valid_command?(move)
    move_arr = move.split(' ')
    return false if !valid_move_from?(move_arr[0])
    valid_move_to?(move_arr)
  end

  def valid_command?(string)
    return true if string == 'draw'
    false
  end

  def execute_command(string)
    @draw = true if string == 'draw'
  end

  def valid_move_from?(square_string)
    return false unless valid_square?(square_string)

    moving_piece = piece_on_square(square_string)
    return false if moving_piece.nil?

    moving_piece.player == @current_player
  end

  def valid_move_to?(move_arr)
    return false unless valid_square(move_arr[1])

    moving_piece = piece_on_square(move_arr[0])
    return false if !moving_piece.valid_move?(move_arr)

    blocking_squares = moving_piece.blocking_squares(move_arr)

    blocking_squares.each { |square| return false if !piece_on_square(square).nil? }

    piece_on_landing_square = piece_on_square(move_arr[1])
    return true if piece_on_landing_square.nil?
    piece_on_landing_square.player != @current_player
  end

  def valid_square?(square_string)
    square_string.downcase.match(/^[abcdefgh][12345678]$/)
  end

  def change_player
    @current_player = (@current_player == 'w' ? 'b' : 'w')
  end

  def current_player_name
    player_name(@current_player)
  end

  def print_board
    puts '  a b c d e f g h'
    puts '  ―――――――――――――――'
    @spots.reverse.each_with_index do |row, i|
      row_string = "#{i + 1}|"
      row.each do |piece|
        row_string += display_spot(piece)
        row_string += '|'
      end
      puts row_string
    end
    puts '  ―――――――――――――――'
  end

  def game_over?
    !winner.nil? || draw?
  end

  def winner
    #check for check
    check_mate = false
    if check?
      king_moves = king_in_check.possible_moves
      check_mate = king_moves.all? { | square | check?(square) }
    end
    #check each of king's possible moves for check
    check_mate ? current_player_name : nil
  end

  def check?(king_square = nil)
    king_square = king_in_check.current_square
    checking_pieces = @current_player == 'w' ? @white_pieces : @black_pieces
    checking_pieces.any? { | piece | piece.can_capture(king_square) && !piece.king? }
  end

  def draw?
    return true if @draw
    return true if only_kings?
    next_move_pieces = @current_player == 'w' ? @black_pieces : @white_pieces
    !next_move_pieces.any? { | piece | piece.has_legal_move }
  end

  def only_kings
    return false if @white_pieces.length != 1 || @black_pieces != 1
    return true if @white_pieces[0].is_king && @black_pieces[0].is_king
    false
  end

  private

  def player_name(player)
    player == 'w' ? 'white' : 'black'
  end

  def remove_piece(square)
    @spots[row(square)][col(square)] = nil
    #remove piece from saved array of pieces
  end

  def move_piece(square, piece)
    @spots[row(square)][col(square)] = piece
    piece.location = square
  end

  def display_spot(piece)
    piece.nil? ? ' ' : piece.display
  end

  def row(square)
    square[1].to_i - 1
  end

  def col(square)
    square[0].downcase.ord - 97
  end

  def piece_on_square(square)
    @spots[row(square)][col(square)]
  end

  def king_in_check
    @current_player == 'w' ? @black_king : @white_king
  end

  def setup_board
    @white_pieces << Rook.new('w')
    move_piece('a1', @white_pieces.last)
    @white_pieces << Rook.new('w')
    move_piece('h1', @white_pieces.last)
    @white_pieces << Knight.new('w')
    move_piece('b1', @white_pieces.last)
    @white_pieces << Knight.new('w')
    move_piece('g1', @white_pieces.last)
    @white_pieces << Bishop.new('w')
    move_piece('c1', @white_pieces.last)
    @white_pieces << Bishop.new('w')
    move_piece('f1', @white_pieces.last)
    @white_pieces << Queen.new('w')
    move_piece('d1', @white_pieces.last)
    @white_pieces << King.new('w')
    move_piece('e1', @white_pieces.last)
    @white_king = @white_pieces.last
    'abcdefgh'.each do | letter |
      @white_pieces << Pawn.new('w')
      move_piece(letter + 2, @white_pieces.last)
    end

    @black_pieces << Rook.new('b')
    move_piece('a8', @black_pieces.last)
    @black_pieces << Rook.new('b')
    move_piece('h8', @black_pieces.last)
    @black_pieces << Knight.new('b')
    move_piece('b8', @black_pieces.last)
    @black_pieces << Knight.new('b')
    move_piece('g8', @black_pieces.last)
    @black_pieces << Bishop.new('b')
    move_piece('c8', @black_pieces.last)
    @black_pieces << Bishop.new('b')
    move_piece('f8', @black_pieces.last)
    @black_pieces << Queen.new('b')
    move_piece('d8', @black_pieces.last)
    @black_pieces << King.new('b')
    move_piece('e8', @black_pieces.last)
    @black_king = @black_pieces.last
    'abcdefgh'.each do | letter |
      @black_pieces << Pawn.new('b')
      move_piece(letter + 7, @black_pieces.last)
    end
  end

  

  #todo en passant
  #todo promotion
  #todo castling

end
