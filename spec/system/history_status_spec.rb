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
    it 'should bring you to the history page' do
      expect_header(selector: 'h1', text: 'History and Status')
    end
  end
end

def expect_header(selector: '.games-list__header', text: 'Your Games')
  expect(page).to have_selector(selector, text:)
end
