require_relative '../lib/piece'

RSpec.shared_examples 'chess piece interface' do
  let(:board) { double('board') }
  subject(:piece) { described_class.new('w', 'a1', board) }

  describe 'name' do
    context 'when name is called' do
      it 'responds' do
        expect(piece).to respond_to(:name)
      end
    end
  end

  describe 'player' do
    context 'when player is called' do
      it 'responds' do
        expect(piece).to respond_to(:player)
      end
    end
  end

  describe 'display_chr' do
    context 'when player is called' do
      it 'display_chr' do
        expect(piece).to respond_to(:display_chr)
      end
    end
  end

  describe 'legal_move?' do
    context 'when legal_move? is called' do
      it 'responds' do
        expect(piece).to respond_to(:legal_move?)
      end
    end
  end

  describe 'possible_moves' do
    context 'when possible_moves is called' do
      it 'responds' do
        expect(piece).to respond_to(:possible_moves)
      end
    end
  end

  describe 'move' do
    context 'when move is called' do
      it 'responds' do
        expect(piece).to respond_to(:move)
      end


      it 'sets current square' do
        expect{piece.move('a2')}.to change { piece.current_square }.to('a2')
      end
    end
  end

  describe 'current_square' do
    context 'when current_square is called' do
      it 'responds' do
        expect(piece).to respond_to(:current_square)
      end
    end
  end

  describe 'king?' do
    context 'when king? is called' do
      it 'responds' do
        expect(piece).to respond_to(:king?)
      end
    end
  end

end

describe Piece do
  let(:board) { double('board') }
  subject(:piece) { described_class.new('w', 'a1', board) }

  describe 'legal_move?' do
    context 'when move is legal but same player piece is in the way' do
      before do
        allow(board).to receive(:row).and_return(0, 0)
        allow(board).to receive(:col).and_return(0, 1)
        allow(board).to receive(:on_board?).and_return(true)
        allow(board).to receive(:same_player_on_square).and_return(true)
      end
      it 'returns false' do
        result = piece.legal_move?('b1')
        expect(result).to be_falsey
      end
    end

    context 'when move is legal but other player piece is in the way' do
      before do
        allow(board).to receive(:row).and_return(0, 0)
        allow(board).to receive(:col).and_return(0, 1)
        allow(board).to receive(:on_board?).and_return(true)
        allow(board).to receive(:same_player_on_square).and_return(false)
      end
      it 'returns true' do
        result = piece.legal_move?('b1')
        expect(result).to be_truthy
      end
    end

    context 'when new square is the same as the old square' do
      before do
        allow(board).to receive(:row).and_return(0, 0)
        allow(board).to receive(:col).and_return(0, 0)
        allow(board).to receive(:on_board?).and_return(true)
        allow(board).to receive(:same_player_on_square).and_return(false)
      end
      it 'returns true' do
        result = piece.legal_move?('a1')
        expect(result).to be_falsey
      end
    end
  end
end