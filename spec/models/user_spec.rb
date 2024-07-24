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

    it 'returns the total time' do
      total_time = user.games.map { |game| game.finished_at - game.started_at }.sum
      expect(user.total_time).to eql format_time(total_time)
    end

    it 'shows run time if the game is not over yet' do
      user = create(:user)
      game = create_game(user:)
      game.play_round!(game.users.last.id, game.go_fish.current_player.hand.sample.rank, user)
      total_time = user.games.map { |this_game| this_game.updated_at - this_game.started_at }.sum
      expect(user.total_time).to eql format_time(total_time)
    end

    it 'shows 0 if the game has been started but not played' do
      user = create(:user)
      create_game(user:)
      expect(user.total_time).to eql '0s'
    end

    it 'returns the highest book count' do
      games = user.game_users.map(&:game)
      book_counts = games.map do |game|
        game.go_fish.players.detect { |player| player.id == user.id }.book_count
      end
      highest_book_count = book_counts.max
      expect(user.highest_book_count).to eql highest_book_count
    end
  end
end
