# frozen_string_literal: false

namespace :generate do
  desc 'Create a given amount of users. The default is 100'
  task :users, [:user_count] => :environment do |_t, args|
    args.with_defaults(user_count: 100)

    user_count = args[:user_count]

    user_count.times.each do |i|
      User.create(
        email: "user#{i}@example.com",
        first_name: 'Test',
        last_name: "User#{i}",
        password: 'password',
        password_confirmation: 'password'
      )
    end
  end

  desc 'Create a given amount of games. The default is 100'
  task :games, [:game_count] => :environment do |_t, args|
    args.with_defaults(game_count: 100)

    game_count = args[:game_count]

    user_count = User.count
    game_count.times.each do |i|
      offset = rand(user_count)
      users = User.offset(offset).first((2..5).to_a.sample)
      game = Game.create(name: "Game#{i}", number_of_players: users.count, users:)
      game.start!
    end
  end

  desc 'Play each game in the data base a number of times. The default is 10'
  task :rounds, [:round_count] => :environment do |_t, args|
    args.with_defaults(round_count: 10)

    round_count = args[:round_count]

    games = Game.all
    games.each do |game|
      round_count.times do
        break if game.over?

        go_fish = game.go_fish
        current_index = go_fish.players.index(go_fish.current_player)
        other_player = go_fish.players[(current_index + 1) % go_fish.players.count]
        rank = go_fish.current_player.hand.sample.rank
        game.play_round!(other_player.id, rank, go_fish.current_player)
      end
    end
  end
end
