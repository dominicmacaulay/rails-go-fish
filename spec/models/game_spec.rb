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

    it 'updates the go_fish attribute' do
      expect(game.go_fish).to be_nil

      2.times { create(:game_user, user: create(:user), game:) }
      game.start!

      expect(game.go_fish).not_to be_nil
    end
  end

  # describe '#go_fish' do
  #   let(:game) { create(:game) }
  #   let(:user1) { create(:user) }
  #   let(:user2) { create(:user) }

  #   before do
  #     create(:game_user, game:, user: user1)
  #     create(:game_user, game:, user: user2)
  #   end

  #   it 'seriliazes' do
  #     game.start!
  #     expect(game.go_fish).not_to be nil
  #   end
  # end
end
