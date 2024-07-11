# frozen_string_literal: true

# class for Go fish
class GoFish
  DEAL_NUMBER = 5
  MINIMUM_BOOK_LENGTH = 4

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

  def ==(other)
    return false unless players == other.players
    return false unless current_player == other.current_player
    return false unless deck == other.deck

    true
  end

  # JSON SECTION
  def self.dump(object)
    object.as_json
  end

  def self.load(payload)
    return unless payload

    from_json(payload)
  end

  def self.from_json(json)
    players = json['players'].map { |player| Player.from_json(player) }
    current_player = players.detect { |player| player.id == json['current_player']['id'] }
    deck = Deck.from_json(json['deck'])
    GoFish.new(players, current_player:, deck:)
  end
end
