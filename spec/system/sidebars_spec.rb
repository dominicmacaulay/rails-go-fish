require 'rails_helper'

RSpec.describe 'sidebar navigation', js: true do
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
    expect_header
  end

  it 'directs you to the user history/status page' do
    click_on 'Game Status'
    expect_header(text: 'Current Games')
    expect_header(text: 'Past Games')
  end

  it "shows the user's name" do
    expect(page).to have_content(user.first_name)
  end

  it 'signs out when button is clicked' do
    click_on 'Logout'
    expect(page).to have_content('Sign in')
  end
end

def expect_header(selector: '.games-list__header', text: 'Your Games')
  expect(page).to have_selector(selector, text:)
end
