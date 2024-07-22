require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user, first_name: 'Dominic', last_name: 'MacAulay', email: 'dominic@gmail.com') }
  describe 'name' do
    it 'returns the full name of the user' do
      expect(user.name).to eql 'Dominic MacAulay'
    end
  end

  describe 'game stats' do
    let(:wins) { 5 }
    let(:losses) { 8 }
    before do
      create_and_play_games(user:, wins:, losses:)
    end
    it 'returns the wins the has' do
      expect(user.wins).to eql wins
    end

    it 'returns the losses the user has' do
      expect(user.losses).to eql losses
    end

    it 'returns the win rate' do
      total_games = wins + losses
      answer = (wins.to_f / total_games * 100).round(2)
      expect(user.win_rate).to eql answer
    end

    it 'returns 0 if there are no wins or losses' do
      user = create(:user)
      create_and_play_games(user:, wins: 0, losses: 0)
      expect(user.win_rate).to eql 0
    end

    it 'returns 0 if there are losses but no wins' do
      user = create(:user)
      create_and_play_games(user:, wins: 0, losses: 1)
      expect(user.win_rate).to eql 0
    end

    it 'returns 100 if there are wins but no losses' do
      user = create(:user)
      create_and_play_games(user:, wins: 1, losses: 0)
      expect(user.win_rate).to eql 100
    end

    it 'returns the total games played' do
      expect(user.games_played).to eql(wins + losses)
    end
  end
end

def create_and_play_games(user:, wins:, losses:) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
  wins.times do
    game = create_game(user:)
    player = game.go_fish.players.select { |p| p.id == user.id }
    game.go_fish.winners = player
    game.save!
  end

  losses.times do
    game = create_game(user:)
    player = game.go_fish.players.reject { |p| p.id == user.id }
    game.go_fish.winners = player
    game.save!
  end
end

def create_game(user:)
  game = create(:game)
  create(:game_user, user:, game:)
  create(:game_user, user: create(:user), game:)
  game.start!
  game
end
