require 'rails_helper'

RSpec.describe 'game history', type: :system, js: true do
  include Warden::Test::Helpers

  let(:user) { create(:user) }
  before do
    create_and_finish_games(amount: 5, user:)
    login_as user
    visit games_path
    click_on 'Game History'
  end

  context 'showing the current games' do
    it 'should bring you to the status page' do
      expect_css(selector: 'h1', text: 'Game History')
    end

    it 'should show all of the table headers' do
      expect_css(selector: 'th', text: 'Games')
      expect_css(selector: 'th', text: 'Rounds Played')
      expect_css(selector: 'th', text: 'Winning Score(s)')
      expect_css(selector: 'th', text: 'Players')
      expect_css(selector: 'th', text: 'Time To Play')
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
        game.users.each do |user|
          expect(page).to have_content user.name
        end
        expect(page).to have_content game.run_time
      end
    end
  end
  context 'spectating' do
    before do
      click_on 'View', match: :first
    end

    it 'allows you to spectate the game without the you hand and your books section' do
      expect(page).to have_content 'Game Feed'
      expect(page).to have_no_content 'Your Hand'
      expect(page).to have_no_content 'Your Books'
    end

    it 'lets you go back to the history page with the back arrow' do
      page.find('a.btn-primary', match: :first).click
      expect_css(selector: 'h1', text: 'Game History')
    end

    it 'lets you go back to the history page with the go back button' do
      page.find('a.btn-primary', text: 'Go back').click
      expect_css(selector: 'h1', text: 'Game History')
    end
  end
end
