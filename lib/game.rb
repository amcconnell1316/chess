# frozen_string_literal: true

require_relative 'board'

class Game 
  def initialize(board = Board.new)
    @board = board
  end

  def play
    puts 'Welcome to chess!'
    take_turn until @board.game_over?
    winner = @board.winner_name
    puts winner.nil? ? "It's a tie!" : "Congratulations player #{winner}! You win!"
  end

  def take_turn
    @board.change_player
    @board.print_board
    puts "Player #{@board.current_player_name}'s turn: "  
    move = player_input
    @board.play_move(move)     
  end

  def player_input
    move = ""
    loop do
      move = gets.chomp
      break if @board.valid_move?(move)

      puts "That's not a valid move. Specify square you are moving from and square you are moving to."
    end
    move
  end
end

Game.new.play

