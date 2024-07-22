require 'rails_helper'

RSpec.describe 'leaderboards', type: :system, js: true do
  include Warden::Test::Helpers

  let(:user) { create(:user) }

  before do
    create_and_start_games(amount: 5, user:)
    login_as user
    visit games_path
    click_on 'Leaderboard'
  end

  it 'shows the header' do
    headers = ['Rank', 'Name', 'Wins', 'Losses', 'Games Played', 'Total Time Played', 'Highest Book Count']
    headers.each do |header|
      expect_css(selector: 'th', text: header)
    end
  end

  it 'shows the info for each user' do
    users = User.all
    users.each do |user|
      expect_css(selector: 'td', text: user.name)
      expect_css(selector: 'td', text: user.wins)
      expect_css(selector: 'td', text: user.losses)
      expect_css(selector: 'td', text: user.games_played)
      expect_css(selector: 'td', text: user.win_rate)
      expect_css(selector: 'td', text: user.total_time)
      expect_css(selector: 'td', text: user.highest_book_count)
    end
  end
end
