class Game < ApplicationRecord
  has_many :game_users, dependent: :destroy
  has_many :users, through: :game_users

  validates :name, presence: true
  validates :number_of_players, presence: true, numericality: { only_integer: true, greater_than: 1 }

  def queue_full?
    users.count == number_of_players
  end

  def started?
    !go_fish.nil?
  end

  serialize :go_fish, coder: GoFish

  def start!
    return false unless queue_full?

    players = users.map { |user| Player.new(user.id, user.name) }
    go_fish = GoFish.new(players)
    go_fish.deal!
    update(go_fish:)
    # update(go_fish:, started_at: DateTime.current)
  end

  def play_round!(opponent_id = nil, rank = nil)
    opponent = go_fish.match_player_id(opponent_id)
    rank = go_fish.validate_rank(rank)
    return false unless opponent && rank

    go_fish.play_round!
    save!
  end
end
