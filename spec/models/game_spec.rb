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

  context 'started' do
    let(:game) { create(:game) }
    it 'should return false if the go_fish is nil' do
      expect(game.started).to be false
    end

    it 'should return true if go_fish is not nil' do
      2.times { create(:game_user, user: create(:user), game:) }
      game.start!
      expect(game.started).to be true
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
      expect(players.map(&:id)).to include user1.user_id
      expect(players.map(&:id)).to include user2.user_id
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
      player1 = Player.new(user1.id, user1.first_name)
      player2 = Player.new(user2.id, user2.first_name)
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

  context '#over' do
    let(:game) { create(:game) }
    before do
      2.times { create(:game_user, user: create(:user), game:) }
      game.start!
    end
    it 'returns false when the game is not over' do
      expect(game.over).to be false
    end

    it 'returns true when a winner is declared' do
      game.go_fish.winners = game.go_fish.players
      expect(game.over).to be true
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
      expect(game.over).to be true
      expect(game.can_destroy?).to be true
    end
  end

  context '#rounds_played' do
    it 'returns the round count for its game' do
      game = create(:game)
      2.times { create(:game_user, user: create(:user), game:) }
      game.start!
      expect(game.rounds_played).to eq 0
      game.go_fish.rounds_played = 5
      game.save!
      expect(game.rounds_played).to eq 5
    end
  end

  context '#score_board' do
    it 'should display the scoreboard' do
      game = create(:game)
      2.times { create(:game_user, user: create(:user), game:) }
      game.start!
      score_board = game.go_fish.score_board
      expect(game.score_board).to eq create_score_message(score_board)
    end

    def create_score_message(players)
      players.map do |_player, info|
        "#{info['name']} books: #{info['books_count']}, total score: #{info['books_value']}"
      end
    end
  end

  context 'game over' do
    let(:game) { create(:game) }
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    before do
      create(:game_user, game:, user: user1)
      create(:game_user, game:, user: user2)
      game.start!
      play_until_finished(game)
    end

    it 'should update the game users that are winners' do
      user1_won = game.go_fish.winners.any? { |winner| winner.id == user1.id }
      user2_won = game.go_fish.winners.any? { |winner| winner.id == user2.id }
      expect(user1.game_users.first.winner).to be user1_won
      expect(user2.game_users.first.winner).to be user2_won
    end

    it 'should update the game users with how many books they had' do
      user1_books = game.go_fish.players.detect { |player| player.id == user1.id }.book_count
      user2_books = game.go_fish.players.detect { |player| player.id == user2.id }.book_count
      expect(user1.game_users.first.books).to eql user1_books
      expect(user2.game_users.first.books).to eql user2_books
    end

    it 'should set the over attribute to true' do
      expect(game.reload.over).to be true
    end

    it 'should set the finished at timestamp' do
      expect(game.finished_at).not_to be nil
    end
  end
end

def play_until_finished(game) # rubocop:disable Metrics/AbcSize
  until game.go_fish.winners
    current_index = game.go_fish.players.index(game.go_fish.current_player)
    other_player = game.go_fish.players[(current_index + 1) % game.go_fish.players.count]
    rank = game.go_fish.current_player.hand.sample.rank
    game.play_round!(other_player.id, rank, game.go_fish.current_player)
  end
end
