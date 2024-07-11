require 'rails_helper'

RSpec.describe Player do
  context '#from_json' do
    let(:player) { Player.new('1', 'Player 1', hand: make_card_set('5'), books: [create_book('10')]) }
    let(:json) do
      { 'id' => '1', 'name' => 'Player 1',
        'hand' => [{ 'rank' => '5', 'suit' => 'Spades' }, { 'rank' => '5', 'suit' => 'Clubs' },
        { 'rank' => '5', 'suit' => 'Diamonds' }, { 'rank' => '5', 'suit' => 'Hearts' }],
        'books' => ['cards' => [{ 'rank' => '10', 'suit' => 'Spades' }, { 'rank' => '10', 'suit' => 'Clubs' },
        { 'rank' => '10', 'suit' => 'Diamonds' }, { 'rank' => '10', 'suit' => 'Hearts' }]] }
    end

    it 'returns a player object with all of the information' do
      new_player = Player.from_json(json)
      second_new_player = Player.from_json(json)
      expect(new_player).to eq second_new_player
      expect(new_player).to eq player
    end
  end

  context '#==' do
    let(:hand) { make_card_set('2').concat(make_card_set('3')) }
    let(:books) { [create_book('4'), create_book('5')] }
    let(:player) { Player.new('1', 'Player 1', hand:, books:) }

    it 'returns true when the player attributes are equal' do
      other_player = Player.new('1', 'Player 1', hand:, books:)
      expect(player).to eq other_player
    end

    it 'returns true even if the hand cards are in a different order' do
      other_player = Player.new('1', 'Player 1', hand: hand.reverse, books: books.reverse)
      expect(player).to eq other_player
    end

    context 'when attributes are not equal' do
      it 'returns false when the player name and id are not equal' do
        player_with_different_id = Player.new('2', 'Player 1', hand:, books:)
        player_with_different_name = Player.new('1', 'Player 2', hand:, books:)
        expect(player).not_to eq player_with_different_id
        expect(player).not_to eq player_with_different_name
      end

      it 'returns false when the player hand is different' do
        player_with_different_hand_count = Player.new('1', 'Player 2', hand: make_card_set('6'), books:)
        player_with_different_hand_cards = Player.new('1', 'Player 2',
                                                      hand: make_card_set('6').concat(make_card_set('8')), books:)
        expect(player).not_to eq player_with_different_hand_count
        expect(player).not_to eq player_with_different_hand_cards
      end

      it 'returns false when the player books are different' do
        player_with_different_book_types = Player.new('1', 'Player 2', hand:,
                                                                       books: [create_book('5'), create_book(9)])
        player_with_different_book_count = Player.new('1', 'Player 2', hand:, books: [create_book('5')])
        expect(player).not_to eq player_with_different_book_types
        expect(player).not_to eq player_with_different_book_count
      end
    end
  end
end

def create_book(rank)
  Book.new(make_card_set(rank))
end

def make_card_set(rank)
  [Card.new(rank, 'Spades'), Card.new(rank, 'Clubs'), Card.new(rank, 'Diamonds'), Card.new(rank, 'Hearts')]
end
