class User < ApplicationRecord
  has_many :game_users
  has_many :games, through: :game_users

  validates :first_name, presence: true
  validates :last_name, presence: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def name
    "#{first_name} #{last_name}"
  end

  def wins
    game_users.select do |game_user|
      game_user.winner == true
    end.count
  end

  def losses
    games_played - wins
  end

  def win_rate
    return 0 if wins.zero?

    return 100 if losses.zero?

    (wins.to_f / games_played * 100).round(2)
  end

  def games_played
    games.select(&:over).count
  end

  def total_time
    time = games.map do |game|
      if game.started_at.nil? || (game.updated_at.nil? && game.finished_at.nil?)
        0
      elsif game.finished_at.nil?
        game.updated_at - game.started_at
      else
        game.finished_at - game.started_at
      end
    end.sum
    (time / 3600).round(2)
  end

  def highest_book_count
    games = game_users.map(&:game)
    games.map do |game|
      game.go_fish&.players&.detect { |player| player.id == id }&.book_count
    end.max
  end
end
