require_relative '../lib/board.rb'

describe Board do

  #public
  describe 'play_move' do
    subject(:board_play) { Board.new(true)}

    context 'when a piece is captured' do
      before do
        board_play.add_piece('king', 'b', 'e8')
        board_play.add_piece('king', 'w', 'e1')
        board_play.add_piece('rook', 'w', 'a1')
        board_play.add_piece('rook', 'b', 'a8')
        board_play.change_player
      end
      it 'is removed from white or black pieces array' do
        expect {board_play.play_move('a1 a8')}.to change { board_play.instance_variable_get(:@black_pieces) }
      end
    end

    context 'when a piece is not captured' do
      before do
        board_play.add_piece('king', 'b', 'e8')
        board_play.add_piece('king', 'w', 'e1')
        board_play.add_piece('rook', 'w', 'a1')
        board_play.add_piece('rook', 'b', 'a8')
        board_play.change_player
      end
      it 'the white or black pieces array is not changed' do
        expect {board_play.play_move('a1 a7')}.to_not change { board_play.instance_variable_get(:@black_pieces) }
      end
    end

    context 'when a piece is moved' do
      let(:white_rook) { board_play.add_piece('rook', 'w', 'a1') }
      before do
        white_rook.name
        board_play.add_piece('king', 'b', 'e8')
        board_play.add_piece('king', 'w', 'e1')
        board_play.add_piece('rook', 'b', 'a8')
        board_play.change_player
      end
      it 'changes @spots' do
        expect {board_play.play_move('a1 a2')}.to change { board_play.instance_variable_get(:@spots) }
      end

      it 'updates current square for the piece' do
        expect {board_play.play_move('a1 a2')}.to change { white_rook.current_square }.from('a1').to('a2')
      end
    end

    context 'when castling white left rook' do
      let(:white_rook) { board_play.add_piece('rook', 'w', 'a1') }
      let(:white_king) { board_play.add_piece('king', 'w', 'e1') }
      before do
        white_rook.name
        white_king.name
        board_play.add_piece('king', 'b', 'e8')
        board_play.add_piece('rook', 'b', 'a8')
        board_play.change_player
      end

      it 'updates current square for the king' do
        expect {board_play.play_move('e1 c1')}.to change { white_king.current_square }.from('e1').to('c1')
      end
      it 'updates current square for the rook' do
        expect {board_play.play_move('e1 c1')}.to change { white_rook.current_square }.from('a1').to('d1')
      end
    end
  end

  #public
  describe 'valid_move?' do
    subject(:board_move) { Board.new(true)}
    before do
      board_move.add_piece('rook', 'w', 'a8')
      board_move.add_piece('king', 'b', 'e8')
      board_move.add_piece('king', 'w', 'e1')
    end
    
    context 'when from square is not on board' do
      it 'returns false' do
        result = board_move.valid_move?('z9 e7')
        expect(result).to eq(false)
      end
    end 
    
    context 'when to square is not on board' do
      it 'returns false' do
        result = board_move.valid_move?('e8 q0')
        expect(result).to eq(false)
      end
    end  

    context 'when there is no piece on from square' do
      it 'returns false' do
        result = board_move.valid_move?('d7 e7')
        expect(result).to eq(false)
      end
    end 

    context 'when piece on from square does not belong to the current player' do
      it 'returns false' do
        result = board_move.valid_move?('a8 a7')
        expect(result).to eq(false)
      end
    end 

    context 'when move is not valid for that piece' do
      it 'returns false' do
        result = board_move.valid_move?('e8 e6')
        expect(result).to eq(false)
      end
    end 

    context 'when kings valid move moves out of check' do  
      it 'returns true' do
        result = board_move.valid_move?('e8 e7')
        expect(result).to eq(true)
      end
    end

    context 'when kings valid move stays in check' do
      it 'returns false' do
        result = board_move.valid_move?('e8 d8')
        expect(result).to eq(false)
      end
    end
  end

  #public, script, test functions it calls
  describe 'game_over?' do
    context 'winner?' do
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
          result = board_winner.game_over?
          expect(result).to eq(true)
        end

        it 'updates winner name' do
          board_winner.game_over?
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
          result = board_winner.game_over?
          expect(result).to eq(false)
        end

        it 'does not update winner name' do
          board_winner.game_over?
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
          result = board_winner.game_over?
          expect(result).to eq(false)
        end

        it 'does not update winner name' do
          board_winner.game_over?
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
          result = board_winner.game_over?
          expect(result).to eq(false)
        end

        it 'does not update winner name' do
          board_winner.game_over?
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
          result = board_winner.game_over?
          expect(result).to eq(false)
        end

        it 'does not update winner name' do
          board_winner.game_over?
          expect(board_winner.winner_name).to eq(nil)
        end
      end
    end

    context 'draw?' do
      subject(:board_draw) { Board.new(true)}

      context 'when players manually said it was a draw' do
        before do
          board_draw.add_piece('rook', 'w', 'a1')
          board_draw.add_piece('king', 'w', 'e1')
          board_draw.add_piece('rook', 'b', 'a8')
          board_draw.add_piece('king', 'b', 'e8')
          board_draw.change_player
        end
        it 'returns true' do
          board_draw.play_move('draw')
          result = board_draw.game_over?
          expect(result).to eq(true)
        end
      end

      context 'when there are only kings left' do
        before do
          board_draw.add_piece('king', 'w', 'e1')
          board_draw.add_piece('king', 'b', 'e8')
          board_draw.change_player
        end
        it 'returns true' do
          result = board_draw.game_over?
          expect(result).to eq(true)
        end
      end

      context 'when there are no moves ' do
        before do
          board_draw.add_piece('king', 'w', 'e1')
          board_draw.add_piece('rook', 'w', 'g1')
          board_draw.add_piece('rook', 'w', 'a7')
          board_draw.add_piece('king', 'b', 'h8')
          board_draw.change_player
        end
        it 'returns true' do
          result = board_draw.game_over?
          expect(result).to eq(true)
        end
        it 'does not update winner name' do
          board_draw.game_over?
          expect(board_draw.winner_name).to eq(nil)
        end
      end
    end
  end

end