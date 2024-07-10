require 'rails_helper'

RSpec.describe 'Games', type: :system, js: true do
  include Warden::Test::Helpers

  describe 'game that is yours', js: true do
    let!(:user) { create(:user) }
    let!(:game) { create(:game) }
    let!(:game_user) { create(:game_user, game:, user:) }

    before do
      login_as user
      visit games_path
    end

    it 'can create a new game' do
      expect_header

      click_on 'New Game'
      fill_in 'Name', with: 'Capybara game'
      fill_in 'Number of Players', with: '3'
      click_on 'Create game'

      expect_header
      expect(page).to have_content('Capybara game')
      expect(page).to have_content('1/3 Players')
    end

    it 'shows a game' do
      click_on 'Play now', match: :first

      expect_header(selector: '.header', text: game.name)
      expect(page).to have_content('players joined')
    end

    it 'Updating a game' do
      click_on 'Edit', match: :first
      expect(page).not_to have_content('Number of Players')
      fill_in 'Name', with: 'Updated game'
      click_on 'Update game'

      expect_header
      expect(page).to have_content('Updated game')
    end

    it 'Destroying a game' do
      expect(page).to have_content(game.name)

      click_on 'Delete', match: :first
      expect(page).not_to have_content(game.name)
    end
  end

  describe 'showing a full game' do
    let!(:user) { create(:user) }
    let!(:game) { create(:game) }
    let!(:game_user) { create(:game_user, game:, user:) }

    before do
      login_as user
      user2 = create(:user)
      create(:game_user, game:, user: user2)
      visit games_path
    end

    it 'displays that the game is full and takes away the join button when full' do
      expect(page).to have_content('Game full')
      expect(page).not_to have_content('Players')
      expect(page).not_to have_content('Join')
    end

    it 'shows a game started message in the show window' do
      click_on 'Play now', match: :first

      expect(page).to have_content('Game started!')
    end
  end

  describe 'game that is not yours', js: true do
    let!(:user) { create(:user) }
    let!(:game) { create(:game) }

    before do
      login_as user
      visit games_path
    end

    it 'does not allow you to edit or delete it, but still shows the players' do
      expect(page).to have_content('0/2 Players')
      expect(page).not_to have_content('Delete')
      expect(page).not_to have_content('Edit')
    end

    it 'allows you to join the game' do
      click_on 'Join'

      expect(page).to have_content('joined')

      click_on 'Back'

      expect(page).to have_content('1/2 Players')
      expect(page).to have_content('Delete')
      expect(page).to have_content('Edit')
    end
  end

  describe 'joining the game', js: true do
    let!(:user) { create(:user) }
    let!(:game) { create(:game) }

    before do
      login_as user
      visit games_path
    end

    it 'does not join if already in the game' do
      create(:game_user, user:, game:)
      click_on 'Join'
      expect(page).to have_content(game.name).twice
      expect(page).to have_content('1/2 Players').twice
    end

    it 'does not join if the game is full' do
      2.times { create(:game_user, user: create(:user), game:) }

      click_on 'Join'
      expect(page).to have_content(game.name).once
      expect(page).to have_content('Game full').once
    end
  end

  describe 'sidebar navigation', js: true do
    let!(:user) { create(:user) }
    let!(:game) { create(:game) }
    let!(:game_user) { create(:game_user, game:, user:) }

    before do
      login_as user
      visit games_path
    end

    it 'signs out when button is clicked' do
      click_on 'Sign out'
      expect(page).to have_content('Sign in')
    end

    it 'returns to the game home page when button is clicked' do
      click_on 'Play', match: :first
      click_on 'Games'
      expect(page).to have_content('Your Games')
    end
  end
end

def expect_header(selector: '.games-list__header', text: 'Your Games')
  expect(page).to have_selector(selector, text:)
end
