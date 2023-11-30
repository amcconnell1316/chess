require_relative '../lib/board.rb'

describe Board do

  describe 'play_move' do
  end

  describe 'valid_move?' do
    subject(:board_move) { Board.new(true)}
    
    context 'when kings valid move stays in check' do
      before do
        board_move.add_piece('rook', 'w', 'a8')
        board_move.add_piece('king', 'b', 'e8')
        board_move.add_piece('king', 'w', 'e1')
      end
      it 'returns false' do
        result = board_move.valid_move?('e8 d8')
        expect(result).to eq(false)
      end
    end
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
    subject(:board_winner) { Board.new(true)}
    
    context 'when king is in check with no possible moves' do
      before do
        board_winner.add_piece('rook', 'w', 'a8')
        board_winner.add_piece('rook', 'w', 'h7')
        board_winner.add_piece('king', 'b', 'e8')
        board_winner.add_piece('king', 'w', 'e1')
        board_winner.change_player
      end
      it 'returns true' do
        result = board_winner.winner?
        expect(result).to eq(true)
      end

      it 'updates winner name' do
        board_winner.winner?
        expect(board_winner.winner_name).to eq("white")
      end
    end

    context 'when king is in check but can move away' do
      before do
        board_winner.add_piece('rook', 'w', 'a8')
        board_winner.add_piece('king', 'b', 'e8')
        board_winner.add_piece('king', 'w', 'e1')
        board_winner.change_player
      end
      it 'returns false' do
        result = board_winner.winner?
        expect(result).to eq(false)
      end

      it 'does not update winner name' do
        board_winner.winner?
        expect(board_winner.winner_name).to eq(nil)
      end
    end

    context 'when king is in check but can capture and move away' do
      before do
        board_winner.add_piece('rook', 'w', 'a8')
        board_winner.add_piece('rook', 'w', 'e7')
        board_winner.add_piece('king', 'b', 'e8')
        board_winner.add_piece('king', 'w', 'e1')
        board_winner.change_player
      end
      it 'returns false' do
        result = board_winner.winner?
        expect(result).to eq(false)
      end

      it 'does not update winner name' do
        board_winner.winner?
        expect(board_winner.winner_name).to eq(nil)
      end
    end

    context 'when king is in check but can capture' do
      before do
        board_winner.add_piece('rook', 'w', 'd8')
        board_winner.add_piece('rook', 'w', 'h7')
        board_winner.add_piece('king', 'b', 'e8')
        board_winner.add_piece('king', 'w', 'e1')
        board_winner.change_player
      end
      it 'returns false' do
        result = board_winner.winner?
        expect(result).to eq(false)
      end

      it 'does not update winner name' do
        board_winner.winner?
        expect(board_winner.winner_name).to eq(nil)
      end
    end

    context 'when king is in check but another piece can capture' do
      before do
        board_winner.add_piece('rook', 'w', 'a8')
        board_winner.add_piece('rook', 'w', 'h7')
        board_winner.add_piece('king', 'b', 'e8')
        board_winner.add_piece('rook', 'b', 'a1')
        board_winner.add_piece('king', 'w', 'e1')
        board_winner.change_player
      end
      it 'returns false' do
        result = board_winner.winner?
        expect(result).to eq(false)
      end

      it 'does not update winner name' do
        board_winner.winner?
        expect(board_winner.winner_name).to eq(nil)
      end
    end
  end

  describe 'check?' do
  end

  describe 'draw' do
  end

  describe 'only_kings' do
  end

end