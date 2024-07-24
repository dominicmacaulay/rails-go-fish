require 'rails_helper'

RSpec.describe Leaderboard, type: :model do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:leaderboards) { Leaderboard.all }
  before do
    create_and_play_games(user: user1, user2:, wins: 5, losses: 10)
  end

  context 'querying the database' do
    it "should return the users' names" do
      users = leaderboards.map(&:user)
      expect(users.count).to eql 2
      expect(users).to include(user1.name)
      expect(users).to include(user2.name)
    end

    it "should return the users' score" do
      scores = leaderboards.map(&:score)
      expect(scores.count).to eql 2
      expect(scores).to include(user1.game_users.sum(&:book_value))
      expect(scores).to include(user2.game_users.sum(&:book_value))
    end

    it "should return the users' ids" do
      user_ids = leaderboards.map(&:user_id)
      expect(user_ids.count).to eql 2
      expect(user_ids).to include(user1.id)
      expect(user_ids).to include(user2.id)
    end

    it "should return the users' wins" do
      wins = leaderboards.map(&:wins)
      expect(wins.count).to eql 2
      expect(wins).to include(user1.game_users.select(&:winner).count)
      expect(wins).to include(user2.game_users.select(&:winner).count)
    end

    it "should return the users' losses" do
      losses = leaderboards.map(&:losses)
      expect(losses.count).to eql 2
      expect(losses).to include(user1.game_users.select { |gu| gu.winner == false }.count)
      expect(losses).to include(user2.game_users.select { |gu| gu.winner == false }.count)
    end

    it "should return the users' game counts" do
      total_games = leaderboards.map(&:total_games)
      expect(total_games.count).to eql 2
      expect(total_games).to include(user1.game_users.count)
      expect(total_games).to include(user2.game_users.count)
    end

    it "should return the users' win rates" do
      win_rates = leaderboards.map { |leaderboard| leaderboard.win_rate.round(2) }
      expect(win_rates.count).to eql 2
      user1_wins = user1.game_users.select(&:winner).count
      user2_wins = user2.game_users.select(&:winner).count
      user1_total_games = user1.game_users.count
      user2_total_games = user2.game_users.count
      expect(win_rates).to include((user1_wins.to_f / user1_total_games).round(2))
      expect(win_rates).to include((user2_wins.to_f / user2_total_games).round(2))
    end

    it "should return the users' highest book count" do
      highest_book_counts = leaderboards.map(&:highest_book_count)
      expect(highest_book_counts.count).to eql 2
      expect(highest_book_counts).to include(user1.game_users.map(&:books).max)
      expect(highest_book_counts).to include(user2.game_users.map(&:books).max)
    end

    it "should return the users' total time played" do
      total_time_played = leaderboards.map(&:total_time_played)
      expect(total_time_played.count).to eql 2
      user1_time = user1.games.map { |game| game.finished_at - game.started_at }.sum
      user2_time = user2.games.map { |game| game.finished_at - game.started_at }.sum
      expect(total_time_played).to include(user1_time)
      expect(total_time_played).to include(user2_time)
    end
  end

  context 'formatting methods' do
    it 'formats the total time into a string converted into hours' do
      times = leaderboards.map(&:time)
      expect(times.count).to eql 2
      user1_time = user1.games.map { |game| game.finished_at - game.started_at }.sum
      user2_time = user2.games.map { |game| game.finished_at - game.started_at }.sum
      expect(times).to include("#{(user1_time / Leaderboard::SECONDS_TO_HOURS_FACTOR).round(2)} hours")
      expect(times).to include("#{(user2_time / Leaderboard::SECONDS_TO_HOURS_FACTOR).round(2)} hours")
    end

    it 'formats the winning rate into a percentage string' do
      rates = leaderboards.map(&:winning_rate)
      expect(rates.count).to eql 2
      user1_total_games = user1.game_users.count
      user2_total_games = user2.game_users.count
      user1_wins = (user1.game_users.select(&:winner).count.to_f / user1_total_games).round(2)
      user2_wins = (user2.game_users.select(&:winner).count.to_f / user2_total_games).round(2)
      expect(rates).to include("#{(user1_wins * 100).round(0)}%")
      expect(rates).to include("#{(user2_wins * 100).round(0)}%")
    end
  end
end
