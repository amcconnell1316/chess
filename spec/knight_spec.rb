require_relative '../lib/knight'
require_relative '../spec/chess_piece_spec'
require_relative '../lib/board'

describe Knight do
  let(:board) { Board.new(true)}
  subject(:knight) { board.add_piece('knight', 'w', 'a1')}
  context 'fulfills the chess piece interface' do
    include_examples 'chess piece interface'
  end

  describe 'legal_move?' do
    context 'when move is legal' do
      it 'returns true' do
        result = subject.legal_move?('b3')
        expect(result).to be_truthy
      end
    end

    context 'when move is illegal' do
      it 'returns false' do
        result = knight.legal_move?('c1')
        expect(result).to be_falsey
      end
    end
  end

  describe 'possible_moves' do
    let(:board_moves) { Board.new(true)}
    subject(:knight_moves) { board_moves.add_piece('knight', 'b', 'e4')}
    context 'when all moves are valid' do
      it 'returns the all eight squares' do
        result = knight_moves.possible_moves
        expect(result).to contain_exactly('c3', 'c5', 'd6', 'd2', 'f2', 'f6', 'g5', 'g3')
      end
    end

    context 'when some moves is valid and rest off board' do
      subject(:knight_moves) { board_moves.add_piece('knight', 'b', 'a1')}
      it 'returns two squares' do
        result = knight_moves.possible_moves
        expect(result).to contain_exactly('b3', 'c2')
      end
    end

    context 'when one move is valid and one has a blocking piece' do
      subject(:knight_moves) { board_moves.add_piece('knight', 'b', 'a1')}
      before do
        board_moves.add_piece('rook', 'b', 'b3')
      end
      it 'returns one square' do
        result = knight_moves.possible_moves
        expect(result).to contain_exactly('c2')
      end
    end

    context 'when no moves are valid' do
      subject(:knight_moves) { board_moves.add_piece('knight', 'b', 'h1')}
      before do
        board_moves.add_piece('rook', 'b', 'f2')
        board_moves.add_piece('rook', 'b', 'g3')
      end
      it 'returns an empty array' do
        result = knight_moves.possible_moves
        expect(result).to eq([])
      end
    end

    context 'when there are moves that can capture' do
      subject(:knight_moves) { board_moves.add_piece('knight', 'b', 'h1')}
      before do
        board_moves.add_piece('rook', 'w', 'f2')
        board_moves.add_piece('rook', 'b', 'g3')
      end
      it 'returns one squre' do
        result = knight_moves.possible_moves
        expect(result).to contain_exactly('f2')
      end
    end

  end


end