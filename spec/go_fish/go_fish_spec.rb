require 'rails_helper'

RSpec.describe GoFish do
  describe 'deal!' do
    before do
      @players = create_players(2)
      @game = GoFish.new(@players)
    end

    it 'each player receives cards' do
      @game.deal!
      count_equal = @players.all? { |player| player.hand_count == GoFish::DEAL_NUMBER }
      expect(count_equal).to be true
    end
  end

  describe 'serialization' do
    let(:go_fish) { GoFish.new(create_players(2)) }
    let(:json) { go_fish_json }

    it 'converts the passed json into an object' do
      new_go_fish = GoFish.from_json(json)
      second_new_go_fish = GoFish.from_json(json)
      expect(new_go_fish).to eq second_new_go_fish
      expect(new_go_fish).to eq go_fish
    end

    it 'returns nil if the parameter is nil' do
      expect(GoFish.dump(nil)).to be nil
      expect(GoFish.load(nil)).to be nil
    end
  end

  describe '#next_player' do
    it 'switches players' do
      players = create_players(2)
      game = GoFish.new(players)
      expect(game.current_player).to eql players.first
      game.next_player
      expect(game.current_player).to eql players.last
    end
  end

  context '#==' do
    let(:players) { create_players(3) }
    let(:deck) { Deck.new(make_card_set('4')) }
    let(:game) { GoFish.new(players, deck:) }

    it 'returns true when the games are equal' do
      new_game = GoFish.new(create_players(3), deck:)
      expect(game).to eq new_game
    end

    context 'when games are not equal' do
      it 'returns false when the players arrays are not equal' do
        players = create_players(4)
        game_with_different_players = GoFish.new(players.last(3), current_player: game.current_player, deck:)
        game_with_different_ordered_players = GoFish.new(players.first(3).reverse, current_player: game.current_player,
                                                                                   deck:)
        expect(game).not_to eq game_with_different_players
        expect(game).not_to eq game_with_different_ordered_players
      end

      it 'returns false when the current players are not equal' do
        game_with_different_current_player = GoFish.new(players, current_player: players.last, deck:)
        expect(game).not_to eq game_with_different_current_player
      end

      it 'returns false whent the decks are not equal' do
        game_with_different_deck = GoFish.new(players, deck: Deck.new(make_card_set('6')))
        expect(game).not_to eq game_with_different_deck
      end
    end
  end
end

def make_card_set(rank)
  [Card.new(rank, 'Spades'), Card.new(rank, 'Clubs'), Card.new(rank, 'Diamonds'), Card.new(rank, 'Hearts')]
end

def create_players(times)
  x = 1
  players = []

  until x > times
    players << Player.new(x, "Player #{x}")
    x += 1
  end

  players
end

def go_fish_json # rubocop:disable Metrics/MethodLength
  { 'players' => [{ 'id' => 1, 'name' => 'Player 1', 'hand' => [], 'books' => [] }, { 'id' => 2, 'name' => 'Player 2',
                                                                                      'hand' => [], 'books' => [] }],
    'current_player' => { 'id' => 1, 'name' => 'Player 1', 'hand' => [], 'books' => [] },
    'deck' =>
  { 'cards' =>
    [{ 'rank' => '2', 'suit' => 'Spades' },
     { 'rank' => '3', 'suit' => 'Spades' },
     { 'rank' => '4', 'suit' => 'Spades' },
     { 'rank' => '5', 'suit' => 'Spades' },
     { 'rank' => '6', 'suit' => 'Spades' },
     { 'rank' => '7', 'suit' => 'Spades' },
     { 'rank' => '8', 'suit' => 'Spades' },
     { 'rank' => '9', 'suit' => 'Spades' },
     { 'rank' => '10', 'suit' => 'Spades' },
     { 'rank' => 'Jack', 'suit' => 'Spades' },
     { 'rank' => 'Queen', 'suit' => 'Spades' },
     { 'rank' => 'King', 'suit' => 'Spades' },
     { 'rank' => 'Ace', 'suit' => 'Spades' },
     { 'rank' => '2', 'suit' => 'Clubs' },
     { 'rank' => '3', 'suit' => 'Clubs' },
     { 'rank' => '4', 'suit' => 'Clubs' },
     { 'rank' => '5', 'suit' => 'Clubs' },
     { 'rank' => '6', 'suit' => 'Clubs' },
     { 'rank' => '7', 'suit' => 'Clubs' },
     { 'rank' => '8', 'suit' => 'Clubs' },
     { 'rank' => '9', 'suit' => 'Clubs' },
     { 'rank' => '10', 'suit' => 'Clubs' },
     { 'rank' => 'Jack', 'suit' => 'Clubs' },
     { 'rank' => 'Queen', 'suit' => 'Clubs' },
     { 'rank' => 'King', 'suit' => 'Clubs' },
     { 'rank' => 'Ace', 'suit' => 'Clubs' },
     { 'rank' => '2', 'suit' => 'Hearts' },
     { 'rank' => '3', 'suit' => 'Hearts' },
     { 'rank' => '4', 'suit' => 'Hearts' },
     { 'rank' => '5', 'suit' => 'Hearts' },
     { 'rank' => '6', 'suit' => 'Hearts' },
     { 'rank' => '7', 'suit' => 'Hearts' },
     { 'rank' => '8', 'suit' => 'Hearts' },
     { 'rank' => '9', 'suit' => 'Hearts' },
     { 'rank' => '10', 'suit' => 'Hearts' },
     { 'rank' => 'Jack', 'suit' => 'Hearts' },
     { 'rank' => 'Queen', 'suit' => 'Hearts' },
     { 'rank' => 'King', 'suit' => 'Hearts' },
     { 'rank' => 'Ace', 'suit' => 'Hearts' },
     { 'rank' => '2', 'suit' => 'Diamonds' },
     { 'rank' => '3', 'suit' => 'Diamonds' },
     { 'rank' => '4', 'suit' => 'Diamonds' },
     { 'rank' => '5', 'suit' => 'Diamonds' },
     { 'rank' => '6', 'suit' => 'Diamonds' },
     { 'rank' => '7', 'suit' => 'Diamonds' },
     { 'rank' => '8', 'suit' => 'Diamonds' },
     { 'rank' => '9', 'suit' => 'Diamonds' },
     { 'rank' => '10', 'suit' => 'Diamonds' },
     { 'rank' => 'Jack', 'suit' => 'Diamonds' },
     { 'rank' => 'Queen', 'suit' => 'Diamonds' },
     { 'rank' => 'King', 'suit' => 'Diamonds' },
     { 'rank' => 'Ace', 'suit' => 'Diamonds' }] } }
end
