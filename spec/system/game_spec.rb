require 'rails_helper'

RSpec.describe 'Games', type: :system, js: true do
  include Warden::Test::Helpers

  describe 'game that is yours', js: true do
    let!(:user) { create(:user) }
    let!(:game) { create(:game) }
    let!(:game_user) { create(:game_user, game:, user:) }

    before do
      login_as user
    end

    it 'can create a new game' do
      visit games_path
      expect_header

      click_on 'New Game'
      fill_in 'Name', with: 'Capybara game'
      fill_in 'Number of players', with: '3'
      click_on 'Create game'

      expect_header
      expect(page).to have_content('Capybara game')
    end

    it 'shows a game' do
      visit games_path
      click_on 'Play now', match: :first

      expect_header(selector: '.header', text: game.name)
    end

    it 'Updating a game', :chrome do
      visit games_path

      click_on 'Edit', match: :first
      expect(page).not_to have_content('Number of Players')
      fill_in 'Name', with: 'Updated game'
      click_on 'Update game'

      expect_header
      expect(page).to have_content('Updated game')
    end

    it 'Destroying a game' do
      visit games_path
      expect(page).to have_content(game.name)

      click_on 'Delete', match: :first
      expect(page).not_to have_content(game.name)
    end
  end

  describe 'game that is not yours', js: true do
    let!(:user) { create(:user) }
    let!(:game) { create(:game) }

    before do
      login_as user
    end

    it 'does not allow you to edit or delete it' do
      visit games_path
      expect(page).not_to have_content('Delete')
      expect(page).not_to have_content('Edit')
    end

    it 'allows you to join the game' do
      visit games_path
      click_on 'Join'

      expect(page).to have_content('joined')

      click_on 'Back'

      expect(page).to have_content('Delete')
      expect(page).to have_content('Edit')
    end
  end
end

def expect_header(selector: '.games-list__header', text: 'Your Games')
  expect(page).to have_selector(selector, text:)
end
