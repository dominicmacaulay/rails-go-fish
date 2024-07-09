require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'queue_full' do
    let!(:game) { create(:game) }
    let!(:user1) { create(:user) }
    let!(:game_user) { create(:game_user, game:, user: user1) }

    it 'returns true when queue is full' do
      user2 = create(:user)
      create(:game_user, game:, user: user2)
      expect(game.queue_full?).to be true
    end

    it 'returns false when the queue is not full' do
      expect(game.queue_full?).to be false
    end
  end
end
