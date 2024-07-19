require 'rails_helper'

RSpec.describe 'history/status page' do
  include Warden::Test::Helpers

  let(:user) { create(:user) }
  before do
    5.times { create(:game_user, user:, game: create(:game)) }
    login_as user
    visit games_path
    click_on 'History/Status'
  end
  context "showing the current user's games" do
    xit "should show all of the current user's games" do
      expect_header(selector: 'h1', text: 'History/Status')
      user.games.each do |game|
        expect(page).to have_content game.name
      end
    end
  end
end

def expect_header(selector: '.games-list__header', text: 'Your Games')
  expect(page).to have_selector(selector, text:)
end
