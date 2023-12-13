# frozen_string_literal: true

require_relative 'board'
require 'json'

class Game 
  def initialize(board = Board.new)
    @board = board
  end

  def play
    puts 'Welcome to chess!'
    choice = File.file?("saved_games/game_last.json") ? initial_menu : 'new'
    @board = load_game if choice == 'saved'

    take_turn until @board.game_over? || @save

    if @save
      save_game
    else
      winner = @board.winner_name
      puts winner.nil? ? "It's a tie!" : "Congratulations player #{winner}! You win!"
    end
  end

  def take_turn
    @board.change_player
    @board.print_board
    puts "Player #{@board.current_player_name}'s turn: "  
    move = player_input
    if move == 'save'
      @save = true
    else
      @board.play_move(move)     
    end
  end

  def player_input
    move = ""
    loop do
      move = gets.chomp.downcase
      break if move == 'save'
      break if @board.valid_move?(move)

      puts "That's not a valid move. Specify square you are moving from and square you are moving to."
    end
    move
  end

  def initial_menu
    puts 'Do you want to open saved game or play new game?'
    choice = 'new'
    loop do
      choice = gets.chomp.downcase
      break if choice == 'saved'
      break if choice == 'new'

      puts 'Enter saved or new'
    end
    choice
  end

  def save_game
    Dir.mkdir('saved_games') unless Dir.exist?('saved_games')

    filename = "saved_games/game_last.json"

    File.open(filename, 'w') do |file|
      file.puts @board.to_json
    end  
  end

  def load_game
    filename = "saved_games/game_last.json"

    file = File.open(filename, 'r') 
    string = file.read.chomp
    file.close
    Board.from_json(string)
  end
end

Game.new.play

