require_relative '../lib/queen'
require_relative '../spec/chess_piece_spec'
require_relative '../lib/board'

describe Queen do
  let(:board) { Board.new(true)}
  subject(:queen) { board.add_piece('queen', 'w', 'h8')}
  context 'fulfills the chess piece interface' do
    include_examples 'chess piece interface'
  end

  describe 'legal_move?' do
    context 'when move is legal down' do
      it 'returns true' do
        result = queen.legal_move?('h2')
        expect(result).to be_truthy
      end
    end

    context 'when move is legal across' do
      it 'returns true' do
        result = queen.legal_move?('d8')
        expect(result).to be_truthy
      end
    end

    context 'when move is legal up right' do
      subject(:queen) { board.add_piece('queen', 'w', 'e4')}
      it 'returns true' do
        result = queen.legal_move?('g6')
        expect(result).to be_truthy
      end
    end

    context 'when move is legal up left' do
      subject(:queen) { board.add_piece('queen', 'w', 'e4')}
      it 'returns true' do
        result = queen.legal_move?('c6')
        expect(result).to be_truthy
      end
    end

    context 'when move is legal down right' do
      subject(:queen) { board.add_piece('queen', 'w', 'e4')}
      it 'returns true' do
        result = queen.legal_move?('g2')
        expect(result).to be_truthy
      end
    end

    context 'when move is legal up left' do
      subject(:queen) { board.add_piece('queen', 'w', 'e4')}
      it 'returns true' do
        result = queen.legal_move?('c2')
        expect(result).to be_truthy
      end
    end

    context 'when move is illegal' do
      it 'returns false' do
        result = queen.legal_move?('f1')
        expect(result).to be_falsey
      end
    end

    context 'when move is legal but blocked by same player' do
      before do
        board.add_piece('queen', 'w', 'h5')
      end
      it 'returns false' do
        result = queen.legal_move?('h1')
        expect(result).to be_falsey
      end
    end

    context 'when move is legal but blocked by opposite player' do
      before do
        board.add_piece('queen', 'b', 'e8')
      end
      it 'returns false' do
        result = queen.legal_move?('a8')
        expect(result).to be_falsey
      end
    end

    context 'when move is legal and can capture' do
      before do
        board.add_piece('queen', 'b', 'e5')
      end
      it 'returns false' do
        result = queen.legal_move?('e5')
        expect(result).to be_truthy
      end
    end
  end

  describe 'possible moves' do
    let(:board_moves) { Board.new(true)}
    subject(:queen_moves) { board_moves.add_piece('queen', 'b', 'h8')}
    context 'when piece is in the corner' do
      it 'returns all 21 squares' do
        result = queen_moves.possible_moves
        expect(result).to contain_exactly('h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'h7', 'a8', 'b8', 'c8', 'd8', 'e8', 'f8', 'g8', 'g7', 'f6', 'e5', 'd4', 'c3', 'b2', 'a1')
      end
    end

    context 'when piece is in the middle of the board' do
      subject(:queen_moves) { board_moves.add_piece('queen', 'b', 'e4')}
      xit 'returns one square' do
        result = queen_moves.possible_moves
        expect(result).to contain_exactly('e1', 'e2', 'e3', 'e5', 'e6', 'e7', 'e8', 'a4', 'b4', 'c4', 'd4', 'f4', 'g4', 'h4')
      end
    end

    context 'when one direction is blocked' do
      before do
        board_moves.add_piece('queen', 'b', 'a2')
      end
      xit 'returns seven valid squares' do
        result = queen_moves.possible_moves
        expect(result).to contain_exactly('b1', 'c1', 'd1', 'e1', 'f1', 'g1', 'h1')
      end
    end

    context 'when no moves are valid' do
      before do
        board_moves.add_piece('queen', 'b', 'a2')
        board_moves.add_piece('queen', 'b', 'b1')
      end
      xit 'returns an empty array' do
        result = queen_moves.possible_moves
        expect(result).to eq([])
      end
    end

    context 'when there are moves that can capture' do
      before do
        board_moves.add_piece('queen', 'w', 'a2')
      end
      xit 'returns eight valid squares' do
        result = queen_moves.possible_moves
        expect(result).to contain_exactly('a2', 'b1', 'c1', 'd1', 'e1', 'f1', 'g1', 'h1')
      end
    end
  end


end