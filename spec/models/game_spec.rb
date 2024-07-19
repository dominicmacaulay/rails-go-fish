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

    it 'returns false if the game is already started' do
      2.times { create(:game_user, user: create(:user), game:) }
      game.start!
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
    let(:go_fish) { game.go_fish }
    let(:current_user) { game.users.detect { |user| user.id == go_fish.current_player.id } }
    let(:opponent) { game.users.detect { |user| user.id != go_fish.current_player.id } }
    let(:rank) { go_fish.current_player.hand.sample.rank }

    context 'when the game state is not valid for playing' do
      it 'returns false if the game has not started yet' do
        expect { game.play_round! }.to raise_error(Game::UnplayableError)
      end

      it 'returns false if the game is over' do
        create(:game_user, game:, user: user1)
        create(:game_user, game:, user: user2)
        game.start!
        game.go_fish.winners = game.go_fish.players
        expect { game.play_round!(opponent.id, rank, current_user) }.to raise_error(Game::UnplayableError)
      end
    end

    context 'when the parameters are invalid' do
      before do
        create(:game_user, game:, user: user1)
        create(:game_user, game:, user: user2)
        game.start!
      end

      it 'returns false when parameters are not given' do
        expect { game.play_round! }.to raise_error(GoFish::ParamsRequiredError)
      end

      it 'returns false when the opponent id is not valid' do
        expect { game.play_round!(1, rank, current_user) }.to raise_error(GoFish::InvalidOpponentError)
      end

      it 'returns false when the opponent id is the current players' do
        expect { game.play_round!(current_user.id, rank, current_user) }.to raise_error(GoFish::InvalidOpponentError)
      end

      it "returns false when the rank is not in the player's hand" do
        expect { game.play_round!(opponent.id, '11', current_user) }.to raise_error(GoFish::InvalidRankError)
      end

      it 'returns false when the user who made the request is not the current player' do
        expect { game.play_round!(opponent.id, rank, opponent) }.to raise_error(GoFish::InvalidRequesterError)
      end
    end
  end

  context '#over?' do
    let(:game) { create(:game) }
    before do
      2.times { create(:game_user, user: create(:user), game:) }
      game.start!
    end
    it 'returns false when the game is not over' do
      expect(game.over?).to be false
    end

    it 'returns true when a winner is declared' do
      game.go_fish.winners = game.go_fish.players
      expect(game.over?).to be true
    end
  end

  context '#can_destroy?' do
    let(:game) { create(:game) }
    it 'returns true when the game has not been started' do
      expect(game.can_destroy?).to be true
    end

    it 'returns false when the game has been started' do
      2.times { create(:game_user, user: create(:user), game:) }
      game.start!
      expect(game.can_destroy?).to be false
    end

    it 'returns true when the game has been finished' do
      2.times { create(:game_user, user: create(:user), game:) }
      game.start!
      game.go_fish.winners = game.go_fish.players
      game.save!
      expect(game.over?).to be true
      expect(game.can_destroy?).to be true
    end
  end
end
