# frozen_string_literal: false

# go fish player class
class Player
  MINIMUM_NAME_LENGTH = 3

  attr_reader :id, :name, :hand, :books

  def initialize(id, name, hand: [], books: [])
    @id = id
    @name = name
    @hand = hand
    @books = books
  end

  def add_to_hand(cards)
    hand.push(*cards)
  end

  def add_to_books(books)
    self.books.push(*books)
  end

  def hand_count # rubocop:disable Rails/Delegate
    hand.count
  end

  def book_count
    books.count
  end

  def total_book_value
    books.map(&:value).sum
  end

  def hand_has_rank?(rank)
    hand.each do |card|
      return true if card.equal_rank?(rank)
    end
    false
  end

  def remove_cards_with_rank(rank)
    cards = hand.dup
    hand.delete_if { |card| card.equal_rank?(rank) }
    cards.select { |card| card.equal_rank?(rank) }
  end

  def rank_count(rank)
    hand.select { |card| card.equal_rank?(rank) }.count
  end

  def make_book?
    unique_cards = hand.uniq(&:rank)
    unique_cards.each do |unique_card|
      create_book(unique_card.rank) if rank_count(unique_card.rank) >= GoFish::MINIMUM_BOOK_LENGTH
    end
    unique_cards != hand.uniq(&:rank)
  end

  def clear
    @books = []
    @hand = []
  end

  def ==(other)
    return false unless id == other.id
    return false unless name == other.name
    return false unless hand_matches?(other)
    return false unless books_match?(other)

    true
  end

  def self.from_json(json)
    hand = json['hand'].map { |card| Card.from_json(card) }
    books = json['books'].map { |book| Book.from_json(book) }
    Player.new(json['id'], json['name'], hand:, books:)
  end

  private

  def hand_matches?(other)
    return false unless hand_count == other.hand_count

    hand.each do |card|
      return false unless other.hand.include?(card)
    end
    true
  end

  def books_match?(other)
    return false unless book_count == other.book_count

    books.each do |book|
      return false unless other.books.include?(book)
    end
    true
  end

  def create_book(rank)
    cards = hand.select { |card| card.equal_rank?(rank) }
    hand.delete_if { |card| cards.include?(card) }
    books << Book.new(cards)
  end
end
