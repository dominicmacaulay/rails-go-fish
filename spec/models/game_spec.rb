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

  describe 'start!' do
    let(:game) { create(:game) }
    it 'returns false if the game is not full' do
      expect(game.start!).to be false
    end

    it 'starts the game if the queue is full' do
      2.times { create(:game_user, user: create(:user), game:) }
      expect(game.start!).not_to be false
    end
  end
end
