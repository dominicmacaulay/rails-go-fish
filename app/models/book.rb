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
    value == other.value
  end

  def self.from_json(json)
    cards = json['cards'].map { |card| Card.from_json(card) }
    Book.new(cards)
  end
end
