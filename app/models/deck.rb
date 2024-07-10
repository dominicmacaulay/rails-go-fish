# frozen_string_literal: true

# go fish deck class
class Deck
  attr_accessor :cards

  def initialize(cards = make_cards)
    @cards = cards
  end

  def shuffle(seed = Random.new)
    cards.shuffle!(random: seed)
  end

  def deal
    cards.shift
  end

  def clear_cards
    self.cards = []
  end

  delegate :count, to: :cards

  def self.from_json(json)
    cards = json['cards'].map { |card| Card.from_json(card) }
    Deck.new(cards)
  end

  private

  def make_cards
    Card::SUITS.flat_map do |suit|
      Card::RANKS.map do |rank|
        Card.new(rank, suit)
      end
    end
  end
end
