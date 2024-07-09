class Game < ApplicationRecord
  has_many :game_users
  has_many :users, through: :game_users

  validates :name, presence: true
end
