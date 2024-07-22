require 'rails_helper'

RSpec.describe 'sidebar navigation', type: :system, js: true do
  include Warden::Test::Helpers

  let!(:user) { create(:user) }
  let!(:game) { create(:game) }
  let!(:game_user) { create(:game_user, game:, user:) }

  before do
    login_as user
    visit games_path
  end

  it 'directs you to the home page' do
    click_on 'Go Fish'
    expect(page).to have_selector('.btn', text: 'View games')
  end

  it 'directs you to the games index page' do
    click_on 'Games'
    expect_css
  end

  it 'directs you to the leader board page' do
    click_on 'Leaderboard'
    expect_css(selector: 'h1', text: 'Leaderboard')
  end

  it 'directs you to the game status page' do
    click_on 'Game Status'
    expect_css(selector: 'h1', text: 'Game Status')
  end

  it "shows the user's name" do
    expect(page).to have_content(user.first_name)
  end

  it 'signs out when button is clicked' do
    click_on 'Logout'
    expect(page).to have_content('Sign in')
  end
end
