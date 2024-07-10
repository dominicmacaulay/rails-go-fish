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
