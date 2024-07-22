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
    games.select do |game|
      game.go_fish&.winners&.any? { |winner| winner.id == id }
    end.count
  end

  def losses
    games.select do |game|
      game.go_fish&.winners&.all? { |winner| winner.id != id }
    end.count
  end

  def win_rate
    return 0 if wins.zero?

    return 100 if losses.zero?

    (wins.to_f / games_played * 100).round(2)
  end

  def games_played
    games.select(&:over).count
  end
end
