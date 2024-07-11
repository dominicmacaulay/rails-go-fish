require 'rails_helper'

RSpec.describe Game, type: :model do
  context 'queue_full' do
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

  context 'started?' do
    let(:game) { create(:game) }
    it 'should return false if the go_fish is nil' do
      expect(game.started?).to be false
    end

    it 'should return true if go_fish is not nil' do
      2.times { create(:game_user, user: create(:user), game:) }
      game.start!
      expect(game.started?).to be true
    end
  end

  context 'start!' do
    let(:game) { create(:game) }
    it 'returns false if the game is not full' do
      expect(game.start!).to be false
    end

    it 'populates the go_fish attributes' do
      expect(game.go_fish).to be_nil
      user1 = create(:game_user, user: create(:user), game:)
      user2 = create(:game_user, user: create(:user), game:)
      game.start!

      expect(game.reload.go_fish).not_to be_nil
      players = game.go_fish.players
      expect(players.map(&:id)).to match [user1.user_id, user2.user_id]
      expect(game.go_fish.deck).to respond_to(:deal)
    end
  end

  context 'serialization' do
    let(:game) { create(:game) }
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    before do
      create(:game_user, game:, user: user1)
      create(:game_user, game:, user: user2)
    end

    it 'seriliazes' do
      player1 = Player.new(user1.id, user1.name)
      player2 = Player.new(user2.id, user2.name)
      go_fish = GoFish.new([player1, player2])
      game.update(go_fish:)
      expect(game.go_fish).to eq go_fish
    end
  end

  context '#play_round!' do
    let(:game) { create(:game) }
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    before do
      create(:game_user, game:, user: user1)
      create(:game_user, game:, user: user2)
      game.start!
    end

    context 'when the parameters are invalid' do
      it 'returns false when parameters are not given' do
        result = game.play_round!
        expect(result).to be false
      end

      it 'returns false when the opponent id is not valid' do
        result = game.play_round!(1, game.go_fish.current_player.hand.sample.rank)
        expect(result).to be false
      end

      it 'returns false when the opponent id is the current players' do
        result = game.play_round!(user1.id, game.go_fish.current_player.hand.sample.rank)
        expect(result).to be false
      end

      it "returns false when the rank is not in the player's hand" do
        result = game.play_round!(user2.id, '11')
        expect(result).to be false
      end
    end
  end
end
