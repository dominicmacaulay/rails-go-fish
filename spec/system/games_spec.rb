require 'rails_helper'

RSpec.describe 'Games', type: :system, js: true do
  include Warden::Test::Helpers

  describe 'game that is yours', js: true do
    let!(:user) { create(:user) }
    let!(:game) { create(:game) }
    let!(:game_user) { create(:game_user, game:, user:) }

    before do
      login_as user
      visit games_path
    end

    it 'can create a new game' do
      expect_css

      click_on 'New Game'
      fill_in 'Name', with: 'Capybara game'
      fill_in 'Number of Players', with: '3'
      expect_css
      click_on 'Create game'

      expect_css
      expect(page).to have_content('Capybara game').twice
      expect(page).to have_content('1/3 Players').twice
    end

    it 'shows a game' do
      click_on 'Play now', match: :first

      expect(page).to have_content game.name
      expect(page).to have_content('Waiting')
    end

    it 'Updating a game' do
      click_on 'Edit', match: :first
      expect(page).to have_no_content('Number of Players')
      expect_css
      fill_in 'Name', with: 'Updated game'
      click_on 'Update game'

      expect_css
      expect(page).to have_content('Updated game').twice
    end

    context 'destroy' do
      it 'Destroying a game' do
        expect(page).to have_content(game.name).twice

        click_on 'Delete', match: :first
        expect(page).not_to have_content(game.name)
      end

      it 'cannot destroy a game when it is In progress' do
        expect(page).to have_content('Delete')
        create(:game_user, game:, user: create(:user))
        game.start!
        expect(page).to have_no_content('Delete')
      end
    end
  end

  describe 'showing a full game' do
    let!(:user) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:game) { create(:game) }

    context 'logging in as the current player' do
      before do
        create(:game_user, game:, user:)
        login_as user
        create(:game_user, game:, user: user2)
        game.start!
        visit games_path
      end

      it 'displays that the game is full and takes away the join button when full' do
        expect(page).to have_content('In progress')
        expect(page).to have_no_content('Players')
        expect(page).to have_no_selector('.btn', text: 'Join')
      end

      it 'shows a game started message in the show window' do
        click_on 'Play now', match: :first

        expect(page).to have_content('Game started!')
      end

      it 'should indicate that which player you are' do
        click_on 'Play now', match: :first
        session_player = game.go_fish.players.detect { |player| player.id == user.id }
        expect(page).to have_content("\n#{session_player.name}\n(you)")
      end

      it 'should show the players cards in the your hand section' do
        click_on 'Play now', match: :first
        session_player = game.go_fish.players.detect { |player| player.id == user.id }
        session_player.hand.each do |card|
          expect(page).to have_selector("img[alt='#{card.rank}, #{card.suit}']").once
        end
      end

      it 'should show the players cards in the accordion section' do
        click_on 'Play now', match: :first
        session_player = game.go_fish.players.detect { |player| player.id == user.id }
        page.find('.accordion__contents', text: session_player.name).click
        session_player.hand.each do |card|
          expect(page).to have_selector("img[alt='#{card.rank}, #{card.suit}']").twice
        end
      end

      it 'should show the opponents cards as hidden' do
        click_on 'Play now', match: :first
        page.find('.accordion__contents', text: user2.first_name).click
        expect(page).to have_selector("img[alt='Playing Card Back']", count: 5)
      end
    end

    context 'logging in as the opponent' do
      before do
        create(:game_user, game:, user:)
        create(:game_user, game:, user: user2)
        game.start!
      end

      it ' should not show the game action section if it is not your turn' do
        non_current_player = game.users.detect { |user| user.id != game.go_fish.current_player.id }
        login_as non_current_player
        visit game_path(game)
        expect(page).to have_content('Game started!')
        expect(page).not_to have_content('Take Turn')
      end
    end
  end

  context 'taking a turn' do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:game) { create(:game) }
    let(:go_fish) { game.go_fish }

    before do
      create(:game_user, game:, user:)
      create(:game_user, game:, user: user2)
      game.start!
      login_as user
      visit games_path
      click_on 'Play now', match: :first

      @rank = go_fish.current_player.hand.sample.rank.to_s
    end
    it 'should show the game action section if it is your turn' do
      expect(page).to have_selector("input[type=submit][value='Take Turn']")
    end

    it 'sends the form information to the game model' do
      expect_any_instance_of(Game).to receive(:play_round!).with(user2.id, @rank, user)
      expect(page).to have_selector("input[type=submit][value='Take Turn']")

      select user2.first_name, from: 'opponent_id'
      click_button @rank
      click_on 'Take Turn'
    end

    it 'reflects that the player has drawn a card' do
      select user2.first_name, from: 'opponent_id'
      click_button @rank
      click_on 'Take Turn'

      session_player = game.go_fish.players.detect { |player| player.id == user.id }
      expect(page).to have_content("\n(you)\nCards: #{session_player.hand_count}")
      page.find('.accordion__contents', text: session_player.name).click
      session_player.hand.each do |card|
        expect(page).to have_selector("img[alt='#{card.rank}, #{card.suit}']").twice
      end
    end

    it 'show the round results in the game feed' do
      select user2.first_name, from: 'opponent_id'
      click_button @rank
      click_on 'Take Turn'
      expect(page).to have_selector('.notification__player-action', text: "You asked #{user2.first_name}")
      expect(page).to have_selector('.notification__opponent-response', text: "#{@rank}'s")
      expect(page).to have_selector('.notification__result', text: 'got')
      expect(page).to have_content 'Game started!'
    end
  end

  context 'game over' do
    let(:user) { create(:user) }
    let(:game) { create(:game) }
    let(:go_fish) { game.go_fish }
    let(:winner) { go_fish.players.detect { |player| player.id == user.id } }

    before do
      create(:game_user, user:, game:)
      create(:game_user, user: create(:user), game:)
      game.start!
      login_as user
      go_fish.winners = [winner]
      game.update(go_fish:)
      visit games_path
      click_on 'View', match: :first
      expect(page).to have_content 'Game Feed'
      wait_for_stream_connection
    end

    it 'shows the game end results when a winner is declared' do
      expect(page).to have_content 'Game Over!'
      expect(page).to have_content 'You won the game'
    end

    it 'replaces the game action section with a button to the index page' do
      expect(page).to have_selector('.btn-primary', text: 'Go back to your games')
      expect(page).not_to have_css '.game-action'
      click_on 'Go back to your games'
      expect(page).to have_content 'Your Games'
    end

    it 'replaces the In progress text with Game Over', chrome: true do
      click_on 'Go back to your games'
      expect(page).to have_content('Game Over').twice
      expect(page).to have_no_content('In progress')
    end

    it 'replaces the current_player badge text with a message' do
      expect(page).to have_selector('.badge-primary', text: 'Game Over')
    end
  end

  context 'broadcasting' do
    let!(:user1) { create(:user) }
    let(:game) { create(:game) }

    context 'joining a game' do
      it 'broadcasts that more players have joined the queue' do
        game = create(:game, number_of_players: 3)
        create(:game_user, game:, user: user1)
        login_as user1
        visit games_path
        click_on 'Play now', match: :first
        expect(page).to have_content 'Waiting for other players'
        expect(page).to have_content "#{game.users.count}/#{game.number_of_players} players joined"

        wait_for_stream_connection

        create(:game_user, game:, user: create(:user))
        game.start!

        expect(page).to have_content 'Waiting for other players'
        expect(page).to have_content "#{game.users.count}/#{game.number_of_players} players joined"
      end

      it 'broadcasts when the game is started' do
        create(:game_user, game:, user: user1)
        login_as user1
        visit games_path
        click_on 'Play now', match: :first
        expect(page).to have_content 'Waiting for other players'
        expect(page).to have_content "#{game.users.count}/#{game.number_of_players} players joined"
        create(:game_user, game:, user: create(:user))
        game.start!
        expect(page).to have_content 'Game started!'
      end
    end

    context 'playing a game' do
      let!(:user2) { create(:user) }
      before do
        create(:game_user, game:, user: user1)
        create(:game_user, game:, user: user2)
        game.start!
      end

      it 'plays a turn' do
        login_as user2
        visit games_path
        click_on 'Play', match: :first
        expect(page).to have_content('Game Feed')
        wait_for_stream_connection

        expect do
          game.play_round!(user2.id, game.go_fish.current_player.hand.sample.rank, user1)
        end.to broadcast_to "games:#{game.id}:users:#{user2.id}"
        expect(page).to have_content('asked')
      end
    end
  end

  describe 'game that is not yours', js: true do
    let!(:user) { create(:user) }
    let!(:game) { create(:game) }

    before do
      login_as user
      visit games_path
    end

    it 'does not allow you to edit or delete it, but still shows the players' do
      expect(page).to have_content('0/2 Players')
      expect(page).not_to have_content('Delete')
      expect(page).not_to have_content('Edit')
    end

    it 'allows you to join the game' do
      click_on 'Join'

      expect(page).to have_content('joined')
    end
  end

  describe 'joining the game', js: true do
    let!(:user) { create(:user) }
    let!(:game) { create(:game) }

    before do
      login_as user
      visit games_path
    end

    it 'does not join if already in the game' do
      create(:game_user, user:, game:)
      click_on 'Join'
      expect(page).to have_content(game.name).twice
      expect(page).to have_content('1/2 Players').twice
    end

    it 'does not join if the game is full' do
      2.times { create(:game_user, user: create(:user), game:) }

      click_on 'Join'
      expect(page).to have_content(game.name).once
      expect(page).to have_content('In progress').once
    end
  end
end
