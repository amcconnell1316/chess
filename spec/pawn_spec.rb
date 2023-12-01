require_relative '../lib/pawn'
require_relative '../spec/chess_piece_spec'
require_relative '../lib/board'

describe Pawn do
  let(:board) { Board.new(true)}
  subject(:pawn) { board.add_piece('pawn', 'w', 'a2')}
  context 'fulfills the chess piece interface' do
    include_examples 'chess piece interface'
  end

  describe 'legal_move?' do
    context 'when player is white' do
    subject(:pawn) { board.add_piece('pawn', 'w', 'a2')}
      context 'when move is legal up' do
        it 'returns true' do
          result = subject.legal_move?('a3')
          expect(result).to be_truthy
        end
      end

      context 'when move is legal, first move two up' do
        it 'returns true' do
          result = subject.legal_move?('a4')
          expect(result).to be_truthy
        end
      end
      context 'when move is legal, diagonal with capture right' do
        before do
          board.add_piece('pawn', 'b', 'b3')
        end
        it 'returns false' do
          result = pawn.legal_move?('b3')
          expect(result).to be_truthy
        end
      end

      context 'when move is legal, diagonal with capture left' do
        subject(:pawn) { board.add_piece('pawn', 'w', 'g2')}
        before do
          board.add_piece('pawn', 'b', 'f3')
        end
        it 'returns true' do
          result = pawn.legal_move?('f3')
          expect(result).to be_truthy
        end
      end

      context 'when move is diagonal with same player' do
        subject(:pawn) { board.add_piece('pawn', 'w', 'g2')}
        before do
          board.add_piece('pawn', 'w', 'f3')
        end
        it 'returns false' do
          result = pawn.legal_move?('f3')
          expect(result).to be_falsey
        end
      end

      context 'when move is illegal, diagonal with no capture' do
        it 'returns false' do
          result = pawn.legal_move?('b3')
          expect(result).to be_falsey
        end
      end

      context 'when move is illegal, over' do
        it 'returns false' do
          result = pawn.legal_move?('b1')
          expect(result).to be_falsey
        end
      end
    end

    context 'when player is black' do
      subject(:pawn) { board.add_piece('pawn', 'b', 'a7')}
        context 'when move is legal up' do
          it 'returns true' do
            result = subject.legal_move?('a6')
            expect(result).to be_truthy
          end
        end
  
        context 'when move is legal, first move two up' do
          it 'returns true' do
            result = subject.legal_move?('a5')
            expect(result).to be_truthy
          end
        end

        context 'when move is illegal, second move two up' do
          it 'returns true' do
            subject.move('a6')
            result = subject.legal_move?('a4')
            expect(result).to be_falsey
          end
        end

        context 'when move is legal, diagonal with capture right' do
          before do
            board.add_piece('pawn', 'w', 'b6')
          end
          it 'returns true' do
            result = pawn.legal_move?('b6')
            expect(result).to be_truthy
          end
        end

        context 'when move is legal, diagonal with capture left' do
          subject(:pawn) { board.add_piece('pawn', 'b', 'g7')}
          before do
            board.add_piece('pawn', 'w', 'f6')
          end
          it 'returns true' do
            result = pawn.legal_move?('f6')
            expect(result).to be_truthy
          end
        end
  
        context 'when move is diagonal with no capture' do
          it 'returns false' do
            result = pawn.legal_move?('b6')
            expect(result).to be_falsey
          end
        end

        context 'when move is diagonal with same player' do
          subject(:pawn) { board.add_piece('pawn', 'b', 'g7')}
          before do
            board.add_piece('pawn', 'b', 'f6')
          end
          it 'returns false' do
            result = pawn.legal_move?('f6')
            expect(result).to be_falsey
          end
        end
  
        context 'when move is over' do
          it 'returns false' do
            result = pawn.legal_move?('b8')
            expect(result).to be_falsey
          end
        end
      end
  end

  describe 'possible moves' do
    let(:board_moves) { Board.new(true)}
    context 'when player is white' do
      subject(:pawn_moves) { board_moves.add_piece('pawn', 'w', 'd2')}
      context 'when first move' do
        it 'return two squares' do
          result = pawn_moves.possible_moves
          expect(result).to contain_exactly('d3', 'd4')
        end
      end

      context 'when second move' do
        it 'return one square' do
          pawn_moves.move('d4')
          result = pawn_moves.possible_moves
          expect(result).to contain_exactly('d5')
        end
      end

      context 'when forward is blocked by the same player' do
        before do
          board_moves.add_piece('pawn', 'w', 'd3')
        end
        it 'returns an empty array' do
          result = pawn_moves.possible_moves
          expect(result).to eq([])
        end
      end

      context 'when forward two is blocked by the same player' do
        before do
          board_moves.add_piece('pawn', 'w', 'd4')
        end
        it 'returns one square' do
          result = pawn_moves.possible_moves
          expect(result).to contain_exactly('d3')
        end
      end

      context 'when forward is blocked by the other player' do
        before do
          board_moves.add_piece('pawn', 'b', 'd3')
        end
        it 'returns an empty array' do
          result = pawn_moves.possible_moves
          expect(result).to eq([])
        end
      end

      context 'when forward two is blocked by the other player' do
        before do
          board_moves.add_piece('pawn', 'b', 'd4')
        end
        it 'returns one square' do
          result = pawn_moves.possible_moves
          expect(result).to contain_exactly('d3')
        end
      end

      context 'when there are moves that can capture' do
        before do
          board_moves.add_piece('pawn', 'b', 'c3')
          board_moves.add_piece('pawn', 'b', 'e3')
        end
        it 'returns four squares' do
          result = pawn_moves.possible_moves
          expect(result).to contain_exactly('c3', 'e3', 'd3', 'd4')
        end
      end
    end

    context 'when player is black' do
      subject(:pawn_moves) { board_moves.add_piece('pawn', 'b', 'd7')}
      context 'when first move' do
        it 'return two squares' do
          result = pawn_moves.possible_moves
          expect(result).to contain_exactly('d6', 'd5')
        end
      end

      context 'when second move' do
        it 'return one square' do
          pawn_moves.move('d5')
          result = pawn_moves.possible_moves
          expect(result).to contain_exactly('d4')
        end
      end

      context 'when forward is blocked by the same player' do
        before do
          board_moves.add_piece('pawn', 'b', 'd6')
        end
        it 'returns an empty array' do
          result = pawn_moves.possible_moves
          expect(result).to eq([])
        end
      end

      context 'when forward two is blocked by the same player' do
        before do
          board_moves.add_piece('pawn', 'b', 'd5')
        end
        it 'returns one square' do
          result = pawn_moves.possible_moves
          expect(result).to contain_exactly('d6')
        end
      end

      context 'when forward is blocked by the other player' do
        before do
          board_moves.add_piece('pawn', 'w', 'd6')
        end
        it 'returns an empty array' do
          result = pawn_moves.possible_moves
          expect(result).to eq([])
        end
      end

      context 'when forward two is blocked by the other player' do
        before do
          board_moves.add_piece('pawn', 'w', 'd5')
        end
        it 'returns one square' do
          result = pawn_moves.possible_moves
          expect(result).to contain_exactly('d6')
        end
      end

      context 'when there are moves that can capture' do
        before do
          board_moves.add_piece('pawn', 'w', 'c6')
          board_moves.add_piece('pawn', 'w', 'e6')
        end
        it 'returns four squares' do
          result = pawn_moves.possible_moves
          expect(result).to contain_exactly('c6', 'e6', 'd6', 'd5')
        end
      end
    end
  end
end