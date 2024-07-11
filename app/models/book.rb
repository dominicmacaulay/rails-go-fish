# frozen_string_literal: true

# Book class
class Book
  attr_reader :cards

  def initialize(cards)
    @cards = cards
  end

  def value
    @value ||= cards.first.value
  end

  def ==(other)
    return false unless value == other.value
    return false unless cards_match?(other)

    true
  end

  def self.from_json(json)
    cards = json['cards'].map { |card| Card.from_json(card) }
    Book.new(cards)
  end

  private

  def cards_match?(other)
    cards.each do |card|
      return false unless other.cards.include?(card)
    end
    true
  end
end
