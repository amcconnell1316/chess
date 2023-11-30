require_relative '../lib/bishop'
require_relative '../spec/chess_piece_spec'
require_relative '../lib/board'

describe Bishop do
  let(:board) { Board.new(true)}
  subject(:bishop) { board.add_piece('bishop', 'w', 'e4')}
  context 'fulfills the chess piece interface' do
    include_examples 'chess piece interface'
  end

  describe 'legal_move?' do
    context 'when move is legal up right' do
      it 'returns true' do
        result = bishop.legal_move?('g6')
        expect(result).to be_truthy
      end
    end

    context 'when move is legal up left' do
      it 'returns true' do
        result = bishop.legal_move?('c6')
        expect(result).to be_truthy
      end
    end

    context 'when move is legal down right' do
      it 'returns true' do
        result = bishop.legal_move?('g2')
        expect(result).to be_truthy
      end
    end

    context 'when move is legal up left' do
      it 'returns true' do
        result = bishop.legal_move?('c2')
        expect(result).to be_truthy
      end
    end

    context 'when move is illegal, across' do
      it 'returns false' do
        result = bishop.legal_move?('a4')
        expect(result).to be_falsey
      end
    end

    context 'when move is legal but blocked by same player, up right' do
      before do
        board.add_piece('bishop', 'w', 'f5')
      end
      it 'returns false' do
        result = bishop.legal_move?('g6')
        expect(result).to be_falsey
      end
    end
    context 'when move is legal but blocked by same player, down right' do
      before do
        board.add_piece('bishop', 'w', 'f3')
      end
      it 'returns false' do
        result = bishop.legal_move?('g2')
        expect(result).to be_falsey
      end
    end

    context 'when move is legal but blocked by opposite player, up left' do
      before do
        board.add_piece('bishop', 'b', 'd3')
      end
      it 'returns false' do
        result = bishop.legal_move?('c2')
        expect(result).to be_falsey
      end
    end

    context 'when move is legal and can capture' do
      before do
        board.add_piece('bishop', 'b', 'h7')
      end
      it 'returns false' do
        result = bishop.legal_move?('h7')
        expect(result).to be_truthy
      end
    end
  end

  describe 'possible moves' do
    let(:board_moves) { Board.new(true)}
    context 'when piece is in the corner' do
      subject(:bishop_moves) { board_moves.add_piece('bishop', 'b', 'a1')}
      it 'returns 7 squares' do
        result = bishop_moves.possible_moves
        expect(result).to contain_exactly('b2', 'c3', 'd4', 'e5', 'f6', 'g7', 'h8')
      end
    end

    context 'when piece is in the middle of the board' do
      subject(:bishop_moves) { board_moves.add_piece('bishop', 'b', 'e4')}
      it 'returns 13 square' do
        result = bishop_moves.possible_moves
        expect(result).to contain_exactly('b1', 'c2', 'd3', 'f5', 'g6', 'h7', 'f3', 'g2', 'h1', 'd5', 'c6', 'b7', 'a8')
      end
    end

    context 'when some squares blocked by same player' do
      subject(:bishop_moves) { board_moves.add_piece('bishop', 'b', 'e4')}
      before do
        board_moves.add_piece('bishop', 'b', 'c2')
        board_moves.add_piece('bishop', 'b', 'b7')
        board_moves.add_piece('bishop', 'b', 'g6')
        board_moves.add_piece('bishop', 'b', 'g2')
      end
      it 'returns five valid squares' do
        result = bishop_moves.possible_moves
        expect(result).to contain_exactly('d3', 'f5', 'f3', 'd5', 'c6')
      end
    end

    context 'when no moves are valid' do
      subject(:bishop_moves) { board_moves.add_piece('bishop', 'b', 'a1')}
      before do
        board_moves.add_piece('bishop', 'b', 'b2')
      end
      it 'returns an empty array' do
        result = bishop_moves.possible_moves
        expect(result).to eq([])
      end
    end

    context 'when there are moves that can capture' do
      subject(:bishop_moves) { board_moves.add_piece('bishop', 'b', 'e4')}
      before do
        board_moves.add_piece('bishop', 'w', 'c2')
        board_moves.add_piece('bishop', 'w', 'b7')
        board_moves.add_piece('bishop', 'w', 'g6')
        board_moves.add_piece('bishop', 'w', 'g2')
      end
      it 'returns nine valid squares' do
        result = bishop_moves.possible_moves
        expect(result).to contain_exactly('c2', 'd3', 'f5', 'g6', 'f3', 'g2', 'd5', 'c6', 'b7')
      end
    end
  end


end