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
      expect_header

      click_on 'New Game'
      fill_in 'Name', with: 'Capybara game'
      fill_in 'Number of Players', with: '3'
      click_on 'Create game'

      expect_header
      expect(page).to have_content('Capybara game')
      expect(page).to have_content('1/3 Players')
    end

    it 'shows a game' do
      click_on 'Play now', match: :first

      expect_header(selector: '.header', text: game.name)
      expect(page).to have_content('players joined')
    end

    it 'Updating a game' do
      click_on 'Edit', match: :first
      expect(page).not_to have_content('Number of Players')
      fill_in 'Name', with: 'Updated game'
      click_on 'Update game'

      expect_header
      expect(page).to have_content('Updated game')
    end

    it 'Destroying a game' do
      expect(page).to have_content(game.name)

      click_on 'Delete', match: :first
      expect(page).not_to have_content(game.name)
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
        expect(page).to have_content('Game full')
        expect(page).not_to have_content('Players')
        expect(page).not_to have_content('Join')
      end

      it 'shows a game started message in the show window' do
        click_on 'Play now', match: :first

        expect(page).to have_content('Game started!')
      end

      it 'should show the players cards in the your hand section' do
        click_on 'Play now', match: :first
        session_player = game.go_fish.players.detect { |player| player.id == user.id }
        session_player.hand.each do |card|
          expect(page).to have_content("#{card.rank}, #{card.suit}").once
        end
      end

      it 'should show the players cards in the accordion section' do
        click_on 'Play now', match: :first
        session_player = game.go_fish.players.detect { |player| player.id == user.id }
        page.find('.accordion__contents', text: session_player.name).click
        session_player.hand.each do |card|
          expect(page).to have_content("#{card.rank}, #{card.suit}").twice
        end
      end

      it 'should show the opponents cards as hidden' do
        click_on 'Play now', match: :first
        page.find('.accordion__contents', text: user2.name).click
        expect(page).to have_content('BACK', count: 5)
      end

      context 'taking a turn' do
        before do
          click_on 'Play now', match: :first

          @rank = game.go_fish.current_player.hand.sample.rank
          select user2.name, from: 'opponent'
          select @rank, from: 'rank'
        end
        it 'should show the game action section if it is your turn' do
          expect(page).to have_content('Take Turn')
        end

        it 'sends the form information to the game model' do
          expect_any_instance_of(Game).to receive(:play_round!).with(user2.id, @rank, user)
          expect(page).to have_selector('.btn-primary', text: 'Take Turn')

          click_on 'Take Turn'
        end

        it 'reflects that the player has drawn a card' do
          click_on 'Take Turn'

          expect(page).to have_content('Cards: 6')
          session_player = game.go_fish.players.detect { |player| player.id == user.id }
          page.find('.accordion__contents', text: session_player.name).click
          session_player.hand.each do |card|
            expect(page).to have_content("#{card.rank}, #{card.suit}").twice
          end
        end

        it 'show the round results in the game feed' do
          click_on 'Take Turn'
          expect(page).to have_content "You asked #{user2.name}"
          expect(page).to have_content "have any #{@rank}'s"
          expect(page).to have_content 'got'
          expect(page).to have_content 'Game started!'
        end
      end

      context 'game over' do
        fit 'show the game end results when a winner is declared', chrome: true do
          go_fish = game.go_fish
          winner = go_fish.players.detect { |player| player.id == user.id }
          go_fish.winners = [winner]
          game.update(go_fish:)

          click_on 'Play now', match: :first
          expect(page).to have_content 'Game Over!'
          expect(page).to have_content "#{winner.name} won the game"
          expect(page).not_to have_css '.game-action'
        end
      end

      xit 'does not reload the full page when the player takes a turn' do
        click_on 'Play now', match: :first
        session_player = game.go_fish.players.detect { |player| player.id == user.id }
        page.find('.accordion__contents', text: session_player.name).click

        click_on 'Take Turn'
        session_player.hand.each do |card|
          expect(page).to have_content("#{card.rank}, #{card.suit}").twice
        end
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

      click_on 'Back'

      expect(page).to have_content('1/2 Players')
      expect(page).to have_content('Delete')
      expect(page).to have_content('Edit')
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
      expect(page).to have_content('Game full').once
    end
  end

  describe 'sidebar navigation', js: true do
    let!(:user) { create(:user) }
    let!(:game) { create(:game) }
    let!(:game_user) { create(:game_user, game:, user:) }

    before do
      login_as user
      visit games_path
    end

    it 'signs out when button is clicked' do
      click_on 'Sign out'
      expect(page).to have_content('Sign in')
    end

    it 'returns to the game home page when button is clicked' do
      click_on 'Play', match: :first
      click_on 'Games'
      expect(page).to have_content('Your Games')
    end
  end
end

def expect_header(selector: '.games-list__header', text: 'Your Games')
  expect(page).to have_selector(selector, text:)
end
