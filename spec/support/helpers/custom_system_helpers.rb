module CustomSystemHelpers
  def expect_css(selector: '.games-list__header', text: 'Your Games')
    expect(page).to have_selector(selector, text:)
  end

  def create_and_start_games(amount:, user:)
    amount.times do
      game = create(:game)
      create(:game_user, user:, game:)
      create(:game_user, user: create(:user), game:)
      game.start!
    end
  end

  def create_and_finish_games(amount:, user:)
    amount.times do
      game = create(:game)
      create(:game_user, user:, game:)
      create(:game_user, user: create(:user), game:)
      game.start!
      game.go_fish.winners = game.go_fish.players
      game.save!
      game.end_game(game.go_fish)
      game.save!
    end
  end
end
