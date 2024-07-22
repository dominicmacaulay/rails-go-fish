module CustomHelpers
  def expect_header(selector: '.games-list__header', text: 'Your Games')
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
end
