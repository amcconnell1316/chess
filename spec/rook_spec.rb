require_relative '../lib/rook'
require_relative '../spec/chess_piece_spec'
require_relative '../lib/board'

describe Rook do
  let(:board) { Board.new(true)}
  subject(:rook) { board.add_piece('rook', 'w', 'a1')}
  context 'fulfills the chess piece interface' do
    include_examples 'chess piece interface'
  end

  describe 'legal_move?' do
    context 'when move is legal up' do
      it 'returns true' do
        result = rook.legal_move?('a2')
        expect(result).to be_truthy
      end
    end

    context 'when move is legal across' do
      it 'returns true' do
        result = rook.legal_move?('d1')
        expect(result).to be_truthy
      end
    end

    context 'when move is illegal, diagonal' do
      it 'returns false' do
        result = rook.legal_move?('c2')
        expect(result).to be_falsey
      end
    end

    context 'when move is legal but blocked by same player' do
      before do
        board.add_piece('rook', 'w', 'b1')
      end
      it 'returns false' do
        result = rook.legal_move?('d1')
        expect(result).to be_falsey
      end
    end

    context 'when move is legal but blocked by opposite player' do
      before do
        board.add_piece('rook', 'b', 'b1')
      end
      it 'returns false' do
        result = rook.legal_move?('d1')
        expect(result).to be_falsey
      end
    end

    context 'when move is legal and can capture' do
      before do
        board.add_piece('rook', 'b', 'd1')
      end
      it 'returns false' do
        result = rook.legal_move?('d1')
        expect(result).to be_truthy
      end
    end
  end

  describe 'possible moves' do
    let(:board_moves) { Board.new(true)}
    subject(:rook_moves) { board_moves.add_piece('rook', 'b', 'a1')}
    context 'when piece is in the corner' do
      it 'returns all 14 squares' do
        result = rook_moves.possible_moves
        expect(result).to contain_exactly('a2', 'a3', 'a4', 'a5', 'a6', 'a7', 'a8', 'b1', 'c1', 'd1', 'e1', 'f1', 'g1', 'h1')
      end
    end

    context 'when piece is in the middle of the board' do
      subject(:rook_moves) { board_moves.add_piece('rook', 'b', 'e4')}
      it 'returns one square' do
        result = rook_moves.possible_moves
        expect(result).to contain_exactly('e1', 'e2', 'e3', 'e5', 'e6', 'e7', 'e8', 'a4', 'b4', 'c4', 'd4', 'f4', 'g4', 'h4')
      end
    end

    context 'when one direction is blocked' do
      before do
        board_moves.add_piece('rook', 'b', 'a2')
      end
      it 'returns seven valid squares' do
        result = rook_moves.possible_moves
        expect(result).to contain_exactly('b1', 'c1', 'd1', 'e1', 'f1', 'g1', 'h1')
      end
    end

    context 'when no moves are valid' do
      before do
        board_moves.add_piece('rook', 'b', 'a2')
        board_moves.add_piece('rook', 'b', 'b1')
      end
      it 'returns an empty array' do
        result = rook_moves.possible_moves
        expect(result).to eq([])
      end
    end

    context 'when there are moves that can capture' do
      before do
        board_moves.add_piece('rook', 'w', 'a2')
      end
      it 'returns eight valid squares' do
        result = rook_moves.possible_moves
        expect(result).to contain_exactly('a2', 'b1', 'c1', 'd1', 'e1', 'f1', 'g1', 'h1')
      end
    end
  end


end