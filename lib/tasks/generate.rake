# frozen_string_literal: false

desc 'create users'
task create_users: :environment do
  100.times.each do |i|
    User.create(
      email: "user#{i}@example.com",
      first_name: 'Test',
      last_name: "User#{i}",
      password: 'password',
      password_confirmation: 'password'
    )
  end
end

desc 'play a few rounds'
task play_rounds: :environment do
  user_count = User.count
  100.times do
    offset = rand(user_count)
    users = User.offset(offset).first((2..5).to_a.sample)
    game = Game.create(users:)
    game.start!
    # play random number of rounds or all the way through
  end
end
