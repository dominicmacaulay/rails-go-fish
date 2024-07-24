module CustomModelHelpers
  def create_and_play_games(user:, wins:, losses:, user2: create(:user)) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    wins.times do
      game = create_game(user:, user2:)
      game.go_fish.players.each(&:clear)
      game.go_fish.deck.clear
      player1 = game.go_fish.players.select { |p| p.id == user.id }.first
      player2 = game.go_fish.players.reject { |p| p.id == user.id }.first
      seed_books_to_players(game, player1, player2)
      game.go_fish.check_for_winners
      game.save!
      game.end_game(game.go_fish)
      game.save!
    end

    losses.times do
      game = create_game(user:, user2:)
      game.go_fish.players.each(&:clear)
      game.go_fish.deck.clear
      player1 = game.go_fish.players.reject { |p| p.id == user.id }.first
      player2 = game.go_fish.players.select { |p| p.id == user.id }.first
      seed_books_to_players(game, player1, player2)
      game.go_fish.check_for_winners
      game.save!
      game.end_game(game.go_fish)
      game.save!
    end
  end

  def seed_books_to_players(game, player1, player2)
    book_count = Random.new.rand(7..12)
    books = make_books
    player1.add_to_books(books.last(book_count))
    player2.add_to_books(books.first(13 - book_count))
    game.save!
  end

  def create_game(user:, user2: create(:user))
    game = create(:game)
    create(:game_user, user:, game:)
    create(:game_user, user: user2, game:)
    game.start!
    game
  end

  def make_books(times = 13)
    deck = retrieve_one_deck
    books = []
    times.times do
      books.push(Book.new(deck.shift))
    end
    books
  end

  def retrieve_one_deck
    Card::RANKS.map do |rank|
      Card::SUITS.flat_map do |suit|
        Card.new(rank, suit)
      end
    end
  end

  def format_time(time)
    if time >= Leaderboard::SECONDS_TO_HOURS_FACTOR
      hours = (time / Leaderboard::SECONDS_TO_HOURS_FACTOR).to_i
      minutes = ((time % Leaderboard::SECONDS_TO_HOURS_FACTOR) / Leaderboard::SECONDS_TO_MINUTES_FACTOR).to_i
      "#{hours}h #{minutes}m"
    elsif time >= Leaderboard::SECONDS_TO_MINUTES_FACTOR
      minutes = (time / Leaderboard::SECONDS_TO_MINUTES_FACTOR).to_i
      remaining_seconds = (time % Leaderboard::SECONDS_TO_MINUTES_FACTOR).to_i
      "#{minutes}m #{remaining_seconds}s"
    else
      "#{time.to_i}s"
    end
  end
end
