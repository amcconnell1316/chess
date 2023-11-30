# frozen_string_literal: true

require_relative 'piece.rb'
require_relative 'king.rb'
# require_relative 'queen.rb'
require_relative 'rook.rb'
# require_relative 'knight.rb'
# require_relative 'bishop.rb'
# require_relative 'pawn.rb'

# This is a class for a chess board
class Board
  attr_reader :winner_name

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
    piece_to_capture = piece_on_square(move_arr[1])
    #capture opponent piece
    if !piece_to_capture.nil?
      puts "#{piece_to_capture.name} has been captured"
      remove_piece(move_arr[1])
    end
    #move piece to new square
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
    next_move_pieces.all? { | piece | piece.possible_moves.empty? }
  end

  def only_kings?
    return false if @white_pieces.length != 1 || @black_pieces != 1
    return true if @white_pieces[0].king? && @black_pieces[0].king?
    false
  end

  def row(square)
    square[1].to_i - 1
  end

  def col(square)
    square[0].downcase.ord - 97
  end

  def to_square(row, col)
    (col.to_i + 97).chr + (row.to_i + 1).to_s
  end

  def on_board?(row, col)
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

  def add_piece(piece, player, square)
    new_piece = nil
    case piece
      when 'king'
        piece = King.new(player, square, self)
        @white_king = piece if player == 'w'
        @black_king = piece if player == 'b'
      when 'rook'
        piece = Rook.new(player, square, self)
    end
    pieces_array =  player == 'w' ? @white_pieces : @black_pieces
    pieces_array << piece
    @spots[row(square)][col(square)] = piece
    piece
  end

  private

  def player_name(player)
    player == 'w' ? 'white' : 'black'
  end

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
    piece = @spots[row(old_square)][col(old_square)] 
    @spots[row(old_square)][col(old_square)] = nil
    @spots[row(new_square)][col(new_square)] = piece
    piece.move(new_square)
  end

  def display_spot(piece)
    piece.nil? ? ' ' : piece.display_chr
  end

  def setup_board
    @white_pieces << Rook.new('w', 'a1', self)
    @spots[0][0] = @white_pieces.last
    @white_pieces << Rook.new('w', 'h1', self)
    @spots[0][7] = @white_pieces.last
    # @white_pieces << Knight.new('w', 'b1')
    # @spots[0][1] = @white_pieces.last
    # @white_pieces << Knight.new('w', 'g1')
    # @spots[0][6] = @white_pieces.last
    # @white_pieces << Bishop.new('w', 'c1')
    # @spots[0][2] = @white_pieces.last
    # @white_pieces << Bishop.new('w', 'f1')
    # @spots[0][5] = @white_pieces.last
    # @white_pieces << Queen.new('w', 'd1')
    # @spots[0][3] = @white_pieces.last
    @white_pieces << King.new('w', 'e1', self)
    @spots[0][4] = @white_pieces.last
    @white_king = @white_pieces.last
    # 'abcdefgh'.each do | letter |
    #   @white_pieces << Pawn.new('w', letter + 2)
    #   @spots[0][col(letter)] = @white_pieces.last
    # end

    @black_pieces << Rook.new('b', 'a8', self)
    @spots[7][0] = @black_pieces.last
    @black_pieces << Rook.new('b', 'h8', self)
    @spots[7][7] = @black_pieces.last
    # @black_pieces << Knight.new('b', 'b8')
    # @spots[7][1] = @black_pieces.last
    # @black_pieces << Knight.new('b', 'g8')
    # @spots[7][6] = @black_pieces.last
    # @black_pieces << Bishop.new('b', 'c8')
    # @spots[7][2] = @black_pieces.last
    # @black_pieces << Bishop.new('b', 'f8')
    # @spots[7][5] = @black_pieces.last
    # @black_pieces << Queen.new('b', 'd8')
    # @spots[7][3] = @black_pieces.last
    @black_pieces << King.new('b', 'e8', self)
    @spots[7][4] = @black_pieces.last
    @black_king = @black_pieces.last
    # 'abcdefgh'.each do | letter |
    #   @black_pieces << Pawn.new('b', letter + 8)
    #   @spots[7][col(letter)] = @black_pieces.last
    # end
  end

  

  #todo en passant
  #todo promotion
  #todo castling

end
