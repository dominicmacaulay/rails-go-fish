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

  describe 'serialization' do
    before do
      @game = GoFish.new(create_players(2))
      @json = GoFish.dump(@game)
    end
    it 'converts the passed in object to json' do
      expect(@json['players'].count).to eql 2
      expect(@json['current_player']).to eql @json['players'].first
    end

    it 'converts the passed json into an object' do
      # change the state of the game
      @game.next_player
      expect(@game.current_player).to eql @game.players.last
      # reload the old state of the game
      @game = GoFish.load(@json)
      expect(@game.current_player).to eql @game.players.first
    end

    it 'returns nil if the parameter is nil' do
      expect(GoFish.dump(nil)).to be nil
      expect(GoFish.load(nil)).to be nil
    end
  end

  describe '#next_player' do
    it 'switches players' do
      players = create_players(2)
      game = GoFish.new(players)
      expect(game.current_player).to eql players.first
      game.next_player
      expect(game.current_player).to eql players.last
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
