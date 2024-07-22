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

  def clear
    self.cards = []
  end

  def ==(other)
    return false unless count == other.count
    return false unless cards_match?(other)

    true
  end

  delegate :count, to: :cards

  def self.from_json(json)
    cards = json['cards'].map { |card| Card.from_json(card) }
    Deck.new(cards)
  end

  private

  def cards_match?(other)
    cards.each do |card|
      return false unless other.cards.include?(card)
    end
    true
  end

  def make_cards
    Card::SUITS.flat_map do |suit|
      Card::RANKS.map do |rank|
        Card.new(rank, suit)
      end
    end
  end
end
