require 'rails_helper'

RSpec.describe 'Games', type: :system do
  # include Warden::Test::Helpers

  let!(:user) { create(:user) }
  let!(:game) { create(:game) }

  # before do
  #   login_as user
  # end

  it 'can create a new game', :js do
    visit games_path
    expect(page).to have_selector('.games-list__header', text: 'Games')

    click_on 'New game'
    fill_in 'Name', with: 'Capybara game'
    expect(page).to have_selector('.games-list__header', text: 'Games')
    click_on 'Create game'

    expect(page).to have_selector('.games-list__header', text: 'Games')
    expect(page).to have_content('Capybara game')
  end

  it 'shows a game' do
    visit games_path
    click_on game.name

    expect(page).to have_selector('.games-list__header', text: game.name)
  end

  it 'Updating a game', :js do
    visit games_path
    expect(page).to have_selector('.games-list__header', text: 'Games')

    click_on 'Edit', match: :first
    fill_in 'Name', with: 'Updated game'
    expect(page).to have_selector('.games-list__header', text: 'Games')
    click_on 'Update game'

    expect(page).to have_selector('.games-list__header', text: 'Games')
    expect(page).to have_content('Updated game')
  end

  it 'Destroying a game' do
    visit games_path
    expect(page).to have_content(game.name)

    click_on 'Delete', match: :first
    expect(page).not_to have_content(game.name)
  end
end
