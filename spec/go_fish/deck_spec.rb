require 'rails_helper'

RSpec.describe Deck do
  context '#from_json' do
    let(:deck) { Deck.new(make_card_set('4')) }
    let(:json) do
      { 'cards' => [{ 'rank' => '4', 'suit' => 'Spades' }, { 'rank' => '4', 'suit' => 'Clubs' },
     { 'rank' => '4', 'suit' => 'Diamonds' }, { 'rank' => '4', 'suit' => 'Hearts' }] }
    end

    it 'returns a deck object with all of the information' do
      new_deck = Deck.from_json(json)
      second_new_deck = Deck.from_json(json)
      expect(new_deck).to eq second_new_deck
      expect(new_deck).to eq deck
    end
  end

  context '#==' do
    let(:cards) { make_card_set('2').concat(make_card_set('4')) }
    let(:deck) { Deck.new(cards) }

    it 'returns true when the cards are equal' do
      new_deck = Deck.new(cards)
      expect(deck).to eq new_deck
    end

    it 'returns true when the cards are equal regardless of order' do
      new_deck = Deck.new(cards.reverse)
      expect(deck).to eq new_deck
    end

    it 'returns false whent the cards are not equal' do
      deck_with_different_length = Deck.new(make_card_set('4'))
      deck_with_different_cards = Deck.new(make_card_set('2').concat(make_card_set('5')))
      expect(deck).not_to eq deck_with_different_length
      expect(deck).not_to eq deck_with_different_cards
    end
  end
end

def make_card_set(rank)
  [Card.new(rank, 'Spades'), Card.new(rank, 'Clubs'), Card.new(rank, 'Diamonds'), Card.new(rank, 'Hearts')]
end
