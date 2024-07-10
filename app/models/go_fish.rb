# frozen_string_literal: true

# class for Go fish
class GoFish
  DEAL_NUMBER = 5

  attr_reader :players, :deck
  attr_accessor :current_player

  def initialize(players, current_player: players.first, deck: Deck.new)
    @players = players
    @current_player = current_player
    @deck = deck
  end

  def deal!
    deck.shuffle
    DEAL_NUMBER.times do
      players.each { |player| player.add_to_hand(deck.deal) }
    end
  end

  def next_player
    index = players.index(current_player)
    self.current_player = players[(index + 1) % players.count]
  end

  # JSON SECTION
  def self.dump(object)
    object.as_json
  end

  def self.load(payload)
    return if payload.nil?

    from_json(payload)
  end

  def self.from_json(json)
    players = json['players'].map { |player| create_player(player) }
    current_player = players.detect { |player| player.id == json['current_player']['id'] }
    deck = create_deck(json['deck'])
    GoFish.new(players, current_player:, deck:)
  end

  def self.create_player(player)
    hand = player['hand'].map { |card| create_card(card) }
    books = player['books'].map { |book| create_book(book) }
    Player.new(player['id'], player['name'], hand:, books:)
  end

  def self.create_deck(deck)
    cards = deck['cards'].map { |card| create_card(card) }
    Deck.new(cards)
  end

  def self.create_book(book)
    cards = book['cards'].map { |card| create_card(card) }
    Book.new(cards)
  end

  def self.create_card(card)
    Card.new(card['rank'], card['suit'])
  end
end
