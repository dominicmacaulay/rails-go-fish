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
    headers = ['rank', 'name', 'wins', 'losses', 'games played']
    headers.each do |header|
      expect_header(selector: '.user-list__header', text: header)
    end
  end

  it 'shows the info for each user' do
    users = User.all
    users.each do |user|
      expect(page).to have_content user.name
      expect(page).to have_content user.wins
      expect(page).to have_content user.losses
      expect(page).to have_content user.games_played
    end
  end
end
