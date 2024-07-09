require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    let(:user) { create(:user) }
    let(:game1) { create(:game) }
    let(:game2) { create(:game) }

    it 'it has users when they are added to the game' do
      user.games << game1
      user.games << game2
      expect(user.games).to include(game1, game2)
    end
  end
end
