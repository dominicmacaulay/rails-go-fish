require 'rails_helper'

RSpec.describe 'game history', type: :system, js: true do
  include Warden::Test::Helpers

  let(:user) { create(:user) }
  before do
    create_and_start_games(amount: 5, user:)
    login_as user
    visit games_path
    click_on 'Game History'
  end

  context 'showing the current games' do
    it 'should bring you to the status page' do
      expect_css(selector: 'h1', text: 'Game History')
    end

    it 'should show all of the table headers' do
      expect_css(selector: 'th', text: 'Past Games')
      expect_css(selector: 'th', text: 'Final Round')
      expect_css(selector: 'th', text: 'Winning Score(s)')
    end

    it "should show all of the current games' name, round, and score" do
      games = Game.all
      current_games = games.select { |game| game.started && game.over }
      current_games.each do |game|
        expect(page).to have_content game.name
        expect(page).to have_content game.rounds_played
        game.score_board.each do |score|
          expect(page).to have_content score
        end
      end
    end
  end
end
