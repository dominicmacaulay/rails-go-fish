# frozen_string_literal: true

# class for Go fish
class GoFish
  attr_reader :players

  DEAL_NUMBER = 5

  def initialize(players)
    @players = players
    @current_player = players.first
  end

  def deck
    @deck ||= Deck.new
  end

  def deal!
    deck.shuffle
    DEAL_NUMBER.times do
      players.each { |player| player.add_to_hand(deck.deal) }
    end
  end

  def self.load(payload)
  end

  def self.dump(address)
  end
end
