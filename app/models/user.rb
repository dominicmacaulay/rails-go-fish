class User < ApplicationRecord
  SECONDS_TO_HOURS_FACTOR = 3600
  SECONDS_TO_MINUTES_FACTOR = 60
  STANDARD_ROUND = 2

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
    end.size
  end

  def losses
    games_played - wins
  end

  def win_rate
    return 0 if wins.zero?

    return 100 if losses.zero?

    (wins.to_f / games_played * 100).round(STANDARD_ROUND)
  end

  def games_played
    games.select(&:over).size
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
    format_time(time)
  end

  def format_time(time)
    if time >= SECONDS_TO_HOURS_FACTOR
      hours = (time / SECONDS_TO_HOURS_FACTOR).to_i
      minutes = ((time % SECONDS_TO_HOURS_FACTOR) / SECONDS_TO_MINUTES_FACTOR).to_i
      "#{hours}h #{minutes}m"
    elsif time >= SECONDS_TO_MINUTES_FACTOR
      minutes = (time / SECONDS_TO_MINUTES_FACTOR).to_i
      remaining_seconds = (time % SECONDS_TO_MINUTES_FACTOR).to_i
      "#{minutes}m #{remaining_seconds}s"
    else
      "#{time.to_i}s"
    end
  end

  def highest_book_count
    game_users.map(&:books).compact.max
  end
end
