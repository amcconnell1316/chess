# frozen_string_literal: true

require_relative 'piece.rb'
require_relative 'king.rb'
require_relative 'queen.rb'
require_relative 'rook.rb'
require_relative 'knight.rb'
require_relative 'bishop.rb'
require_relative 'pawn.rb'

# This is a class for a chess board
class Board
  attr_reader :winner_name

  #public methods called by game
  def initialize(skip_setup = false)
    @spots = Array.new(8) { Array.new(8, nil) }
    @white_pieces = []
    @black_pieces = []
    @current_player = 'b' # this is switched to white before the first turn
    setup_board unless skip_setup
  end

  def play_move(move)
    if valid_command?(move)
      execute_command(move)
      return
    end

    #break move into from square and to square
    move_arr = move.split(' ')

    #check opponent piece in new square
    square_to_capture = en_passant_move?(move_arr[1], @current_player) ? en_passant_square(move_arr[1], @current_player) : move_arr[1]
    piece_to_capture = piece_on_square(square_to_capture)
    #capture opponent piece
    if !piece_to_capture.nil?
      puts "#{piece_to_capture.name} has been captured"
      remove_piece(square_to_capture)
    end
    #move piece to new square
    handle_castling(move_arr[0], move_arr[1])
    move_piece(move_arr[0], move_arr[1])
  end

  def valid_move?(move)
    return true if valid_command?(move)
    move_arr = move.split(' ')
    return false if move_arr[0].nil? || move_arr[1].nil?
    return false unless valid_move_from?(move_arr[0])
    return false unless valid_move_to?(move_arr)
    !possible_move_check?(@current_player == 'w' ? 'b' : 'w', piece_on_square(move_arr[0]), move_arr[1])
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
      row_string = "#{8 - i}|"
      row.each do |piece|
        row_string += display_spot(piece)
        row_string += '|'
      end
      puts row_string
    end
    puts '  ―――――――――――――――'
  end

  def game_over?
    winner? || draw?
  end

  def to_json
    JSON.dump ({
      :current_player => @current_player,
      :en_passant_w => @en_passant_w,
      :en_passant_b => @en_passant_b,
      :black_pieces => @black_pieces,
      :white_pieces => @white_pieces
    })
  end

  def self.from_json(string)
    data = JSON.load string
    saved_board = self.new(true)
    other_player = data['current_player'] == 'w' ? 'b' : 'w' #player will get changed on first turn
    saved_board.instance_variable_set(:@current_player, other_player)
    saved_board.instance_variable_set(:@en_passant_b, data['en_passant_b'])
    saved_board.instance_variable_set(:@en_passant_w, data['en_passant_w'])
    data['black_pieces'].each do | piece_data |
      piece = saved_board.add_piece(piece_data['name'], piece_data['player'], piece_data['current_square'])
      piece.instance_variable_set(:@first_move, piece_data['first_move']) 
    end
    data['white_pieces'].each do | piece_data |
      piece = saved_board.add_piece(piece_data['name'], piece_data['player'], piece_data['current_square'])
      piece.instance_variable_set(:@first_move, piece_data['first_move']) 
    end
    saved_board
  end

  #public methods called by the pieces
  def row(square)
    square[1].to_i - 1
  end

  def col(square)
    square[0].downcase.ord - 97
  end

  def to_square(row, col)
    (col.to_i + 97).chr + (row.to_i + 1).to_s
  end

  def on_board?(square)
    row = row(square)
    col = col(square)
    row >= 0 && row < 8  && col >= 0 && col < 8
  end

  def piece_on_square(square)
    #handle pretending a piece has been moved to check for checkmate
    return nil if square == @old_square
    return @spots[row(@old_square)][col(@old_square)] if square == @new_square

    @spots[row(square)][col(square)]
  end

  def same_player_on_square(square, player)
    piece_on_square = piece_on_square(square)
    return false if piece_on_square.nil?
    piece_on_square.player == player
  end

  def other_player_on_square(square, player)
    piece_on_square = piece_on_square(square)
    return false if piece_on_square.nil?
    piece_on_square.player != player
  end

  def add_piece(piece, player, square)
    new_piece = nil
    case piece
      when 'king'
        piece = King.new(player, square, self)
        @white_king = piece if player == 'w'
        @black_king = piece if player == 'b'
      when 'rook'
        piece = Rook.new(player, square, self)
      when 'bishop'
        piece = Bishop.new(player, square, self)
      when 'knight'
        piece = Knight.new(player, square, self)
      when 'queen'
        piece = Queen.new(player, square, self)
      when 'pawn'
        piece = Pawn.new(player, square, self)
    end
    pieces_array =  player == 'w' ? @white_pieces : @black_pieces
    pieces_array << piece
    @spots[row(square)][col(square)] = piece
    piece
  end

  def en_passant_move?(square, player)
    ep_square = en_passant_square(square, player)
    piece = piece_on_square(ep_square) if on_board?(ep_square)
    !piece.nil? && piece == (player == 'w' ? @en_passant_b : @en_passant_w)
  end

  def en_passant_square(square, player)
    if player == 'w'
      ep_row = row(square) - 1
    else
      ep_row = row(square) + 1
    end

    to_square(ep_row, col(square))
  end

  def castling_legal?(player, new_square)
    king = player == 'w' ? @white_king : @black_king
    rook = castling_rook(king, player, new_square)
    return false if rook.nil?
    return false unless rook.first_move && king.first_move

    #no pieces between king and rook
    return false if rook.blocked?(king.current_square)

    #king cannot be in check and the square it moves through cannot be attacked
    checking_player = player == 'w' ? 'b' : 'w'
    new_rook_square = castling_rook_new_square(king, new_square)
    return false if check?(checking_player)
    !possible_move_check?(checking_player, king, new_rook_square)
  end

  private

  # methods for validating moves
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
    return false unless valid_square?(move_arr[1])

    moving_piece = piece_on_square(move_arr[0])

    moving_piece.legal_move?(move_arr[1])
  end

  def valid_square?(square_string)
    square_string.downcase.match(/^[abcdefgh][12345678]$/)
  end

  # methods for validating check and checkmate
  def winner?
    #check for check
    check_mate = false
    if check?
      puts "Check!"
      checked_pieces = @current_player == 'b' ? @white_pieces : @black_pieces
      check_mate = checked_pieces.all? do | piece |
        possible_moves = piece.possible_moves
        possible_moves.all? do | square |
          possible_move_check?(@current_player, piece, square)
        end
      end
    end
    #check each of king's possible moves for check
    @winner_name = check_mate ? current_player_name : nil
    check_mate
  end

  def possible_move_check?(checking_player, piece, square)
    @captured_piece = piece_on_square(square)
    @old_square = piece.current_square
    @new_square = square 
    ret_val = piece.king? ? check?(checking_player, square) : check?(checking_player)
    @old_square = nil
    @new_square = nil
    @captured_piece = nil
    ret_val
  end

  def check?(checking_player = @current_player, king_square = nil)

    king_in_check = checking_player == 'w' ? @black_king : @white_king
    king_square = king_in_check.current_square if king_square.nil?

    checking_pieces = checking_player == 'w' ? @white_pieces : @black_pieces
    checking_pieces.any? do | piece | 
      next if piece == @captured_piece
      piece.legal_move?(king_square)
    end
  end

  def draw?
    return true if @draw
    return true if only_kings?
    next_move_pieces = @current_player == 'w' ? @black_pieces : @white_pieces
    next_move_pieces.all? do | piece |
      moves = piece.possible_moves
      return false if moves.empty?
      moves.all? { |move| possible_move_check?(@current_player, piece, move)}
    end
  end

  def only_kings?
    return false if @white_pieces.length != 1 || @black_pieces.length != 1
    @white_pieces[0].king? && @black_pieces[0].king?
  end
  
  def player_name(player)
    player == 'w' ? 'white' : 'black'
  end

  # methods for handing @spots
  def remove_piece(square)
    piece = @spots[row(square)][col(square)]

    if piece.player == 'w'
      index = @white_pieces.find_index(piece)
      @white_pieces.slice!(index)
    else
      index = @black_pieces.find_index(piece)
      @black_pieces.slice!(index)
    end

    @spots[row(square)][col(square)] = nil
  end

  def move_piece(old_square, new_square)
    piece = piece_on_square(old_square)

    #en passant
    if piece.is_a?(Pawn)
      if @current_player == 'w'
        promotion = row(new_square) == 7
        @en_passant_w = piece if (row(old_square) - row(new_square)).abs == 2
      else
        promotion = row(new_square) == 0
        @en_passant_b = piece if (row(old_square) - row(new_square)).abs == 2
      end
    else
      if @current_player == 'w'
        @en_passant_w = nil
      else
        @en_passant_b = nil
      end
    end

    @spots[row(old_square)][col(old_square)] = nil

    if promotion 
      add_piece('queen', @current_player, new_square)
    else
      @spots[row(new_square)][col(new_square)] = piece
      piece.move(new_square)
    end
  end

  def handle_castling(old_square, new_square)
    return unless castling?(old_square, new_square)

    king = @current_player == 'w' ? @white_king : @black_king
    rook = castling_rook(king, @current_player, new_square)
    new_rook_square = castling_rook_new_square(king, new_square)
    move_piece(rook.current_square, new_rook_square)
  end

  def castling?(old_square, new_square)
    piece = piece_on_square(old_square)
    return false if piece.nil? || !piece.king?
    current_col = col(old_square)
    new_col = col(new_square)
    (current_col - new_col).abs == 2
  end

  def castling_rook(king, player, new_king_square)
    current_col = col(king.current_square)
    new_col = col(new_king_square)
    direction = current_col > new_col ? 'left' : 'right'
    rook_col = direction == 'left' ? 0 : 7
    rook_row = player == 'w' ? 0 : 7
    rook = piece_on_square(to_square(rook_row, rook_col))
    return nil if rook.nil?
    rook.name == 'rook' ? rook : nil
  end

  def castling_rook_new_square(king, new_square)
    current_col = col(king.current_square)
    new_king_col = col(new_square)
    row = row(new_square)
    new_rook_col = current_col > new_king_col ? current_col - 1 : current_col + 1
    new_rook_square = to_square(row, new_rook_col)
  end

  def display_spot(piece)
    piece.nil? ? ' ' : piece.display_chr
  end

  def setup_board
    @white_pieces << Rook.new('w', 'a1', self)
    @spots[0][0] = @white_pieces.last
    @white_pieces << Rook.new('w', 'h1', self)
    @spots[0][7] = @white_pieces.last
    @white_pieces << Knight.new('w', 'b1', self)
    @spots[0][1] = @white_pieces.last
    @white_pieces << Knight.new('w', 'g1', self)
    @spots[0][6] = @white_pieces.last
    @white_pieces << Bishop.new('w', 'c1', self)
    @spots[0][2] = @white_pieces.last
    @white_pieces << Bishop.new('w', 'f1', self)
    @spots[0][5] = @white_pieces.last
    @white_pieces << Queen.new('w', 'd1', self)
    @spots[0][3] = @white_pieces.last
    @white_pieces << King.new('w', 'e1', self)
    @spots[0][4] = @white_pieces.last
    @white_king = @white_pieces.last
    ['a','b','c','d','e','f','g','h'].each do | letter |
      @white_pieces << Pawn.new('w', letter + '2', self)
      @spots[1][col(letter)] = @white_pieces.last
    end

    @black_pieces << Rook.new('b', 'a8', self)
    @spots[7][0] = @black_pieces.last
    @black_pieces << Rook.new('b', 'h8', self)
    @spots[7][7] = @black_pieces.last
    @black_pieces << Knight.new('b', 'b8', self)
    @spots[7][1] = @black_pieces.last
    @black_pieces << Knight.new('b', 'g8', self)
    @spots[7][6] = @black_pieces.last
    @black_pieces << Bishop.new('b', 'c8', self)
    @spots[7][2] = @black_pieces.last
    @black_pieces << Bishop.new('b', 'f8', self)
    @spots[7][5] = @black_pieces.last
    @black_pieces << Queen.new('b', 'd8', self)
    @spots[7][3] = @black_pieces.last
    @black_pieces << King.new('b', 'e8', self)
    @spots[7][4] = @black_pieces.last
    @black_king = @black_pieces.last
    ['a','b','c','d','e','f','g','h'].each do | letter |
      @black_pieces << Pawn.new('b', letter + '7', self)
      @spots[6][col(letter)] = @black_pieces.last
    end
  end
end
