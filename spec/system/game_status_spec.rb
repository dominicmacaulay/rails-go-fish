require 'rails_helper'

RSpec.describe 'history/status page', type: :system, js: true do
  include Warden::Test::Helpers

  let(:user) { create(:user) }
  before do
    create_and_start_games(amount: 5, user:)
    login_as user
    visit games_path
    click_on 'Game Status'
  end
  context "showing the current user's games" do
    it 'should bring you to the history page' do
      expect_header(selector: 'h1', text: 'Game Status')
    end

    it 'should show a section for the current and past games' do
      expect_header(text: 'Current Games')
      expect_header(text: 'Past Games')
    end

    it "should show all of the current games' name, round, and score" do
      games = Game.all
      current_games = games.select { |game| game.started? && !game.over? }
      current_games.each do |game|
        expect(page).to have_content game.name
        expect(page).to have_content game.rounds_played
        expect(page).to have_content game.scoreboard
      end
    end
  end
end

def expect_header(selector: '.games-list__header', text: 'Your Games')
  expect(page).to have_selector(selector, text:)
end

def create_and_start_games(amount:, user:)
  amount.times do
    game = create(:game)
    create(:game_user, user:, game:)
    create(:game_user, user: create(:user), game:)
    game.start!
  end
end
