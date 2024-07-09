class User < ApplicationRecord
  has_many :game_users
  has_many :games, through: :game_users

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def name
    first_split = email.split('@').first.capitalize
    first_split.split('.').first
  end
end
