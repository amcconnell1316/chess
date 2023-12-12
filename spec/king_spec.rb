require_relative '../lib/king'
require_relative '../spec/chess_piece_spec'
require_relative '../lib/board'

describe King do
  let(:board) { Board.new(true)}
  subject(:king) { board.add_piece('king', 'w', 'a1')}
  context 'fulfills the chess piece interface' do
    include_examples 'chess piece interface'
  end

  describe 'legal_move?' do
    context 'when move is legal up' do
      it 'returns true' do
        result = subject.legal_move?('a2')
        expect(result).to be_truthy
      end
    end

    context 'when move is illegal, two squares over' do
      it 'returns false' do
        result = king.legal_move?('c1')
        expect(result).to be_falsey
      end
    end

    context 'when move is legal, castling' do
      let(:board) { Board.new(true)}
      subject(:king) { board.add_piece('king', 'w', 'e1')}

      before do
        king.name
        board.add_piece('rook', 'w', 'h1')
        board.change_player
      end

      it 'returns true' do
        result = subject.legal_move?('g1')
        expect(result).to be_truthy
      end
    end

    context 'when move is not legal, castling, rook has moved' do
      let(:board) { Board.new(true)}
      subject(:king) { board.add_piece('king', 'w', 'e1')}

      before do
        king.name
        board.add_piece('rook', 'w', 'h2')
        board.change_player
        board.play_move('h2 h1')
      end

      it 'returns false' do
        result = subject.legal_move?('g1')
        expect(result).to be_falsey
      end
    end

    context 'when move is not legal, castling, king has moved' do
      let(:board) { Board.new(true)}
      subject(:king) { board.add_piece('king', 'w', 'd1')}

      before do
        king.name
        board.add_piece('rook', 'w', 'h1')
        board.change_player
        board.play_move('d1 e1')
      end

      it 'returns false' do
        result = subject.legal_move?('g1')
        expect(result).to be_falsey
      end
    end

    context 'when move is not legal, castling, piece blocking' do
      let(:board) { Board.new(true)}
      subject(:king) { board.add_piece('king', 'w', 'e1')}

      before do
        king.name
        board.add_piece('rook', 'w', 'h1')
        board.add_piece('bishop', 'w', 'f1')
        board.change_player
      end

      it 'returns false' do
        result = subject.legal_move?('g1')
        expect(result).to be_falsey
      end
    end

    context 'when move is not legal, castling, king was in check' do
      let(:board) { Board.new(true)}
      subject(:king) { board.add_piece('king', 'w', 'e1')}

      before do
        king.name
        board.add_piece('rook', 'w', 'h1')
        board.add_piece('bishop', 'b', 'c3')
        board.change_player
      end

      it 'returns false' do
        result = subject.legal_move?('g1')
        expect(result).to be_falsey
      end
    end

    context 'when move is not legal, castling, passed over square was under attck' do
      let(:board) { Board.new(true)}
      subject(:king) { board.add_piece('king', 'w', 'e1')}

      before do
        king.name
        board.add_piece('rook', 'w', 'h1')
        board.add_piece('bishop', 'b', 'd3')
        board.change_player
      end

      it 'returns false' do
        result = subject.legal_move?('g1')
        expect(result).to be_falsey
      end
    end
  end

  describe 'possible moves' do
    let(:board_moves) { Board.new(true)}
    subject(:king_moves) { board_moves.add_piece('king', 'b', 'b5')}
    context 'when all moves are valid' do
      it 'returns the all eight squares' do
        result = king_moves.possible_moves
        expect(result).to contain_exactly('a6', 'b6', 'c6', 'c5', 'a5', 'a4', 'b4', 'c4')
      end
    end

    context 'when some moves is valid and rest off board' do
      subject(:king_moves) { board_moves.add_piece('king', 'b', 'a8')}
      it 'returns some squares' do
        result = king_moves.possible_moves
        expect(result).to contain_exactly('b8', 'a7', 'b7')
      end
    end

    context 'when most moves are valid and one has a blocking piece' do
      subject(:king_moves) { board_moves.add_piece('king', 'b', 'b5')}
      before do
        board_moves.add_piece('rook', 'b', 'b4')
      end
      it 'returns one square' do
        result = king_moves.possible_moves
        expect(result).to contain_exactly('a6', 'b6', 'c6', 'c5', 'a5', 'a4', 'c4')
      end
    end

    context 'when no moves are valid' do
      subject(:king_moves) { board_moves.add_piece('king', 'b', 'a8')}
      before do
        board_moves.add_piece('rook', 'b', 'b8')
        board_moves.add_piece('rook', 'b', 'a7')
        board_moves.add_piece('rook', 'b', 'b7')
      end
      it 'returns an empty array' do
        result = king_moves.possible_moves
        expect(result).to eq([])
      end
    end

    context 'when there are moves that can capture' do
      subject(:king_moves) { board_moves.add_piece('king', 'b', 'a1')}
      before do
        board_moves.add_piece('rook', 'w', 'b1')
        board_moves.add_piece('rook', 'w', 'b2')
        board_moves.add_piece('rook', 'b', 'a2')
      end
      it 'returns an empty array' do
        result = king_moves.possible_moves
        expect(result).to contain_exactly('b1', 'b2')
      end
    end

    context 'when castling is available' do
      subject(:king_moves) { board_moves.add_piece('king', 'b', 'e8')}
      before do
        board_moves.add_piece('rook', 'b', 'h8')
        board_moves.add_piece('rook', 'b', 'a8')
      end
      it 'returns seven squares' do
        result = king_moves.possible_moves
        expect(result).to contain_exactly('c8', 'g8', 'd8', 'f8', 'd7', 'e7', 'f7')
      end
    end

  end


end