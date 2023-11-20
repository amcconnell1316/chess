require_relative '../lib/board.rb'

describe Board do

  describe 'play_move' do
    subject(:board) { described_class.new }
    context 'when move is a command' do
      it 'only calls execute_command' do
        allow
      end
    end
  end

  describe 'valid_move?' do
  end

  describe 'valid_command?' do
  end

  describe 'execute_command' do
  end

  describe 'valid_move_from?' do
  end

  describe 'valid_move_to?' do
  end

  describe 'valid_square?' do
  end

  describe 'change_player' do
  end

  describe 'current_player_name' do
  end

  describe 'game_over?' do
  end

  describe 'winner' do
  end

  describe 'check?' do
  end

  describe 'draw' do
  end

  describe 'only_kings' do
  end

end